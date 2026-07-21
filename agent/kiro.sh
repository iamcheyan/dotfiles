#!/usr/bin/env bash
# Usage:
#   kiro                         # Run Kiro CLI
#   kiro -f                      # Force reinstall Kiro
#
# ── Kiro CLI Reference ───────────────────────────────────────────────────────
#
# Binary: kiro-cli (installed to ~/.local/bin/)
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

if $FORCE_REINSTALL || ! command -v kiro-cli &>/dev/null; then
  echo "kiro-cli not found, installing..."
  curl -fsSL https://cli.kiro.dev/install | bash
  export PATH="$HOME/.local/bin:$PATH"
fi

if [ $# -eq 0 ]; then
  exec kiro-cli
else
  exec kiro-cli "$@"
fi
