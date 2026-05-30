#!/usr/bin/env bash
# Usage:
#   agy                          # Run Antigravity CLI
#   agy -f                       # Force reinstall Antigravity

set -euo pipefail

export NVM_DIR="${NVM_DIR:-$HOME/.nvm}"
if [ -s "$NVM_DIR/nvm.sh" ]; then
  \. "$NVM_DIR/nvm.sh"
fi

if ! command -v nvm &>/dev/null; then
  echo "Error: nvm not found. Install nvm first." >&2
  exit 1
fi

nvm use node

# Check for -f flag (force reinstall)
FORCE_REINSTALL=false
for arg in "$@"; do
  if [ "$arg" = "-f" ]; then
    FORCE_REINSTALL=true
    break
  fi
done

if $FORCE_REINSTALL || ! command -v agy &>/dev/null; then
  echo "agy not found, installing..."
  curl -fsSL https://antigravity.google/cli/install.sh | bash
fi

exec agy "$@"
