using System;
using System.Collections.Generic;
using System.Data;
using System.IO;
using System.Threading;
using System.Threading.Tasks;
using Azure.Storage.Blobs;
using Azure.Storage.Blobs.Models;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;

namespace EchoBot.Storage
{
    /// <summary>
    /// Manages storage operations.
    /// </summary>
    /// <seealso cref="IStorageManager" />
    public class StorageManager(ILogger<StorageManager> logger, IConfiguration configuration) : IStorageManager
    {
        public const string UploadedByMetadataKey = "uploadedBy";
        public const string OriginalFilenameMetadataKey = "originalFilename";
        public const string DescriptionMetadataKey = "description";
        public const string PeopleMetadataKey = "people";

        /// <summary>
        /// Generates a unique name for a file based on a Guid.
        /// </summary>
        /// <returns>A unique name for a file. </returns>
        public string GenerateUniqueName()
        {
            //encode the guid to base64
            var base64Guid = Convert.ToBase64String(Guid.NewGuid().ToByteArray());
            // encode to base64url
            return base64Guid.Replace('+', '-').Replace('/', '_').TrimEnd('=');
        }

        /// <summary>
        /// Uploads a file to a container in Azure Blob Storage.
        /// </summary>
        /// <param name="username">The username of the user uploading the file. Username may be empty if the file is not user-specific</param>
        /// <param name="fileName">The name of the file to upload.</param>
        /// <param name="containerName">The name of the container to upload the file to.</param>
        /// <param name="stream">The stream containing the file to upload.</param>
        /// <param name="contentType">The content type of the file.</param>
        /// <param name="originalFileName">The original name of the file.</param>
        /// <param name="cancellationToken">The cancellation token.</param>
        /// <returns>A task that represents the asynchronous operation.</returns>
        public async Task UploadAsync(string username, string fileName, string containerName, Stream stream, string contentType, string originalFileName, CancellationToken cancellationToken = default)
        {
            if (string.IsNullOrEmpty(fileName))
            {
                throw new ArgumentNullException(nameof(fileName));
            }
            if (string.IsNullOrEmpty(containerName))
            {
                throw new ArgumentNullException(nameof(containerName));
            }

            string connectionString = configuration.GetValue<string>("STORAGE_CONNECTION_STRING") ?? throw new InvalidOperationException("STORAGE_CONNECTION_STRING is not set.");

            var containerClient = new BlobContainerClient(connectionString, containerName);
            var user = username.Replace('@', '-');
            string fullPath = $"{user}/{fileName}";
            var blobClient = containerClient.GetBlobClient(fullPath);

            logger.LogInformation("Saving {fullPath} to {containerName} container with type {contentType}", fullPath, containerName, contentType);
            BlobUploadOptions options = new()
            {
                HttpHeaders = new BlobHttpHeaders { ContentType = contentType },
                Metadata = new Dictionary<string, string> { { UploadedByMetadataKey, username } }
            };
            if (!string.IsNullOrEmpty(originalFileName))
            {
                options.Metadata.Add(OriginalFilenameMetadataKey, originalFileName);
            }
            await blobClient.UploadAsync(stream, options: options, cancellationToken: cancellationToken);
            logger.LogInformation("{fullPath} Saved", fullPath);
        }

        /// <summary>
        /// Replicates the metadata of a file from one container to another.
        /// </summary>
        /// <param name="fileName">The name of the file to replicate the metadata for.</param>
        /// <param name="originalContainer">The name of the container where the file is located.</param>
        /// <param name="destName">The name of the file to replicate the metadata to.</param>
        /// <param name="destContainer">The name of the container to replicate the metadata to.</param>
        /// <returns>A task that represents the asynchronous operation.</returns>
        public async Task ReplicateMetadataAsync(string fileName, string originalContainer, string destName, string destContainer)
        {

            if (string.IsNullOrEmpty(fileName))
            {
                throw new ArgumentNullException(nameof(fileName));
            }
            if (string.IsNullOrEmpty(originalContainer))
            {
                throw new ArgumentNullException(nameof(originalContainer));
            }
            if (string.IsNullOrEmpty(destContainer))
            {
                throw new ArgumentNullException(nameof(destContainer));
            }
            if (string.IsNullOrEmpty(destName))
            {
                throw new ArgumentNullException(nameof(destName));
            }

            string connectionString = configuration.GetValue<string>("STORAGE_CONNECTION_STRING") ?? throw new InvalidOperationException("STORAGE_CONNECTION_STRING is not set.");

            logger.LogInformation("Replicating metadata from {originalContainer}/{fileName} to {destContainer}/{fileName}", originalContainer, fileName, destContainer, destName);
            var containerClient = new BlobContainerClient(connectionString, originalContainer);
            var originalBlobClient = containerClient.GetBlobClient(fileName);
            var properties = await originalBlobClient.GetPropertiesAsync();
            var metadata = properties.Value.Metadata;

            logger.LogInformation("Setting metadata to {destContainer}/{destName}", destContainer, destName);
            var destContainerClient = new BlobContainerClient(connectionString, destContainer);
            var destBlobClient = destContainerClient.GetBlobClient(destName);
            await destBlobClient.SetMetadataAsync(metadata);
        }

        /// <summary>
        /// Downloads a file from a container in Azure Blob Storage.
        /// </summary>
        /// <param name="fileName">The name of the file to download.</param>
        /// <param name="containerName">The name of the container to download the file from.</param>
        /// <returns>A task with the stream containing the file.</returns>
        public async Task<Stream> DownloadAsync(string username, string fileName, string containerName)
        {
            // if (string.IsNullOrEmpty(username)) throw new ArgumentNullException(nameof(username));
            if (string.IsNullOrEmpty(fileName)) throw new ArgumentNullException(nameof(fileName));
            if (string.IsNullOrEmpty(containerName)) throw new ArgumentNullException(nameof(containerName));

            string connectionString = configuration.GetValue<string>("STORAGE_CONNECTION_STRING") ?? throw new InvalidOperationException("STORAGE_CONNECTION_STRING is not set.");

            var containerClient = new BlobContainerClient(connectionString, containerName);
            containerClient.CreateIfNotExists();
            var user = username.Replace('@', '-');
            string fullPath = $"{user}/{fileName}";
            var blobClient = containerClient.GetBlobClient(fullPath);
            if (await blobClient.ExistsAsync())
            {
                return await blobClient.OpenReadAsync();
            }
            else
            {
                return Stream.Null;
            }
        }
    }
}