using System.IO;
using System.Threading;
using System.Threading.Tasks;

namespace EchoBot.Storage
{
    /// <summary>
    /// Interface for managing storage operations.
    /// </summary>
    public interface IStorageManager
    {
        /// <summary>
        /// Uploads a file to storage.
        /// </summary>
        /// <param name="userName"> The name of the user uploading the file. </param>
        /// <param name="fileName"> The name of the file to upload. </param>
        /// <param name="containerName"> The name of the container to upload the file to. </param>
        /// <param name="stream"> The stream containing the file to upload. </param>
        /// <param name="contentType"> The content type of the file. </param>
        /// <param name="originalFileName"> The original name of the file. </param>
        /// <param name="cancellationToken"> The cancellation token. </param>
        /// <returns> A task that represents the asynchronous operation. </returns>
        Task UploadAsync(string userName, string fileName, string containerName, Stream stream, string contentType, string originalFileName, CancellationToken cancellationToken);

        /// <summary>
        /// Downloads a file from storage.
        /// </summary>
        /// <param name="fileName"> The name of the file to download. </param>
        /// <param name="containerName"> The name of the container to download the file from. </param>
        /// <returns> A task with the stream containing the file. </returns>
        Task<Stream> DownloadAsync(string username, string fileName, string containerName);

        /// <summary>
        /// Deletes a file from storage.
        /// </summary>
        /// <param name="fileName"> The name of the file to delete. </param>
        /// <param name="containerName"> The name of the container to delete the file from. </param>
        /// <returns> A task that represents the asynchronous operation. </returns>
        Task ReplicateMetadataAsync(string fileName, string originalContainer, string destFileName, string destContainer);

        /// <summary>
        /// Generates a unique name for a file.
        /// </summary>
        /// <returns> A unique name for a file. </returns>
        string GenerateUniqueName();
    }
}