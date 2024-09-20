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
Welcome to the **Advanced Prompt Engineering Lab**!

In this lab, we will dive deep into sophisticated prompt engineering techniques within the context of developing a startup. This guide is tailored for participants who already possess foundational knowledge of prompt engineering and are eager to explore advanced methodologies to enhance their skills.

### Lab Overview

Throughout this lab, you will embark on a journey to build a comprehensive startup plan using advanced prompt engineering techniques. You will leverage Large Language Models (LLMs) to:

- Advise on business strategy topics.
- Navigate complex decision-making processes.
- Generate structured outputs like SWOT analyses and pros & cons tables.
- Create visual concept illustrations using HTML and Mermaid.js.
- Utilize chain-of-thought reasoning for intricate problem-solving.

Additionally, an optional challenge will allow you to compare the performance of GPT-4o with the newer OpenAI o1 reasoning model, highlighting their strengths in handling complex tasks.

### Learning Objectives

By the end of this lab, you will:

- Master advanced prompt engineering techniques.
- Apply LLMs to strategic business planning and analysis.
- Generate and manipulate structured data outputs.
- Create simple graphical representations using code.
- Understand the comparative strengths of different LLM reasoning models.

Let’s get started by setting the foundation for our startup journey!
</div>
</div>

<div class="section" markdown="1">

## Exercise 1 – Establishing Your Startup Context

<div class="step" markdown="1">

> **Note:** This exercise assumes you have a basic understanding of prompt engineering. We will focus on setting up a robust context for your startup to enable advanced interactions with the LLM.

### Step 1: Define Your Startup Persona

To begin, define the personas involved in your startup. This will help the LLM generate contextually relevant and coherent responses.

**Prompt:**
You are the CEO of a tech startup focused on sustainable energy solutions. Your role involves strategic planning, business development, and leading a team of experts in engineering and marketing. Your executive assistant is an experienced business strategist with a background in environmental science, tasked with supporting you in achieving the company's mission.
*This **zero-shot prompt** sets the context and assigns roles without providing specific examples.*
</div>

<div class="step" markdown="1">

### Step 2: Generate a Comprehensive SWOT Analysis

A SWOT analysis is crucial for understanding your startup's strengths, weaknesses, opportunities, and threats. Use the LLM to create a detailed SWOT analysis by prompting it to ask clarifying questions to gather necessary information.

**Prompt:**As my executive assistant, please help me create a comprehensive SWOT analysis for our sustainable energy startup. Start by asking me questions to gather relevant information for each of the four categories: Strengths, Weaknesses, Opportunities, and Threats.
*This prompt leverages the LLM's ability to navigate complexity by initiating an interactive process.*

</div>

<div class="step" markdown="1">

### Step 3: Structuring the SWOT Analysis

Once the LLM gathers the necessary information, instruct it to present the SWOT analysis in a structured table format.

**Prompt:**
Based on the information we've discussed, please organize the SWOT analysis into a table with four columns: Strengths, Weaknesses, Opportunities, and Threats. Ensure each point is concise and clearly articulated.
*Generating structured data helps in better visualization and analysis.*

</div>
</div>


<div class="section" markdown="1">

## Exercise 2 – Strategic Business Planning with Advanced Prompts

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

**Expected Output:**

| Pros                                      | Cons                                    |
|-------------------------------------------|-----------------------------------------|
| Diversifies product offerings             | High initial investment costs          |
| Meets increasing demand for renewable tech| Potential market saturation             |
| Enhances brand reputation in sustainability| Requires new supply chain logistics     |

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

<div class="step" markdown="1">

### Step 7: Optional Challenge – Comparing GPT-4o vs. OpenAI o1 Reasoning Models
Enhance your understanding of different LLM reasoning capabilities by comparing GPT-4o with the newer OpenAI o1 model.

Instructions:

Task Definition:

Select a complex problem relevant to your startup, such as optimizing the energy distribution network or developing a new sustainable product.
Prompt Both Models:

Use identical prompts to both GPT-4o and o1 models to solve the selected problem.
Analyze Responses:

Evaluate the depth, accuracy, and coherence of the solutions provided by each model.
Note how each model handles multi-step reasoning and complex decision-making.
Report Findings:

Summarize the strengths and weaknesses of each model based on your analysis.
Provide recommendations on which model to use for specific types of tasks within your startup.

Example Prompt for Both Models:
Develop a comprehensive plan to integrate renewable energy sources into our existing energy distribution network. Consider factors like cost, scalability, and environmental impact. Let's think step-by-step.

This challenge will help you understand the practical applications and optimal use cases for different LLM reasoning models.

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

Additional Resources
To further enhance your knowledge and skills in prompt engineering and AI language models, explore the following resources:

Prompting Guide: A comprehensive guide to prompting techniques for AI language models.
OpenAI Prompt Engineering: A guide to prompt engineering by the GPT-4 creators.
Prompt Engineering Techniques: Tips and tricks for prompting with Azure OpenAI Service.
Mermaid.js Documentation: Learn how to create diagrams and visualizations using Mermaid.js.
Chain-of-Thought Prompting: Research paper on chain-of-thought reasoning in LLMs.
ReAct: Synergizing Reasoning and Acting in Language Models: Explore the ReAct framework for integrating reasoning and actions in LLMs.
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