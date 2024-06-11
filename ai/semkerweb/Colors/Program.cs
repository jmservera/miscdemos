using Microsoft.SemanticKernel;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddKernel();
builder.Services.AddAzureOpenAIChatCompletion(Environment.GetEnvironmentVariable("OpenAIModel"),
                                                      endpoint: Environment.GetEnvironmentVariable("OpenAIEndpoint"),
                                                      apiKey: Environment.GetEnvironmentVariable("OpenAIApiKey"));

// Add services to the container.
// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();

var summaries = new[]
{
    "Freezing", "Bracing", "Chilly", "Cool", "Mild", "Warm", "Balmy", "Hot", "Sweltering", "Scorching"
};

app.MapGet("/weatherforecast", async (Kernel kernel) =>
{
    var temp=Random.Shared.Next(-20, 55);
    var forecast =  
        new WeatherForecast
        (
            DateOnly.FromDateTime(DateTime.Now.AddDays(1)),
            temp,
            await kernel.InvokePromptAsync<string>($"Short description of the weather at {temp} ºC")
        );
    return forecast;
})
.WithName("GetWeatherForecast")
.WithOpenApi();

app.Run();

record WeatherForecast(DateOnly Date, int TemperatureC, string? Summary)
{
    public int TemperatureF => 32 + (int)(TemperatureC / 0.5556);
}
