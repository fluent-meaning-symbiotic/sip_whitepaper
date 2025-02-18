ChatML Templates - to design LLM instructions.
https://github.com/openai/openai-python/blob/release-v0.28.0/chatml.md
Tool Name: calculator, Description: Multiply two integers., Arguments: a: int, b: int, Outputs: int

Tool creation:
https://platform.openai.com/docs/guides/function-calling
https://huggingface.co/learn/agents-course/unit1/tools

Semanitc Tool:
Tool Name: calculator, Description: Multiply two integers., Arguments: a: int, b: int, Outputs: int
LLM Inspects tools, not the code.
Tools of the file are written in intent.yaml
LLaMA 3.1 AP

# Agent:

## Thought:

## Action:

can write and execute a code instead of think - call tools per message

## Observation:

Collects Feedback: Receives data or confirmation that its action was successful (or not).
Appends Results: Integrates the new information into its existing context, effectively updating its memory.
Adapts its Strategy: Uses this updated context to refine subsequent thoughts and actions.
