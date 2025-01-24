using System.Threading;
using System.Threading.Tasks;
using Microsoft.SemanticKernel.ChatCompletion;


namespace EchoBot.Messaging;
/// <summary>
/// Interface for managing chat history.
/// /// </summary>
public interface IChatHistoryManager
{
    /// <summary>
    /// Clears the chat history for a specific user and chat.
    /// </summary>
    /// <param name="username">The username of the user.</param>
    /// <param name="chatId">The ID of the chat.</param>
    /// <param name="cancellationToken">A token to monitor for cancellation requests.</param>
    /// <returns>A task that represents the asynchronous operation.</returns>
    Task ClearHistoryAsync(string username, long chatId, CancellationToken cancellationToken);

    /// <summary>
    /// Saves the chat history for a specific user and chat.
    /// </summary>
    /// <param name="username">The username of the user.</param>
    /// <param name="chatId">The ID of the chat.</param>
    /// <param name="history">The chat history to save.</param>
    /// <param name="cancellationToken">A token to monitor for cancellation requests.</param>
    /// <returns>A task that represents the asynchronous operation.</returns>
    Task SaveHistoryAsync(string username, long chatId, ChatHistory history, CancellationToken cancellationToken);

    /// <summary>
    /// Retrieves the chat history for a specific user and chat.
    /// </summary>
    /// <param name="username">The username of the user.</param>
    /// <param name="fullName">The full name of the user.</param>
    /// <param name="chatId">The ID of the chat.</param>
    /// <returns>A task that represents the asynchronous operation, containing the chat history.</returns>
    Task<ChatHistory> GetHistoryAsync(string username, string fullName, long chatId);
}

