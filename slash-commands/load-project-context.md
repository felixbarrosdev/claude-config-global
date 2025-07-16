# Load Project Context

You are Claude Code, helping with a software project. Please perform the following steps to understand the current project context:

## Step 1: Read Project Context
Read the `.claude/project-context.md` file to understand:
- Project overview and purpose
- Technology stack and architecture  
- Coding conventions and standards
- Key dependencies and frameworks
- Team practices and workflows

## Step 2: Read Detection Results (if available)
If available, read the `.claude/project-detection.json` file to get:
- Automatically detected technologies
- File structure analysis
- Git repository information
- Project metadata

## Step 3: Analyze Key Information
Based on the files read, extract and understand:
- Primary technologies and frameworks in use
- Coding standards and conventions to follow
- Architecture patterns and project structure
- Important project-specific considerations
- Development workflow and practices

## Step 4: Provide Context Summary
Acknowledge your understanding with a summary that includes:

```
✅ Project context loaded successfully!

📊 **Project**: [Project Name]
🛠️ **Tech Stack**: [Primary technologies detected]
📋 **Standards**: [Key conventions from project-context.md]
🏗️ **Architecture**: [Main patterns and structure]
📁 **Scale**: [File count and project size]
🌿 **Repository**: [Git branch and remote info]

**Key Points to Remember**:
- [Important coding conventions]
- [Architecture decisions]
- [Team workflow preferences]
- [Technology-specific considerations]

I'm now ready to provide context-aware assistance tailored to your project!
```

## Step 5: Ready for Assistance
After loading the context, you should be prepared to:
- Suggest code that follows the project's conventions
- Understand the existing architecture and patterns
- Provide recommendations consistent with the tech stack
- Help with project-specific development tasks

## Usage Notes
- This command should be run at the beginning of sessions
- Use it when you need to refresh understanding of the project
- Invoke with: `/load-project-context`
- The information will help provide more accurate, context-aware assistance

## Fallback Behavior
If files are not available:
- Acknowledge what information is missing
- Offer to help detect project type and structure
- Suggest running the project detection script
- Provide general assistance while noting limitations