#!/usr/bin/env bash
set -euo pipefail

FNM_DIR="${FNM_DIR:-$HOME/.fnm}"
export FNM_DIR
export PATH="$FNM_DIR:$FNM_DIR/bin:$HOME/.local/share/fnm:$HOME/.local/bin:$PATH"

if command -v fnm >/dev/null 2>&1; then
  eval "$(fnm env --shell bash)"
  fnm use default >/dev/null 2>&1 || true
fi

hunk_bin="$(command -v hunk 2>/dev/null || command -v hunkdiff 2>/dev/null || true)"
if [[ -z "$hunk_bin" || "$hunk_bin" == "$0" ]]; then
  echo "Error: hunk not found in fnm-managed Node versions or PATH" >&2
  exit 1
fi

exec "$hunk_bin" "$@"
