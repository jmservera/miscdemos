---
layout: custom
title: "Prompt Engineering Hands on Lab"
subTitle: "HSG Alumni"
authors: "Florian Follonier - Microsoft, Juan Manuel Servera - Microsoft"
permalink: /prompt-engineering
---
Authors:

   * Florian Follonier - Cloud Solution Architect Data & AI - Microsoft
   * Juan Manuel Servera - Cloud Solution Architect App Inno - Microsoft

## Prompt Engineering Hands-on Lab: An Introduction  
   
Welcome to the Prompt Engineering Hands-on Lab!

This  guide is designed to assist you in understanding and utilizing Microsoft's AI companion, Copilot, in a practical and engaging manner.   
  
Throughout this lab, we will delve into the world of AI-powered chat, explore various types of prompts, and learn how to guide an AI language model to generate desired content. The exercises are designed to be hands-on, allowing you to learn by doing and apply your newfound skills in real-time.   
  
Our goal is to equip you with the skills and understanding to effectively use AI tools like Copilot in your own projects, whether they be for business, education, or personal use.  
   
In the first exercise, you'll get to know how Copilot works by using simple prompts. In the second exercise, you'll use Copilot to create different things for a made-up space startup. This will involve generating a company name, mission statement, logo, and even a business plan, all using different prompting techniques.   
  
By the end of this lab, you will have a comprehensive understanding of how to interact with and guide AI language models, and how to use them as a powerful tool in your own projects.   
  
Now, let's dive in and get started with our first exercise!  
   

## Exercise 1 – Warmup & Basic prompts

For this exercise we are going to use Microsoft Copilot, your everyday AI companion, providing AI-powered chat for the web. Open it at <https://www.bing.com/chat> and configure the conversation style to “**More creative**”, because today we are going to have an ideation session and, as Linus Pauling said once, the best way to have a good idea is to have lots of ideas.

![Screenshot showing Copilot in the web](./img/Copilot%20in%20desktop.png)

Write the following prompt in the “Ask me anything…” textbox:

```prompt
The space is
```

This is the most basic prompt and is called a **seed text prompt**. A seed text prompt is a simple, open-ended statement or question that serves as a starting point for AI-generated content.

What was the output that Copilot generated? Depending on the day, it can generate a long dissertation about the vastness and complexity of space. It is just filling the emptiness…

If we want a specific answer, we need to ask a specific question. The more detailed our question, the better the answer.

Before starting with the new prompt, click on New topic button, this will clear the context to start from scratch.

![New Topic button in Copilot](img/new%20topic.png)

If you write this more explicit prompt:

```prompt
Complete this sentence:

The space is
```

You will get a shorter more concise answer.

Next, we have **conditional prompts**. You use these to tell the AI to create content based on certain rules or conditions. Try this one:

```prompt
Write a story about a new company building a spaceship to fly to Mars, founded by an astronaut, a few former NASA and ESA engineers, and an awarded cook.
```

In **multiple choice prompts** you present the AI with several options from which it must choose or recommend the most appropriate one based on the context or criteria provided.

```prompt
What do we need to fly to Mars?

A) a giant Mars chocolate bar

B) a DeLorean

C) a spaceship

D) a private jet
```

The previous examples are simple **Zero-shot prompts**. In these prompts we do not provide any example, we directly instruct the model to answer a question and we rely on the training data to obtain the answer. (Keep in mind that nowadays Bing chat has access to the internet, and it is also using some other techniques like meta-prompting, function calling, content filtering and RAG, so this is not completely true, but for this exercise we will just ignore this).

```prompt
Classify the text into neutral, negative or positive.

Text: I think the space is cool.

Sentiment:
```

This should give you a positive sentiment, but you can challenge the LLM to fix its answer if you feel it is not the right one:

```prompt
Are you sure? What if the word cool was factual in this sentence?
```

Now Copilot must have given this a second thought and understood the nuances.

