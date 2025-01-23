using System.IO;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;

namespace EchoBot.Controllers;

[Route("api/pictures")]
[ApiController]
public class PicturesController(ILogger<PicturesController> logger) : ControllerBase
{
    // an action to return a picture from disk via GET
    [HttpGet("{id}")]
    public IActionResult GetPicture(string id)
    {
        logger.LogInformation("Getting picture {id}.", id);
        var filename = Path.Join(Path.GetTempPath(), id);
        var ext = Path.GetExtension(id);

        FileStream fileStream = new(filename, FileMode.Open, FileAccess.Read);

        return File(fileStream, $"image/{ext}");
    }

}