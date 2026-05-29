#!/usr/bin/env bash
# Usage:
#   cc                          # Run Claude Code with default Anthropic
#   cc <provider>               # Run with provider from opencode.json (uses first model)
#   cc <provider> <model>       # Run with specific model
#   cc -s, --select             # Interactive model selection
#   cc -v, --version            # Show current vs latest version
#   cc --versions               # Show recent 10 versions
#   cc -c                       # Continue the most recent conversation
#   cc -r, --resume [id]        # Resume a conversation (interactive picker or by ID)
#   cc --session-id <uuid>      # Use a specific session ID
#   cc --fork-session           # Fork session when resuming
#   cc --from-pr [pr]           # Resume session linked to a PR
#   cc -p, --print <prompt>     # Non-interactive mode (print and exit)
#   cc -n, --name <name>        # Set session display name
#   cc -d, --debug [filter]     # Enable debug mode
#   cc --bare                   # Minimal mode
#   cc --effort <level>         # Set effort level (low/medium/high/xhigh/max)
#   cc -w, --worktree [name]    # Create a git worktree for this session
#   cc --permission-mode <mode> # Permission mode (acceptEdits/auto/bypassPermissions/default/dontAsk/plan)
#   cc --model <model>          # Override model for this session
#
# Examples:
#   cc mimo-anthropic           # Uses mimo-v2.5-pro (first model)
#   cc mimo-anthropic mimo-v2.5 # Uses specific model
#   cc deepseek                 # Uses deepseek-v4-flash
#   cc kimi kimi-k2.6           # Uses kimi-k2.6
#   cc -s                       # Pick model from interactive list
#   cc -c                       # Continue last conversation
#   cc -r                       # Interactive session picker
#   cc -r abc123-def456         # Resume specific session
#   cc -p "fix the bug"         # Non-interactive print mode

set -euo pipefail

HAS_ARGS=$#

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

nvm use node >/dev/null 2>&1

if ! command -v claude &>/dev/null; then
  echo "claude not found, installing @anthropic-ai/claude-code..."
  npm i -g @anthropic-ai/claude-code
fi

# Version commands
if [ "${1:-}" = "-v" ] || [ "${1:-}" = "--version" ]; then
  CURRENT=$(npm list -g @anthropic-ai/claude-code --depth=0 2>/dev/null | grep '@anthropic-ai/claude-code@' | sed 's/.*@//')
  LATEST=$(npm view @anthropic-ai/claude-code version 2>/dev/null)
  echo "Current:  ${CURRENT:-not installed}"
  echo "Latest:   ${LATEST:-unknown}"
  if [ -n "$CURRENT" ] && [ -n "$LATEST" ] && [ "$CURRENT" = "$LATEST" ]; then
    echo "Status:   up to date ✓"
  elif [ -n "$CURRENT" ] && [ -n "$LATEST" ]; then
    echo "Status:   update available"
  fi
  exit 0
fi

if [ "${1:-}" = "--versions" ]; then
  LATEST=$(npm view @anthropic-ai/claude-code version 2>/dev/null)
  CURRENT=$(npm list -g @anthropic-ai/claude-code --depth=0 2>/dev/null | grep '@anthropic-ai/claude-code@' | sed 's/.*@//')
  echo "Current: ${CURRENT:-not installed}  Latest: ${LATEST:-unknown}"
  echo ""
  echo "Recent versions:"
  npm view @anthropic-ai/claude-code versions --json 2>/dev/null \
    | node -pe "JSON.parse(require('fs').readFileSync('/dev/stdin','utf8')).slice(-10).join('\n')"
  exit 0
fi

CONFIG="$HOME/.config/opencode/opencode.json"

# ── Parse arguments ──────────────────────────────────────────────────────────
# Two-pass approach: first identify provider/model, then collect everything
# else as passthrough args for claude.
#
# Pass 1: scan non-flag args against opencode.json providers.
#   - If a non-flag arg matches a provider name, it's consumed.
#   - If the next non-flag arg after a provider doesn't match any provider, it's the model.
# Pass 2: all remaining args (including all flags) → EXTRA_ARGS → passed to claude.

PROVIDER=""
MODEL=""
EXTRA_ARGS=()
SELECT_MODE=false

