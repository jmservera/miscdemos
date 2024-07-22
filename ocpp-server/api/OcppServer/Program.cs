using Microsoft.Azure.WebPubSub.AspNetCore;
using Microsoft.Extensions.Azure;
using OcppServer.Api;
using OcppServer.PubSub;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();
builder.Services.AddControllers();

var pubSubConnectionString = builder.Configuration["WEBPUBSUB_SERVICE_CONNECTION_STRING"] ?? Environment.GetEnvironmentVariable("WEBPUBSUB_SERVICE_CONNECTION_STRING");

builder.Services.AddWebPubSub(o => o.ServiceEndpoint = new WebPubSubServiceEndpoint(
    pubSubConnectionString
));

builder.Services.AddWebPubSubServiceClient<OcppService>();


var app = builder.Build();


app.MapWebPubSubHub<OcppService>("/eventhandler/{*path}").AddEndpointFilter(async (context, next) =>
{
    var logger = app.Services.GetRequiredService<ILogger<OcppService>>();

    try
    {
        logger.LogInformation("EndpointFilter called with context path: {context}",
            context.HttpContext.Request.Path.ToString().Replace(Environment.NewLine, ""));
        if (!context.HttpContext.Response.Headers["WebHook-Allowed-Origin"].Contains("*"))
            _ = context.HttpContext.Response.Headers["WebHook-Allowed-Origin"].Append("*");
    }
    catch (Exception ex)
    {
        logger.LogError("Error in EndpointFilter: {error}", ex.Message);
    }
    return await next(context);
});


app.Services.GetRequiredService<IHostApplicationLifetime>().ApplicationStopping.Register(
    async () =>
    {
        app.Services.GetRequiredService<ILogger<WebSocketController>>().LogInformation("Stopping WebSockets");
        await WebSocketController.StopAsync();
    }
);

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
    app.UseHttpsRedirection();
}

app.UseWebSockets();
app.UseDefaultFiles();
app.UseStaticFiles();
app.MapControllers();


var summaries = new[]
{
    "Freezing", "Bracing", "Chilly", "Cool", "Mild", "Warm", "Balmy", "Hot", "Sweltering", "Scorching"
};

app.MapGet("/weatherforecast", () =>
{
    var forecast = Enumerable.Range(1, 5).Select(index =>
        new WeatherForecast
        (
            DateOnly.FromDateTime(DateTime.Now.AddDays(index)),
            Random.Shared.Next(-20, 55),
            summaries[Random.Shared.Next(summaries.Length)]
        ))
        .ToArray();
    return forecast;
})
.WithName("GetWeatherForecast")
.WithOpenApi();

app.Run();

record WeatherForecast(DateOnly Date, int TemperatureC, string? Summary)
{
    public int TemperatureF => 32 + (int)(TemperatureC / 0.5556);
}
