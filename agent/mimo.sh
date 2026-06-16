#!/usr/bin/env bash
# Usage:
#   mimo                          # Continue last session (skip permissions)
#   mimo -f                       # Force reinstall MiMo Code
#
# Examples:
#   mimo                          # Continue last session
#   mimo --version                # Show version
#
# ── MiMo CLI Reference ──────────────────────────────────────────────────────
#
# Session:
#   -c, --continue                    Continue the last session
#   -s, --session <id>                Session id to continue
#   --fork                            Fork the session when continuing
#
# Model:
#   -m, --model <id>                  Model to use (format: provider/model)
#   --provider <name>                 Provider name
#   --model-reasoning-effort <level>  Override model reasoning effort
#
# Prompt & Context:
#   prompt                            Initial prompt to send
#   --prompt <text>                   Initial prompt (alternative form)
#   --system-prompt <text>            Override system prompt
#   --system-prompt-file <path>       Path to system prompt file
#   -f, --file <path>                 Attach files to the message
#
# Permissions & Sandbox:
#   --dangerously-skip-permissions    Auto-approve permissions not explicitly denied
#
# UI:
#   -t, --theme <theme>              Set the TUI theme
#   --autocomplete                    Enable autocomplete in TUI
#   --no-autocomplete                 Disable autocomplete in TUI
#   --check                           Check system for required dependencies
#
# MCP:
#   --mcp-config <path>               Path to MCP configuration JSON file
#
# ─────────────────────────────────────────────────────────────────────────────

set -euo pipefail

export PATH="$HOME/.local/bin:$PATH"

# Check for -f flag (force reinstall)
FORCE_REINSTALL=false
for arg in "$@"; do
  if [ "$arg" = "-f" ]; then
    FORCE_REINSTALL=true
    break
  fi
done

if $FORCE_REINSTALL || ! command -v mimo &>/dev/null; then
  echo "mimo not found, installing..."
  curl -fsSL https://mimo.xiaomi.com/install | bash
fi

if [ $# -eq 0 ]; then
  exec mimo -c --dangerously-skip-permissions
else
  exec mimo "$@"
fi
