#!/usr/bin/env bash
# Usage:
#   grok                          # Run Grok CLI
#   grok -f                       # Force reinstall Grok

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

if $FORCE_REINSTALL || ! command -v grok &>/dev/null; then
  echo "grok not found, installing..."
  curl -fsSL https://x.ai/cli/install.sh | bash
fi

exec grok "$@"
