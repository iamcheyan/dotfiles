#!/usr/bin/env bash
set -euo pipefail

# Load nvm
export NVM_DIR="${NVM_DIR:-$HOME/.nvm}"
if [ -s "$NVM_DIR/nvm.sh" ]; then
  \. "$NVM_DIR/nvm.sh"
fi

# Ensure nvm is available
if ! command -v nvm &>/dev/null; then
  echo "Error: nvm not found. Install nvm first." >&2
  exit 1
fi

# Use the latest Node.js version
nvm use node

# Check if codex is installed, install if not
if ! command -v codex &>/dev/null; then
  echo "codex not found, installing @openai/codex..."
  npm i -g @openai/codex
fi

# Run codex with all arguments passed to this script
exec codex "$@"
