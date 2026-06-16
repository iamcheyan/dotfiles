#!/usr/bin/env bash
# Usage:
#   mimo                          # Run MiMo Code
#   mimo -f                       # Force reinstall MiMo Code
#
# Examples:
#   mimo                          # Start MiMo Code
#   mimo --version                # Show version

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

exec mimo "$@"
