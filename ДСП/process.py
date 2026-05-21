import subprocess
import os

def process_file(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    prompt = f"""You are a strict text-formatting assistant. Your task is to apply specific formatting to the provided markdown file. 

Instructions:
1. In the section `## 2. Полный ответ`, break down the paragraphs into logical blocks using subheadings like `### 2.1. [Logical Topic Name]`, `### 2.2. [Another Topic]`, etc. You must analyze the text to infer the topic names.
2. In the section `## 4. Основные теоремы и свойства`, convert bolded text that acts as a header (e.g., `**Свойство 1. Название.**` or `**Теорема.**`) into markdown subheadings (e.g., `### 4.1. Свойство 1. Название`, `### 4.2. Теорема.`).
3. In the section `## 5. Примеры`, convert bolded text that acts as a header (e.g., `**Пример 1. Название.**`) into markdown subheadings (e.g., `### 5.1. Пример 1. Название.`).
4. **CRITICAL:** DO NOT shorten, delete, or rewrite ANY of the actual text, formulas ($...$), or proofs. You are ONLY allowed to add or replace the header markup. The final document MUST contain 100% of the original content.
5. Return the full modified markdown file content. Do NOT wrap your output in ```markdown ... ``` tags. ONLY return the final raw text.

File content to process:
{content}
"""

    result = subprocess.run(['gemini', '-p', prompt, '--raw-output'], capture_output=True, text=True)
    if result.returncode == 0:
        output = result.stdout
        if output.startswith("```markdown\n"):
            output = output[12:]
        if output.endswith("```\n"):
            output = output[:-4]
        if output.endswith("```"):
            output = output[:-3]
        return output, result.stderr
    else:
        return None, result.stderr

output, stderr = process_file('notes/tickets/01.md')
with open('test_out.md', 'w', encoding='utf-8') as f:
    f.write(output if output else "ERROR")
print("Done. Stderr:", stderr)
