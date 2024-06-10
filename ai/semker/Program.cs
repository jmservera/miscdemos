﻿
using System.ComponentModel;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Logging;
using Microsoft.SemanticKernel;
using Microsoft.SemanticKernel.ChatCompletion;
using Microsoft.SemanticKernel.Connectors.OpenAI;

var builder = Kernel.CreateBuilder();
builder.Services.AddLogging(b=>b.AddConsole().SetMinimumLevel(LogLevel.Trace));
var kernel = builder.AddAzureOpenAIChatCompletion("gpt432",
                                                      endpoint: Environment.GetEnvironmentVariable("OpenAIEndpoint"),
                                                      apiKey: Environment.GetEnvironmentVariable("OpenAIApiKey"))
                        .Build();

kernel.ImportPluginFromType<Demographics>();

var settings = new OpenAIPromptExecutionSettings() { ToolCallBehavior = ToolCallBehavior.AutoInvokeKernelFunctions };

ChatHistory chat = new();
var chatSvc = kernel.GetRequiredService<IChatCompletionService>();

while (true)
{
    Console.Write("Q: ");
    chat.AddUserMessage(Console.ReadLine());
    var r = await chatSvc.GetChatMessageContentAsync(chat, settings, kernel);
    Console.WriteLine(r);
    chat.Add(r);
}

public class Demographics
{

    [KernelFunction]
    public int GetPersonAge(string name)
    {
        return name switch
        {
            "Juanma" => 53,
            _ => 25
        };
    }

    [KernelFunction, Description("Returns a description of the age.")]
    public string AgeDescription(int age)
    {
        return age switch
        {
            < 18 => "young",
            53 => "aged",
            < 65 => "adult",
            _ => "senior"
        };
    }
}