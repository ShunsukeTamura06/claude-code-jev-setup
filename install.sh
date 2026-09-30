#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="${1:-$SCRIPT_DIR/config.env}"

if [[ ! -f "$CONFIG_FILE" ]]; then
  echo "Config not found: $CONFIG_FILE"
  echo "Copy config.example.env to config.env and edit JEV_MCP_URL."
  exit 1
fi

JEV_MCP_URL=""
JEV_MCP_NAME="jev"
JEV_MCP_HEADER=""

while IFS= read -r raw || [[ -n "$raw" ]]; do
  line="${raw%$'\r'}"
  [[ -z "$line" || "$line" =~ ^[[:space:]]*# ]] && continue
  key="${line%%=*}"
  value="${line#*=}"
  key="$(printf '%s' "$key" | xargs)"
  case "$key" in
    JEV_MCP_URL) JEV_MCP_URL="$value" ;;
    JEV_MCP_NAME) JEV_MCP_NAME="$value" ;;
    JEV_MCP_HEADER) JEV_MCP_HEADER="$value" ;;
  esac
done < "$CONFIG_FILE"

: "${JEV_MCP_URL:?JEV_MCP_URL is required}"
JEV_MCP_NAME="${JEV_MCP_NAME:-jev}"

if ! command -v claude >/dev/null 2>&1; then
  echo "Claude Code CLI ('claude') was not found in PATH."
  exit 1
fi

mkdir -p "$HOME/.claude/rules"
cp "$SCRIPT_DIR/rules/jev.md" "$HOME/.claude/rules/jev.md"

# Idempotent: replace an existing user-scope entry with the same name.
claude mcp remove "$JEV_MCP_NAME" --scope user >/dev/null 2>&1 || true

ARGS=(mcp add --transport http --scope user "$JEV_MCP_NAME" "$JEV_MCP_URL")
if [[ -n "$JEV_MCP_HEADER" ]]; then
  ARGS+=(--header "$JEV_MCP_HEADER")
fi
claude "${ARGS[@]}"

echo
echo "Jev integration installed."
echo "Rule: $HOME/.claude/rules/jev.md"
echo "MCP:  $JEV_MCP_NAME -> $JEV_MCP_URL"
echo
echo "Verify with: claude mcp list"
