using Microsoft.SemanticKernel;
using Microsoft.SemanticKernel.TextToImage;
using Microsoft.AspNetCore.Builder;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddKernel();
builder.Services.AddAzureOpenAIChatCompletion(Environment.GetEnvironmentVariable("OpenAIModel"),
                                                      endpoint: Environment.GetEnvironmentVariable("OpenAIEndpoint"),
                                                      apiKey: Environment.GetEnvironmentVariable("OpenAIApiKey"));
builder.Services.AddAzureOpenAITextToImage(Environment.GetEnvironmentVariable("DallEModel"),
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

app.UseStaticFiles();

app.Map("/", (HttpContext context) =>
{
    context.Response.Redirect("/index.html");
});

var summaries = new[]
{
    "a fluffy puppy",
    "a coloured duck",
    "a stray cat",
    "a playful kitten",
    "a loyal dog",
    "a graceful swan",
    "a curious rabbit",
    "a majestic horse",
    "a friendly parrot",
    "a cuddly hamster"
};

app.MapGet("/colorandpet", async (Kernel kernel) =>
{
    var r=Random.Shared.Next(0, 255);
    var g=Random.Shared.Next(0, 255);
    var b=Random.Shared.Next(0, 255);
    var c=(r+g+b)*10/(256*3);
     
    var summary=await kernel.InvokePromptAsync<string>($"Short description of a pet for the color rgb({r},{g},{b}). Generate animal, breed and name for it."); //summaries[c] //
    var dallE = kernel.GetRequiredService<ITextToImageService>();
    var img=await dallE.GenerateImageAsync(summary, 1024,1024,kernel);

    return     new ColorAndPet
        (
            $"rgb({r},{g},{b})",
             summary,
             img
        );
    
})
.WithName("ColorAndPet")
.WithOpenApi();

app.Run();

record ColorAndPet( string rgb, string? Summary, string? ImageUrl=null);

