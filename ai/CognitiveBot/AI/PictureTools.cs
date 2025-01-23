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
    public async Task<string> GenerateImageFromTextAsync(string prompt, CancellationToken cancellationToken)
    {
        logger.LogInformation("Generating image from text.");
        var image = await dalle.GenerateImageAsync(prompt, 1024, 1024, cancellationToken: cancellationToken);
        return image;
    }

    public async Task<Stream> RemoveBackground(Stream picture, CancellationToken cancellationToken)
    {
        logger.LogInformation("Removing background from image.");
        picture.Position = 0;

        using var httpClient = new HttpClient();

        httpClient.DefaultRequestHeaders.Add("Content-Type", "application/octet-stream");
        httpClient.DefaultRequestHeaders.Add("Ocp-Apim-Subscription-Key", config.GetValue<string>("AI_SERVICES_KEY") ?? throw new InvalidOperationException("VISION_KEY is not set."));

        var endpoint = string.Concat(config.GetValue<string>("AI_SERVICES_ENDPOINT") ?? throw new InvalidOperationException("VISION_ENDPOINT is not set."),
            "/computervision/imageanalysis:segment?api-version=2023-02-01-preview&mode=backgroundRemoval");

        var response = await httpClient.PostAsync(endpoint, new StreamContent(picture), cancellationToken);

        return await response.Content.ReadAsStreamAsync(cancellationToken);
    }

    public async Task<byte[]> GetThumbnailAsync(Stream picture, string contentType, CancellationToken cancellationToken)
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
            Size = new Size(320, 320)
        };

        using var thumb = new MemoryStream();
        image.Mutate(o => o.Resize(resizeOptions));
        await image.SaveAsync(thumb, format, cancellationToken: cancellationToken);
        thumb.Position = 0;
        return thumb.ToArray();
    }

    public async Task<Stream> MixPicturesAsync(Stream foreground, string contentType, Stream background, CancellationToken cancellationToken)
    {
        var fore = Image.Load(foreground);
        fore.Configuration.ImageFormatsManager.TryFindFormatByMimeType(contentType, out IImageFormat format);
        if (format is null)
        {
            throw new InvalidOperationException($"Unsupported Image format {contentType}.");
        }

        var back = Image.Load(background);

        // Resize the foreground image to fit the background image
        var resizeOptions = new ResizeOptions
        {
            Mode = ResizeMode.Max,
            Size = new Size(back.Width, back.Height)
        };
        fore.Mutate(o => o.Resize(resizeOptions));

        // Mix the images
        back.Mutate(o => o.DrawImage(fore, 1));

        var result = new MemoryStream();
        await back.SaveAsync(result, format, cancellationToken: cancellationToken);
        result.Position = 0;
        return result;
    }

}