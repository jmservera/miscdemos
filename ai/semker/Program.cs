
using System.ComponentModel;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Logging;
using Microsoft.SemanticKernel;
using Microsoft.SemanticKernel.ChatCompletion;
using Microsoft.SemanticKernel.Connectors.OpenAI;
using Microsoft.SemanticKernel.Plugins.Web;
using Microsoft.SemanticKernel.Plugins.Web.Bing;

var builder=Kernel.CreateBuilder();
builder.Services.AddLogging(b=>b.AddDebug().SetMinimumLevel(LogLevel.Trace));
builder.Services.AddSingleton<IFunctionInvocationFilter, PermissionFilter>();

Kernel kernel = builder
    .AddAzureOpenAIChatCompletion(Environment.GetEnvironmentVariable("OpenAIModel"),
                                                      endpoint: Environment.GetEnvironmentVariable("OpenAIEndpoint"),
                                                      apiKey: Environment.GetEnvironmentVariable("OpenAIApiKey"))
    .Build();

kernel.ImportPluginFromType<MyPlugin>();
kernel.ImportPluginFromObject(new WebSearchEnginePlugin(new BingConnector(Environment.GetEnvironmentVariable("BingApiKey"))));


var settings= new OpenAIPromptExecutionSettings(){ToolCallBehavior= ToolCallBehavior.AutoInvokeKernelFunctions};

ChatHistory chat=[];
var chatSvc= kernel.GetRequiredService<IChatCompletionService>();

while(true){
    Console.Write("You: ");
    chat.AddUserMessage(Console.ReadLine());
    var r=await chatSvc.GetChatMessageContentAsync(chat,settings, kernel);
    chat.Add(r);
    Console.WriteLine(r);
}

class MyPlugin{

    [KernelFunction]
    public int GetPeopleAge(string name){

        return name switch{
            "Juanma" => 53,
            _ => 30
        };
    }

    [KernelFunction, Description("Gets the description for an age")]
    public string GetAgeDescription(int age){
        return age switch{
            53 => "Old",
            _ => "Young"
        };
    }
}

class PermissionFilter : IFunctionInvocationFilter
{
    public async Task OnFunctionInvocationAsync(FunctionInvocationContext context, Func<FunctionInvocationContext, Task> next)
    {
        if(context.Function.PluginName=="WebSearchEnginePlugin"){
            Console.WriteLine("Permission to search? (y/n)");
            var yn=Console.ReadLine();
            if(yn.ToLower()!="y"){
                throw new Exception("Permission denied");
            }
        }
        await next(context);
    }
}