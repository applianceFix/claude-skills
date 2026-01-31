# Implement Skill

A Claude Code skill that executes plan files, creating feature branches and tracking implementation results.

## Features

- **Plan execution**: Follows steps defined in a PLAN.md file
- **Git integration**: Creates feature branches automatically
- **Session tracking**: Records the implementation conversation
- **Results documentation**: Generates RESULTS.md with completed steps and verification checklist

## Prerequisites

This skill requires the **export-session-plan** skill to be installed for HTML generation:

```bash
# Verify export-session-plan is installed
ls ~/.claude/skills/export-session-plan/export.py
```

If not installed, install it from the `export-session-plan/` directory in this repo.

## Installation

Copy the skill file to your Claude Code skills directory:

```bash
mkdir -p ~/.claude/skills/implement
cp SKILL.md ~/.claude/skills/implement/
```

Or run:

```bash
./install.sh
```

## Usage

After installation, restart Claude Code and run:

```bash
/implement path/to/PLAN.md
```

### Plan File Requirements

Your PLAN.md must have a title with the "Plan:" prefix:

```markdown
# Plan: My Feature Name

## Steps

### Step 1: Do something
...
```

## Output Structure

The skill creates an implementation directory with session artifacts:

```
exports/sessions/
└── 2025-01-30-my-feature-name-implementation/
    ├── session.json      # Raw session data
    ├── session.html      # Interactive transcript view
    └── RESULTS.md        # Implementation summary
```

### RESULTS.md Format

```markdown
# Plan: My Feature Name

This session implemented the plan defined in `path/to/PLAN.md`.

## Summary

Brief summary of what was accomplished.

## Implementation Steps Completed

### Step 1: Step name [✅ or ❌]
- Actions taken
- Files modified
- Decisions made

## Verification Checklist

- [ ] Item to verify
- [ ] Another item

## Branch

`feature/my-feature-name`
```

## Workflow

1. **Validate** - Checks plan path is provided and file exists
2. **Extract name** - Parses "Plan:" prefix from title (required)
3. **Create directory** - `exports/sessions/{date}-{name}-implementation/`
4. **Create branch** - `feature/{name}` (fails if branch exists)
5. **Execute plan** - Follows each step, stops on issues
6. **Write session.json** - Records conversation
7. **Generate HTML** - Uses export-session-plan's export.py
8. **Create RESULTS.md** - Documents what was done
9. **Report completion** - Shows created files and next steps

## Error Handling

The skill stops immediately and waits for user direction when:

- Plan file doesn't have "Plan:" prefix in title
- Feature branch already exists
- A step is unclear and needs clarification
- A step cannot be completed

## File Structure

```
implement-skill/
├── README.md       # This file
├── SKILL.md        # Skill instructions for Claude
└── install.sh      # Installation script
```

Installed skill location:
```
~/.claude/skills/implement/
└── SKILL.md
```

## License

MIT
