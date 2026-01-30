#!/bin/bash
# Install the implement skill for Claude Code

SKILL_DIR="$HOME/.claude/skills/implement"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "Installing implement skill..."

# Check for share-session dependency
if [ ! -f "$HOME/.claude/skills/share-session/export.py" ]; then
    echo "Warning: share-session skill not found at ~/.claude/skills/share-session/"
    echo "The implement skill requires share-session for HTML generation."
    echo "Install share-session first, or HTML export will fail."
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
