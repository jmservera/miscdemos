// Generated with EchoBot .NET Template version v4.22.0

using System;
using System.IO;
using System.Net.Http;
using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.Bot.Builder;
using Microsoft.Bot.Schema;
using Microsoft.Extensions.Logging;
using EchoBot.AI;
using System.Linq;
using System.Web;

namespace EchoBot.Bots
{
    public class EchoBot(ILogger<EchoBot> logger, PictureDescriber describer, PictureTools pictureTools) : ActivityHandler
    {
        static readonly HashSet<string> validMimeTypes = ["image/jpeg", "image/png", "image/gif"];
        protected override async Task OnMessageActivityAsync(ITurnContext<IMessageActivity> turnContext, CancellationToken cancellationToken)
        {
            logger.LogInformation("Running dialog with Message Activity.");
            if (turnContext.Activity.Attachments != null && turnContext.Activity.Attachments.Count > 0)
            {
                foreach (var attachment in turnContext.Activity.Attachments)
                {
                    if (validMimeTypes.Contains(attachment.ContentType))
                    {
                        await turnContext.SendActivityAsync(MessageFactory.Text("Analyzing the picture..."), cancellationToken);
                        await turnContext.SendActivityAsync(Activity.CreateTypingActivity(), cancellationToken);

                        var fileContent = await DownloadAttachmentAsync(attachment.ContentUrl, cancellationToken);

                        var descriptions = await describer.DescribePictureAsync(fileContent, attachment.ContentType, cancellationToken);


                        await turnContext.SendActivityAsync(MessageFactory.Text("I've generated some ideas, take a look while you give me some more time to make a nice background..."), cancellationToken);
                        // foreach (var description in descriptions)
                        // {
                        //     try
                        //     {
                        //         var card = new Activity()
                        //         {
                        //             Type = ActivityTypes.Message,
                        //             Attachments = [new HeroCard()
                        //         {
                        //             Title = description.Title,
                        //             Text = description.Description,
                        //         }.ToAttachment()]
                        //         };
                        //         await turnContext.SendActivityAsync(card, cancellationToken);
                        //     }
                        //     catch (Exception ex)
                        //     {
                        //         logger.LogError(ex, "Error generating new card. {title}: {subtitle}", description.Title, description.Description);
                        //     }
                        // }

                        await turnContext.SendActivityAsync(MessageFactory.Text("I'm going to remove the background of the picture..."), cancellationToken);
                        await turnContext.SendActivityAsync(Activity.CreateTypingActivity(), cancellationToken);
                        // we need it again as the stream has been closed
                        fileContent = await DownloadAttachmentAsync(attachment.ContentUrl, cancellationToken);

                        await turnContext.SendActivityAsync(Activity.CreateTypingActivity(), cancellationToken);
                        var (foreground, height, width) = await pictureTools.RemoveBackground(fileContent, attachment.ContentType, cancellationToken);
                        await turnContext.SendActivityAsync(MessageFactory.Text("Great, now I'm going to generate some alternative pictures..."), cancellationToken);
                        await turnContext.SendActivityAsync(Activity.CreateTypingActivity(), cancellationToken);
                        foreach (var description in descriptions)
                        {
                            try
                            {
                                var prompt = $"""
                            Generate a background for a picture that would match the following description of another picture:
                            ---
                            Title: {description.Title}
                            Description: {description.Description}
                            ---
                            Generate a background that is not too distracting as it will be used to merge the original picture of the people over it.
                            """;
                                var background = await pictureTools.GenerateBackgroundFromTextAsync(prompt, cancellationToken);
                                foreground.Position = 0;
                                Stream newImage;
                                if (background != null)
                                {
                                    newImage = await pictureTools.MergePicturesAsync(foreground, attachment.ContentType, background, cancellationToken);
                                }
                                else
                                {
                                    newImage = foreground;
                                }
                                var url = await pictureTools.PersistImageAsync(newImage, attachment.ContentType, cancellationToken);
                                var msg = new Activity()
                                {
                                    Type = ActivityTypes.Message,
                                    Attachments = [new HeroCard()
                                    {
                                        Title = description.Title,
                                        Text = description.Description,
                                        Images = [new(url, description.Description)]
                                    }.ToAttachment()]
                                };
                                await turnContext.SendActivityAsync(msg, cancellationToken);
                            }
                            catch (Exception ex)
                            {
                                logger.LogError(ex, "Error generating new image card.");
                            }
                        }



                        // var reply = MessageFactory.Text("Here's what I've generated for you:");

                        // reply.AttachmentLayout = AttachmentLayoutTypes.Carousel;
                        // reply.Attachments = [.. descriptions.Select(d => new HeroCard()
                        // {
                        //     Title = d.Title,
                        //     Subtitle = d.Description,
                        //     Images = [new(d.Url)]
                        // }.ToAttachment())];

                        // await turnContext.SendActivityAsync(reply, cancellationToken);
                        var reply = MessageFactory.Text("Which one is your favorite?");
                        reply.SuggestedActions = new SuggestedActions() { Actions = [.. descriptions.Select(d => new CardAction() { Title = d.Title, Type = ActionTypes.MessageBack, Value = d.Title, DisplayText = d.Description })] };
                        await turnContext.SendActivityAsync(reply, cancellationToken);
                    }
                    else
                    {
                        var replyText = $"Attachment of type {attachment.ContentType} is not supported.";
                        await turnContext.SendActivityAsync(MessageFactory.Text(replyText, replyText), cancellationToken);
                    }
                }
            }
            else
            {
                if (turnContext.Activity.Value != null)
                {
                    var replyText = $"You selected: {turnContext.Activity.Value}";
                    await turnContext.SendActivityAsync(MessageFactory.Text(replyText, replyText), cancellationToken);
                }
                else
                {
                    var replyText = $"Echos: {turnContext.Activity.Text}";
                    await turnContext.SendActivityAsync(MessageFactory.Text(replyText, replyText), cancellationToken);
                }
            }
        }

        private async Task<Stream> DownloadAttachmentAsync(string contentUrl, CancellationToken cancellationToken)
        {
            logger.LogInformation("Downloading attachment from {contentUrl}.", contentUrl);
            // todo - dispose this client properly (cannot be done in this method as the ReadAsStreamAsync method will return an error)
            var httpClient = new HttpClient();
            var response = await httpClient.GetAsync(contentUrl, cancellationToken);
            response.EnsureSuccessStatusCode();
            response.Headers.TryGetValues("Content-Type", out var values);
            logger.LogInformation("Creating stream from {contentUrl}. Content-Type: {contentType}.", contentUrl, values?.FirstOrDefault());
            // write the content to a file on disk as jpeg
            return await response.Content.ReadAsStreamAsync(cancellationToken);
        }

        protected override async Task OnMembersAddedAsync(IList<ChannelAccount> membersAdded, ITurnContext<IConversationUpdateActivity> turnContext, CancellationToken cancellationToken)
        {
            var welcomeText = "Hello and welcome!";
            foreach (var member in membersAdded)
            {
                if (member.Id != turnContext.Activity.Recipient.Id)
                {
                    await turnContext.SendActivityAsync(MessageFactory.Text(welcomeText, welcomeText), cancellationToken);
                }
            }
        }
    }
}
