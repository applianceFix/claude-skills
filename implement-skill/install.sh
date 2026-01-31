#!/bin/bash
# Install the implement skill for Claude Code

SKILL_DIR="$HOME/.claude/skills/implement"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "Installing implement skill..."

# Check for export-session dependency
if [ ! -f "$HOME/.claude/skills/export-session/export.py" ]; then
    echo "Warning: export-session skill not found at ~/.claude/skills/export-session/"
    echo "The implement skill requires export-session for HTML generation."
    echo "Install export-session first, or HTML export will fail."
    echo ""
fi

# Create skill directory
mkdir -p "$SKILL_DIR"

# Copy files
cp "$SCRIPT_DIR/SKILL.md" "$SKILL_DIR/"

echo "Installed to: $SKILL_DIR"
ls -la "$SKILL_DIR"

echo ""
echo "Done! Restart Claude Code and run: /implement path/to/PLAN.md"
