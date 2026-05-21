import os
import re
import subprocess
import concurrent.futures

def process_file(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    # 1. Process Section 4 and 5 with Regex
    # Find Section 4
    def repl_sec4(match):
        header_text = match.group(1).strip()
        # Remove trailing period if present
        if header_text.endswith('.'):
            header_text = header_text[:-1]
        return f"### {header_text}"
        
    # Replace **bold text** at the start of a line inside Sections 4 and 5 with ### headings
    # Actually, let's just make it simple: replace **...** at the beginning of a line with ### ...
    # but only in certain sections.
    
    parts = re.split(r'(## \d+\. .*)', content)
    
    new_parts = []
    current_section = ""
    for part in parts:
        if part.startswith('## '):
            current_section = part.strip()
            new_parts.append(part)
        else:
            if "Основные теоремы и свойства" in current_section or "Примеры" in current_section or "Дополнительные вопросы" in current_section:
                # Replace **Text** or **Text.** at the start of a line
                part = re.sub(r'^\*\*(.*?)\*\*(\s*)', repl_sec4, part, flags=re.MULTILINE)
            
            if "Полный ответ" in current_section:
                # Use Gemini CLI to inject headers
                prompt = f"""You are a strict markdown formatter. I will give you the text of a section.
Your task is to break the text into logical blocks by inserting Markdown subheadings (e.g. `### 2.1. Title`, `### 2.2. Title`).
DO NOT DELETE, MODIFY OR SHORTEN A SINGLE WORD OF THE ORIGINAL TEXT. DO NOT MODIFY EQUATIONS. ONLY INSERT `### 2.X. Title` HEADERS between paragraphs where appropriate.

Text to process:
{part}
"""
                # Write prompt to a temp file to avoid argument length limits
                prompt_file = filepath + ".prompt"
                with open(prompt_file, 'w', encoding='utf-8') as pf:
                    pf.write(prompt)
                
                # Execute gemini CLI non-interactively
                # cat prompt_file | gemini -p "" --raw-output
                cmd = f"cat '{prompt_file}' | gemini -p \"\" --raw-output"
                result = subprocess.run(cmd, shell=True, capture_output=True, text=True)
                
                if os.path.exists(prompt_file):
                    os.remove(prompt_file)
                
                if result.returncode == 0 and result.stdout.strip():
                    out = result.stdout.strip()
                    if out.startswith("```markdown"):
                        out = out[11:]
                    if out.endswith("```"):
                        out = out[:-3]
                    out = out.strip()
                    # Only replace if the length is somewhat similar, protecting against LLM truncation
                    if len(out) > len(part) * 0.8:
                        part = "\n\n" + out + "\n\n"
                    else:
                        print(f"Warning: LLM output too short for {filepath}, keeping original.")
                else:
                    print(f"Warning: LLM failed for {filepath}, keeping original. Error: {result.stderr}")

            new_parts.append(part)
            
    with open(filepath, 'w', encoding='utf-8') as f:
        f.write("".join(new_parts))
    print(f"Processed {filepath}")

# Let's process files
files = [f"notes/tickets/{str(i).zfill(2)}.md" for i in range(1, 25)]

with concurrent.futures.ThreadPoolExecutor(max_workers=5) as executor:
    executor.map(process_file, files)
