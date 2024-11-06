---
layout: custom
title: "Advanced Prompt Engineering Lab"
subtitle: "HSG Alumni"
authors: ["Juan Manuel Servera & Florian Follonier - Microsoft"]
permalink: /prompt-engineering-advanced
---

<div class="section" markdown="1">

By Florian Follonier - Cloud Solution Architect Data & AI - Microsoft
& Juan Manuel Servera - Cloud Solution Architect App Innovation - Microsoft

## Introduction

<div class="step" markdown="1">

![Screenshot showing Copilot on the web.](./img/Copilot%20image.png)

Welcome to the Advanced Prompt Engineering Lab. This guide will guide you through a series of steps that will teach you advanced prompt engineering skills in the context of developing a startup.

This guide is tailored for participants who already possess foundational knowledge of prompt engineering and are eager to explore advanced methodologies to enhance their skills. Furthermore, the lab has been developed to work best with Microsoft Copilot. 

Our goal is to bring your skills and understanding to effectively use AI tools to the next level.  

### Lab Overview

In this lab, you will follow a guided journey to create a startup plan using sophisticated prompt engineering methods.

Overview:

- Exercise 1: Getting Familiar with Microsoft Copilot and Zero-Shot Prompting
- Exercise 2: In-Context Learning and Setting Goals with Task-Specific Prompting
- Exercise 3: Refining Responses with Recursive Prompting and Task Splitting
- Exercise 4: Enhancing Reasoning with Chain-of-Thought and Tree-of-Thought Prompting
- Exercise 5: Generating Structured Outputs and Visualizations with Advanced Techniques

Let’s get started by setting the foundation for our startup journey!

</div>
</div>

<div class="section" markdown="1">

## Exercise 1 – Getting familiar with Microsoft Copilot

<div class="step" markdown="1">

### Objective

In this exercise, you'll become acquainted with Microsoft Copilot and practice zero-shot prompting by initiating a SWOT analysis for your startup.

</div>

<div class="step" markdown="1">

### Step 1: Setting Up Microsoft Copilot

