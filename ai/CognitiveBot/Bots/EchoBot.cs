// Generated with EchoBot .NET Template version v4.22.0

using System;
using System.IO;
using System.Net.Http;
using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.Bot.Builder;
using Microsoft.Bot.Schema;

namespace EchoBot.Bots
{
    public class EchoBot : ActivityHandler
    {
        protected override async Task OnMessageActivityAsync(ITurnContext<IMessageActivity> turnContext, CancellationToken cancellationToken)
        {
            if (turnContext.Activity.Attachments != null && turnContext.Activity.Attachments.Count > 0)
            {
                foreach (var attachment in turnContext.Activity.Attachments)
                {
                    var fileContent = await DownloadAttachmentAsync(attachment.ContentUrl);
                    // Process the file content as needed
                    var replyText = $"Received file: {attachment.Name}";
                    await turnContext.SendActivityAsync(MessageFactory.Text(replyText, replyText), cancellationToken);
                }
            }
            else
            {
                var replyText = $"Echos: {turnContext.Activity.Text}";
                await turnContext.SendActivityAsync(MessageFactory.Text(replyText, replyText), cancellationToken);
            }
        }

        private async Task<string> DownloadAttachmentAsync(string contentUrl)
        {
            using (var httpClient = new HttpClient())
            {
                var response = await httpClient.GetAsync(contentUrl);
                response.EnsureSuccessStatusCode();
                var content = await response.Content.ReadAsStringAsync();
                return content;
            }
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
