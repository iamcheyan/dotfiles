#!/usr/bin/env bash
set -euo pipefail

if ! command -v broot >/dev/null 2>&1; then
  echo "broot is not installed or not in PATH" >&2
  exit 1
fi

CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"
REPO_BROOT_DIR="$HOME/dotfiles/config/broot"
CONFIG_DIR="$CONFIG_HOME/broot"
LAUNCHER_DIR="$CONFIG_HOME/broot/launcher"
LAUNCHER_FILE="$LAUNCHER_DIR/br"
INIT_FLAG="$STATE_HOME/broot/init.done"

mkdir -p "$CONFIG_DIR" "$LAUNCHER_DIR" "${INIT_FLAG%/*}"
if [[ -f "$REPO_BROOT_DIR/verbs.hjson" ]]; then
  install -m 0644 "$REPO_BROOT_DIR/verbs.hjson" "$CONFIG_DIR/verbs.hjson"
fi
broot --print-shell-function zsh > "$LAUNCHER_FILE"
chmod 0644 "$LAUNCHER_FILE"
broot --set-install-state installed >/dev/null 2>&1 || true
touch "$INIT_FLAG"
