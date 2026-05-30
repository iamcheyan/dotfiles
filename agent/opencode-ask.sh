#!/usr/bin/env bash
# oc-ask — Quick opencode question using free model (non-interactive)
#
# Usage:
#   oc-ask <question>                    # Ask with default model (mimo, free)
#   oc-ask -m provider/model <question>  # Specify model
#   oc-ask -p <file> <question>          # Attach file context
#   oc-ask -c <question>                 # Continue last session
#   oc-ask --dangerously-skip-permissions <question>  # Auto-approve all
#   oc-ask -f <question>                              # Force reinstall opencode
# Examples:
#   oc-ask "what does this script do" ./setup.sh
#   oc-ask "fix the typo in README.md"
#   oc-ask -m zhipu/glm-4-flash "翻译这段话"
#   oc-ask -c "继续上次的讨论"
#   echo "error log" | oc-ask "分析这个错误"

set -euo pipefail

OPENCODE_BIN="$HOME/.local/bin/opencode"

# Check for -f flag (force reinstall)
FORCE_REINSTALL=false
for arg in "$@"; do
  if [ "$arg" = "-f" ]; then
    FORCE_REINSTALL=true
    break
  fi
done

# ── Install check ─────────────────────────────────────────────────────────────
if $FORCE_REINSTALL || [ ! -x "$OPENCODE_BIN" ]; then
  # Try global opencode
  if command -v opencode &>/dev/null; then
    OPENCODE_BIN="$(command -v opencode)"
  else
    echo "opencode not found, installing..." >&2
    curl -fsSL https://opencode.ai/install | bash
    export PATH="$HOME/.local/bin:$PATH"
    if ! command -v opencode &>/dev/null; then
      echo "Error: opencode installation failed." >&2
      exit 1
    fi
    OPENCODE_BIN="$(command -v opencode)"
  fi
fi

# ── Build command ─────────────────────────────────────────────────────────────
CMD=("$OPENCODE_BIN" "run" "--dangerously-skip-permissions")

# Parse flags
while [ $# -gt 0 ]; do
  case "$1" in
    -m|--model)
      shift
      CMD+=("-m" "$1")
      ;;
    -p|--file)
      shift
      CMD+=("-f" "$1")
      ;;
    -c|--continue)
      CMD+=("-c")
      ;;
    *)
      break
      ;;
  esac
  shift
done

# ── Collect question ──────────────────────────────────────────────────────────
# Remaining args become the prompt
QUESTION="$*"

# If no args and stdin is not a terminal, read from pipe
if [ -z "$QUESTION" ] && [ ! -t 0 ]; then
  QUESTION="$(cat)"
fi

if [ -z "$QUESTION" ]; then
  echo "Usage: oc-ask <question>" >&2
  echo "       oc-ask -m provider/model <question>" >&2
  echo "       echo 'content' | oc-ask <question>" >&2
  exit 1
fi

# ── Run ───────────────────────────────────────────────────────────────────────
exec "${CMD[@]}" "$QUESTION"