For this exercise, we’ll be using **Microsoft Copilot** —your go-to AI companion for web-based AI-powered chat. Open Copilot at [bing.com/chat](https://www.bing.com/chat) and set the conversation style to "**More creative**." We're diving into an ideation session today, and as Linus Pauling once said:

Today, we’ll dive into brainstorming and strategic planning for EcoGen Solutions. Your tasks will include defining the company’s strengths and weaknesses, identifying opportunities in a growing market, and anticipating potential threats. As Linus Pauling once said:

> *The best way to have a good idea is to have lots of ideas.*

![Screenshot showing Copilot on the web.](./img/Copilot%20in%20desktop.png)

*Note:* If you’re accessing this exercise on a mobile browser, you might encounter a different interface. In that case, you may be prompted to log in with your Microsoft account to proceed.

> **Important:** This exercise builds on foundational prompt engineering concepts. If you’re new to prompt engineering, we recommend starting with the [entry-level tutorial](https://jmservera.github.io/miscdemos/prompt-engineering#exercise-1--warmup-with-basic-prompts) to familiarize yourself with the basics before moving on to advanced techniques.
</div>


<div class="step" markdown="1">

### Step 2: Initiating a SWOT Analysis with Zero-Shot Prompting

Zero-shot prompting involves giving the AI a broad prompt without specific examples, allowing it to generate open-ended responses.

Imagine you're the CEO of a EcoVerse Solutions - a leading company for Co2 storage.

Your mission is to lead strategic growth while ensuring innovation. 
Alongside you is an AI-driven executive assistant that you can prompt to tackle this task.

> **Information About EcoVerse Solutions:** 
EcoVerse Solutions, a leading innovator in direct air capture (DAC) technology, has established itself as a key player in the fight against climate change by developing advanced systems to capture CO₂ directly from the atmosphere. Backed by strategic partnerships with major corporations like Microsoft and strong financial support, the company is poised for growth. However, EcoVerse Solutions faces challenges in scaling its operations and reducing the high costs associated with capturing carbon, which limits broader adoption. As global policies shift towards net-zero goals, the company has significant opportunities to benefit from government regulations and the growing carbon credits market. Nonetheless, emerging competition in the DAC space and potential economic fluctuations pose risks to its future expansion.

```prompt
As the founder of EcoVerse Solutions, I need to understand the current market landscape. Please provide a SWOT analysis for my company, considering the renewable energy sector.

<insert the information from above here>
```

*This **zero-shot prompt** sets the context and assigns roles without providing specific examples.*

Expected Outcome:

Copilot should provide a basic SWOT analysis outlining potential strengths, weaknesses, opportunities, and threats for EcoVerse Solutions.

</div>
</div>

<div class="section" markdown="1">

## Exercise 2 – In-Context Learning and Setting Goals with Task-Specific Prompting

<div class="step" markdown="1">

### Objective

Enhance the AI's responses by providing context and setting clear goals, using in-context learning and task-specific prompting.

</div>

<div class="step" markdown="1">

### Step 1: Define Your Startup Persona

In-context learning provides the AI with specific information within the prompt to guide its response.

Scenario:

You are the CEO of EcoVerse Solutions. Your mission is to lead strategic growth while ensuring innovation in renewable energy.

```prompt
I am the CEO of EcoVerse Solutions. You are an experienced business strategist with a background in renewable energy. Assist me with a series of tasks based on the following information about my company:
```

This prompt provides context, setting roles and background information to guide the AI's response more effectively.

</div>

<div class="step" markdown="1">

### Step 2: Setting Goals with Task-Specific Prompting

Task-specific prompting focuses the AI's output on desired deliverables.

Why Identify Your Goals?
Clearly outlining your goals serves multiple purposes:

Use the following questions to comprehensively define the goals of your project:

What is the problem you are solving or the goal that you are trying to achieve?
Why do you need to solve this problem?
Who is the stakeholder/end-user of the solution?
How does the solution impact them?
Where is your data stored and where will the solution be hosted?
When does it need to be ready?

```prompt
Please help me create an outline for a 10-slide presentation targeted at potential investors. The objective is to effectively communicate our mission to become the leading provider of affordable, high-efficiency solar panels. After the presentation, I want the investors to be excited and inspired to invest in my company. Additional requirements:

Use simple language.
Catchy slide titles.
Clear call to action at the end.
Present the outline in bullet points.
```

Expected Outcome:

Copilot should generate a structured presentation outline that meets the specified requirements, demonstrating how providing clear goals and context improves the quality of the AI's output.

</div>
</div>

<div class="section" markdown="1">

## Exercise 3 – Refining Responses with Recursive Prompting and Task Splitting

<div class="step" markdown="1">

### Objective

Learn how to refine AI responses through recursive prompting and improve task handling by splitting complex tasks into subtasks.

</div>

<div class="step" markdown="1">

### Step 1: Recursive Prompting – Anticipating Investor Questions

Recursive prompting involves using follow-up prompts to refine the AI's output.

```Prompt:
Based on the presentation outline, put yourself in the shoes of skeptical investors and think about 10 critical questions they might ask during the presentation. Be creative and extra critical.
```

```Follow-Up Prompt 1:
For each question, please provide a well-thought-out answer.
```

```Follow-Up Prompt 2:
Please present the results in a table with two columns: "Question" and "Answer".
```

Expected Outcome:

Copilot should generate a table with critical investor questions and corresponding answers, demonstrating how recursive prompts can refine and expand the AI's responses.

</div>


<div class="step" markdown="1">

### Step 2: Task Splitting – Breaking Down Complex Tasks

Task splitting involves dividing a complex task into simpler, manageable parts to improve accuracy.

```Prompt:
Let's improve our investor Q&A section. First, list common investor concerns in the renewable energy sector. Then, for each concern, explain how EcoVerse Solutions addresses it.
```

Expected Outcome:

By breaking down the task, Copilot can focus on listing concerns first and then addressing them, resulting in a more detailed and accurate output.

</div>
</div>

<div class="section" markdown="1">

## Exercise 4 – Enhancing Reasoning with Chain-of-Thought and Tree-of-Thought Prompting

<div class="step" markdown="1">

### Objective

Utilize advanced prompting techniques to encourage the AI to perform deeper reasoning and consider multiple perspectives.

</div>

<div class="step" markdown="1">

### Step 1: Splitting Tasks Into Subtasks

Chain-of-thought prompting guides the AI to think through problems step-by-step.

```Prompt:
We need to develop a strategic plan to scale our manufacturing while maintaining cost-effectiveness. Let's think through the steps we need to take to achieve this goal.
```

Expected Outcome:

Copilot should outline a step-by-step plan, considering factors like supply chain optimization, cost reduction strategies, and potential partnerships.

</div>

<div class="step" markdown="1">

### Step 2: Tree-of-Thought Prompting – Considering Multiple Solutions

Tree-of-thought prompting encourages the AI to explore different ideas before selecting the best one.

```Prompt:
We are exploring new markets to expand into. Imagine three different market entry strategies: entering developing countries, targeting urban areas in developed countries, or partnering with governments for large-scale projects. Generate these ideas and evaluate which aligns best with our mission and resources.
```

Expected Outcome:

Copilot should provide an analysis of each strategy, comparing their pros and cons, and suggest the most suitable option.

</div>
</div>

<div class="section" markdown="1">

## Exercise 5 – Generating Structured Outputs and Visualizations with Advanced Techniques

<div class="step" markdown="1">

### Objective

Learn how to instruct the AI to produce process visualizations using Mermaid.js and create interactive representations using HTML to enhance business communication and strategic planning.

</div>

<div class="step" markdown="1">

### Step 1: Defining a Business Process to Visualize

Choose a key business process within EcoVerse Solutions that would benefit from visualization. For this exercise, we'll focus on the Customer Onboarding Process for new clients purchasing solar panel systems.

```Prompt:
As the CEO of EcoVerse Solutions, I want to visualize our Customer Onboarding Process to identify areas for improvement and enhance customer experience. Please help me outline the steps involved in our Customer Onboarding Process.
```

Expected Outcome:

Copilot should provide a detailed list of steps involved in the customer onboarding process, such as:

1. Customer Inquiry: The customer expresses interest via phone, email, or website form.
2. Initial Consultation: Our sales team contacts the customer to discuss needs and schedule a site visit.
3. Site Assessment: Technicians assess the property to determine suitability and system requirements.
4. Proposal Preparation: A customized proposal is created, outlining system design and costs.
5. Proposal Presentation: The proposal is presented to the customer for review.
6. Contract Signing: Upon agreement, contracts are signed, and financing options are arranged.
7. Installation Scheduling: Installation dates are scheduled based on customer availability.
8. System Installation: The installation team installs the solar panel system.
9. Inspection and Testing: The system is inspected and tested to ensure proper operation.
10. Customer Training: The customer is trained on system use and maintenance.
11. Post-Installation Support: Ongoing support and maintenance services are provided.
12. Customer Feedback Collection: Feedback is gathered to improve services.

</div>

<div class="step" markdown="1">

### Step 2: Generating Mermaid.js Code to Visualize the Process

Use the detailed process steps to create a visual flowchart using Mermaid.js.

```Prompt:
Based on the detailed Customer Onboarding Process, generate Mermaid.js code for a flowchart that visualizes each step. Ensure that the flowchart accurately represents the sequence of steps and includes any decision points or feedback loops.
```

Expected Outcome:

Copilot should provide Mermaid.js code that, when rendered, displays a flowchart of the customer onboarding process.

graph TD
    A[Customer Inquiry] --> B[Initial Consultation]
    B --> C[Site Assessment]
    C --> D[Proposal Preparation]
    D --> E[Proposal Presentation]
    E --> F{Proposal Accepted?}
    F -- Yes --> G[Contract Signing]
    F -- No --> H[Revise Proposal]
    H --> D
    G --> I[Installation Scheduling]
    I --> J[System Installation]
    J --> K[Inspection and Testing]
    K --> L[Customer Training]
    L --> M[Post-Installation Support]
    M --> N[Customer Feedback Collection]

Instructions:

Use the Mermaid Live Editor at Mermaid Live Editor [mermaid.live](https://mermaid.live/) to visualize the diagram.
Paste the generated code into the editor to view the interactive flowchart.

![The diagram should look similar to this](./img/mermaidjs.png)

</div>

<div class="step" markdown="1">

### Step 4: Creating an Interactive HTML Representation

Enhance the process visualization by creating an interactive HTML representation of the Customer Onboarding Process.

```Prompt:
Please generate an HTML snippet that outlines the Customer Onboarding Process. 
When the user hovers above one of the steps, there should be additional information displayed.
```

Expected Outcome:

Copilot should produce HTML code that, when rendered, presents the onboarding process in an interactive format, allowing users to click through each step.


Instructions:

Copy the generated HTML code into an .html file.
Open the file in a web browser to interact with the onboarding process steps.

</div>
</div> 


<div class="section" markdown="1">

## Exercise 6 – Classifying Text with Zero-Shot and Few-Shot Sentiment Analysis

<div class="step" markdown="1">

### Objective

Learn how to perform text classification, specifically sentiment analysis, using both zero-shot and few-shot prompting techniques. This exercise will enable you to analyze customer feedback effectively, enhancing your ability to understand and respond to customer sentiments.

</div> 

<div class="step" markdown="1">

### Step 1: Zero-Shot Sentiment Classification
Zero-shot prompting allows the AI to classify text based on the provided instructions without specific examples. This technique is useful when you want the AI to apply general knowledge to categorize sentiments.

Scenario:

EcoVerse Solutions has received various pieces of customer feedback. You need to classify the sentiment of each feedback to understand customer satisfaction levels.

```Prompt:
*Classify the following customer feedback into positive, negative, or neutral sentiment.*
```

Feedback: "The installation team was professional and efficient."

Sentiment:
Expected Outcome:

Copilot should analyze the feedback and classify the sentiment appropriately.

Example Response:

Positive

Instructions:

Provide the Prompt: Use the prompt as shown above, replacing the feedback text as needed.
Interpret the Response: The AI will classify the sentiment based on the content of the feedback.
Benefits:

Efficiency: Quickly categorize large volumes of feedback.
Insight: Gain insights into overall customer satisfaction and areas needing improvement.

</div> 

<div class="step" markdown="1">

### Step 2: Few-Shot Sentiment Classification

Few-shot prompting involves providing the AI with a few examples of how to classify sentiments. This technique guides the AI to follow a specific pattern, improving accuracy and consistency in classification.

Scenario:

To enhance the accuracy of sentiment classification, provide the AI with example classifications.

```Prompt:
*Classify the following customer feedback into positive, negative, or neutral sentiment based on the examples below:*

- "The installation team was professional and efficient." // Positive
- "The product stopped working after a week." // Negative
- "The service was okay, nothing exceptional." // Neutral

Feedback: "I love the design of your solar panels, but the pricing is a bit high."

Sentiment:
```

Expected Outcome:

Copilot should classify the sentiment of the new feedback by following the pattern established in the examples.

Example Response:

Positive
Instructions:

Provide the Prompt: Use the prompt as shown above, ensuring to include clear examples.
Interpret the Response: The AI will classify the sentiment based on the provided examples.
Benefits:

Improved Accuracy: The AI follows the demonstrated pattern, reducing misclassification.
Consistency: Ensures that similar feedback is classified in a uniform manner.

</div> 

<div class="section" markdown="1">

### Conclusion

<div class="step" markdown="1">
Congratulations on completing the Advanced Prompt Engineering Lab!

![You are the Prompt Hero](./img/prompt%20hero%20badge%20advanced.png)

Throughout this lab, you have:

Applied Advanced Techniques: Leveraged zero-shot, few-shot, recursive, chain-of-thought, and tree-of-thought prompting to develop a robust startup plan.
Generated Structured Outputs: Created Business Model Canvas, presentation outlines, and strategic plans in various formats, including tables and JSON.
Enhanced Visual Communication: Utilized HTML and Mermaid.js to produce visual representations of your startup's concepts and organizational structure.
Navigated Complex Problem-Solving: Employed advanced reasoning techniques to tackle intricate business challenges methodically.
Remember, advanced prompt engineering is about creativity, precision, and iterative refinement. Continue experimenting with different techniques and prompts to uncover new possibilities and optimize your interactions with AI models.

We encourage you to apply these advanced techniques in your projects, whether for strategic planning, data analysis, or creative development. The skills you've honed here will empower you to harness the full potential of AI in driving your startup's success.

Happy prompting!

### Additional Resources

If you want to learn more, here you have a few interesting resources to extend your knowledge on prompt engineering and AI language models:

* [Prompting Guide](https://www.promptingguide.ai): A comprehensive guide to prompting techniques for AI language models.
* [OpenAI Prompt Engineering](https://platform.openai.com/docs/guides/prompt-engineering/prompt-engineering): A guide to prompt engineering by the GPT-4 creators.
* [Prompt Engineering Techniques](https://learn.microsoft.com/en-us/azure/ai-services/openai/concepts/advanced-prompt-engineering): Tips and tricks for prompting with Azure OpenAI Service.

</div> 
</div> 

<div class="section" markdown="1">

Glossary

<div class="step" markdown="1"> 

1. **AI Companion**: An artificial intelligence system designed to assist users in various tasks. 
2. **Prompt**: A command or statement that guides the AI in generating content. 
3. **Zero-Shot Prompt**: A simple, open-ended statement or question that serves as a starting point for AI-generated content without providing specific examples. 
4. **Conditional Prompt**: A type of prompt where you guide the AI to generate content based on certain conditions or criteria. 
5. **Multiple Choice Prompt**: Prompts where the AI is presented with several options from which it must choose or recommend the most appropriate one. 
6. **Few-Shot Prompt**: A type of prompt that provides some examples of the desired output, followed by an empty line where the AI will fill in a new output based on the examples.
7. **Chain-of-Thought Prompting**: A technique that involves guiding the AI to think through the problem step-by-step, leading it to the desired output. 
8. **Tree-of-Thought Prompting**: A technique that helps the AI generate different ideas and choose the best one from them. 
9. **Mermaid.js**: A JavaScript-based diagramming and charting tool that uses text-based definitions to create diagrams dynamically. 
10. **SWOT Analysis**: A strategic planning tool that evaluates the Strengths, Weaknesses, Opportunities, and Threats related to a business or project. 
11. **Pros and Cons Table**: A structured format that lists the advantages and disadvantages of a particular decision or option.
12. **System Message**: A message that sets the rules for the generation process in AI chat apps. 
13. **Context**: The information that precedes the prompt and influences the AI's response.
14. **Persona**: A defined role or character assigned to the AI to guide its responses in a specific manner. 
15. **ReAct**: A framework that integrates reasoning and acting in language models, enabling them to generate reasoning traces and task-specific actions.

These definitions are specific to this lab guide and the usage of Microsoft's AI companion, Copilot. The definitions might vary slightly in different contexts or with different AI systems.

</div> 
</div> 

<div class="section" markdown="1">

Additional Example Prompts

<div class="step" markdown="1"> 

Here are advanced examples for each type of prompt mentioned in the lab:
Zero-Shot Prompt:
"Develop a marketing strategy for our sustainable energy startup targeting urban households."
Conditional Prompt:
"Based on our current market position, propose three strategic initiatives to increase our market share in the renewable energy sector."
Multiple Choice Prompt:
"Which of the following technologies should we invest in to enhance our energy storage capabilities?
A) Lithium-ion batteries
B) Flow batteries
C) Solid-state batteries
D) Hydrogen fuel cells"
Few-Shot Prompt:
"Here are some mission statements from leading sustainable energy companies:
'To accelerate the world's transition to sustainable energy.'
'Innovating renewable energy solutions for a greener tomorrow.'
'Empowering communities with clean and affordable energy.'
Generate three mission statements for our startup that emphasizes innovation and sustainability."
Chain-of-Thought Prompting:
"We aim to reduce our carbon footprint by 50% over the next five years. Let's outline the steps needed to achieve this goal."
Tree-of-Thought Prompting:
"Our product development team is brainstorming ideas for a new solar panel design. They have three different concepts. Generate these ideas and evaluate which one aligns best with our sustainability goals."
Mermaid.js Prompt:
"Create Mermaid.js code for a flowchart depicting our customer onboarding process, including steps like 'Sign Up', 'Verification', 'Welcome Package', and 'First Purchase'."

</div> 
</div> 