---
name: export-session-plan
description: Export the current conversation to Markdown and HTML files with implementation plan
disable-model-invocation: true
allowed-tools: Write, Bash, Read
argument-hint: [session-name]
---

# Export Session to Markdown and HTML

Export this conversation with Claude-generated summary and implementation plan.

## Output Paths

Base path from arguments: `$ARGUMENTS`

### Default Location (no arguments provided)

1. Check if `exports/` directory exists in the current repo
2. If yes: use `exports/sessions/<timestamp>/`
3. If no: use `exports/sessions/<timestamp>/` (create it)

Timestamp format: `YYYY-MM-DD-HHMM` (e.g., `2024-01-29-1430`)

### With Arguments

If the user provides a name, append it to the timestamp:
- `/export-session-plan auth-refactor` → `exports/sessions/2024-01-29-1430-auth-refactor/`
- `/export-session-plan ./custom/path` → `./custom/path/` (absolute paths bypass the default location logic)

### Files Created

Within the session directory:
- `session.json` - Raw session data (intermediate)
- `session.html` - Interactive transcript view
- `session.md` - Claude-generated summary (problem/solution/gotchas)
- `PLAN.md` - The implementation plan from the session

Plus in exports/:
- `CHANGELOG.md` - Timeline of when plans were created

Example structure:
```
exports/
├── sessions/
│   ├── 2025-01-30-1145/
│   │   ├── session.json      # Raw session data
│   │   ├── session.html      # Interactive transcript view
│   │   ├── session.md        # Claude-generated summary
│   │   └── PLAN.md           # Implementation plan
│   └── 2025-01-30-1430-auth-refactor/
│       ├── session.json
│       ├── session.html
│       ├── session.md
│       └── PLAN.md
└── CHANGELOG.md              # Timeline of plans
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

## Step 4: Write PLAN.md (Implementation Plan)

If the session involved planning or discussing an implementation approach, write `PLAN.md` with the plan that was discussed.

If no plan was discussed (e.g., just a bug fix or Q&A session), write a minimal PLAN.md:

```markdown
# Plan

No formal implementation plan was discussed in this session.

See `session.md` for a summary of what was accomplished.
```

## Step 5: Generate HTML

Run the export script to generate the HTML transcript:

```bash
python3 ~/.claude/skills/export-session-plan/export.py "{session_dir}/session.json" "{session_dir}/session"
```

This generates `session.html` from the JSON.

## Step 6: Update CHANGELOG.md

Update `exports/CHANGELOG.md` with a new entry (newest first).

**If CHANGELOG.md doesn't exist**, create it with:

```markdown
# Session Changelog

Timeline of exported sessions and plans.

---

## YYYY-MM-DD - [Brief description]
**Session:** [YYYY-MM-DD-HHMM-session-name](sessions/YYYY-MM-DD-HHMM-session-name/)
```

**If CHANGELOG.md exists**, prepend a new entry after the header (after the `---` line):

```markdown
## YYYY-MM-DD - [Brief description]
**Session:** [YYYY-MM-DD-HHMM-session-name](sessions/YYYY-MM-DD-HHMM-session-name/)

```

The brief description should be 3-5 words summarizing the session's purpose.

## Step 7: Sync to iCloud (Optional)

If iCloud Drive is available, sync exports for private backup. Auto-detects repo name:

```bash
REPO_NAME=$(basename "$(pwd)")
ICLOUD_DIR="$HOME/Library/Mobile Documents/com~apple~CloudDocs/code-exports/$REPO_NAME"
mkdir -p "$ICLOUD_DIR"
rsync -av --delete ./exports/ "$ICLOUD_DIR/exports/"
```

This syncs `exports/` to `~/Library/Mobile Documents/com~apple~CloudDocs/code-exports/<repo-name>/exports/`.

Skip this step if iCloud Drive is not available (non-macOS or iCloud not configured).

## Step 8: Report Results

Tell the user:
- Paths to all created files
- Number of messages exported
- Any warnings (truncated content, redacted secrets, incomplete recall)
- Confirmation that files were synced to iCloud

## Example Workflow

```bash
# User runs: /export-session-plan auth-refactor

# 1. Determine output directory
TIMESTAMP=$(date '+%Y-%m-%d-%H%M')  # e.g., 2024-01-29-1430
SESSION_DIR="exports/sessions/${TIMESTAMP}-auth-refactor"
mkdir -p "$SESSION_DIR"

# 2. Write JSON
Write "${SESSION_DIR}/session.json" with reconstructed conversation

# 3. Write session.md (Claude generates this directly)
Write "${SESSION_DIR}/session.md" with problem/solution/gotchas summary

# 4. Write PLAN.md
Write "${SESSION_DIR}/PLAN.md" with implementation plan

# 5. Run export script (HTML only)
python3 ~/.claude/skills/export-session-plan/export.py "${SESSION_DIR}/session.json" "${SESSION_DIR}/session"

# 6. Update changelog
# Read exports/CHANGELOG.md, prepend new entry, write back

# 7. Sync to iCloud (if available)
REPO_NAME=$(basename "$(pwd)")
ICLOUD_DIR="$HOME/Library/Mobile Documents/com~apple~CloudDocs/code-exports/$REPO_NAME"
mkdir -p "$ICLOUD_DIR" && rsync -av --delete ./exports/ "$ICLOUD_DIR/exports/"

# 8. Report
Created:
- exports/sessions/2024-01-29-1430-auth-refactor/session.json (raw data)
- exports/sessions/2024-01-29-1430-auth-refactor/session.html (interactive transcript)
- exports/sessions/2024-01-29-1430-auth-refactor/session.md (summary)
- exports/sessions/2024-01-29-1430-auth-refactor/PLAN.md (implementation plan)
- exports/CHANGELOG.md (updated)
```

## Important Notes

- Reconstruct the ENTIRE conversation from the beginning
- Include ALL messages and tool uses in session.json
- Write session.md yourself - do NOT run Python for markdown generation
- If conversation is very long and early parts are unclear, note this in metadata
- The HTML file is self-contained and works offline (file:// protocol)
