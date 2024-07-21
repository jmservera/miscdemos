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
        if (request.Query.TryGetValue("id", out var id))
        {
            return new ValueTask<ConnectEventResponse>(request.CreateResponse(userId: id.FirstOrDefault(), null, null, null));
        }

        // The SDK catches this exception and returns 401 to the caller
        throw new UnauthorizedAccessException("Request missing id");
    }
    public override async Task OnConnectedAsync(ConnectedEventRequest request)
    {
        Console.WriteLine($"[SYSTEM] {request.ConnectionContext.UserId} joined.");
    }

    public override async ValueTask<UserEventResponse> OnMessageReceivedAsync(UserEventRequest request, CancellationToken cancellationToken)
    {
        await _serviceClient.SendToAllAsync(RequestContent.Create(
        new
        {
            from = request.ConnectionContext.UserId,
            message = request.Data.ToString()
        }),
        ContentType.ApplicationJson);

        return new UserEventResponse();
    }
}
