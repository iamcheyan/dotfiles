#!/usr/bin/env bash
# Usage:
#   cp                        # Run Copilot (default: last session)
#   cp -f                     # Force reinstall Copilot
#
# ── Copilot CLI Reference ────────────────────────────────────────────────────
#
# Subcommands:
#   help                      Show help
#   version                   Show version
#   install                   Install Copilot CLI
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

if $FORCE_REINSTALL || ! command -v copilot &>/dev/null; then
  echo "copilot not found, installing..."
  curl -fsSL https://gh.io/copilot-install | bash
  export PATH="$HOME/.local/bin:$PATH"
fi

if [ $# -eq 0 ]; then
  exec copilot
else
  exec copilot "$@"
fi
