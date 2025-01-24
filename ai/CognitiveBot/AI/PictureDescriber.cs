using System;
using System.Collections.Generic;
using System.IO;
using System.Text.RegularExpressions;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Routing;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using Microsoft.SemanticKernel;
using Microsoft.SemanticKernel.ChatCompletion;
using Microsoft.SemanticKernel.Connectors.OpenAI;
using Newtonsoft.Json;
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Formats;
using SixLabors.ImageSharp.Processing;

namespace EchoBot.AI;

public record DescriptionInfo(IList<string> Names, int TotalPeople, IList<PictureDescription> Descriptions);
public record PictureDescription([property: JsonProperty("title")] string Title, [property: JsonProperty("description")] string Description)
{
    [JsonProperty("url")]
    public string Url { get; set; }
}
public record Results([property: JsonProperty("result")] IList<PictureDescription> Result);

public class PictureDescriber(ILogger<PictureDescriber> logger, FaceRecognition face,
                                            IChatCompletionService chatCompletionService, PictureTools pictureTools)
{
    public async Task<DescriptionInfo> DescribePictureAsync(Stream picture, string contentType, CancellationToken cancellationToken = default)
    {
        picture.Position = 0;
        var imageBytes = await pictureTools.GetThumbnailAsync(picture, contentType, 800, 800, cancellationToken);
        picture.Position = 0;
        logger.LogInformation("Identifying people in the picture.");
        var people = await face.IdentifyInPersonGroupAsync(picture, cancellationToken: cancellationToken);
        logger.LogInformation("Generating descriptions with AI for the picture.");
        var descriptions = await GenerateDescriptionsFromImageOrCaptionsAsync(contentType, imageBytes, people, cancellationToken);
        return new DescriptionInfo(people.Names, people.TotalFaces, descriptions);
    }

    private async Task<IList<PictureDescription>> GenerateDescriptionsFromImageOrCaptionsAsync(string contentType, byte[] imageBytes, Faces people, CancellationToken cancellationToken)
    {
#pragma warning disable SKEXP0010 // Type is for evaluation purposes only and is subject to change or removal in future updates. Suppress this diagnostic to proceed.
        OpenAIPromptExecutionSettings settings = new() { ResponseFormat = "json_object" };
#pragma warning restore SKEXP0010 // Type is for evaluation purposes only and is subject to change or removal in future updates. Suppress this diagnostic to proceed.
        var history = new ChatHistory();

        history.AddSystemMessage("""
        You are an AI assistant that helps people find funny descriptions and short titles of pictures that may contain people known by the requester.
        Do not translate the names for the people in the picture.
        You will generate three different descriptions and titles and will return a JSON object with the following format:

        {"result":[{"title":"The short title","description": "A longer but funny description"},
                   {"title":"The second title", "description": "The second funny description"},
                   {"title":"The third title", "description": "The third funny description"}]}
        """);

        ChatMessageContentItemCollection items = [];

        items.Add(new TextContent(people?.Names?.Count > 0 ? $"""
            In this picture you see the following people: {string.Join(',', people.Names)}.
            Please find a funny title and description for this picture that includes the provided names.
            """ : "Please find a funny title and description for this picture."));

        ImageContent imageContent = new(new ReadOnlyMemory<byte>(imageBytes), contentType);
        items.Add(imageContent);

        history.AddUserMessage(items);

        var chatMessageContent = await chatCompletionService.GetChatMessageContentAsync(history, settings, cancellationToken: cancellationToken);
        var description = chatMessageContent.Content ?? throw new InvalidOperationException("No text generated");

        var localizedDescriptions = JsonConvert.DeserializeObject<Results>(description) ?? throw new InvalidOperationException("No text converted");

        return localizedDescriptions.Result;
    }

}