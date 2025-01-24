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
using Microsoft.Bot.Builder.Integration.AspNet.Core;
using Microsoft.Extensions.Configuration;

namespace EchoBot.Bots
{
    public class EchoBot(ILogger<EchoBot> logger, IBotFrameworkHttpAdapter adapter, PictureDescriber describer, PictureTools pictureTools, IConfiguration configuration) : ActivityHandler
    {
        static readonly HashSet<string> validMimeTypes = ["image/jpeg", "image/png", "image/gif"];
        static Timer timer;

        static EchoBot()
        {
            // Start a cleanup task
            // Create background thread that will run every minute, do not use a Task
            timer = new Timer(state =>
            {
                var now = DateTime.UtcNow;
                foreach (var key in attachments.Keys)
                {
                    if (attachments[key].LastActivity.AddMinutes(10) < now)
                    {
                        Console.WriteLine($"Removing attachment {key}.");
                        attachments.Remove(key);
                    }
                }
            }, null, TimeSpan.FromMinutes(1), TimeSpan.FromMinutes(1));
        }

        public class ConversationState
        {
            public Attachment[] Attachments { get; set; }
            public int Stage { get; set; }
            public DescriptionInfo DescriptionInfo { get; set; }
            public Stream Foreground { get; set; }
            public DateTime LastActivity { get; set; }
            public bool WaitingForAnswer { get; set; }
        }

        static readonly Dictionary<string, ConversationState> attachments = [];

        private async Task BotCallback(ITurnContext turnContext, CancellationToken cancellationToken)
        {
            var reference = turnContext.Activity.GetConversationReference();

            attachments.TryGetValue(reference.Conversation.Id, out var state);
            if (state == null)
            {
                attachments[reference.Conversation.Id] = state = new ConversationState();
            }
            if (state.WaitingForAnswer)
            {
                state.WaitingForAnswer = false;
                var replyText = $"You selected: {turnContext.Activity.Text}";
                await turnContext.SendActivityAsync(MessageFactory.Text(replyText, replyText), cancellationToken);
                return;
            }
            foreach (var attachment in state.Attachments)
            {
                if (validMimeTypes.Contains(attachment.ContentType))
                {
                    BotAdapter botAdapter = (BotAdapter)adapter;

                    switch (state.Stage)
                    {
                        case 0:
                            await turnContext.SendActivityAsync(MessageFactory.Text("Thanks for the picture, let me analyze it."), cancellationToken);
                            await turnContext.SendActivityAsync(Activity.CreateTypingActivity(), cancellationToken);
                            // _ = Task.Run(async () =>                            {
                            var fileContent = await DownloadAttachmentAsync(attachment.ContentUrl, cancellationToken);
                            var descriptions = await describer.DescribePictureAsync(fileContent, attachment.ContentType, cancellationToken);

                            state.Stage = 1;
                            state.DescriptionInfo = descriptions;
                            await botAdapter.ContinueConversationAsync(configuration.GetValue<string>("MicrosoftAppId") ?? string.Empty, reference, BotCallback, cancellationToken);
                            // }, cancellationToken);
                            break;
                        case 1:
                            var peopleorperson = state.DescriptionInfo.TotalPeople > 1 ? "people" : "person";
                            await turnContext.SendActivityAsync(MessageFactory.Text($"There's {state.DescriptionInfo.TotalPeople} {peopleorperson} in the picture. {string.Join(", ", state.DescriptionInfo.Names)}."), cancellationToken);
                            await turnContext.SendActivityAsync(MessageFactory.Text("I'm going to remove the background of the picture..."), cancellationToken);
                            await turnContext.SendActivityAsync(Activity.CreateTypingActivity(), cancellationToken);
                            await turnContext.SendActivityAsync(Activity.CreateTypingActivity(), cancellationToken);

                            _ = Task.Run(async () =>
                            {
                                try
                                {
                                    var fileContent = await DownloadAttachmentAsync(attachment.ContentUrl, cancellationToken);

                                    var (foreground, height, width) = await pictureTools.RemoveBackground(fileContent, attachment.ContentType, cancellationToken);

                                    state.Stage = 2;
                                    state.Foreground = foreground;

                                    await botAdapter.ContinueConversationAsync(configuration.GetValue<string>("MicrosoftAppId") ?? string.Empty, reference, BotCallback, cancellationToken);
                                }
                                catch (Exception ex)
                                {
                                    logger.LogError(ex, "Error removing background.");
                                }
                            }, cancellationToken);

                            break;
                        case 2:
                            //todo - this can be done in parallel
                            await turnContext.SendActivityAsync(MessageFactory.Text("Great, now I'm going to generate some alternative pictures..."), cancellationToken);

                            foreach (var description in state.DescriptionInfo.Descriptions)
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
                                    state.Foreground.Position = 0;
                                    Stream newImage;
                                    if (background != null)
                                    {
                                        newImage = await pictureTools.MergePicturesAsync(state.Foreground, attachment.ContentType, background, cancellationToken);
                                    }
                                    else
                                    {
                                        newImage = state.Foreground;
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

                            var reply = MessageFactory.Text("Which one is your favorite?");
                            reply.SuggestedActions = new SuggestedActions() { Actions = [.. state.DescriptionInfo.Descriptions.Select(d => new CardAction() { Title = d.Title, Type = ActionTypes.MessageBack, Value = d.Title, DisplayText = d.Description })] };
                            await turnContext.SendActivityAsync(reply, cancellationToken);
                            break;
                    }
                }
                else
                {
                    var replyText = $"Attachment of type {attachment.ContentType} is not supported.";
                    await turnContext.SendActivityAsync(MessageFactory.Text(replyText, replyText), cancellationToken);
                }
            }

        }
        protected override async Task OnMessageActivityAsync(ITurnContext<IMessageActivity> turnContext, CancellationToken cancellationToken)
        {
            logger.LogInformation("Running dialog with Message Activity.");
            if (turnContext.Activity.Attachments != null && turnContext.Activity.Attachments.Count > 0)
            {
                var reference = turnContext.Activity.GetConversationReference();
                var state = new ConversationState { Attachments = [.. turnContext.Activity.Attachments], LastActivity = DateTime.UtcNow };
                attachments.TryAdd(reference.Conversation.Id, state);
                BotAdapter botAdapter = (BotAdapter)adapter;
                await botAdapter.ContinueConversationAsync(configuration.GetValue<string>("MicrosoftAppId") ?? string.Empty, reference, BotCallback, cancellationToken);
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
                    // TODO: Use ChatGPT to generate answers
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
