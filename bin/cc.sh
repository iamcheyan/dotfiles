#!/usr/bin/env bash
# Usage:
#   cc                          # Run Claude Code with default Anthropic
#   cc <provider>               # Run with provider from opencode.json (uses first model)
#   cc <provider> <model>       # Run with specific model
#
# Examples:
#   cc mimo-anthropic           # Uses mimo-v2.5-pro (first model)
#   cc mimo-anthropic mimo-v2.5 # Uses specific model
#   cc deepseek                 # Uses deepseek-v4-flash
#   cc kimi kimi-k2.6           # Uses kimi-k2.6

set -euo pipefail

# Config file to remember last used model
CC_CONFIG="$HOME/.cache/cc_last_model"
mkdir -p "$(dirname "$CC_CONFIG")"

export NVM_DIR="${NVM_DIR:-$HOME/.nvm}"
if [ -s "$NVM_DIR/nvm.sh" ]; then
  \. "$NVM_DIR/nvm.sh"
fi

if ! command -v nvm &>/dev/null; then
  echo "Error: nvm not found. Install nvm first." >&2
  exit 1
fi

nvm use node

if ! command -v claude &>/dev/null; then
  echo "claude not found, installing @anthropic-ai/claude-code..."
  npm i -g @anthropic-ai/claude-code
fi

CONFIG="$HOME/.config/opencode/opencode.json"

# Load last used model if no arguments provided
if [ $# -eq 0 ] && [ -f "$CC_CONFIG" ]; then
  LAST_PROVIDER=$(head -1 "$CC_CONFIG" 2>/dev/null || echo "")
  LAST_MODEL=$(tail -1 "$CC_CONFIG" 2>/dev/null || echo "")
  if [ -n "$LAST_PROVIDER" ]; then
    set -- "$LAST_PROVIDER" ${LAST_MODEL:+"$LAST_MODEL"}
  fi
fi

PROVIDER="${1:-}"
MODEL="${2:-}"

if [ -n "$PROVIDER" ] && [ -f "$CONFIG" ]; then
  PROVIDER_CONFIG=$(node -e "
    const config = require('$CONFIG');
    const p = config.provider['$PROVIDER'];
    if (!p) { console.error('Provider $PROVIDER not found'); process.exit(1); }
    const models = Object.keys(p.models);
    console.log(JSON.stringify({ apiKey: p.options.apiKey, baseURL: p.options.baseURL, models }));
  " 2>/dev/null) || { echo "Error: Provider '$PROVIDER' not found in $CONFIG" >&2; exit 1; }

  API_KEY=$(echo "$PROVIDER_CONFIG" | node -pe "JSON.parse(require('fs').readFileSync('/dev/stdin','utf8')).apiKey")
  BASE_URL=$(echo "$PROVIDER_CONFIG" | node -pe "JSON.parse(require('fs').readFileSync('/dev/stdin','utf8')).baseURL")
  MODELS=$(echo "$PROVIDER_CONFIG" | node -pe "JSON.parse(require('fs').readFileSync('/dev/stdin','utf8')).models")

  export ANTHROPIC_API_KEY="$API_KEY"
  export ANTHROPIC_BASE_URL="$BASE_URL"

  if [ -n "$MODEL" ]; then
    export ANTHROPIC_MODEL="$MODEL"
  else
    # Use first model as default
    DEFAULT_MODEL=$(echo "$MODELS" | node -pe "JSON.parse(require('fs').readFileSync('/dev/stdin','utf8'))[0]")
    export ANTHROPIC_MODEL="$DEFAULT_MODEL"
  fi

  shift
  [ -n "$MODEL" ] && shift
fi

# Auto update
echo "Checking for Claude Code updates..."
npm update -g @anthropic-ai/claude-code 2>/dev/null || true

# Print model info
if [ -n "${ANTHROPIC_MODEL:-}" ]; then
  echo "Model: $ANTHROPIC_MODEL"
fi

# Save current model for next time
if [ -n "${PROVIDER:-}" ]; then
  echo "$PROVIDER" > "$CC_CONFIG"
  echo "${MODEL:-}" >> "$CC_CONFIG"
fi

exec claude --dangerously-skip-permissions "$@"
