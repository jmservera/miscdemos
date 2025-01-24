using System;
using System.IO;
using System.Text;
using System.Text.Json;
using System.Threading;
using System.Threading.Tasks;
using EchoBot.Storage;
using Microsoft.Extensions.Logging;
using Microsoft.SemanticKernel.ChatCompletion;


namespace EchoBot.Messaging;

/// <summary>
/// Manages chat history for the bot.
/// </summary>
/// <param name="logger">The logger instance for logging errors and information.</param>
/// <param name="uploader">The storage manager for uploading and downloading chat history.</param>
public class BotHistoryManager(ILogger<BotHistoryManager> logger, IStorageManager uploader) : IChatHistoryManager
{
    const string ChatHistoryContainerName = "chat-history";

    /// </summary>
    /// Clears the chat history for a specific user and chat.
    /// </summary>
    /// <param name="username">The username of the user.</param>
    /// <param name="chatId">The ID of the chat.</param>
    /// <param name="cancellationToken">A token to monitor for cancellation requests.</param>
    /// <returns>A task that represents the asynchronous operation.</returns>
    public async Task ClearHistoryAsync(string username, long chatId, CancellationToken cancellationToken)
    {
        await uploader.UploadAsync(username, $"{chatId}.json", ChatHistoryContainerName, Stream.Null, "application/json", null, cancellationToken);
    }

    /// </summary>
    /// Saves the chat history for a specific user and chat.
    /// </summary>
    /// <param name="username">The username of the user.</param>
    /// <param name="chatId">The ID of the chat.</param>
    /// <param name="history">The chat history to save.</param>
    /// <param name="cancellationToken">A token to monitor for cancellation requests.</param>
    /// <returns>A task that represents the asynchronous operation.</returns>
    public async Task SaveHistoryAsync(string username, long chatId, ChatHistory history, CancellationToken cancellationToken)
    {
        //trim history to 60 messages
        if (history.Count > 60)
        {
            history.RemoveRange(1, history.Count - 60);
        }
        var value = JsonSerializer.Serialize(history);
        using var stream = new MemoryStream(Encoding.UTF8.GetBytes(value));
        await uploader.UploadAsync(username, $"{chatId}.json", ChatHistoryContainerName, stream, "application/json", null, cancellationToken);
    }

    /// </summary>
    /// Retrieves the chat history for a specific user and chat.
    /// </summary>
    /// <param name="username">The username of the user.</param>
    /// <param name="fullName">The full name of the user.</param>
    /// <param name="chatId">The ID of the chat.</param>
    /// <returns>A task that represents the asynchronous operation, containing the chat history.</returns>
    public async Task<ChatHistory> GetHistoryAsync(string username, string fullName, long chatId)
    {
        try
        {
            using var stream = await uploader.DownloadAsync(username, $"{chatId}.json", ChatHistoryContainerName);
            if (stream.Length > 0)
            {
                using StreamReader reader = new(stream);
                var history = JsonSerializer.Deserialize<ChatHistory>(reader.ReadToEnd());
                if (history is not null)
                {
                    return history;
                }
            }
        }
        catch (Exception ex)
        {
            logger.LogError(ex, "Error getting chat history");
        }
        ChatHistory newHistory = [];
        return newHistory;
    }

}