# Export Session

A Claude Code skill that exports conversations with Claude-generated summaries.

## Features

- **Claude-generated summaries**: Problem/solution/gotchas format written by Claude
- **Timeline tracking**: CHANGELOG.md tracks when sessions were exported
- **Self-contained HTML**: Interactive transcript with sidebar navigation
- **Offline support**: HTML works with `file://` protocol
- **iCloud sync**: Automatic backup to iCloud Drive (macOS)

## Installation

Copy the skill files to your Claude Code skills directory:

```bash
mkdir -p ~/.claude/skills/export-session
cp SKILL.md export.py template.html ~/.claude/skills/export-session/
```

Or run:

```bash
./install.sh
```

## Usage

**Syntax:**
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

# Export session with plan file from plan mode
/export-session --name network-handling --plan plans/compressed-roaming-volcano.md

# Flags can be in any order
/export-session --plan plans/my-plan.md --name auth-refactor
```

**⚠️ Important: Must exit plan mode before running this skill**

This skill requires execution mode (cannot run while in plan mode). See [Workflows](#workflows) below.

## Workflows

### Workflow 1: Plan → Implement (Multi-Session)

This is the typical workflow for planning and implementing a feature across multiple sessions:

#### Session 1: Planning

1. **Enter plan mode** (manually or via a planning skill)
   - Claude creates a plan file in `plans/` directory
   - Plan file has auto-generated name (e.g., `compressed-roaming-volcano.md`)

2. **Work on your plan**
   - Claude writes implementation steps
   - Discusses architecture decisions
   - Plan gets saved to `plans/compressed-roaming-volcano.md`

3. **Exit plan mode** ⚠️ **REQUIRED STEP**
   - Approve the plan or manually exit
   - This switches from plan mode → execution mode

4. **Export the planning session**
   ```bash
   /export-session --name feature-planning --plan plans/compressed-roaming-volcano.md
   ```

5. **Result:**
   ```
   exports/sessions/2025-01-30-1430-feature-planning/
   ├── session.json
   ├── session.html
   ├── session.md     # Summary: "Created implementation plan for feature X"
   └── plan.md        # The implementation plan
   ```

#### Session 2: Implementation

1. **Start a NEW conversation** (fresh session)

2. **Reference the plan**
   - Tell Claude: "Implement the plan from `plans/compressed-roaming-volcano.md`"
   - Claude reads the plan and implements the features

3. **Export the implementation session**
   ```bash
   /export-session --name feature-implementation
   ```
   Note: No `--plan` flag needed - the `-implementation` suffix makes it clear this relates to the `feature-planning` session

4. **Result:**
   ```
   exports/sessions/2025-01-31-0900-feature-implementation/
   ├── session.json
   ├── session.html
   └── session.md     # Summary: "Implemented features according to plan"
   ```

**Key Point:** Use naming convention to link sessions:
- `feature-name` → planning session (has plan.md)
- `feature-name-implementation` → implementation session (references plan by name)

### Workflow 2: Regular Session (No Planning)

For bug fixes, simple implementations, or exploratory sessions:

1. **Work in regular mode**
   - Fix bugs, implement features, explore code
   - Never enter plan mode

2. **Export when done**
   ```bash
   /export-session --name bug-fix-photo-upload
   ```

3. **Result:**
   ```
   exports/sessions/2025-01-30-1545-bug-fix-photo-upload/
   ├── session.json
   ├── session.html
   └── session.md     # Summary of the session
   ```

### Why Can't I Run This in Plan Mode?

**Plan mode restrictions:**
- Plan mode is **read-only** - can only read files, search code, explore
- **Cannot write files** - no Write, Edit, or file-creating commands

**This skill needs to:**
- Write files (session.json, session.md, etc.)
- Edit files (CHANGELOG.md)
- Run bash commands (export script)

**Solution:** Always exit plan mode before running `/export-session`

## Output Structure

Sessions are organized under an `exports/` directory with timestamped subdirectories:

```
exports/
├── sessions/
│   ├── 2025-01-30-1145-new-feature/           # Planning session
│   │   ├── session.json
│   │   ├── session.html
│   │   ├── session.md
│   │   └── plan.md           # Implementation plan (--plan flag used)
│   ├── 2025-01-31-0900-new-feature-implementation/  # Implementation session
│   │   ├── session.json
│   │   ├── session.html
│   │   └── session.md        # No plan.md (linked by naming convention)
│   └── 2025-02-01-1430-bug-fix-auth/
│       ├── session.json
│       ├── session.html
│       ├── session.md
│       └── VISUAL-FLOW.md    # Visual flow diagrams (optional)
└── CHANGELOG.md              # Timeline of exported sessions
```

**Directory naming:** `YYYY-MM-DD-HHMM-<session-name>`

**Naming convention for multi-session features:**
- `feature-name` → planning session (contains plan.md)
- `feature-name-implementation` → implementation session (references plan by name)

### session.md Format

Claude writes the summary directly with this structure:

```markdown
# Session Summary: [Session Name]

