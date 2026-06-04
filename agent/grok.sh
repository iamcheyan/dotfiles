#!/usr/bin/env bash
# Usage:
#   grok                          # Run Grok CLI
#   grok -f                       # Force reinstall Grok

set -euo pipefail

export FNM_DIR="${FNM_DIR:-$HOME/.fnm}"
export PATH="$FNM_DIR:$FNM_DIR/bin:$HOME/.local/share/fnm:$HOME/.local/bin:$PATH"

if ! command -v fnm &>/dev/null; then
  echo "Error: fnm not found. Run init.sh or install fnm first." >&2
  exit 1
fi

eval "$(fnm env --shell bash)"
fnm use default >/dev/null 2>&1 || {
  fnm install --lts
  latest=$(fnm list 2>/dev/null | grep -Eo 'v[0-9]+\.[0-9]+\.[0-9]+' | sort -V | tail -n 1 || true)
  [ -n "$latest" ] && fnm default "$latest" >/dev/null || true
  fnm use default >/dev/null || true
}

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
