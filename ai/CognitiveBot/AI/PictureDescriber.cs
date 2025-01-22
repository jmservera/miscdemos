using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Text;
// using System.Text.Json;
using System.Text.RegularExpressions;
using System.Threading;
using System.Threading.Tasks;
using Azure.AI.Vision.ImageAnalysis;
using Microsoft.Azure.CognitiveServices.Vision.Face;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using Microsoft.SemanticKernel;
using Microsoft.SemanticKernel.ChatCompletion;
using Microsoft.SemanticKernel.Connectors.OpenAI;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Formats;
using SixLabors.ImageSharp.Processing;

namespace EchoBot.AI;

public record Descriptions([property: JsonProperty("title")] string Title, [property: JsonProperty("description")] string Description);
public record Results([property: JsonProperty("result")] IList<Descriptions> Result);

public partial class PictureDescriber(ILogger<PictureDescriber> logger, FaceRecognition face,
                                            IChatCompletionService chatCompletionService,
                                            //ImageAnalysisClient imageClient,
                                            IConfiguration configuration)
{
    public async Task<IList<Descriptions>> DescribePictureAsync(Stream picture, string contentType, CancellationToken cancellationToken)
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
        var imageBytes = thumb.ToArray();

        picture.Position = 0;
        var people = await face.IdentifyInPersonGroupAsync(picture, cancellationToken: cancellationToken);
        var descriptions = await GenerateDescriptionsFromImageOrCaptionsAsync(contentType, imageBytes, people, cancellationToken);
        return descriptions;
    }

    [GeneratedRegex("^\"|\"$")]
    private static partial Regex RemoveDoubleQuotes();

    private async Task<IList<Descriptions>> GenerateDescriptionsFromImageOrCaptionsAsync(string contentType, byte[] imageBytes, Faces people, CancellationToken cancellationToken)
    {
#pragma warning disable SKEXP0010 // Type is for evaluation purposes only and is subject to change or removal in future updates. Suppress this diagnostic to proceed.
        OpenAIPromptExecutionSettings settings = new() { ResponseFormat = "json_object" };
#pragma warning restore SKEXP0010 // Type is for evaluation purposes only and is subject to change or removal in future updates. Suppress this diagnostic to proceed.
        var history = new ChatHistory();

        history.AddSystemMessage("You are an AI assistant that helps people find a funny description and short title of pictures that may contain people known by the requester. Do not translate the names for the people in the picture." +
        "You will generate between three different descriptions and titles and will return a JSON object with the following format:\n" +
        "{\"result\":[{\"title\":\"The short title\",\"description\": \"A longer but funny description\"},{\"title\":\"The second title\", \"description\": \"The second funny description\"}]}");

        ChatMessageContentItemCollection items = [];
        // if (captions != null)
        // {
        //     items.Add(new TextContent($"Here is the description for the picture: {captions}\n"));
        // }        

        items.Add(new TextContent(people.Names.Count > 0 ? $"In this picture you see the following people: {string.Join(',', people.Names)}. Please find a funny title and description for this picture that includes the provided names." :
                    "Please find a funny title and description for this picture."));
        if (imageBytes != null)
        {
            //read image stream into byte array

            ImageContent imageContent = new(new ReadOnlyMemory<byte>(imageBytes), contentType);
            items.Add(imageContent);
        }
        history.AddUserMessage(items);

        var chatMessageContent = await chatCompletionService.GetChatMessageContentAsync(history, settings);
        var description = chatMessageContent.Content ?? throw new InvalidOperationException("No text generated");

        var localizedDescriptions = JsonConvert.DeserializeObject<Results>(description) ?? throw new InvalidOperationException("No text converted");
        return localizedDescriptions.Result;
        // return localizedDescriptions.Select(
        //     s => new KeyValuePair<string, string>(s.Key,
        //         //url encode string to be stored in metadata
        //         Uri.EscapeDataString(
        //             //remove double quotes
        //             RemoveDoubleQuotes().Replace(s.Value, "")
        //         ))).ToDictionary();
    }

}