
using System.Net.Http.Headers;
using Microsoft.SemanticKernel;
using Microsoft.SemanticKernel.TextToImage;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddKernel();
builder.Services.AddAzureOpenAIChatCompletion(Environment.GetEnvironmentVariable("OpenAIModel")!,
                                                      endpoint: Environment.GetEnvironmentVariable("OpenAIEndpoint")!,
                                                      apiKey: Environment.GetEnvironmentVariable("OpenAIApiKey")!);

builder.Services.AddAzureOpenAITextToImage(Environment.GetEnvironmentVariable("DallEModel")!,
                                                      endpoint: Environment.GetEnvironmentVariable("OpenAIEndpoint")!,
                                                      apiKey: Environment.GetEnvironmentVariable("OpenAIApiKey")!);
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

var pictures = new[]{
    "https://icons.iconarchive.com/icons/iconarchive/cute-animal/256/Cute-Dog-icon.png",
    "https://icons.iconarchive.com/icons/gianni-polito/colobrush/256/duck-quack-icon.png",
    "https://icons.iconarchive.com/icons/iconka/saint-whiskers/256/cat-banjo-icon.png",
    "https://icons.iconarchive.com/icons/martin-berube/flat-animal/256/kitten-icon.png",
    "https://icons.iconarchive.com/icons/shrikant-rawa/animals/256/dog-icon.png",
    "https://icons.iconarchive.com/icons/microsoft/fluentui-emoji-3d/256/Swan-3d-icon.png",
    "https://icons.iconarchive.com/icons/yellowicon/easter/256/rabbit-icon.png",
    "https://icons.iconarchive.com/icons/iconarchive/plasticine/256/Horse-icon.png",
    "https://icons.iconarchive.com/icons/iconarchive/childrens-book-animals/256/Parrot-icon.png",
    "https://icons.iconarchive.com/icons/iconarchive/childrens-book-animals/256/Hamster-icon.png"  
};

app.MapGet("/colorandpet", async (Kernel kernel) =>
{
    var r = Random.Shared.Next(0, 255);
    var g = Random.Shared.Next(0, 255);
    var b = Random.Shared.Next(0, 255);
    var c = Random.Shared.Next(0,9);

    var summary = await kernel.InvokePromptAsync<string>($"Create a short description of a pet with the color RGB({r},{g},{b}). Include the type of animal, its breed, and a name for it. The pet can be any animal, including common domestic pets and fantastical creatures.");
    var dalle=kernel.GetRequiredService<ITextToImageService>();

    return new ColorAndPet
        (
            $"rgb({r},{g},{b})",
             summary,
            await dalle.GenerateImageAsync(summary!,1024,1024)
        );

})
.WithName("ColorAndPet")
.WithOpenApi();

app.Run();

record ColorAndPet(string rgb, string? Summary, string? ImageUrl = null);

