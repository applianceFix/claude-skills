---
name: export-session
description: Export the current conversation to Markdown and HTML files for sharing or archiving
---

# Export Session to Markdown and HTML

Export this conversation with Claude-generated summary.

## Output Paths

All sessions are saved to: `exports/sessions/YYYY-MM-DD-HHMM-<session-name>/`

## Usage

```bash
/export-session --name <session-name> [--plan <plan-file-path>]
```

**Flags:**
- `--name` (required): Session name for the export
- `--plan` (optional): Path to plan file to include (e.g., `plans/compressed-roaming-volcano.md`)

**Examples:**
```bash
# Export session without plan
/export-session --name network-handling

# Export session with plan file
/export-session --name network-handling --plan plans/compressed-roaming-volcano.md

# Flags can be in any order
/export-session --plan plans/my-plan.md --name auth-refactor
```

**Output:** `exports/sessions/2024-01-29-1430-network-handling/`

Timestamp format: `YYYY-MM-DD-HHMM` (e.g., `2024-01-29-1430`)

### Files Created

Within the session directory:
- `session.json` - Raw session data (intermediate)
- `session.html` - Interactive transcript view
- `session.md` - Claude-generated summary (problem/solution/gotchas)
- `plan.md` - Implementation plan (optional, if `--plan` flag provided)
- `VISUAL-FLOW.md` - Visual diagrams (optional, for state machines/flows)

Example structure:
```
exports/
└── sessions/
    ├── 2025-01-30-1145-network-handling/
    │   ├── session.json      # Raw session data
    │   ├── session.html      # Interactive transcript view
    │   ├── session.md        # Claude-generated summary
    │   └── plan.md           # Implementation plan (if --plan provided)
    └── 2025-01-30-1430-auth-refactor/
        ├── session.json
        ├── session.html
        ├── session.md
        └── VISUAL-FLOW.md    # Visual flow diagrams (optional)
```

## Step 1: Parse Arguments and Determine Output Directory

Parse flags from `$ARGUMENTS`:

```bash
# Parse flags from arguments
SESSION_NAME=""
PLAN_FILE=""

# Split arguments into array
IFS=' ' read -ra ARGS <<< "$ARGUMENTS"

# Parse flags
i=0
while [ $i -lt ${#ARGS[@]} ]; do
  case "${ARGS[$i]}" in
    --name)
      SESSION_NAME="${ARGS[$((i+1))]}"
      i=$((i+2))
      ;;
    --plan)
      PLAN_FILE="${ARGS[$((i+1))]}"
      i=$((i+2))
      ;;
    *)
      echo "Unknown flag: ${ARGS[$i]}"
      exit 1
      ;;
  esac
done

# Validate required arguments
if [ -z "$SESSION_NAME" ]; then
  echo "Error: --name is required"
  exit 1
fi

# Check for exports directory, create if needed
mkdir -p exports/sessions

# Generate timestamp in YYYY-MM-DD-HHMM format
TIMESTAMP=$(date '+%Y-%m-%d-%H%M')

# Build session directory name: TIMESTAMP-SESSION_NAME
SESSION_DIR="exports/sessions/${TIMESTAMP}-${SESSION_NAME}"
mkdir -p "$SESSION_DIR"
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

## Step 5: Generate VISUAL-FLOW.md (Optional)

Determine if visual documentation would enhance understanding:

**Ask yourself:**
"Does this session involve state machines, complex flows, before/after
architectural changes, or benefit from visual diagrams?"

**Create VISUAL-FLOW.md if the session includes:**
- ✅ State machines with multiple states and transitions
- ✅ Complex multi-step workflows with branching logic
- ✅ Before/after architectural comparisons
- ✅ Timeline-based scenarios (e.g., "at 5s do X, at 10s do Y")
- ✅ Network/API flow diagrams
- ✅ UI state transitions

**Skip VISUAL-FLOW.md for:**
- ❌ Simple bug fixes
- ❌ Configuration changes
- ❌ Straightforward feature additions without complex logic
- ❌ General discussions or Q&A sessions

**If creating VISUAL-FLOW.md, include:**

```markdown
# [Session Name]: Visual Flow Documentation

## Before vs After

[Show the problem state vs solution state with clear comparison]

Example:
```
### BEFORE (Problem)
[ASCII diagram or structured explanation of old behavior]

### AFTER (Solution)
[ASCII diagram or structured explanation of new behavior]
```

