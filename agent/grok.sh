#!/usr/bin/env bash
# Usage:
#   grok                          # Continue last session (yolo mode)
#   grok -f                       # Force reinstall Grok
#
# ── Grok CLI Reference ──────────────────────────────────────────────────────
#
# Session:
#   -c, --continue                    Continue from most recent session
#   -r, --resume [id]                Resume specific session (or picker if omitted)
#   --session-id <id>                Use specific session by ID
#   --compact                        Start with compact system prompt
#   --fork <id>                      Fork from a specific session
#
# Model & Provider:
#   -m, --model <id>                 Model ID (e.g. grok-4, grok-3-mini)
#   -p, --provider <name>            Provider (xai, azure-openai, openai, ...)
#   --list-providers                 List all available providers
#   --list-models                    List models from active provider
#   --list-all-models                List models from all providers
#   --set-default <provider/model>   Set default provider and/or model
#   --set-api-key [provider]         Set API key for provider
#
# Tool Execution & Approval:
#   --yolo                           Auto-approve and auto-retry all tool calls
#   --auto-approve <tools...>        Auto-approve specific tools (repeatable)
#   --dangerously-auto-approve-all   Shorthand for --yolo
#   --confirm-everything             Require confirmation for all tool calls
#
# Subagents:
#   --enable-subagents               Enable subagent spawning
#   --subagent-model <id>            Model ID for subagent instances
#   --subagent-provider <name>       Provider for subagent instances
#
# Safety:
#   --fs-root <path>                 Restrict file operations to directory
#   --sandbox-mode <mode>            Sandbox mode: off, local, docker, k8s
#   --dangerously-skip-permissions   Skip all permission checks (DANGEROUS)
#
# Prompt & Context:
#   -t, --prompt <text>              Non-interactive mode: send prompt and exit
#   -s, --system-prompt <text>       Custom system prompt
#   --system-prompt-file <path>      Load system prompt from file
#   -w, --cwd <dir>                  Working directory
#   -e, --env <KEY=VALUE>            Environment variables for tool execution
#   -i, --image <path>               Attach image(s) to message (repeatable)
#
# MCP:
#   --mcp-config <path>              Path to MCP configuration file
#
# CLI Options:
#   -v, --version                    Show version
#   --json                           Output in JSON format
#   -h, --help                       Show help
#
# Subcommands:
#   init                             Initialize/reset configuration
#   update                           Update CLI
#   configure                        Configure settings
#   reset                            Reset session or full wipe
#   completion                       Generate shell completions
#
# ─────────────────────────────────────────────────────────────────────────────

set -euo pipefail

export FNM_DIR="${FNM_DIR:-$HOME/.fnm}"
export PATH="$FNM_DIR:$FNM_DIR/bin:$HOME/.local/share/fnm:$HOME/.local/bin:$PATH"

if ! command -v fnm &>/dev/null; then
  echo "Error: fnm not found. Run init.sh or install fnm first." >&2
  exit 1
fi

eval "$(fnm env --shell bash)"
fnm use default >/dev/null 2>&1 || {
  fnm install --lts
  latest=$(fnm list 2>/dev/null | grep -Eo 'v[0-9]+\.[0-9]+\.[0-9]+' | sort -V | tail -n 1 || true)
  [ -n "$latest" ] && fnm default "$latest" >/dev/null || true
  fnm use default >/dev/null || true
}

# Check for -f flag (force reinstall)
FORCE_REINSTALL=false
for arg in "$@"; do
  if [ "$arg" = "-f" ]; then
    FORCE_REINSTALL=true
    break
  fi
done

if $FORCE_REINSTALL || ! command -v grok &>/dev/null; then
  echo "grok not found, installing..."
  curl -fsSL https://x.ai/cli/install.sh | bash
fi

if [ $# -eq 0 ]; then
  # Check if there is any session for the current directory
  if command grok sessions list 2>/dev/null | grep -F "$PWD" >/dev/null; then
    exec grok --yolo --continue
  else
    exec grok --yolo
  fi
else
  exec grok "$@"
fi
