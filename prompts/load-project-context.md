# Load Project Context

## Purpose
This prompt helps Claude automatically load and understand the current project context from project-context.md and project-detection.json files.

## Instructions for Claude

When this prompt is invoked, please:

1. **Read the project-context.md file** from the .claude directory to understand:
   - Project overview and purpose
   - Technology stack and architecture
   - Coding conventions and standards
   - Key dependencies and frameworks
   - Team practices and workflows

2. **Read the project-detection.json file** (if available) to get:
   - Automatically detected technologies
   - File structure analysis
   - Git repository information
   - Project metadata

3. **Summarize the key information** that will help you work effectively:
   - Primary technologies and frameworks
   - Coding standards to follow
   - Architecture patterns in use
   - Important project-specific considerations

4. **Acknowledge your understanding** with a brief summary like:
   ```
   ✅ Project context loaded successfully!
   
   📊 Project: [Name]
   🛠️ Tech Stack: [Primary technologies]
   📋 Standards: [Key conventions]
   🏗️ Architecture: [Main patterns]
   
   I'm now ready to help with context-aware assistance.
   ```

## Usage
Run this prompt at the beginning of a session or when you need Claude to refresh its understanding of the project.

## Example
```
/load-project-context
```

This will help Claude provide more accurate, context-aware assistance tailored to your specific project.