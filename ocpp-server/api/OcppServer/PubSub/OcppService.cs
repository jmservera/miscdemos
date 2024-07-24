using System.Linq.Expressions;
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
            if(request.Query.TryGetValue("auth", out var auth)){
                _logger.LogInformation("[SYSTEM] new user found {userId} connecting with auth {auth}.", id, auth);
                if(auth.FirstOrDefault()!="c3RhdGlvbjI6Z29vZHB3ZA==") //goodpwd
                {
                    _logger.LogError("[SYSTEM] auth failed.");
                    throw new UnauthorizedAccessException();
                }
            } else {
                _logger.LogInformation("[SYSTEM] new user found {userId} connecting without auth.", id);
            }
            if (request.Subprotocols.Count > 0)
            {
                _logger.LogInformation("[SYSTEM] connecting with subprotocol {subprotocol}.", request.Subprotocols[0]);
                if (request.Subprotocols[0] == "ocpp1.6")
                    return new ValueTask<ConnectEventResponse>(request.CreateResponse(userId: id.FirstOrDefault(), null, request.Subprotocols[0], null));
                else
                {
                    _logger.LogError("[SYSTEM] subprotocol not supported.");
                    throw new HttpProtocolException(426, "Subprotocol not supported", null);
                }
            }
            return new ValueTask<ConnectEventResponse>(request.CreateResponse(userId: id.FirstOrDefault(), null, null, null));
        }

        // The SDK catches this exception and returns 401 to the caller
        throw new UnauthorizedAccessException("Request missing id");
    }
    public override Task OnConnectedAsync(ConnectedEventRequest request)
    {
        _logger.LogInformation("[SYSTEM] {userId} joined.", request.ConnectionContext.UserId);
        return Task.CompletedTask;
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

    public override Task OnDisconnectedAsync(DisconnectedEventRequest request)
    {
        _logger.LogInformation("[SYSTEM] {userId} left.", request.ConnectionContext.UserId);
        return Task.CompletedTask;
    }
}
