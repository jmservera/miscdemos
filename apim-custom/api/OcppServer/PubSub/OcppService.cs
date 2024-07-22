using Azure.Core;
using Microsoft.Azure.WebPubSub.AspNetCore;
using Microsoft.Azure.WebPubSub.Common;

namespace OcppServer.PubSub;

public sealed class OcppService(WebPubSubServiceClient<OcppService> serviceClient, ILogger<OcppService> logger) : WebPubSubHub
{
    private readonly WebPubSubServiceClient<OcppService> _serviceClient = serviceClient;
    private readonly ILogger<OcppService> _logger = logger;

    public override ValueTask<ConnectEventResponse> OnConnectAsync(ConnectEventRequest request, CancellationToken cancellationToken)
    {
        _logger.LogInformation("[SYSTEM] new user connecting.");
        if (request.Query.TryGetValue("id", out var id))
        {
            _logger.LogInformation("[SYSTEM] new user found {userId} connecting.",id);
            return new ValueTask<ConnectEventResponse>(request.CreateResponse(userId: id.FirstOrDefault(), null, null, null));
        }

        // The SDK catches this exception and returns 401 to the caller
        throw new UnauthorizedAccessException("Request missing id");
    }
    public override async Task OnConnectedAsync(ConnectedEventRequest request)
    {
        _logger.LogInformation("[SYSTEM] {userId} joined.",request.ConnectionContext.UserId);
    }

    public override async ValueTask<UserEventResponse> OnMessageReceivedAsync(UserEventRequest request, CancellationToken cancellationToken)
    {
        _logger.LogInformation("[{from}] {message}", request.ConnectionContext.UserId, request.Data.ToString());
        await _serviceClient.SendToAllAsync(RequestContent.Create(
        new
        {
            from = request.ConnectionContext.UserId,
            message = request.Data.ToString()
        }),
        ContentType.ApplicationJson);

        return new UserEventResponse();
    }

    public override async Task OnDisconnectedAsync(DisconnectedEventRequest request)
    {
        _logger.LogInformation("[SYSTEM] {userId} left.",request.ConnectionContext.UserId);
    }
}