if [ $# -gt 0 ]; then
  # Build list of known providers from config
  PROVIDERS=()
  if [ -f "$CONFIG" ]; then
    mapfile -t PROVIDERS < <(node -e "
      const config = require('$CONFIG');
      Object.keys(config.provider || {}).forEach(p => console.log(p));
    " 2>/dev/null || true)
  fi

  # Two-pass: first pass identifies provider/model, second collects extras
  ARGS=("$@")
  USED=() # track indices consumed by provider/model
  IDX=0

  for arg in "${ARGS[@]}"; do
    # -s / --select
    if [ "$arg" = "-s" ] || [ "$arg" = "--select" ]; then
      SELECT_MODE=true
      USED+=("$IDX")
      IDX=$((IDX + 1))
      continue
    fi

    # Non-flag arg: could be provider or model
    if [[ "$arg" != -* ]]; then
      # Already found provider and model? Skip (shouldn't happen, but safe)
      if [ -n "$PROVIDER" ] && [ -n "$MODEL" ]; then
        IDX=$((IDX + 1))
        continue
      fi
      # Check if this is a known provider
      IS_PROVIDER=false
      if [ ${#PROVIDERS[@]} -gt 0 ]; then
        for p in "${PROVIDERS[@]}"; do
          if [ "$arg" = "$p" ]; then
            IS_PROVIDER=true
            break
          fi
        done
      fi
      if $IS_PROVIDER && [ -z "$PROVIDER" ]; then
        PROVIDER="$arg"
        USED+=("$IDX")
        # Peek ahead: next non-flag arg that isn't a known provider = model
        JDX=$((IDX + 1))
        while [ "$JDX" -lt "${#ARGS[@]}" ]; do
          NEXT="${ARGS[$JDX]}"
          if [[ "$NEXT" == -* ]] || [ "$NEXT" = "-s" ] || [ "$NEXT" = "--select" ]; then
            JDX=$((JDX + 1))
            continue
          fi
          # Check if it's a known provider — if so, it's not the model
          NEXT_IS_PROVIDER=false
          if [ ${#PROVIDERS[@]} -gt 0 ]; then
            for p in "${PROVIDERS[@]}"; do
              if [ "$NEXT" = "$p" ]; then
                NEXT_IS_PROVIDER=true
                break
              fi
            done
          fi
          if ! $NEXT_IS_PROVIDER; then
            MODEL="$NEXT"
            USED+=("$JDX")
          fi
          break
        done
      fi
    fi
    IDX=$((IDX + 1))
  done

  # Collect everything not used as provider/model
  IDX=0
  for arg in "${ARGS[@]}"; do
    USED_FLAG=false
    if [ ${#USED[@]} -gt 0 ]; then
      for u in "${USED[@]}"; do
        if [ "$IDX" -eq "$u" ]; then
          USED_FLAG=true
          break
        fi
      done
    fi
    if ! $USED_FLAG; then
      EXTRA_ARGS+=("$arg")
    fi
    IDX=$((IDX + 1))
  done
fi

# Interactive model selection
if $SELECT_MODE; then
  if [ ! -f "$CONFIG" ]; then
    echo "Error: Config file not found: $CONFIG" >&2
    exit 1
  fi

  SELECTOR="$(dirname "$0")/cc-select.mjs"
  RESULT=$(node "$SELECTOR" "$CONFIG") || exit 1

  PROVIDER=$(echo "$RESULT" | node -pe "JSON.parse(require('fs').readFileSync('/dev/stdin','utf8')).provider")
  MODEL=$(echo "$RESULT" | node -pe "JSON.parse(require('fs').readFileSync('/dev/stdin','utf8')).model")

  echo "Selected: $PROVIDER / $MODEL"
fi

# Load last used model if no provider specified
if [ -z "$PROVIDER" ] && [ -f "$CC_CONFIG" ] && [ "$HAS_ARGS" -eq 0 ]; then
  LAST_PROVIDER=$(head -1 "$CC_CONFIG" 2>/dev/null || echo "")
  LAST_MODEL=$(tail -1 "$CC_CONFIG" 2>/dev/null || echo "")
  if [ -n "$LAST_PROVIDER" ]; then
    PROVIDER="$LAST_PROVIDER"
    MODEL="${LAST_MODEL:-}"
  fi
fi

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
fi

# Auto update only when arguments are provided
if [ "$HAS_ARGS" -gt 0 ]; then
  echo "Checking for Claude Code updates..."
  npm update -g @anthropic-ai/claude-code 2>/dev/null || true
fi

# Print model info
if [ -n "${ANTHROPIC_MODEL:-}" ]; then
  echo "Model: $ANTHROPIC_MODEL"
fi

# Save current model for next time
if [ -n "${PROVIDER:-}" ]; then
  echo "$PROVIDER" > "$CC_CONFIG"
  echo "${MODEL:-}" >> "$CC_CONFIG"
fi

if [ ${#EXTRA_ARGS[@]} -gt 0 ]; then
  exec claude --dangerously-skip-permissions "${EXTRA_ARGS[@]}"
else
  exec claude --dangerously-skip-permissions
fi
