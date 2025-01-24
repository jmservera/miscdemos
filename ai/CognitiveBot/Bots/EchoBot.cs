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
using Microsoft.SemanticKernel.ChatCompletion;

namespace EchoBot.Bots
{
    public class EchoBot(ILogger<EchoBot> logger, IBotFrameworkHttpAdapter adapter, PictureDescriber describer, PictureTools pictureTools,
     IChatCompletionService chatCompletionService,
     IConfiguration configuration) : ActivityHandler
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
            public ChatHistory History { get; init; } = [];
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
                            var msg_0 = "Thanks for the picture, let me analyze it.";
                            state.History.AddAssistantMessage(msg_0);
                            await turnContext.SendActivityAsync(MessageFactory.Text(msg_0), cancellationToken);
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
                            string msg_1;
                            if (state.DescriptionInfo.TotalPeople > 1)
                            {
                                msg_1 = $"I see there are {state.DescriptionInfo.TotalPeople} people in the picture.";
                            }
                            else
                            {
                                if (state.DescriptionInfo.TotalPeople == 0)
                                {
                                    msg_1 = $"I don't see any people in the picture.";
                                }
                                else
                                {
                                    msg_1 = $"I see there is {state.DescriptionInfo.TotalPeople} person in the picture.";
                                }
                            }
                            if (state.DescriptionInfo.Names?.Count > 0)
                            {
                                var names = string.Join(", ", state.DescriptionInfo.Names);
                                if (state.DescriptionInfo.Names.Count > 1)
                                {
                                    names = string.Concat(names.AsSpan(0, names.LastIndexOf(',') + 1), "and ", names.AsSpan(names.LastIndexOf(',') + 1));
                                    msg_1 += $" I believe these are {names}.";
                                }
                                else
                                {
                                    msg_1 += $" I believe this is {names}.";
                                }
                            }
                            msg_1 += " I'm going to remove the background of the picture.";

                            state.History.AddAssistantMessage(msg_1);

                            await turnContext.SendActivityAsync(MessageFactory.Text(msg_1), cancellationToken);
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
                            var msg_2 = "Thanks for waiting, I removed the background. Now I'm going to generate some alternative pictures.";
                            state.History.AddAssistantMessage(msg_2);
                            await turnContext.SendActivityAsync(MessageFactory.Text(msg_2), cancellationToken);

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
                                    state.History.AddAssistantMessage($"{description.Title}: ![{description.Description}]({url})");
                                    await turnContext.SendActivityAsync(msg, cancellationToken);
                                }
                                catch (Exception ex)
                                {
                                    logger.LogError(ex, "Error generating new image card.");
                                }
                            }

                            var reply = MessageFactory.Text("Which one is your favorite?");
                            state.History.AddUserMessage(reply.Text);
                            state.Stage = 0;
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
            var reference = turnContext.Activity.GetConversationReference();
            attachments.TryGetValue(reference.Conversation.Id, out var state);
            if (state == null)
            {
                attachments[reference.Conversation.Id] = state = new ConversationState();
            }
            state.LastActivity = DateTime.UtcNow;
            if (state.History?.Count == 0)
            {
                state.History.AddSystemMessage("""
                Your name is the SnapMash Bot. You are an assistant that helps people get funny quotes and descriptions for their pictures, along with some privacy by removing the original background of the pictures and replacing it with an AI generated one.
                This is what the bot will do when a user uploads a picture:
                1. Background Removal: Upload your selfie. I'll automatically remove the background, leaving you with a clean image of yourself.
                2. Generate a Funny Quote: Once your background is removed, I'll generate a humorous quote that suits your selfie.
                3. Create a New Background: I'll then generate a new background based on the quote, ensuring it complements your selfie perfectly.
                4. Seamlessly Merge Everything: I'll blend your selfie, the funny quote, and the new background into one cohesive and entertaining image.
                5. Share and Enjoy
                Save your masterpiece and share it with friends or on social media.

                Enjoy the creative and humorous twist to your selfies!

                This is your main task. You can let users chat with you, but tell them that you are focused on helping them with their pictures, so they need to upload one to get started.
                When a user connects for the first time, introduce yourself and your main task.
                """);
            }

            logger.LogInformation("Running dialog with Message Activity.");
            if (turnContext.Activity.Attachments != null && turnContext.Activity.Attachments.Count > 0)
            {
                state.Attachments = [.. turnContext.Activity.Attachments];
                BotAdapter botAdapter = (BotAdapter)adapter;
                await botAdapter.ContinueConversationAsync(configuration.GetValue<string>("MicrosoftAppId") ?? string.Empty, reference, BotCallback, cancellationToken);
            }
            else
            {
                await turnContext.SendActivityAsync(Activity.CreateTypingActivity(), cancellationToken);
                if (turnContext.Activity.Value != null)
                {
                    state.History.AddUserMessage(turnContext.Activity.Value.ToString());
                }
                else
                {
                    state.History.AddUserMessage(turnContext.Activity.Text);
                }
                var response = await chatCompletionService.GetChatMessageContentAsync(state.History, cancellationToken: cancellationToken);
                state.History.AddAssistantMessage(response.Content);

                await turnContext.SendActivityAsync(MessageFactory.Text(response.Content, response.Content), cancellationToken);
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
