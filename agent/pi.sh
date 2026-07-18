#!/usr/bin/env bash
# Usage:
#   pi                          # Continue last session
#   pi -f                       # Force reinstall Pi
#
# Examples:
#   pi                          # Continue last session
#   pi --version                # Show version

set -euo pipefail

export PATH="$HOME/.local/bin:$PATH"

FORCE_REINSTALL=false
for arg in "$@"; do
  if [ "$arg" = "-f" ]; then
    FORCE_REINSTALL=true
    break
  fi
done

if $FORCE_REINSTALL || ! command -v pi &>/dev/null; then
  echo "pi not found, installing..."
  curl -fsSL https://pi.dev/install.sh | sh
fi

exec pi "$@"
