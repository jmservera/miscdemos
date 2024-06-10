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
from semantic_kernel.prompt_template import KernelPromptTemplate
from semantic_kernel.functions.kernel_arguments import KernelArguments
from semantic_kernel.prompt_template.input_variable import InputVariable
from semantic_kernel.prompt_template.prompt_template_config import PromptTemplateConfig

import logging
logFormatter = logging.Formatter("%(asctime)s [%(threadName)-12.12s] [%(levelname)-5.5s]  %(message)s")
rootLogger = logging.getLogger()
rootLogger.setLevel(logging.INFO)

fileHandler = logging.FileHandler("{0}/{1}.log".format("/tmp", "semantic_kernel"))
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

def old():
    request = input("Your request: ")
    prompt = f"""
 ## Instructions
    Provide the intent of the request using the following format:

    ```json
    {{
        "intent": {{intent}}
    }}
    ```

    If you don't know the intent, don't guess; instead respond with "Unknown".

    ## Choices
    You can choose between the following intents:

    ```json
    ["SendEmail", "SendMessage", "CompleteTask", "CreateDocument"]
    ```

    ## User Input
    The user input is:

    ```json
    {{
        "request": "{request}"
    }}
    ```

    ## Intent
    """


async def main():
    dotenv.load_dotenv()

    prompt = """{{$history}}"""

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
    
    chat_prompt_template_config = PromptTemplateConfig(
        template=prompt,
        description="Chat with the assistant",
        execution_settings=execution_config,
        input_variables=[
            InputVariable(name="request", description="The user input", is_required=True),
            InputVariable(name="history", description="The history of the conversation", is_required=True),
        ],
    )

    chat_function = kernel.add_function(
        prompt=prompt,
        plugin_name="Summarize_Conversation",
        function_name="Chat",
        description="Chat with the assistant",
        prompt_template_config=chat_prompt_template_config,
    )

    template= KernelPromptTemplate(prompt_template_config= chat_prompt_template_config)

    while True:
        try:
            request = input("User:> ")
        except KeyboardInterrupt:
            print("\n\nExiting chat...")
            return False
        except EOFError:
            print("\n\nExiting chat...")
            return False

        if request == "exit":
            print("\n\nExiting chat...")
            return False

        # Add the request to the history before we
        # invoke the function to include it in the prompt
        history.add_user_message(request)


        args=KernelArguments(request=request, history=history)
        rendered_prompt= await template.render(kernel,   arguments=args)

        print(f"Rendered prompt {rendered_prompt}")

        kernel.invoke_prompt()

        result = kernel.invoke_stream(
            chat_function,
            request=request,
            history=history,
        )
        assistant=await print_stream(result, header="Assistant:> ")
        history.add_assistant_message(assistant)

# this is a function to prepare the prompt by summarizing the conversation and sending it to
# a vector database to find relevant documents



if __name__ == "__main__":
    asyncio.run(main())
    print('Done!')