> Great job on completing the first exercise! Remember, there's no 'one-size-fits-all' approach to using AI. Feel free to experiment with different types of prompts to see what results you get. The more you experiment, the more you'll understand how to guide Copilot effectively. If you need some more examples for each type of prompt, check the [example guide](#some-more-example-prompts) at the end of this document.

## Exercise 2 – Create your own space startup

> As we dive into the second exercise, keep in mind that this is your opportunity to get creative and experiment. Try different prompt techniques, adjust your instructions, and see how Copilot responds. Remember, there's no right or wrong way to do this – the goal is to learn and have fun!

### Introduction

You may have noticed by now that Copilot can give you up to 30 answers in a session:

![The Copilot detail showing a max of 30 responses](./img/30%20answers.png)

This means that after iterating 30 times you will need to start again from scratch. So, before starting this second exercise, click on the “**New topic**” button to start a new session.

In this exercise, you will use Copilot to generate various elements of your own space startup, such as the name, the mission statement, the logo, and the business plan. You will also learn how to use different prompting techniques, such as few-shot prompts, chain-of-thought prompts, and tree-of thought-prompts, to guide the generation process and produce high-quality results.

### Step 1: Set the context

Usually, Large Language Model (LLM) chat apps use a System Message and some templates to set the rules of the generation. We cannot change the system message for Copilot, but we can provide our own context for the session as a first message.

In this exercise, we want you to be the CEO of a new spaceship startup, so Copilot will be your executive assistant that will help you shape your ideas. Write a prompt like this to set the context:

```prompt

You are an executive assistant to an awarded cook that now is the CEO of a cutting-edge spaceship startup; your role is multifaceted and pivotal. You possess a deep understanding of aerospace engineering, which allows you to contribute significantly to the design and logistics of human spaceships bound for Mars. Your strategic planning skills enable you to assist in setting long-term goals, allocating resources effectively, and ensuring that every project milestone aligns with the company’s ambitious vision.

Your creative input is crucial in ideating innovative solutions and designing a corporate image that encapsulates the startup’s spirit. You’re adept at translating complex engineering concepts into comprehensive strategies, facilitating effective communication across departments. Your project management expertise ensures that all initiatives are executed flawlessly, reflecting the company’s commitment to pioneering space exploration.

Above all, your personal traits are what make you extraordinary. Your passion for space, visionary outlook, and proactive nature equips you to anticipate challenges and address them with resilience. Detail-oriented and adaptable, you maintain composure under pressure, making you an indispensable asset to the CEO and the entire organization as you collectively strive to achieve the monumental task of shipping a human spaceship to Mars.
```

This was again a zero-Shot prompt, but we are just establishing the context.

### Step 2: Generate a name for your space startup

To generate a name for your space startup, you can use a **few-shot prompt**, which is a type of prompt that provides some examples of the desired output, followed by an empty line where Bing Chat will fill in a new output based on the examples. For example, you can write:

```prompt
Some possible names for a space startup are:

- SpaceX
- Blue Origin
- Virgin Galactic
- Clearspace

Generate three names for our space startup that builds and sends human spaceships to Mars and show the special background of our CEO:
```

You can try different examples or add more details to the prompt, such as the type of service or product your startup offers, to get different results.

### Step 3: Assess the costs

Sending a spaceship with humans is tough. But as a startup, we must show investors that we've done our math. You can use **chain-of-thought prompting** to enforce the model to think about all the details. It involves guiding the AI to think through the problem step-by-step, leading it to the desired output:

```prompt
Calculate the costs of shipping a spaceship to Mars with a crew of 6, this first mission is a one-way trip, so we need to consider the travel time and how to send all the materials needed to survive on Mars. Let’s think step by step.

This part of the project is called Budget.
```

Now that you've calculated the costs of the mission, you might want to experiment with different scenarios. What if the crew size changed? Or the distance to Mars varied? Feel free to play around with these variables and see how the costs change.

### Step 4: Generate a business plan

As you will be challenged by the investors when you present your plan, you can use a [**tree-of-thought**](https://www.promptingguide.ai/techniques/tot) prompting technique. This technique helps the model generate different ideas and choose the best one from them.

```prompt
I have selected the name for the startup: [PUT THE NAME YOU SELECTED HERE].
Imagine our top three engineers are discussing three different ideas for our startup's business plan. Generate them and pick the best one.
```

**Prompt refinement and iteration**: ask for additional improvements to the content generated. For example, generate the full plan based on that idea:

```prompt
Now, based on the executive summary and budget, please complete the business plan with the following sections: the executive summary, the market analysis, the service description, the sales strategy and the operations plan.

This part of the project work is called Business Plan.
```

### Step 5: Generate a mission statement for your space startup

Now that we have a lot of content, we can generate a mission statement for your space startup. For example, you can write:

```prompt
This part of the project work is called Mission Statement.

Write a mission statement that reflects our objectives and the values of the company.
```

### Step 6: Create a logo for your company

Microsoft Copilot in Bing is a **multimodal** model, this means that it can also generate and understand pictures and audio. In this case the LLM has already a lot of information to work with, so we don’t need to provide lots of details, just indicate what we want in a clear statement. Let’s ask Copilot to generate a logo for our company:

```prompt
This part of the project is called Company Branding

Create a monochromatic logo in red for our company that reflects the mission and values of our company.
```

> Did you notice that the prompt for DALL·E was crafted by Copilot? You didn’t need to explain again that it was a spaceship company going to Mars, because it used the **chains** it already had. You can also go directly to <https://www.bing.com/images/create> to generate images with your own prompts.

### Step 7: pulling it all together

In this step, you will use the AI to review and summarize all the content generated during the previous exercises. This step is crucial in ensuring that all the elements of your project are coherent and aligned with your objectives.  
   
Here's how to proceed:  
   
1. **Review:** Start by asking the AI to review the text generated during the previous exercises. This will allow you to see all the content in one place and assess its overall quality and coherence.  
   
2. **Summarize:** Next, instruct the AI to generate a summary of all the content. The summary should highlight the key points from each part of the project, such as the business plan, budget, and company branding.   
  
3. **Format:** Finally, ask the AI to format the content in a specific way. For instance, you might want each part of the project to be presented as a separate section with its own title and description. This will make the content easier to read and understand.  
   
Remember, as with all AI interactions, you may need to refine your prompts or ask for additional improvements to get the desired output. Don't be afraid to experiment and iterate until you get the results you're looking for.

Here's the suggested prompt:

```prompt
Let's review all the text we wrote for the project. Can you give me the last edited copy for these parts of the project:

* Business Plan
* Budget
* Company Branding

And add a summary at the beginning.

Can you format it like this:

## Title ##

Description
```

## Conclusion  
   
Congratulations on completing this lab! Remember, the key to mastering AI is practice and experimentation. Don't be afraid to try new things, make mistakes and learn from them. Keep experimenting with different prompts and techniques, and see where your creativity takes you with AI!

Throughout this lab, you've gained hands-on experience in crafting and refining prompts, guiding AI language models to generate desired content, and using AI tools for practical applications.  
   
In particular, you've learned about various types of prompts, including seed text prompts, conditional prompts, multiple choice prompts, zero-shot prompts, and few-shot prompts. You've seen how these prompts can guide the AI model in different ways, from generating creative ideas to making detailed calculations.  
   
By creating elements for a fictional space startup, you've also seen how these techniques can be applied to real-world scenarios. Whether you're generating a company name, mission statement, business plan, or logo, you now have the skills to use AI tools effectively in your own projects.  
   
We hope you found this lab engaging and insightful. We encourage you to continue exploring and experimenting with AI tools like Copilot in your future projects. Remember, the possibilities are as vast as space itself.

Happy prompting!

## Glossary  
   
1. **AI Companion**: An artificial intelligence system designed to assist users in various tasks.  
   
2. **Prompt**: A command or statement that guides the AI in generating content.  
   
3. **Seed Text Prompt**: A simple, open-ended statement or question that serves as a starting point for AI-generated content.  
   
4. **Conditional Prompt**: A type of prompt where you guide the AI to generate content based on certain conditions or criteria.  
   
5. **Multiple Choice Prompts**: Prompts where the AI is presented with several options from which it must choose or recommend the most appropriate one.  
   
6. **Zero-shot Prompts**: These prompts do not provide any example, they directly instruct the model to answer a question and rely on the training data to obtain the answer.  
   
7. **Few-shot Prompt**: A type of prompt that provides some examples of the desired output, followed by an empty line where the AI will fill in a new output based on the examples.  
   
8. **Chain-of-thought Prompting**: A technique that involves guiding the AI to think through the problem step-by-step, leading it to the desired output.  
   
9. **Tree-of-thought Prompting**: A technique that helps the AI generate different ideas and choose the best one from them.  
   
10. **Multimodal Model**: An AI model capable of understanding and generating different types of data, such as text, images, and audio.  
   
11. **System Message**: A message that sets the rules for the generation process in AI chat apps.  
   
12. **Templates**: Predefined formats or structures that guide the generation process in AI chat apps.  
   
13. **Context**: The information that precedes the prompt and influences the AI's response.  
   
14. **Session**: A sequence of interactions with the AI model.  
   
*These definitions are specific to this lab guide and the usage of Microsoft's AI companion, Copilot. The definitions might vary slightly in different contexts or with different AI systems.*

## Some more example prompts

Here are a few more examples for each type of prompt mentioned in the guide:  
   
1. **Seed Text Prompt**:  
   - "Artificial Intelligence is"  
   - "The future of space exploration lies in"  
   
2. **Conditional Prompt**:  
   - "Describe a day in the life of an astronaut training for a mission to Mars."  
   - "Imagine a scenario where an AI becomes the president of a country. Write a short story based on this."  
   
3. **Multiple Choice Prompts**:  
   - "Which of the following programming languages is most suitable for data science?  
     A) JavaScript  
     B) Python  
     C) C++  
     D) Swift"  
   - "What's the best way to travel to work?  
     A) Walking  
     B) Cycling  
     C) Driving  
     D) Public transport"  
   
