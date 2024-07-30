using Microsoft.AspNetCore.Mvc;

namespace OcppServer.Api;

[Route("/health")]
public class HealthController(ILogger<HealthController> logger) : ControllerBase
{
    public ActionResult Get()
    {
        logger.LogInformation("Health check requested");
        return Ok("Healthy");
    }
}