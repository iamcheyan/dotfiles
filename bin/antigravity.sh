#!/usr/bin/env bash
# Usage:
#   agy                          # Run Antigravity CLI

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

if ! command -v agy &>/dev/null; then
  echo "agy not found, installing..."
  curl -fsSL https://antigravity.google/cli/install.sh | bash
fi

exec agy "$@"
