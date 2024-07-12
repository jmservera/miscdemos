namespace OcppServer.Api
{
    public class Api
    {
        public HttpResponseData Run(HttpRequestData req, WebPubSubConnection connectionInfo)
        {
            _logger.LogInformation("Negotiate request received.");

            foreach (var header in req.Headers)
            {
                _logger.LogInformation("Header: {key} = {value}", header.Key, header.Value);
            }
            var response = req.CreateResponse(HttpStatusCode.OK);
            response.Headers.Add("Sec-WebSocket-Protocol", "ocpp1.6");
            response.WriteAsJsonAsync(connectionInfo);
            return response;
        }
    }
}