**Date:** 2025-01-30
**Working Directory:** /path/to/project

## Problem

What issue was being solved? What was broken or missing?

## Solution

How was it solved? Key decisions made during the session.

## Gotchas

Potential issues identified, edge cases to watch for, things learned.

## Key Files

- `src/auth/token.ts` - Description of changes
- `src/middleware/auth.ts` - Description of changes
```

### CHANGELOG.md

Timeline of exported sessions (newest first):

```markdown
# Completed Features Changelog

This file tracks all completed feature implementations in chronological order.

---

## 2025-01-30-1430-auth-refactor
**Session:** [sessions/2025-01-30-1430-auth-refactor/](sessions/2025-01-30-1430-auth-refactor/)

Implemented JWT token refresh mechanism with automatic retry logic.

---

## 2025-01-29-0915-initial-setup
**Session:** [sessions/2025-01-29-0915-initial-setup/](sessions/2025-01-29-0915-initial-setup/)

Set up project structure and configured build tools.
```

**Format:**
- Heading: Full session directory name (`YYYY-MM-DD-HHMM-session-name`)
- Link: Relative path to session directory
- Description: Brief summary from session.md

## How It Works

1. **Parse flags**: Extract `--name` and optional `--plan` from arguments
2. **Create directory**: `exports/sessions/YYYY-MM-DD-HHMM-<name>/`
3. **Reconstruct JSON**: Claude rebuilds the entire conversation as structured JSON
4. **Write summary**: Claude writes `session.md` with problem/solution/gotchas
5. **Generate HTML**: Python script converts JSON to interactive HTML
6. **Copy plan** (optional): If `--plan` provided, copy plan file as `plan.md`
7. **Visual flow** (optional): Create `VISUAL-FLOW.md` for complex state machines/flows
8. **Update changelog**: Prepend new entry to `exports/CHANGELOG.md`
9. **iCloud sync**: Syncs exports to iCloud Drive (if available)

## File Structure

```
export-session/
├── README.md           # This file
├── SKILL.md            # Skill instructions for Claude
├── export.py           # Python script (HTML generation only)
├── template.html       # HTML template with sidebar UI
└── install.sh          # Installation script
```

Installed skill location:
```
~/.claude/skills/export-session/
├── SKILL.md
├── export.py
└── template.html
```

## HTML Features

The HTML export includes:

- **Sidebar**: Lists all messages with role icons and preview text
- **Search**: Filter messages by text content
- **Filters**: Show All, User only, Assistant only, or messages with Tools
- **Collapsible tools**: Click tool headers to expand/collapse output
- **Dark theme**: Easy on the eyes
- **Responsive**: Works on mobile devices

## Quick Reference

### Common Commands

```bash
# Export regular session
/export-session --name bug-fix-auth

# Export session with plan from plan mode
/export-session --name feature-search --plan plans/swift-prancing-otter.md
```

### Important Reminders

✅ **DO:**
- Exit plan mode before running `/export-session`
- Use `--name` flag (required)
- Look in `plans/` directory for plan filenames
- Use full session directory name in CHANGELOG entries

❌ **DON'T:**
- Try to run this skill while in plan mode (will fail)
- Forget to specify `--name` flag (required)
- Manually edit CHANGELOG.md (skill handles it)

### Plan → Implement Workflow (Most Common!)

**Session 1 (Planning):**
```
1. Enter plan mode → 2. Create plan → 3. EXIT PLAN MODE ⚠️ → 4. Export with --plan
```
Example: `/export-session --name new-feature --plan plans/swift-prancing-otter.md`

**Session 2 (Implementation - NEW SESSION):**
```
1. Start fresh session → 2. Tell Claude to implement plan → 3. Export with -implementation suffix
```
Example: `/export-session --name new-feature-implementation` (no --plan needed)

**Remember:**
- Plan mode is read-only. This skill needs to write files, so you MUST exit plan mode first!
- Use naming convention to link sessions: `feature-name` → `feature-name-implementation`
- The `-implementation` suffix makes it clear which plan it relates to (no need to duplicate plan.md)

## Acknowledgments

This skill builds on the work of others:

- **[Ben Tossell](https://github.com/bentossell/share-session)** - For demonstrating how to extract content from other repos, like the /share command, via this [YouTube video](https://www.youtube.com/live/5YBjll9XJlw?si=uEhRuA4GtrZTiSOA) (around 34:00)
- **[Mario Zechner (badlogic)](https://github.com/badlogic/pi-mono/tree/main/packages/coding-agent)** - The original `/share` command implementation in pi-mono/coding-agent that inspired this skill's approach to session export

## License

MIT
