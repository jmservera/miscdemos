// Generated with EchoBot .NET Template version v4.22.0

using System;
using Azure.AI.Vision.ImageAnalysis;
using EchoBot.AI;
using EchoBot.Messaging;
using EchoBot.Storage;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Hosting;
using Microsoft.Azure.CognitiveServices.Vision.Face;
using Microsoft.Bot.Builder;
using Microsoft.Bot.Builder.Integration.AspNet.Core;
using Microsoft.Bot.Connector.Authentication;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using Microsoft.SemanticKernel;

namespace EchoBot
{
    public class Startup(IConfiguration configuration)
    {
        // This method gets called by the runtime. Use this method to add services to the container.
        public void ConfigureServices(IServiceCollection services)
        {

            services.AddHttpClient().AddControllers().AddNewtonsoftJson(options =>
            {
                options.SerializerSettings.MaxDepth = HttpHelper.BotMessageSerializerSettings.MaxDepth;
            });

            // Create the Bot Framework Authentication to be used with the Bot Adapter.
            services.AddSingleton<BotFrameworkAuthentication, ConfigurationBotFrameworkAuthentication>();

            // Create the Bot Adapter with error handling enabled.
            services.AddSingleton<IBotFrameworkHttpAdapter, AdapterWithErrorHandler>();

            // Create the bot as a transient. In this case the ASP Controller is expecting an IBot.
            services.AddTransient<IBot, Bots.EchoBot>()
                    .AddTransient<IFaceClient, FaceClient>(provider =>
                        {
                            return new FaceClient(new ApiKeyServiceClientCredentials(
                                                            configuration.GetValue<string>("VISION_KEY") ?? throw new InvalidOperationException("VISION_KEY is not set.")))
                            {
                                Endpoint = configuration.GetValue<string>("VISION_ENDPOINT") ?? throw new InvalidOperationException("VISION_ENDPOINT is not set.")
                            };
                        })
                    .AddTransient<PictureTools>()
                    .AddTransient<AI.FaceRecognition>()
                    .AddTransient<AI.PictureDescriber>()
                    .AddTransient<IStorageManager, StorageManager>()
                    .AddTransient<IChatHistoryManager, BotHistoryManager>()
                    .AddAzureOpenAIChatCompletion(
                        configuration.GetValue<string>("AOAI_DEPLOYMENT_NAME") ?? throw new InvalidOperationException("AOAI_DEPLOYMENT_NAME is not set."),
                        configuration.GetValue<string>("AOAI_ENDPOINT") ?? throw new InvalidOperationException("AOAI_ENDPOINT is not set."),
                        configuration.GetValue<string>("AOAI_KEY") ?? throw new InvalidOperationException("AOAI_KEY is not set."))
                    .AddAzureOpenAITextToImage(
                        configuration.GetValue<string>("AOAI_DALLE_NAME") ?? throw new InvalidOperationException("AOAI_DALLE_NAME is not set."),
                        configuration.GetValue<string>("AOAI_ENDPOINT") ?? throw new InvalidOperationException("AOAI_ENDPOINT is not set."),
                        configuration.GetValue<string>("AOAI_KEY") ?? throw new InvalidOperationException("AOAI_KEY is not set."));
        }

        // This method gets called by the runtime. Use this method to configure the HTTP request pipeline.
        public void Configure(IApplicationBuilder app, IWebHostEnvironment env)
        {
            if (env.IsDevelopment())
            {
                app.UseDeveloperExceptionPage();
            }

            app.UseDefaultFiles()
                .UseStaticFiles()
                .UseWebSockets()
                .UseRouting()
                .UseAuthorization()
                .UseEndpoints(endpoints =>
                {
                    endpoints.MapControllers();
                });

            // app.UseHttpsRedirection();
        }
    }
}
