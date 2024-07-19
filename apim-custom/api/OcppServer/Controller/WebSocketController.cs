using System.Net.WebSockets;
using System.Text;
using Microsoft.AspNetCore.Mvc;

namespace OcppServer.Api
{
    public class WebSocketController(ILogger<WebSocketController> logger) : ControllerBase
    {
        static readonly CancellationTokenSource _cts = new();

        /// <summary>
        /// Gracefully stops all websockets
        /// </summary>
        /// <returns>Task</returns>
        public static async Task StopAsync()
        {
            foreach (var socket in _sockets.Values)
            {
                if (socket.State == WebSocketState.Open)
                {
                    try
                    {
                        await socket.CloseAsync(WebSocketCloseStatus.NormalClosure, "Server shutting down", CancellationToken.None);
                    }
                    catch (Exception)
                    {
                        // ignore
                    }
                }
            }
            _cts.Cancel();
        }

        /// <summary>
        /// Static constructor to start a background task to clean up the sockets and send keepalive messages
        /// </summary>
        static WebSocketController()
        {
            //TODO: use singleton instead of static constructor

            // start a background task to clean up the sockets
            Task.Run(async () =>
            {
                using Mutex mutex = new(true, "Global\\WebSocketControllerMutex", out bool createdNew);
                if (!createdNew)
                {
                    return;
                }
                while (!_cts.Token.IsCancellationRequested)
                {
                    await Task.Delay(20 * 1000, _cts.Token);
                    if (!_cts.Token.IsCancellationRequested)
                    {
                        foreach (var socket in _sockets.Values)
                        {
                            await KeepAliveAsync(socket, _cts.Token);
                        }
                    }
                }
            });
        }
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
                new ArraySegment<byte>(buffer), _cts.Token);

            while (!receiveResult.CloseStatus.HasValue)
            {
                string message = Encoding.UTF8.GetString(buffer, 0, receiveResult.Count);
                if (message == "ping" || message == "pong")
                {
                    _logger.LogInformation("Received {message} from {station}.", message, station);
                }
                else
                {
                    message = $"Station: {station}, Message: {message}";

                    var sendBuffer = new ReadOnlyMemory<byte>(Encoding.UTF8.GetBytes(message));
                    await Parallel.ForEachAsync(_sockets.Values, _cts.Token, async (socket, token) =>
                    {
                        await socket.SendAsync(
                            sendBuffer,
                            receiveResult.MessageType,
                            receiveResult.EndOfMessage,
                            token);
                    });
                }

                receiveResult = await webSocket.ReceiveAsync(
                    new ArraySegment<byte>(buffer), _cts.Token);
            }
            if (webSocket.State == WebSocketState.Open)
            {
                await webSocket.CloseAsync(
                    receiveResult.CloseStatus.Value,
                    receiveResult.CloseStatusDescription,
                    _cts.Token);
            }
        }

        /// <summary>
        /// Ping pong keepalive functionality for websockets
        /// </summary>
        /// <param name="webSocket">destination ws to send ping</param>
        /// <param name="token">Cancellation token</param>
        /// <returns>awaitable Task</returns>
        private async static Task KeepAliveAsync(WebSocket webSocket, CancellationToken token)
        {
            if (!token.IsCancellationRequested)
            {
                if (webSocket.State == WebSocketState.Open)
                {
                    await webSocket.SendAsync(
                        new ArraySegment<byte>(Encoding.UTF8.GetBytes("ping")),
                        WebSocketMessageType.Text,
                        true,
                        token);
                }
            }
        }
    }
}