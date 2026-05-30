#!/usr/bin/env bash
# Usage:
#   pi                          # Run Pi (auto-install if needed)
#   pi <args>                   # Pass arguments to Pi
#
# Pi is auto-installed to ~/Development/pi/ if not present.
# Binary path is resolved from PI_REPO or ~/Development/pi/.

set -euo pipefail

PI_ROOT="${PI_REPO:-$HOME/Development/pi}"

# Auto-install if PI_ROOT doesn't exist
if [[ ! -d "$PI_ROOT" ]]; then
  echo "Pi not found at $PI_ROOT, installing..."
  curl -fsSL https://raw.githubusercontent.com/iamcheyan/pi/main/fork/init.sh | bash
fi

# Resolve binary path
if [[ -f "$PI_ROOT/packages/coding-agent/dist/pi" ]]; then
  PI_BIN="$PI_ROOT/packages/coding-agent/dist/pi"
elif [[ "$OSTYPE" == "darwin"* ]]; then
  PI_BIN="$PI_ROOT/fork/dist/pi-darwin-arm64/bin/pi"
else
  PI_BIN="$PI_ROOT/fork/dist/pi-linux-x64/bin/pi"
fi

# Fallback to ~/.pi/bin/pi (installed by curl remote mode)
[[ ! -x "$PI_BIN" ]] && PI_BIN="$HOME/.pi/bin/pi"

if [[ ! -x "$PI_BIN" ]]; then
  echo "Error: Pi binary not found. Tried:" >&2
  echo "  $PI_ROOT/packages/coding-agent/dist/pi" >&2
  echo "  $PI_ROOT/fork/dist/pi-darwin-arm64/bin/pi" >&2
  echo "  $PI_ROOT/fork/dist/pi-linux-x64/bin/pi" >&2
  echo "  $HOME/.pi/bin/pi" >&2
  exit 1
fi

exec "$PI_BIN" "$@"
