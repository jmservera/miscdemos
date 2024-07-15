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
        [Route("/ws")]
        [ApiExplorerSettings(IgnoreApi = true)] // Hide from Swagger because CONNECT is not supported
        public async Task HandleWebSocketRequest(string station)
        {
            _logger.LogInformation("Websocket request received for {station}.", station);
            if (HttpContext.WebSockets.IsWebSocketRequest)
            {
                foreach (var protocol in HttpContext.WebSockets.WebSocketRequestedProtocols)
                {
                    _logger.LogInformation("Requested protocol: {protocol}", protocol);
                }
                WebSocket? socket;

                if (HttpContext.WebSockets.WebSocketRequestedProtocols.Count == 0)
                {
                    socket = await HttpContext.WebSockets.AcceptWebSocketAsync();
                }
                else
                {
                    if (HttpContext.WebSockets.WebSocketRequestedProtocols.Contains("ocpp1.6"))
                    {
                        socket = await HttpContext.WebSockets.AcceptWebSocketAsync("ocpp1.6");
                        // //HttpContext.Response.Headers.Append("Expected", "Ocpp1.6");
                    }
                    else
                    {
                        _logger.LogError("Requested protocol is not supported. Ocpp1.6 expected.");
                        HttpContext.Response.StatusCode = StatusCodes.Status400BadRequest;
                        return;

                    }
                }
                var socketId = Guid.NewGuid().ToString();
                _sockets.Add(socketId, socket);
                try
                {
                    await Echo(socket, station);
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

        private async Task Echo(WebSocket webSocket, string? station)
        {
            var buffer = new byte[1024 * 4];
            var receiveResult = await webSocket.ReceiveAsync(
                new ArraySegment<byte>(buffer), CancellationToken.None);

            string message = Encoding.UTF8.GetString(buffer, 0, receiveResult.Count);
            message = $"Station: {station}, Message: {message}";

            var sendBuffer = new ReadOnlyMemory<byte>(Encoding.UTF8.GetBytes(message));

            while (!receiveResult.CloseStatus.HasValue)
            {
                await Parallel.ForEachAsync(_sockets.Values, CancellationToken.None, async (socket, token) =>
                {
                    await socket.SendAsync(
                        sendBuffer,
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