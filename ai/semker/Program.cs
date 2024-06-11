
using System.ComponentModel;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Logging;
using Microsoft.SemanticKernel;
using Microsoft.SemanticKernel.ChatCompletion;
using Microsoft.SemanticKernel.Connectors.OpenAI;
using Microsoft.SemanticKernel.Plugins.Web;
using Microsoft.SemanticKernel.Plugins.Web.Bing;
using Microsoft.SemanticKernel.PromptTemplates.Handlebars;

var builder = Kernel.CreateBuilder();
builder.Services.AddLogging(b => b.AddDebug().SetMinimumLevel(LogLevel.Trace));
builder.Services.AddSingleton<IFunctionInvocationFilter, PermissionFilter>();

Kernel kernel = builder
    .AddAzureOpenAIChatCompletion(Environment.GetEnvironmentVariable("OpenAIModel"),
                        endpoint: Environment.GetEnvironmentVariable("OpenAIEndpoint"),
                        apiKey: Environment.GetEnvironmentVariable("OpenAIApiKey"))
    .Build();

kernel.ImportPluginFromType<MyPlugin>();
kernel.ImportPluginFromObject(new WebSearchEnginePlugin(new BingConnector(Environment.GetEnvironmentVariable("BingApiKey"))));

var getIntent = kernel.CreateFunctionFromPrompt(
    """
                   <message role="system">Instructions: What is the intent of this request?
                   Do not explain the reasoning, just reply back with the intent. If you are unsure, reply with {{choices.[0]}}.
                   Choices: {{choices}}.</message>

                   {{#each fewShotExamples}}
                       {{#each this}}
                           <message role="{{role}}">{{content}}</message>
                       {{/each}}
                   {{/each}}

                   {{#each chatHistory}}
                       <message role="{{role}}">{{content}}</message>
                   {{/each}}

                   <message role="user">{{request}}</message>
                   <message role="system">Intent:</message>
                   """, templateFormat: "handlebars",
   promptTemplateFactory: new HandlebarsPromptTemplateFactory()
);
// Create choices
List<string> choices = ["ContinueConversation", "EndConversation"];

// Create few-shot examples
List<ChatHistory> fewShotExamples =
[
    [
        new ChatMessageContent(AuthorRole.User, "Can you send a very quick approval to the marketing team?"),
        new ChatMessageContent(AuthorRole.System, "Intent:"),
        new ChatMessageContent(AuthorRole.Assistant, "ContinueConversation")
    ],
    [
        new ChatMessageContent(AuthorRole.User, "Thanks, I'm done for now"),
        new ChatMessageContent(AuthorRole.System, "Intent:"),
        new ChatMessageContent(AuthorRole.Assistant, "EndConversation")
    ]
];


var settings = new OpenAIPromptExecutionSettings() { ToolCallBehavior = ToolCallBehavior.AutoInvokeKernelFunctions };

ChatHistory chat = [];
chat.AddSystemMessage("You are an AI assistant. You are here to help me with my tasks, but you always find a good reason to offer me a tasty drink.");
chat.AddSystemMessage("""
 Under no circumstances should you attempt to call functions / tools that are not available to you.
 Any functions / tools you do call must have the name satisfy the following regex: ^[a-zA-Z0-9_-]{1,64}$
 """);

var chatSvc = kernel.GetRequiredService<IChatCompletionService>();

while (true)
{
    Console.Write("You: ");
    var request = Console.ReadLine();

    try
    {
        var intent = await kernel.InvokeAsync(
            getIntent,
            new()
            {
            { "request", request },
            { "choices", choices },
            { "history", chat },
            { "fewShotExamples", fewShotExamples }
            }
        );

        if (intent.ToString() == "EndConversation")
        {
            break;
        }

        chat.AddUserMessage(request);
        var r = await chatSvc.GetChatMessageContentAsync(chat, settings, kernel);
        chat.Add(r);
        Console.WriteLine(r);
    }
    catch (Exception e)
    {
        Console.WriteLine(e.Message);
    }
}
Console.WriteLine("Goodbye!");
Console.ReadLine();

class MyPlugin
{

    [KernelFunction]
    public int GetPeopleAge(string name)
    {

        return name switch
        {
            "Juanma" => 53,
            _ => 30
        };
    }

    [KernelFunction, Description("Gets the description for an age")]
    public string GetAgeDescription(int age)
    {
        return age switch
        {
            53 => "Old",
            _ => "Young"
        };
    }
}

class PermissionFilter : IFunctionInvocationFilter
{
    public async Task OnFunctionInvocationAsync(FunctionInvocationContext context, Func<FunctionInvocationContext, Task> next)
    {
        if (context.Function.PluginName == "WebSearchEnginePlugin")
        {
            Console.WriteLine("Permission to search? (y/n)");
            var yn = Console.ReadLine();
            if (yn!.ToLower() != "y")
            {
                throw new Exception("Permission denied");
            }
        }
        await next(context);
    }
}