#!/bin/bash
# Install the export-session-plan skill for Claude Code

SKILL_DIR="$HOME/.claude/skills/export-session-plan"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "Installing export-session-plan skill..."

# Create skill directory
mkdir -p "$SKILL_DIR"

# Copy files
cp "$SCRIPT_DIR/SKILL.md" "$SKILL_DIR/"
cp "$SCRIPT_DIR/export.py" "$SKILL_DIR/"
cp "$SCRIPT_DIR/template.html" "$SKILL_DIR/"

echo "Installed to: $SKILL_DIR"
ls -la "$SKILL_DIR"

echo ""
echo "Done! Restart Claude Code and run: /export-session-plan"
