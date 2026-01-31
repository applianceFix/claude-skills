---
name: implement
description: Execute a plan file, creating a feature branch and tracking implementation results
allowed-tools: Read, Write, Edit, Bash, Glob, Grep, Task
argument-hint: <path-to-PLAN.md>
---

# Implement Plan

Execute a previously created plan, tracking progress and documenting results.

## Arguments

- `$ARGUMENTS` - Path to the PLAN.md file to implement

## Prerequisites

- A PLAN.md file must exist at the specified path
- The current directory must be a git repository

## Output Files

Within the implementation directory:
- `session.json` - Raw session data (intermediate)
- `session.html` - Interactive transcript view
- `RESULTS.md` - Implementation summary with completed steps

Example structure:
```
exports/sessions/
└── 2025-01-30-improved-workflow-stages-implementation/
    ├── session.json
    ├── session.html
    └── RESULTS.md
```

## Workflow

### Step 1: Validate Arguments and Read Plan

```
# Validate that a plan path was provided
if $ARGUMENTS is empty:
  Error: "Usage: /implement <path-to-PLAN.md>"

# Read the plan file
Read the file at $ARGUMENTS
```

If the file doesn't exist or can't be read, report an error and stop.

### Step 2: Extract Project Name

Parse the plan file to extract the project name from its title:

1. Look for the first `# ` heading in the file (e.g., `# Plan: Improved Workflow Stages`)
2. The heading **must** contain "Plan:" prefix. If not found:
   ```
   Error: "Cannot find project name in the plan.md file"
   ```
   Exit the skill immediately.
3. Extract the title after "Plan:"
4. Convert to kebab-case for use in directory/branch names:
   - "Improved Workflow Stages Implementation" → "improved-workflow-stages"
   - "Add User Authentication" → "add-user-authentication"
   - Remove "Implementation" suffix if present (we'll add it back for the directory)

Store both:
- `PROJECT_NAME` (kebab-case, e.g., "improved-workflow-stages")
- `PROJECT_TITLE` (original title for documentation)

### Step 3: Create Implementation Directory

Create the implementation tracking directory:

```bash
# Get today's date
DATE=$(date +%Y-%m-%d)

# Create the implementation directory
mkdir -p exports/sessions/${DATE}-${PROJECT_NAME}-implementation
```

### Step 4: Create and Switch to Feature Branch

```bash
# Create feature branch from current branch
git checkout -b feature/${PROJECT_NAME}
```

If the branch already exists:
```
Error: "branch name: feature/${PROJECT_NAME} already exists"
```
Exit the skill immediately.

Report which branch you're now on.

### Step 5: Execute the Plan

Now execute the implementation steps defined in the plan file:

1. Read through each step in the plan
2. Execute each step methodically
3. Track what actions you take for the RESULTS.md

**Important guidelines:**
- Follow the plan's steps in order
- If a step is unclear, stop and ask the user for clarification before proceeding
- If a step cannot be completed, stop and flag the issue to the user; wait for user direction before proceeding
- Track all file changes, commands run, and decisions made

### Step 6: Write session.json

Create a JSON file with the session data:

```json
{
  "metadata": {
    "exportedAt": "[current date/time]",
    "workingDirectory": "[current working directory]",
    "planFile": "[path to original plan file]",
    "projectName": "[PROJECT_NAME]"
  },
  "messages": [
    {
      "role": "user",
      "content": "User's message text"
    },
    {
      "role": "assistant",
      "content": "Simple text response"
    },
    {
      "role": "assistant",
      "content": [
        {"type": "text", "text": "Response with tool uses"},
        {
          "type": "tool_use",
          "name": "ToolName",
          "input": {"param": "value"},
          "output": "Tool output text"
        }
      ]
    }
  ]
}
```

### Content Rules

- **User messages**: Always a string
- **Assistant messages**: String for text-only, array for responses with tool uses
- **Tool uses**: Include name, input parameters, and output
- **Large outputs**: Truncate to ~2000 chars with `[... truncated]`
- **Sensitive data**: Replace API keys/passwords with `[REDACTED]`

Write to: `exports/sessions/${DATE}-${PROJECT_NAME}-implementation/session.json`

### Step 7: Generate session.html

Run the export script to generate the HTML transcript:

```bash
python3 ~/.claude/skills/export-session/export.py "{session_dir}/session.json" "{session_dir}/session"
```

This generates `session.html` from the JSON using the shared template.

### Step 8: Create RESULTS.md

After execution is complete, create `RESULTS.md` in the implementation directory:

```markdown
# Plan: [PROJECT_TITLE]

This session implemented the plan defined in `[original plan path]`.

## Summary

[Brief 1-2 sentence summary of what was accomplished]

## Implementation Steps Completed

### Step 1: [Step name from plan] [✅ or ❌]
- [Bulleted list of specific actions taken]
- [Files modified/created]
- [Key decisions made]

### Step 2: [Step name from plan] [✅ or ❌]
- [Bulleted list of specific actions taken]
...

## Verification Checklist

- [ ] [Item 1 to verify the implementation works]
- [ ] [Item 2 to verify]
- [ ] [Item 3 to verify]
...

## Branch

`feature/[PROJECT_NAME]`
```

Write this file to: `exports/sessions/${DATE}-${PROJECT_NAME}-implementation/RESULTS.md`

### Step 9: Report Completion

Tell the user:
- Path to all created files (session.json, session.html, RESULTS.md)
- Branch name created/used
- Summary of steps completed vs. any that failed
- Next steps (e.g., "Run verification checklist items, then create PR")

## Example

```bash
# User runs:
/implement exports/sessions/2025-01-30-improved-workflow-stages/PLAN.md

# Claude:
# 1. Reads the plan
# 2. Extracts "improved-workflow-stages" from title
# 3. Creates exports/sessions/2025-01-30-improved-workflow-stages-implementation/
# 4. Creates/switches to feature/improved-workflow-stages branch
# 5. Executes each step in the plan
# 6. Writes session.json with full conversation
# 7. Generates session.html via export.py
# 8. Creates RESULTS.md documenting what was done
# 9. Reports completion

# Output:
Created:
- exports/sessions/2025-01-30-improved-workflow-stages-implementation/session.json
- exports/sessions/2025-01-30-improved-workflow-stages-implementation/session.html
- exports/sessions/2025-01-30-improved-workflow-stages-implementation/RESULTS.md

Branch: feature/improved-workflow-stages
```

## Notes

- If implementation encounters errors, document them in RESULTS.md and stop the skill immediately so the user can resolve them
- The RESULTS.md should be detailed enough that someone can understand exactly what changed
- Use ✅ for completed steps and ❌ for steps that couldn't be completed
- Include any gotchas or issues discovered during implementation
- Reconstruct the ENTIRE conversation from the beginning for session.json
- The HTML file is self-contained and works offline (file:// protocol)
