using System.Net.WebSockets;
using System.Text;
using Microsoft.AspNetCore.Mvc;

namespace OcppServer.Api
{
    public class WebSocketController(ILogger<WebSocketController> logger) : ControllerBase
    {
        private readonly ILogger<WebSocketController> _logger = logger;
        private static readonly Dictionary<string, WebSocket> _sockets = [];

        [ProducesResponseType(StatusCodes.Status101SwitchingProtocols)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        [HttpGet("/ws")]
        public async Task HandleWebSocketRequest()
        {
            if (HttpContext.WebSockets.IsWebSocketRequest)
            {
                foreach (var protocol in HttpContext.WebSockets.WebSocketRequestedProtocols)
                {
                    _logger.LogInformation("Requested protocol: {protocol}", protocol);
                }
                if (!HttpContext.WebSockets.WebSocketRequestedProtocols.Contains("ocpp1.6"))
                {
                    //HttpContext.Response.Headers.Append("Expected", "Ocpp1.6");
                    _logger.LogError("Requested protocol is not supported. Ocpp1.6 expected.");
                    HttpContext.Response.StatusCode = StatusCodes.Status400BadRequest;
                    return;
                }
                var socket = await HttpContext.WebSockets.AcceptWebSocketAsync("ocpp1.6");
                var socketId = Guid.NewGuid().ToString();
                _sockets.Add(socketId, socket);
                try
                {
                    await Echo(socket);
                }
                finally
                {
                    _sockets.Remove(socketId);
                }
            }
            else
            {
                //HttpContext.Response.Headers.Append("Expected", "Websocket connection");
                HttpContext.Response.StatusCode = StatusCodes.Status400BadRequest;
            }
        }

        private async Task Echo(WebSocket webSocket)
        {
            var buffer = new byte[1024 * 4];
            var receiveResult = await webSocket.ReceiveAsync(
                new ArraySegment<byte>(buffer), CancellationToken.None);

            while (!receiveResult.CloseStatus.HasValue)
            {
                await Parallel.ForEachAsync(_sockets.Values, CancellationToken.None, async (socket, token) =>
                {
                    await socket.SendAsync(
                        new ArraySegment<byte>(buffer, 0, receiveResult.Count),
                        receiveResult.MessageType,
                        receiveResult.EndOfMessage,
                        token);
                });

                receiveResult = await webSocket.ReceiveAsync(
                    new ArraySegment<byte>(buffer), CancellationToken.None);
            }

            await webSocket.CloseAsync(
                receiveResult.CloseStatus.Value,
                receiveResult.CloseStatusDescription,
                CancellationToken.None);
        }
        // public HttpResponseData Run(HttpRequestData req, WebPubSubConnection connectionInfo)
        // {
        //     _logger.LogInformation("Negotiate request received.");

        //     foreach (var header in req.Headers)
        //     {
        //         _logger.LogInformation("Header: {key} = {value}", header.Key, header.Value);
        //     }
        //     var response = req.CreateResponse(HttpStatusCode.OK);
        //     response.Headers.Add("Sec-WebSocket-Protocol", "ocpp1.6");
        //     response.WriteAsJsonAsync(connectionInfo);
        //     return response;
        // }
    }
}