# Export Session Plan

A Claude Code skill that exports conversations with Claude-generated summaries and implementation plans.

## Features

- **Claude-generated summaries**: Problem/solution/gotchas format written by Claude
- **Plan capture**: Saves implementation plans as PLAN.md
- **Timeline tracking**: CHANGELOG.md tracks when sessions were exported
- **Self-contained HTML**: Interactive transcript with sidebar navigation
- **Offline support**: HTML works with `file://` protocol
- **iCloud sync**: Automatic backup to iCloud Drive (macOS)

## Installation

Copy the skill files to your Claude Code skills directory:

```bash
mkdir -p ~/.claude/skills/export-session-plan
cp SKILL.md export.py template.html ~/.claude/skills/export-session-plan/
```

Or run:

```bash
./install.sh
```

## Usage

After installation, restart Claude Code and run:

```bash
# Export with automatic naming (timestamp-based)
/export-session-plan

# Export with custom session name
/export-session-plan auth-refactor

# Export to custom path (bypasses default location)
/export-session-plan ./custom/path
```

## Output Structure

Sessions are organized under an `exports/` directory:

```
exports/
├── sessions/
│   └── 2025-01-30-auth-refactor/
│       ├── session.json      # Raw session data
│       ├── session.html      # Interactive transcript view
│       ├── session.md        # Claude-generated summary
│       └── PLAN.md           # Implementation plan
└── CHANGELOG.md              # Timeline of exported sessions
```

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

### PLAN.md

Contains the implementation plan discussed during the session. If no formal plan was discussed, notes that the session was exploratory.

### CHANGELOG.md

Timeline of exported sessions (newest first):

```markdown
# Session Changelog

Timeline of exported sessions and plans.

---

## 2025-01-30 - Auth token refresh planning
**Session:** [auth-refactor](sessions/auth-refactor/)

## 2025-01-29 - Initial project setup
**Session:** [initial-setup](sessions/initial-setup/)
```

## How It Works

1. **Location**: Creates `exports/sessions/<name>/` directory
2. **JSON**: Claude reconstructs the conversation into structured JSON
3. **Summary**: Claude writes `session.md` with problem/solution/gotchas
4. **Plan**: Claude writes `PLAN.md` with implementation details
5. **HTML**: Python script converts JSON to interactive HTML
6. **Changelog**: New entry prepended to `exports/CHANGELOG.md`
7. **iCloud**: Syncs exports to iCloud Drive (if available)

## File Structure

```
export-session-plan/
├── README.md           # This file
├── SKILL.md            # Skill instructions for Claude
├── export.py           # Python script (HTML generation only)
├── template.html       # HTML template with sidebar UI
└── install.sh          # Installation script
```

Installed skill location:
```
~/.claude/skills/export-session-plan/
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

## Related Skills

- **implement**: Executes a PLAN.md file created by export-session-plan

## Acknowledgments

This skill builds on the work of others:

- **[Ben Tossell](https://github.com/bentossell/share-session)** - For demonstrating how to extract content from other repos, like the /share command, via this [YouTube video](https://www.youtube.com/live/5YBjll9XJlw?si=uEhRuA4GtrZTiSOA) (around 34:00)
- **[Mario Zechner (badlogic)](https://github.com/badlogic/pi-mono/tree/main/packages/coding-agent)** - The original `/share` command implementation in pi-mono/coding-agent that inspired this skill's approach to session export

## License

MIT
