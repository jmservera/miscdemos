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

                        await turnContext.SendActivityAsync(MessageFactory.Text("I've generated some ideas, give me some more time to make a nice background..."), cancellationToken);
                        await turnContext.SendActivityAsync(Activity.CreateTypingActivity(), cancellationToken);

                        fileContent.Seek(0, SeekOrigin.Begin);





                        var reply = MessageFactory.Text("Here's what I've generated for you:");

                        reply.AttachmentLayout = AttachmentLayoutTypes.Carousel;
                        reply.Attachments = [.. descriptions.Select(d => new HeroCard()
                        {
                            Title = d.Title,
                            Subtitle = d.Description,
                            Images = [new(d.Url)]
                        }.ToAttachment())];

                        await turnContext.SendActivityAsync(reply, cancellationToken);
                        reply = MessageFactory.Text("Which one is your favorite?");
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
