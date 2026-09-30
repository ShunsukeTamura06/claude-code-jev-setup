#!/usr/bin/env bash
set -euo pipefail
NAME="${1:-jev}"
claude mcp remove "$NAME" --scope user >/dev/null 2>&1 || true
rm -f "$HOME/.claude/rules/jev.md"
echo "Removed Jev MCP '$NAME' and ~/.claude/rules/jev.md"