4. **Zero-shot Prompts**:  
   - "Translate the following sentence into French: 'The sky is clear today.'"  
   - "Solve the following equation: 2x + 3 = 9."  
   
5. **Few-shot Prompts**:  
   - "Some possible names for a fitness app are:  
     - FitBuddy  
     - HealthTrack  
     - WorkoutPal  
     Generate three names for our fitness app that focuses on home workouts:"  
   - "Here are some slogans for a bakery:  
     - 'Freshness you can taste'  
     - 'Baked with love'  
     - 'Your daily bread'  
     Generate three slogans for our bakery that specializes in gluten-free products:"  
   
6. **Chain-of-thought Prompting**:  
   - "Let's plan a 3-day trip to New York. Start with choosing the places to visit, then decide the best order to visit them to save travel time."  
   - "We need to plan a surprise birthday party for our friend. Start by listing out what we need, then decide the order in which we should arrange everything."  
   
7. **Tree-of-thought Prompting**:  
   - "Three of our best chefs are creating a new menu for our restaurant. They are discussing the main dish and have three different ideas. Generate them and select the best one based on your expertise."  
   - "Our marketing team is brainstorming ideas for our next ad campaign. They have three different concepts. Generate them and choose the best one."  
   
Remember to tailor the prompts to your specific needs and goals, and don't be afraid to experiment with different formats and styles to get the best results.