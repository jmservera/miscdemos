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

Welcome to the Advanced Prompt Engineering Lab. This guide will guide you through a series of steps that will teach you advanced prompt engineering skills in the context of developing a startup.

This guide is tailored for participants who already possess foundational knowledge of prompt engineering and are eager to explore advanced methodologies to enhance their skills. Furthermore, the lab has been developed to work best with Microsoft Copilot. 

Our goal is to bring your skills and understanding to effectively use AI tools to the next level.  

### Lab Overview

In this lab, you will follow a guided journey to create a startup plan using sophisticated prompt engineering methods.


## Learning Objectives

Overview:

Exercise 1: Getting Familiar with Microsoft Copilot and Zero-Shot Prompting
Exercise 2: In-Context Learning and Setting Goals with Task-Specific Prompting
Exercise 3: Refining Responses with Recursive Prompting and Task Splitting
Exercise 4: Enhancing Reasoning with Chain-of-Thought and Tree-of-Thought Prompting
Exercise 5: Generating Structured Outputs and Visualizations with Advanced Techniques

Let’s get started by setting the foundation for our startup journey!

</div>
</div>

<div class="section" markdown="1">

## Exercise 1 – Getting familiar with Microsoft Copilot

<div class="step" markdown="1">

For this exercise, we’ll be using **Microsoft Copilot** —your go-to AI companion for web-based AI-powered chat. Open Copilot at [bing.com/chat](https://www.bing.com/chat) and set the conversation style to "**More creative**." We're diving into an ideation session today, and as Linus Pauling once said:

Today, we’ll dive into brainstorming and strategic planning for EcoGen Solutions. Your tasks will include defining the company’s strengths and weaknesses, identifying opportunities in a growing market, and anticipating potential threats. As Linus Pauling once said:

> *The best way to have a good idea is to have lots of ideas.*

![Screenshot showing Copilot on the web.](./img/Copilot%20in%20desktop.png)

*Note:* If you’re accessing this exercise on a mobile browser, you might encounter a different interface. In that case, you may be prompted to log in with your Microsoft account to proceed.

> **Important:** This exercise builds on foundational prompt engineering concepts. If you’re new to prompt engineering, we recommend starting with the [entry-level tutorial](https://jmservera.github.io/miscdemos/prompt-engineering#exercise-1--warmup-with-basic-prompts) to familiarize yourself with the basics before moving on to advanced techniques.
</div>
</div>


<div class="section" markdown="1">

## Exercise 2 – In-context Learning

<div class="step" markdown="1">

### Step 1: Define Your Startup Persona

In-context learning, also known as few-shot learning is a technique where an LLM is given instructions or examples within the input prompt to guide its response. This method leverages the model's ability to understand adapt to patterns presented in the immediate context of the query. 

Imagine you're the CEO of a Carbonova - a leading company for Co2 storage.

Your mission is to lead strategic growth while ensuring innovation. 
Alongside you is an AI-driven executive assistant that you can prompt to tackle this task.

EcoVerse Solutions, a leading innovator in direct air capture (DAC) technology, has established itself as a key player in the fight against climate change by developing advanced systems to capture CO₂ directly from the atmosphere. Backed by strategic partnerships with major corporations like Microsoft and strong financial support, the company is poised for growth. However, Carbonova faces challenges in scaling its operations and reducing the high costs associated with capturing carbon, which limits broader adoption. As global policies shift towards net-zero goals, the company has significant opportunities to benefit from government regulations and the growing carbon credits market. Nonetheless, emerging competition in the DAC space and potential economic fluctuations pose risks to its future expansion.

```prompt
As the founder of EcoVerse Solutions, I need to understand the current market landscape. Please provide a SWOT analysis for my company, considering the renewable energy sector.

Information about Carbonova:
<insert the information from above here>
```

*This **zero-shot prompt** sets the context and assigns roles without providing specific examples.*

Expected Outcome:

Copilot should provide a basic SWOT analysis outlining potential strengths, weaknesses, opportunities, and threats for EcoVerse Solutions.

</div>

<div class="step" markdown="1">

### Step 2: Setting Goals

The first step in planning a project enhanced with prompt engineering and ChatGPT is to clearly define your project goals. This foundational step helps shape your vision, ensuring that your prompt strategy aligns seamlessly with your objectives.

Why Identify Your Goals?
Clearly outlining your goals serves multiple purposes:

Use the following questions to comprehensively define the goals of your project:

What is the problem you are solving or the goal that you are trying to achieve?
Why do you need to solve this problem?
Who is the stakeholder/end-user of the solution?
How does the solution impact them?
Where is your data stored and where will the solution be hosted?
When does it need to be ready?

**Prompt:**
Please help me creating an outline for a presentation targeted at potential investors. 
I want you to make the outline not more than 10 slides. Be brief and use bulletpoints.
The objective is to effectively communicate our company's mission to become the leading provider of CO₂ air capturing technology. 
My goal is that after the presentation, everybody in the room is excited and inspired and wants to invest into my company.
Additional requirements: 
- Use simple language. 
- Catchy slide titles. 
- Clear call to action at the end.

</div>

<div class="step" markdown="1">

### Step 3: Providing References

Using reference texts when crafting prompts for language models can significantly enhance the accuracy and relevance of the output, especially in fields that require precise information. This approach is akin to providing a student with notes during an exam; it guides the model to deliver responses based on factual information rather than making uninformed guesses, particularly in specialized or niche topics. 

By directing the model to use the provided text, the likelihood of fabricating responses (hallucinations) is reduced, promoting more reliable and verifiable outputs.

**Prompt:**
What are the benefits of the OpenAI o1 model?

**Prompt:**
What are the benefits of the OpenAI o1 model?

"""<insert document here>"""

</div>


<div class="step" markdown="1">

### Step 4: Recusrive Prompting

**Follow Up Prompt:**
Based on this presentation, put yourself into the shoes if the investors and think about 10 questions that sceptic investors might ask during the presentation. Be creative and extra critical.

**Follow Up Prompt:**
For each question, please also provide a good answer. 

**Follow Up Prompt:**
Please, give me the result as a table with columns "question" and "answer"

</div>

<div class="step" markdown="1">

### Step 5: Splitting Tasks Into Subtasks

Complex tasks often result in higher error rates and can be overwhelming for the AI. By breaking a complex task into simpler, manageable parts, the model can handle each segment with greater accuracy. This method is akin to modular programming in software engineering, where a large system is divided into smaller, independent modules. For language models, this could involve processing a task in stages, where the output of one stage serves as the input for the next, thereby simplifying the overall task and reducing potential errors.

**Follow Up Prompt:**


</div>


<div class="section" markdown="1">

## Exercise 3 – Chain of Thought Prompting

<div class="step" markdown="1">

### Step 1: Giving the Model Time to "Think"

Allowing the model time to "think" or process information can lead to more accurate and thoughtful responses. Encouraging a model to perform a 'chain of thought' process before arriving at a conclusion can mimic the human problem-solving process, enhancing the reliability of the responses. This approach is particularly useful in complex calculation or reasoning tasks, where immediate answers may not be as accurate. This strategy encourages the model to use more compute to provide a more comprehensive response.

**Prompt:**
First work out your own solution to the problem. Then compare your solution to the xxxx and evaluate if the solution is correct or not. Don't decide if the solution is correct until you have figured it out yourself. 

</div>

<div class="step" markdown="1">

### Step 2: Considering Multiple Perspectives with Tree of Thoughts

ToT maintains a tree of thoughts, where thoughts represent coherent language sequences that serve as intermediate steps toward solving a problem. This approach enables an LM to self-evaluate the progress through intermediate thoughts made towards solving a problem through a deliberate reasoning process. The LM's ability to generate and evaluate thoughts is then combined with search algorithms (e.g., breadth-first search and depth-first search) to enable systematic exploration of thoughts with lookahead and backtracking.


**Prompt:**
Imagine three different experts are answering this question.
All experts will write down 1 step of their thinking,
then share it with the group.
Then all experts will go on to the next step, etc.
If any expert realises they're wrong at any point then they leave.
The question is...

</div>
</div>


<div class="section" markdown="1">

## Exercise 4 – Generating Different Output Formats

<div class="step" markdown="1">

### Step 1: Generate a SWOT Analysis

A SWOT analysis can help with understanding your company's strengths, weaknesses, opportunities, and threats. 
Use the LLM to create a detailed SWOT analysis by prompting it to ask clarifying questions to gather necessary information.

**Prompt:**
As my executive assistant, please help me create a SWOT analysis based on the information provided.

*This prompt leverages the LLM's ability to structure and conceptualize complex information.*

</div>

<div class="step" markdown="1">

### Step 2: Structuring the SWOT Analysis

Once the LLM gathers the necessary information, instruct it to present the SWOT analysis in a structured table format.

**Prompt:**
Based on the information we've discussed, please organize the SWOT analysis into a table with four columns: Strengths, Weaknesses, Opportunities, and Threats. Ensure each point is concise and clearly articulated. Return it as Table format.
*Generating structured data helps in better visualization and analysis.*

</div>



<div class="step" markdown="1">

### Step 3: Change the Format to JSON with Predefined Structure

You want to hand the SWOT analysis over to a programmer to embedd it into an application, who wants it as a JSON file.

**Prompt:**
Please turn the SWOT analysis into JSON format with the following structure: 
{
  "SWOT_Analysis": {
    "Strengths": [
      ""
    ],
    "Weaknesses": [
      ""
    ],
    "Opportunities": [
      ""
    ],
    "Threats": [
      ""
    ]
  }
}

*Generating structured data helps in better visualization and analysis.*

</div>
</div>


<div class="section" markdown="1">

## Exercise 5 – Strategic Business Planning with Advanced Prompts

<div class="step" markdown="1">

### Step 1: Business Strategy Advising

Utilize the LLM to gain insights and advice on business strategy topics relevant to your startup.

**Prompt:**
Given our SWOT analysis, what strategic initiatives should we prioritize to leverage our strengths and opportunities while addressing our weaknesses and mitigating threats? Provide a detailed plan with actionable steps.

*This **conditional prompt** directs the LLM to generate specific strategic advice based on prior analysis.*

</div>

<div class="step" markdown="1">

### Step 2: Pros and Cons Table for Strategic Decisions

When faced with strategic decisions, use the LLM to create a pros and cons table to evaluate options objectively.

**Prompt:**
We are considering expanding our product line to include solar-powered batteries. Please create a table outlining the pros and cons of this expansion.
*Structured outputs like tables facilitate clearer decision-making.*

</div>

<div class="step" markdown="1">

### Step 3: Detailed SWOT Analysis with Interactive Input

Enhance your SWOT analysis by allowing the LLM to ask targeted questions, ensuring a thorough evaluation.

**Prompt:**
Let's refine our SWOT analysis further. Please ask specific questions about each category to ensure we have covered all critical aspects.
*This interactive approach ensures comprehensive data collection for each SWOT category.*

</div>

<div class="step" markdown="1">

### Step 4: Creating Visual Concept Illustrations with HTML

Visual representations can aid in communicating your startup's vision. Use the LLM to generate simple HTML code for concept illustrations.

**Prompt:**
Create a simple HTML snippet that visually represents our sustainable energy solution, incorporating elements like solar panels, wind turbines, and energy storage units.

**Expected Output:**

*Generating HTML code allows for easy integration of visual elements into presentations or websites.*

<div>
```html
<!DOCTYPE html>
<html>
<head>
    <title>Our Sustainable Energy Solution</title>
    <style>
        .concept {
            display: flex;
            justify-content: space-around;
            align-items: center;
        }
        .element {
            text-align: center;
        }
    </style>
</head>
<body>
    <div class="concept">
        <div class="element">
            <img src="solar-panel.png" alt="Solar Panels" width="100">
            <p>Solar Panels</p>
        </div>
        <div class="element">
            <img src="wind-turbine.png" alt="Wind Turbines" width="100">
            <p>Wind Turbines</p>
        </div>
        <div class="element">
            <img src="energy-storage.png" alt="Energy Storage" width="100">
            <p>Energy Storage Units</p>
        </div>
    </div>
</body>
</html>
```html
</div>

To display the HTML create a file with HTML extension, for example by pressing STRG + S in your browser.
Then open the HTML file with an editor and copy the HTML code over to the file. 
You can then open the file in Browser and view the result.
![The mermaid code visualized.](./img/html_code.png)
</div>

<div class="step" markdown="1">

### Step 5: Generating Diagrams with Mermaid.js
For more complex visualizations like flowcharts or organizational structures, use Mermaid.js code generated by the LLM.

**Prompt:**
Generate Mermaid.js code for an organizational chart of our startup, showing the CEO, CTO, CFO, Marketing Director, and Engineering Team.

Mermaid.js allows for dynamic and interactive diagrams, enhancing visual communication.

**Expected Output:**
graph TD
    CEO[CEO]
    CTO[CTO]
    CFO[CFO]
    Marketing[Marketing Director]
    Engineering[Engineering Team]

    CEO --> CTO
    CEO --> CFO
    CEO --> Marketing
    CTO --> Engineering*

You can view this diagram at Mermaid Live Editor (free version): https://www.mermaidflow.app/editor
![The mermaid code visualized.](./img/mermaid_code.png)

</div>

<div class="step" markdown="1">

### Step 6: Implementing Chain-of-Thought Reasoning
For complex problem-solving and strategic planning, utilize chain-of-thought prompting to guide the LLM through multi-step reasoning.

**Prompt:**
We need to optimize our supply chain for better efficiency and cost-effectiveness. Let's think step-by-step about how to achieve this.

Chain-of-thought prompting encourages the LLM to break down the problem into manageable steps, leading to more coherent and logical solutions.

**Expected Output:**

Assess Current Supply Chain:

Map out all suppliers, manufacturers, and distributors.
Identify bottlenecks and inefficiencies.
Identify Cost Drivers:

Analyze costs associated with each stage of the supply chain.
Determine areas with the highest expenses.
Explore Optimization Strategies:

Consider bulk purchasing to reduce costs.
Implement just-in-time inventory to minimize storage expenses.
Negotiate better terms with suppliers.
Implement Technology Solutions:

Adopt supply chain management software for better tracking.
Utilize automation in warehouses to increase efficiency.
Monitor and Review:

Establish KPIs to measure supply chain performance.
Regularly review processes and make adjustments as needed.
Sustainability Considerations:

Incorporate eco-friendly practices to align with our sustainable mission.
Partner with suppliers who prioritize environmental responsibility.

</div>
</div> 

<div class="section" markdown="1">

### Conclusion

<div class="step" markdown="1">
Congratulations on completing the Advanced Prompt Engineering Lab!

Throughout this lab, you have:

Applied Advanced Techniques: Leveraged business strategy advising, interactive SWOT analyses, and chain-of-thought reasoning to develop a robust startup plan.
Generated Structured Outputs: Created SWOT tables, pros and cons lists, and detailed business plans to support strategic decisions.
Enhanced Visual Communication: Utilized HTML and Mermaid.js to produce visual representations of your startup's concepts and organizational structure.
Navigated Complex Problem-Solving: Employed chain-of-thought prompting to tackle intricate challenges methodically.
Explored Model Comparisons: Optionally compared GPT-4o with the OpenAI o1 reasoning model to understand their respective strengths in handling complex tasks.
Remember: Advanced prompt engineering is about creativity, precision, and iterative refinement. Continue experimenting with different techniques and prompts to uncover new possibilities and optimize your interactions with AI models.

We encourage you to apply these advanced techniques in your projects, whether for strategic planning, data analysis, or creative development. The skills you've honed here will empower you to harness the full potential of AI in driving your startup's success.

Happy prompting!
![You are the Prompt Hero](./img/prompt%20hero%20badge%20advanced.png)

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