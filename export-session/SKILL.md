---
name: export-session
description: Export the current conversation to Markdown and HTML files for sharing or archiving
disable-model-invocation: true
allowed-tools: Write, Bash, Read
argument-hint: [session-name]
---

# Export Session to Markdown and HTML

Export this conversation with Claude-generated summary.

## Output Paths

Base path from arguments: `$ARGUMENTS`

### Default Location (no arguments provided)

1. Check if `exports/` directory exists in the current repo
2. If yes: use `exports/sessions/<timestamp>/`
3. If no: use `exports/sessions/<timestamp>/` (create it)

Timestamp format: `YYYY-MM-DD-HHMM` (e.g., `2024-01-29-1430`)

### With Arguments

If the user provides a name, append it to the timestamp:
- `/export-session auth-refactor` → `exports/sessions/2024-01-29-1430-auth-refactor/`
- `/export-session ./custom/path` → `./custom/path/` (absolute paths bypass the default location logic)

### Files Created

Within the session directory:
- `session.json` - Raw session data (intermediate)
- `session.html` - Interactive transcript view
- `session.md` - Claude-generated summary (problem/solution/gotchas)

Example structure:
```
exports/
└── sessions/
    ├── 2025-01-30-1145/
    │   ├── session.json      # Raw session data
    │   ├── session.html      # Interactive transcript view
    │   └── session.md        # Claude-generated summary
    └── 2025-01-30-1430-auth-refactor/
        ├── session.json
        ├── session.html
        └── session.md
```

## Step 1: Determine Output Directory

```bash
# Check for exports directory, create if needed
mkdir -p exports/sessions

# Generate timestamp in YYYY-MM-DD-HHMM format
TIMESTAMP=$(date '+%Y-%m-%d-%H%M')

# Determine session name
# If $ARGUMENTS is a path starting with . or /: use that path directly
# If $ARGUMENTS is empty: use exports/sessions/$TIMESTAMP
# Otherwise: use exports/sessions/$TIMESTAMP-$ARGUMENTS
```

## Step 2: Write session.json

Create a JSON file with this structure:

```json
{
  "metadata": {
    "exportedAt": "[current date/time]",
    "workingDirectory": "[current working directory]"
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
        },
        {"type": "text", "text": "More response text"}
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

## Step 3: Write session.md (Claude-Generated Summary)

Claude writes `session.md` directly (do NOT run Python for this). Use this structure:

```markdown
# Session Summary: [Session Name]

**Date:** YYYY-MM-DD
**Working Directory:** /path/to/project

## Problem

[What issue was being solved? What was broken or missing?]

## Solution

[How was it solved? Key decisions made during the session.]

## Gotchas

[Potential issues identified, edge cases to watch for, things learned during exploration. If none, write "None identified."]

## Key Files

- `path/to/file1.ts` - Brief description of changes or relevance
- `path/to/file2.ts` - Brief description of changes or relevance
```

Write this summary based on the actual conversation content, reflecting what was discussed and decided.

## Step 4: Generate HTML

Run the export script to generate the HTML transcript:

```bash
python3 ~/.claude/skills/export-session/export.py "{session_dir}/session.json" "{session_dir}/session"
```

This generates `session.html` from the JSON.

## Step 5: Report Results

Tell the user:
- Paths to all created files
- Number of messages exported
- Any warnings (truncated content, redacted secrets, incomplete recall)

## Example Workflow

```bash
# User runs: /export-session auth-refactor

# 1. Determine output directory
TIMESTAMP=$(date '+%Y-%m-%d-%H%M')  # e.g., 2024-01-29-1430
SESSION_DIR="exports/sessions/${TIMESTAMP}-auth-refactor"
mkdir -p "$SESSION_DIR"

# 2. Write JSON
Write "${SESSION_DIR}/session.json" with reconstructed conversation

# 3. Write session.md (Claude generates this directly)
Write "${SESSION_DIR}/session.md" with problem/solution/gotchas summary

# 4. Run export script (HTML only)
python3 ~/.claude/skills/export-session/export.py "${SESSION_DIR}/session.json" "${SESSION_DIR}/session"

# 5. Report
Created:
- exports/sessions/2024-01-29-1430-auth-refactor/session.json (raw data)
- exports/sessions/2024-01-29-1430-auth-refactor/session.html (interactive transcript)
- exports/sessions/2024-01-29-1430-auth-refactor/session.md (summary)
```

## Important Notes

- Reconstruct the ENTIRE conversation from the beginning
- Include ALL messages and tool uses in session.json
- Write session.md yourself - do NOT run Python for markdown generation
- If conversation is very long and early parts are unclear, note this in metadata
- The HTML file is self-contained and works offline (file:// protocol)
