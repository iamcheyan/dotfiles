#!/usr/bin/env bash
# Usage:
#   grok                          # Run Grok CLI

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

if ! command -v grok &>/dev/null; then
  echo "grok not found, installing..."
  curl -fsSL https://x.ai/cli/install.sh | bash
fi

exec grok "$@"
