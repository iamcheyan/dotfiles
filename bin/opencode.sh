#!/usr/bin/env bash
# Usage:
#   oc                              # Launch opencode TUI (default: mimo/mimo-v2.5)
#   oc <provider>                   # Run with provider from opencode.json
#   oc <provider> <model>           # Run with specific model
#   oc -s, --select                 # Interactive model selection
#   oc -m, --model <provider/model> # Override model directly
#   oc -p, --print <prompt>         # Non-interactive: answer and exit
#   oc -v, --version                # Show version
#   oc -c                           # Continue last session
#   oc --dangerously-skip-permissions  # Auto-approve all permissions
#
# Examples:
#   oc                              # TUI with mimo (free)
#   oc zhipu                        # Use zhipu provider (glm-4-flash, free)
#   oc deepseek                     # Use deepseek provider
#   oc -m mimo/mimo-v2.5-pro        # Use specific model
#   oc -p "explain this function"   # Non-interactive question
#   oc -s                           # Pick model from interactive list

set -euo pipefail

HAS_ARGS=$#

# ── Install check ─────────────────────────────────────────────────────────────
if ! command -v opencode &>/dev/null; then
  echo "opencode not found, installing..."
  curl -fsSL https://opencode.ai/install | bash
  export PATH="$HOME/.local/bin:$PATH"
  if ! command -v opencode &>/dev/null; then
    echo "Error: opencode installation failed." >&2
    exit 1
  fi
fi

# ── Version ───────────────────────────────────────────────────────────────────
if [ "${1:-}" = "-v" ] || [ "${1:-}" = "--version" ]; then
  opencode --version
  exit 0
fi

CONFIG="$HOME/.config/opencode/opencode.json"

# ── Parse arguments ───────────────────────────────────────────────────────────
PROVIDER=""
MODEL=""
EXTRA_ARGS=()
SELECT_MODE=false
PRINT_MODE=false
SKIP_PERMS=false
CONTINUE=false

# Build list of known providers from config
PROVIDERS=()
if [ -f "$CONFIG" ]; then
  while IFS= read -r line; do
    PROVIDERS+=("$line")
  done < <(node -e "
    const config = require('$CONFIG');
    Object.keys(config.provider || {}).forEach(p => console.log(p));
  " 2>/dev/null || true)
fi

if [ $# -gt 0 ]; then
  ARGS=("$@")
  USED=()
  IDX=0

  for arg in "${ARGS[@]}"; do
    case "$arg" in
      -s|--select)
        SELECT_MODE=true
        USED+=("$IDX")
        ;;
      -p|--print)
        PRINT_MODE=true
        USED+=("$IDX")
        ;;
      -c)
        CONTINUE=true
        EXTRA_ARGS+=("-c")
        USED+=("$IDX")
        ;;
      --dangerously-skip-permissions)
        SKIP_PERMS=true
        USED+=("$IDX")
        ;;
      -m|--model)
        USED+=("$IDX")
        IDX=$((IDX + 1))
        if [ "$IDX" -lt "${#ARGS[@]}" ]; then
          MODEL="${ARGS[$IDX]}"
          USED+=("$IDX")
        fi
        ;;
      -*)
        # Unknown flag, pass through
        EXTRA_ARGS+=("$arg")
        USED+=("$IDX")
        ;;
      *)
        # Non-flag: provider or model
        if [ -z "$PROVIDER" ]; then
          IS_PROVIDER=false
          for p in "${PROVIDERS[@]}"; do
            if [ "$arg" = "$p" ]; then
              IS_PROVIDER=true
              break
            fi
          done
          if $IS_PROVIDER; then
            PROVIDER="$arg"
            USED+=("$IDX")
          else
            EXTRA_ARGS+=("$arg")
            USED+=("$IDX")
          fi
        elif [ -z "$MODEL" ]; then
          # After provider, next non-flag arg = model
          MODEL="$arg"
          USED+=("$IDX")
        else
          EXTRA_ARGS+=("$arg")
          USED+=("$IDX")
        fi
        ;;
    esac
    IDX=$((IDX + 1))
  done

  # Collect remaining unused args
  IDX=0
  for arg in "${ARGS[@]}"; do
    USED_FLAG=false
    for u in "${USED[@]}"; do
      if [ "$IDX" -eq "$u" ]; then
        USED_FLAG=true
        break
      fi
    done
    if ! $USED_FLAG; then
      EXTRA_ARGS+=("$arg")
    fi
    IDX=$((IDX + 1))
  done
fi

# ── Interactive model selection ───────────────────────────────────────────────
if $SELECT_MODE; then
  if [ ! -f "$CONFIG" ]; then
    echo "Error: Config not found: $CONFIG" >&2
    exit 1
  fi
  SELECTOR="$(dirname "$0")/lib/select.mjs"
  RESULT=$(node "$SELECTOR" --provider "$CONFIG") || exit 1
  PROVIDER=$(echo "$RESULT" | node -pe "JSON.parse(require('fs').readFileSync('/dev/stdin','utf8')).provider")
  MODEL=$(echo "$RESULT" | node -pe "JSON.parse(require('fs').readFileSync('/dev/stdin','utf8')).model")
  echo "Selected: $PROVIDER / $MODEL"
fi

# ── Default to mimo (free) if no provider/model and no extra args ────────────
if [ -z "$PROVIDER" ] && [ -z "$MODEL" ] && [ ${#EXTRA_ARGS[@]} -eq 0 ]; then
  PROVIDER="mimo"
  MODEL="mimo-v2.5"
fi

# ── Build command ─────────────────────────────────────────────────────────────
CMD=(opencode run)

if [ -n "$PROVIDER" ] && [ -n "$MODEL" ]; then
  CMD+=("-m" "$PROVIDER/$MODEL")
elif [ -n "$MODEL" ]; then
  CMD+=("-m" "$MODEL")
fi

if $SKIP_PERMS; then
  CMD+=("--dangerously-skip-permissions")
fi

# ── Execute ───────────────────────────────────────────────────────────────────
if [ ${#EXTRA_ARGS[@]} -gt 0 ]; then
  # Has positional args → non-interactive run mode
  CMD+=("${EXTRA_ARGS[@]+"${EXTRA_ARGS[@]}"}")
  exec "${CMD[@]}"
else
  # No args → launch interactive TUI
  exec opencode
fi