## State Machine Flow

[Diagram showing all states and transitions]

Example:
```
                    ┌─────────┐
                    │  IDLE   │
                    └────┬────┘
                         │ event
                         ↓
                  ┌──────────────┐
                  │   STATE_A    │
                  └──────┬───────┘
                         │
        ┌────────────────┴────────────────┐
        ↓                                  ↓
┌─────────────────┐            ┌─────────────────┐
│    STATE_B      │            │    STATE_C      │
└─────────────────┘            └─────────────────┘
```

## Timeline Examples

[Walk through specific scenarios with time-based progression]

Example:
```
### Scenario 1: Network Timeout

Time    State       Description
────────────────────────────────────────────────────
0s      Loading     User clicks button
5s      Slow        Request taking longer than expected
10s     Diagnostic  Timeout occurred, checking network
20s     Error       NetInfo confirms offline
```

## Key Transitions

[Explain critical state changes and why they happen]
```

Write to: `{session_dir}/VISUAL-FLOW.md`

## Step 5.5: Include Plan File (Optional)

If the `--plan` flag was provided, copy the plan file to the session directory.

```bash
# Check if plan file was specified and exists
if [ -n "$PLAN_FILE" ]; then
  if [ -f "$PLAN_FILE" ]; then
    cp "$PLAN_FILE" "${SESSION_DIR}/plan.md"
    echo "Included plan file: $PLAN_FILE"
  else
    echo "Warning: Plan file not found: $PLAN_FILE"
  fi
fi
```

**Important:**
- Plan file is copied as `plan.md` (standardized name)
- Original plan file path can be anywhere (e.g., `plans/compressed-roaming-volcano.md`)
- If plan file doesn't exist, show warning but continue with export

## Step 6: Update CHANGELOG.md

After creating the session files, update the main CHANGELOG.md in the exports directory.

**Location**: `exports/CHANGELOG.md` (parent directory of sessions/)

**Process**:

1. Read the existing `exports/CHANGELOG.md`
2. Extract the session name from the session directory path
   - If directory is `exports/sessions/2026-02-06-1430-network-error-handling/`
   - Extract the full name: `2026-02-06-1430-network-error-handling`
3. Extract brief description from the just-created `session.md` Solution section (1-2 sentences max)
4. Format a new changelog entry:

```markdown
## {session-dir-name}
**Session:** [sessions/{session-dir-name}/](sessions/{session-dir-name}/)

[Brief description from session.md Solution section]
```

5. Insert the new entry at the top of the changelog, right after the initial header section (after the "---" separator that follows the intro text)
6. Preserve all existing entries below

**Example**:

If session directory is `2026-02-06-1430-network-error-handling/` and `session.md` contains:
```markdown
# Session Summary: Network Error Handling

## Problem
API calls were failing silently without user feedback.

## Solution
Added comprehensive error handling with user-friendly messages and retry logic.
```

Add to CHANGELOG.md:
```markdown
## 2026-02-06-1430-network-error-handling
**Session:** [sessions/2026-02-06-1430-network-error-handling/](sessions/2026-02-06-1430-network-error-handling/)

Added comprehensive error handling with user-friendly messages and retry logic.

---
[...existing entries below...]
```

**Important**:
- Use the exact session directory name as the heading (makes it easy to map changelog → session)
- Keep description concise (extract from Solution section of session.md)
- Relative path to session should work from CHANGELOG.md location
- Maintain reverse chronological order (newest first)
- Preserve the `---` separator between entries

## Step 7: Report Results

Tell the user:
- Paths to all created files (session.json, session.html, session.md, plan.md if included, VISUAL-FLOW.md if created)
- Confirmation that CHANGELOG.md was updated with the new entry
- Number of messages exported
- Any warnings (truncated content, redacted secrets, incomplete recall)

## Example Workflow

### Example 1: Planning Session with Plan File

```bash
# User runs: /export-session --name new-feature --plan plans/compressed-roaming-volcano.md

# 1. Parse arguments
SESSION_NAME="new-feature"
PLAN_FILE="plans/compressed-roaming-volcano.md"

# 2. Determine output directory
TIMESTAMP=$(date '+%Y-%m-%d-%H%M')  # e.g., 2024-01-29-1430
SESSION_DIR="exports/sessions/${TIMESTAMP}-auth-refactor"
mkdir -p "$SESSION_DIR"

