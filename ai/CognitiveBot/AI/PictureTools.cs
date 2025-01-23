using System;
using System.IO;
using System.Net.Http;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.Bot.Builder.Adapters;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using Microsoft.SemanticKernel.TextToImage;
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Formats;
using SixLabors.ImageSharp.Processing;

namespace EchoBot.AI;

public class PictureTools(ILogger<PictureTools> logger, ITextToImageService dalle, IConfiguration config)
{
    public async Task<Stream> GenerateBackgroundFromTextAsync(string prompt, CancellationToken cancellationToken = default)
    {
        logger.LogInformation("Generating image from text.");
        int retries = 3;
        while (retries-- > 0)
        {
            try
            {
                var description = $"""
                <system>You are a bot that helps generate backgrounds that will be used to draw some people on top of it. Do not overcomplicate them and avoid showing people at the forefront.</system>
                <user>{prompt}</user>
                """;
                var image = await dalle.GenerateImageAsync(prompt, 1024, 1024, cancellationToken: cancellationToken);
                // load the string into an image stream
                if (image.StartsWith("http"))
                {
                    using var httpClient = new HttpClient();
                    return await httpClient.GetStreamAsync(image, cancellationToken);
                }
                else
                {
                    return new MemoryStream(Convert.FromBase64String(image));
                }
            }
            catch (Microsoft.SemanticKernel.HttpOperationException ex)
            {
                if (ex.StatusCode == System.Net.HttpStatusCode.TooManyRequests)
                {
                    int delay = (3 - retries) * (3 - retries) * 1000;
                    logger.LogWarning("Too many requests. Waiting for {delay} seconds before retrying.", (3 - retries) * (3 - retries));
                    await Task.Delay(delay, cancellationToken);
                }
                else
                {
                    logger.LogError(ex, "Error generating image from text.");
                }
            }
        }
        return null;
    }

    public async Task<(Stream stream, int width, int height)> RemoveBackground(Stream picture, string contentType, CancellationToken cancellationToken = default)
    {
        logger.LogInformation("Removing background from image.");
        picture.Position = 0;

        using var image = Image.Load(picture);
        image.Configuration.ImageFormatsManager.TryFindFormatByMimeType(contentType, out IImageFormat format);
        if (format is null)
        {
            throw new InvalidOperationException($"Unsupported Image format {contentType}.");
        }
        ResizeOptions resizeOptions = new()
        {
            Mode = ResizeMode.Max,
            Size = new Size(1024, 1024)
        };

        using var thumb = new MemoryStream();
        image.Mutate(o => o.Resize(resizeOptions));
        await image.SaveAsync(thumb, format, cancellationToken: cancellationToken);
        thumb.Position = 0;

        using var httpClient = new HttpClient();
        var httpRequest = new HttpRequestMessage(HttpMethod.Post,
            string.Concat(config.GetValue<string>("AI_SERVICES_ENDPOINT") ?? throw new InvalidOperationException("VISION_ENDPOINT is not set."),
            "/computervision/imageanalysis:segment?api-version=2023-02-01-preview&mode=backgroundRemoval"));
        httpRequest.Content = new StreamContent(thumb);
        httpRequest.Content.Headers.Add("Content-Type", "application/octet-stream");
        httpRequest.Headers.Add("Ocp-Apim-Subscription-Key", config.GetValue<string>("AI_SERVICES_KEY") ?? throw new InvalidOperationException("VISION_KEY is not set."));

        var response = await httpClient.SendAsync(httpRequest, cancellationToken);
        var result = new MemoryStream();
        await response.Content.CopyToAsync(result, cancellationToken);
        result.Position = 0;
        return (result, image.Width, image.Height);
    }

    public async Task<byte[]> GetThumbnailAsync(Stream picture, string contentType, int width = 1024, int height = 1024, CancellationToken cancellationToken = default)
    {
        using var image = Image.Load(picture);
        image.Configuration.ImageFormatsManager.TryFindFormatByMimeType(contentType, out IImageFormat format);
        if (format is null)
        {
            throw new InvalidOperationException($"Unsupported Image format {contentType}.");
        }
        ResizeOptions resizeOptions = new()
        {
            Mode = ResizeMode.Max,
            Size = new Size(width, height)
        };

        using var thumb = new MemoryStream();
        image.Mutate(o => o.Resize(resizeOptions));
        await image.SaveAsync(thumb, format, cancellationToken: cancellationToken);
        thumb.Position = 0;
        return thumb.ToArray();
    }

    public async Task<Stream> MergePicturesAsync(Stream foreground, string contentType, Stream background, CancellationToken cancellationToken = default)
    {
        // ensure the streams are at the beginning
        var fore = Image.Load(foreground);
        fore.Configuration.ImageFormatsManager.TryFindFormatByMimeType(contentType, out IImageFormat format);
        if (format is null)
        {
            throw new InvalidOperationException($"Unsupported Image format {contentType}.");
        }

        var back = Image.Load(background);

        // Resize the background image to fit the foreground
        var resizeOptions = new ResizeOptions
        {
            Mode = ResizeMode.Crop,
            Size = new Size(fore.Width, fore.Height)
        };
        back.Mutate(o => o.Resize(resizeOptions));

        // Mix the images
        back.Mutate(o => o.DrawImage(fore, 1));

        var result = new MemoryStream();
        await back.SaveAsync(result, format, cancellationToken: cancellationToken);
        result.Position = 0;
        return result;
    }

    public async Task<String> PersistImageAsync(Stream image, string contentType, CancellationToken cancellationToken = default)
    {
        // write image to disk with a random name in the temp folder
        var tempFileName = Path.GetTempFileName();
        tempFileName = Path.ChangeExtension(tempFileName, contentType.Split('/')[1]);
        using var dest = File.Create(tempFileName);
        await image.CopyToAsync(dest, cancellationToken);
        return string.Concat(config.GetValue<string>("BaseUrl") ?? throw new InvalidOperationException("BaseUrl is not set."),
                             "api/pictures/", Path.GetFileName(tempFileName));
    }
}