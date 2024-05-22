import asyncio
import os
from typing import AsyncIterable
from semantic_kernel.functions.function_result import FunctionResult
from semantic_kernel.contents.streaming_content_mixin import StreamingContentMixin
from semantic_kernel.connectors.ai.open_ai import (
    AzureChatCompletion,
    AzureTextCompletion,
    )
from semantic_kernel import Kernel
import dotenv

from semantic_kernel.contents.chat_history import ChatHistory
from semantic_kernel.prompt_template import KernelPromptTemplate, Jinja2PromptTemplate
from semantic_kernel.functions.kernel_arguments import KernelArguments
from semantic_kernel.prompt_template.input_variable import InputVariable
from semantic_kernel.prompt_template.prompt_template_config import PromptTemplateConfig

import logging
logFormatter = logging.Formatter("%(asctime)s [%(threadName)-12.12s] [%(levelname)-5.5s]  %(message)s")
rootLogger = logging.getLogger()
rootLogger.setLevel(logging.INFO)

fileHandler = logging.FileHandler("{0}/{1}.log".format("/tmp", "jinja"))
fileHandler.setFormatter(logFormatter)
rootLogger.addHandler(fileHandler)

# consoleHandler = logging.StreamHandler()
# consoleHandler.setFormatter(logFormatter)
# rootLogger.addHandler(consoleHandler)

async def print_stream(stream:AsyncIterable[list["StreamingContentMixin"] | FunctionResult | list[FunctionResult]], header:str) -> str : 
    end_result=""
    if(header):
        print(header, end="")
    else:
        print("Assistant:> ", end="")
    async for result in stream:
        for message in result:
            for content in message.inner_content.choices:
                if content.delta.content:
                    print(content.delta.content, end="")
                    end_result+=content.delta.content
    print()
    return end_result

async def main():
    dotenv.load_dotenv()

    kernel = Kernel()

    history=ChatHistory()

    kernel.add_service(
        service=AzureTextCompletion(
            service_id= "azure_gpt35_text_completion",
            deployment_name= os.getenv("AZURE_OPEN_AI_TEXT_COMPLETION_DEPLOYMENT_NAME"),
            endpoint=os.getenv("AZURE_OPENAI_ENDPOINT"),
            api_key=os.getenv("AZURE_OPENAI_API_KEY")
        ),
    )

    gpt35_chat_service = AzureChatCompletion(
        service_id="azure_gpt35_chat_completion",
                deployment_name= os.getenv("AZURE_OPEN_AI_CHAT_COMPLETION_DEPLOYMENT_NAME"),
                endpoint=os.getenv("AZURE_OPENAI_ENDPOINT"),
                api_key=os.getenv("AZURE_OPENAI_API_KEY")
    )

    kernel.add_service(gpt35_chat_service)


    from semantic_kernel.connectors.ai.open_ai import OpenAITextPromptExecutionSettings

    execution_config = OpenAITextPromptExecutionSettings(service_id = "azure_gpt35_chat_completion",
                                                        max_tokens=2000)
    
    # chat_function = kernel.create_function_from_prompt(
    #     prompt="""{{system_message}}{% for item in chat_history %}{{ message(item) }}{% endfor %}""",
    #     function_name="chat",
    #     plugin_name="chat",
    #     template_format="jinja2",
    #     prompt_execution_settings=execution_config,
    # )

    chat_prompt_template_config = PromptTemplateConfig(
        template="""{{system_message}}{% for item in chat_history %}{{ message(item) }}{% endfor %}""",
        description="Chat with the assistant",
        execution_settings=execution_config,
        template_format="jinja2",        
    )

    template= Jinja2PromptTemplate(prompt_template_config= chat_prompt_template_config)

    history.add_system_message("You are a helpful chatbot.")
    history.add_user_message("User message")
    history.add_assistant_message("Assistant message")

    args=KernelArguments(chat_history=history,system_message="whatever")
    rendered_prompt= await template.render(kernel,   arguments=args)

    print(f"Rendered prompt {rendered_prompt}")


if __name__ == "__main__":
    asyncio.run(main())
    print('Done!')