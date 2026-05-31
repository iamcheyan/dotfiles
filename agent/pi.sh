#!/usr/bin/env bash
# Usage:
#   pi                          # Run Pi (auto-install if needed)
#   pi <args>                   # Pass arguments to Pi
#   pi --reinstall              # Clean install: remove old files, re-run init.sh, sync skills
#
# Pi is auto-installed to ~/Development/pi/ if not present.
# Binary path is resolved from PI_REPO or ~/Development/pi/.

set -euo pipefail

# Ensure ~/.pi/bin is in PATH (created by pi installer)
export PATH="$HOME/.pi/bin:$PATH"

PI_ROOT="${PI_REPO:-$HOME/Development/pi}"

# ── Parse --reinstall flag and strip it from args ──────────────────────
FORCE_REINSTALL=false
PI_ARGS=()
for arg in "$@"; do
  if [[ "$arg" == "--reinstall" || "$arg" == "-r" ]]; then
    FORCE_REINSTALL=true
  else
    PI_ARGS+=("$arg")
  fi
done

# ── Ensure npm is available ────────────────────────────────────────────
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

# ── Handle --reinstall: clean + init + sync skills ─────────────────────
if $FORCE_REINSTALL; then
  echo "🗑️  Cleaning old installation..."

  # Remove extensions (will be recreated by init.sh)
  rm -rf "$HOME/.pi/agent/extensions/"*

  # Remove skills (will be recreated by init.sh + our sync below)
  rm -rf "$HOME/.pi/agent/skills/"*

  # Remove binary
  rm -f "$HOME/.pi/bin/pi"

  echo "  ✓ cleaned extensions, skills, and binary"
fi

# ── Auto-install if PI_ROOT doesn't exist ──────────────────────────────
if $FORCE_REINSTALL || [[ ! -d "$PI_ROOT" ]]; then
  if $FORCE_REINSTALL; then
    echo "🔄 Reinstalling Pi..."
  else
    echo "Pi not found at $PI_ROOT, installing..."
  fi
  curl -fsSL https://raw.githubusercontent.com/iamcheyan/pi/main/fork/init.sh | bash
fi

# ── Ensure pi-ralph is available locally (for skills sync) ─────────────
PI_RALPH_LOCAL="$PI_ROOT/fork/pi-ralph"
if [[ ! -d "$PI_RALPH_LOCAL" ]]; then
  mkdir -p "$PI_ROOT/fork"
  git clone --depth 1 https://github.com/iamcheyan/pi-ralph.git "$PI_RALPH_LOCAL" 2>/dev/null || true
fi

# ── Sync all skills from pi-ralph (covers skills missing from init.sh) ─
PI_RALPH_SKILLS="$PI_RALPH_LOCAL/skills"
if [[ -d "$PI_RALPH_SKILLS" ]]; then
  SKILLS_DIR="$HOME/.pi/agent/skills"
  for skill_dir in "$PI_RALPH_SKILLS"/*/; do
    skill="$(basename "$skill_dir")"
    src="$skill_dir/SKILL.md"
    if [[ -f "$src" && ! -f "$SKILLS_DIR/$skill/SKILL.md" ]]; then
      mkdir -p "$SKILLS_DIR/$skill"
      # Symlink in local mode, copy in remote mode
      if [[ "$PI_ROOT" == "$HOME/Development/pi" ]]; then
        ln -sfn "$src" "$SKILLS_DIR/$skill/SKILL.md"
      else
        cp "$src" "$SKILLS_DIR/$skill/SKILL.md"
      fi
      echo "  ✓ synced skill: $skill"
    fi
  done
fi

# ── Resolve binary path ────────────────────────────────────────────────
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

exec "$PI_BIN" "${PI_ARGS[@]}"
