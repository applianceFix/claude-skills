# `/update-plan` - Plan Update Manager

A Claude Code skill for creating timestamped update directories when plans evolve, preserving both the updated plan and the session conversation that led to the update.

## Problem

When a plan is updated after initial creation, the original session artifacts (session.html, session.json) become stale - they capture the original planning conversation, not the update discussion. This makes it hard to:

- Trace how and why the plan evolved
- Debug "which version did we implement?"
- Learn from the decision-making process
- Understand what triggered the change

## Solution

The `/update-plan` skill creates a new timestamped directory containing:
- Updated plan generated from the current conversation
- Current session artifacts (the update conversation)
- Rationale document explaining what changed and why
- Clear lineage to the original plan

## How It Works

1. You discuss improvements to an existing plan with Claude
2. Through the conversation, you refine and evolve the plan
3. You run `/update-plan` pointing to the original plan directory
4. The skill generates the updated plan based on your conversation
5. Everything is saved: new plan, session transcript, and rationale

## Installation

```bash
cd update-plan
./install.sh
```

## Usage

### Basic Usage

```bash
/update-plan exports/sessions/2026-02-03-1647-network-handling
```

### With Rationale

```bash
/update-plan exports/sessions/2026-02-03-1647-network-handling \
  --rationale "Shifted from complex guards to communication-first approach"
```

## Parameters

### Required
- `original_dir` - Path to original plan directory

### Optional
- `--rationale` - Why this update was needed (auto-extracted if not provided)
- `--plan-file` - Custom plan filename to read from original directory (default: PLAN.md)

## What Gets Created

### Original Plan Directory
```
exports/sessions/2026-02-03-1647-network-handling/
├── PLAN.md                    # Original plan
├── session.html               # Original planning session
├── session.json
└── SUPERSEDED.md              # Points to latest update
```

### New Update Directory
```
exports/sessions/2026-02-04-1523-network-handling-update/
├── PLAN.md                    # Updated approach
├── session.html               # Update conversation
├── session.json
└── UPDATE_RATIONALE.md        # What changed & why
```

## Directory Naming

Format: `{YYYY-MM-DD-HHMM}-{topic}-update/`

The `-update` suffix is always used to clearly distinguish plan updates from new plans.

Examples:
- `2026-02-04-1523-network-handling-update/`
- `2026-02-05-0900-network-handling-update/` (different timestamp)
- `2026-02-04-1523-network-handling-update-v2/` (collision handling)

## Files Generated

### UPDATE_RATIONALE.md
Documents what changed, why, key insights, and impact of the update.

### SUPERSEDED.md
Added to the original plan directory, pointing to the latest update with reason and date.

## Workflow Integration

```
/plan → /export-session-plan → [discussion with Claude] → /update-plan → /implement
            ↓                                                      ↑
    Original plan created                          Updated plan generated from conversation
```

Works with:
- `/export-session-plan` - Creates initial plan from session
- `/update-plan` - Creates updated plan from refinement conversation
- `/implement` - Executes approved plan
- `/plan` - Enters planning mode

## Examples

### First Update
```bash
/update-plan exports/sessions/2026-02-03-1647-network-handling
```

Creates:
- `exports/sessions/2026-02-04-1523-network-handling-update/`
- Marks original as superseded

### Second Update (Chaining)
```bash
/update-plan exports/sessions/2026-02-04-1523-network-handling-update
```

Creates:
- `exports/sessions/2026-02-05-0900-network-handling-update/`
- Updates chain of superseded markers

## Edge Cases Handled

1. **Multiple updates** - Each gets new timestamped directory
2. **Missing plan file** - Error with prompt to specify manually
3. **Directory collision** - Appends `-v2`, `-v3`, etc.
4. **Session export fails** - Creates directory anyway, notes in rationale
5. **Relative paths** - All links use relative paths for portability

## Success Criteria

✅ New directory created with `-update` suffix and timestamp
✅ Updated plan copied to new directory
✅ Session artifacts (HTML + JSON) saved
✅ UPDATE_RATIONALE.md generated
✅ SUPERSEDED.md created in original directory
✅ All paths are relative (portable)
✅ Clear console output showing what was created

## Related Skills

- `/export-session` - Export current session
- `/export-session-plan` - Export session with plan
- `/implement` - Execute a plan from feature branch