# 3. Write JSON
Write "${SESSION_DIR}/session.json" with reconstructed conversation

# 4. Write session.md (Claude generates this directly)
Write "${SESSION_DIR}/session.md" with problem/solution/gotchas summary

# 5. Run export script (HTML only)
python3 ~/.claude/skills/export-session/export.py "${SESSION_DIR}/session.json" "${SESSION_DIR}/session"

# 5.5. Copy plan file
cp "plans/compressed-roaming-volcano.md" "${SESSION_DIR}/plan.md"

# 6. Generate VISUAL-FLOW.md if needed (optional)
# If session involves state machines or complex flows
Write "${SESSION_DIR}/VISUAL-FLOW.md" with visual diagrams

# 7. Update CHANGELOG.md
Read "exports/CHANGELOG.md"
Extract session directory name and solution from session.md
Insert new entry at top:
## 2024-01-29-1430-auth-refactor
**Session:** [sessions/2024-01-29-1430-auth-refactor/](sessions/2024-01-29-1430-auth-refactor/)

[Brief description from session.md Solution section]

---

# 8. Report
Created:
- exports/sessions/2024-01-29-1430-auth-refactor/session.json (raw data)
- exports/sessions/2024-01-29-1430-auth-refactor/session.html (interactive transcript)
- exports/sessions/2024-01-29-1430-auth-refactor/session.md (summary)
- exports/sessions/2024-01-29-1430-auth-refactor/plan.md (implementation plan)
- exports/sessions/2024-01-29-1430-auth-refactor/VISUAL-FLOW.md (if complex flows)
Updated:
- exports/CHANGELOG.md (added new entry at top)
```

### Example 2: Implementation Session (No Plan Duplication)

```bash
# User runs: /export-session --name new-feature-implementation
# This is a NEW session implementing the plan from Example 1

# 1. Parse arguments
SESSION_NAME="new-feature-implementation"
PLAN_FILE=""  # No --plan flag provided

# 2. Determine output directory
TIMESTAMP=$(date '+%Y-%m-%d-%H%M')  # e.g., 2024-01-30-0900
SESSION_DIR="exports/sessions/${TIMESTAMP}-new-feature-implementation"
mkdir -p "$SESSION_DIR"

# 3-5. Write JSON, session.md, generate HTML (same as Example 1)

# 5.5. Copy plan file - SKIPPED (no PLAN_FILE specified)

# 6-8. Generate VISUAL-FLOW (optional), update CHANGELOG, report

# Result:
# - exports/sessions/2024-01-30-0900-new-feature-implementation/
#   - session.json, session.html, session.md
#   - No plan.md (linked to planning session by naming convention)
```

**Note:** The `-implementation` suffix makes it clear this session implements the plan from the `new-feature` planning session.

### Example 3: Regular Session without Plan

```bash
# User runs: /export-session --name bug-fix-photo-upload

# Same as Example 1, but skips step 5.5 (no plan file to copy)
# Report will not mention plan.md
```

## Important Notes

### Usage Requirements
- **Must exit plan mode first** - This skill requires execution mode (cannot run in plan mode)
- **Session name is required** - Use `--name` flag to specify session name
- **Plan file is optional** - Use `--plan` flag to include a plan file (e.g., from `plans/` directory)

### Session Export
- Reconstruct the ENTIRE conversation from the beginning
- Include ALL messages and tool uses in session.json
- Write session.md yourself - do NOT run Python for markdown generation
- Create VISUAL-FLOW.md when the session involves complex state machines, workflows, or would benefit from visual diagrams

### Plan File Handling
- If `--plan` flag provided, the plan file will be copied to `plan.md` in the session directory
- Plan files are typically from plan mode (e.g., `plans/compressed-roaming-volcano.md`)
- If plan file doesn't exist, a warning is shown but export continues

### Multi-Session Naming Convention
- Use naming convention to link planning and implementation sessions:
  - Planning: `feature-name` (includes --plan flag)
  - Implementation: `feature-name-implementation` (no --plan flag needed)
- The `-implementation` suffix makes the relationship clear without duplicating plan.md

### CHANGELOG
- Always update CHANGELOG.md with a new entry after creating the session files
- Use full timestamp (YYYY-MM-DD-HHMM) in CHANGELOG entries to match session directory names

### Technical Details
- If conversation is very long and early parts are unclear, note this in metadata
- The HTML file is self-contained and works offline (file:// protocol)
