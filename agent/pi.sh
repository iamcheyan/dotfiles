#!/usr/bin/env bash
# Usage:
#   pi                          # Run Pi (auto-install if needed)
#   pi <args>                   # Pass arguments to Pi
#   pi -f                       # Force reinstall Pi
#
# Pi is auto-installed to ~/Development/pi/ if not present.
# Binary path is resolved from PI_REPO or ~/Development/pi/.

set -euo pipefail

# Ensure ~/.pi/bin is in PATH (created by pi installer)
export PATH="$HOME/.pi/bin:$PATH"

PI_ROOT="${PI_REPO:-$HOME/Development/pi}"

# Check for -f flag (force reinstall)
FORCE_REINSTALL=false
for arg in "$@"; do
  if [ "$arg" = "-f" ]; then
    FORCE_REINSTALL=true
    break
  fi
done

# Ensure npm is available (needed by pi-subagents)
if ! command -v npm &>/dev/null; then
  echo "npm not found, installing Node.js..."
  if [[ "$OSTYPE" == "darwin"* ]]; then
    if command -v brew &>/dev/null; then
      brew install node
    else
      echo "Error: brew not found. Install Homebrew first: https://brew.sh" >&2
      exit 1
    fi
  elif [[ -f /etc/debian_version ]]; then
    curl -fsSL https://deb.nodesource.com/setup_22.x | sudo bash -
    sudo apt install -y nodejs
  elif [[ -f /etc/redhat-release ]]; then
    curl -fsSL https://rpm.nodesource.com/setup_22.x | sudo bash -
    sudo yum install -y nodejs
  else
    echo "Error: npm not found. Install Node.js manually: https://nodejs.org" >&2
    exit 1
  fi
fi

# Auto-install if PI_ROOT doesn't exist or force reinstall
if $FORCE_REINSTALL || [[ ! -d "$PI_ROOT" ]]; then
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
