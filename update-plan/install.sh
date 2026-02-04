#!/bin/bash
# Install the update-plan skill for Claude Code

SKILL_DIR="$HOME/.claude/skills/update-plan"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "Installing update-plan skill..."

# Create skill directory
mkdir -p "$SKILL_DIR"

# Copy files
cp "$SCRIPT_DIR/SKILL.md" "$SKILL_DIR/"
cp "$SCRIPT_DIR/README.md" "$SKILL_DIR/"

echo "Installed to: $SKILL_DIR"
ls -la "$SKILL_DIR"

echo ""
echo "Done! Restart Claude Code and run: /update-plan"
