#!/usr/bin/env bash
# Usage:
#   pi                          # Continue last session
#   pi <args>                   # Pass arguments to Pi
#   pi --reinstall              # Clean install: remove old files, re-run init.sh, sync skills
#
# Pi is auto-installed to ~/Development/pi/ if not present.
# Binary path is resolved from PI_REPO or ~/Development/pi/.
#
# ── Pi CLI Reference ────────────────────────────────────────────────────────
#
# Session:
#   --continue, -c                Continue previous session
#   --resume, -r                  Select a session to resume
#   --session <path|id>           Use specific session file or partial UUID
#   --session-id <id>             Use exact project session ID
#   --session-dir <dir>           Directory for session storage
#   --fork <path|id>              Fork session into a new one
#   --no-session                  Don't save session (ephemeral)
#   --name, -n <name>             Set session display name
#
# Model & Provider:
#   --provider <name>             Provider name (default: google)
#   --model <pattern>             Model pattern or ID (supports "provider/id" and ":<thinking>")
#   --models <patterns>           Comma-separated model patterns for Ctrl+P cycling
#   --api-key <key>               API key (defaults to env vars)
#   --list-models [search]        List available models (with fuzzy search)
#
# Input / Output:
#   --print, -p                   Non-interactive mode: process prompt and exit
#   --mode <mode>                 Output mode: text (default), json, or rpc
#   --export <file>               Export session to HTML and exit
#   @files...                     Include files in initial message
#
# Prompt & Context:
#   --system-prompt <text>        System prompt
#   --append-system-prompt <text> Append text/file to system prompt (repeatable)
#   --thinking <level>            off | minimal | low | medium | high | xhigh
#
# Tools:
#   --no-tools, -nt               Disable all tools by default
#   --no-builtin-tools, -nbt      Disable built-in tools (keep extension tools)
#   --tools, -t <tools>           Comma-separated allowlist of tool names
#   --exclude-tools, -xt <tools>  Comma-separated denylist of tool names
#
# Extensions & Skills:
#   --extension, -e <path>        Load extension file (repeatable)
#   --no-extensions, -ne          Disable extension discovery
#   --skill <path>                Load skill file or directory (repeatable)
#   --no-skills, -ns              Disable skills discovery
#   --prompt-template <path>      Load prompt template (repeatable)
#   --no-prompt-templates, -np    Disable prompt template discovery
#   --theme <path>                Load theme file or directory (repeatable)
#   --no-themes                   Disable theme discovery
#
# Approval & Safety:
#   --approve, -a                 Trust project-local files for this run
#   --no-approve, -na             Ignore project-local files for this run
#   --no-context-files, -nc       Disable AGENTS.md and CLAUDE.md discovery
#   --offline                     Disable startup network operations
#
# MCP:
#   --mcp-config <value>          Path to MCP config file
#
# CLI Options:
#   --verbose                     Force verbose startup
#   --help, -h                    Show help
#   --version, -v                 Show version
#
# Subcommands:
#   install <source> [-l]         Install extension source
#   remove <source> [-l]          Remove extension source
#   update [source|self|pi]       Update pi and extensions
#   list                          List installed extensions
#   config                        Open TUI to enable/disable resources
#
# ─────────────────────────────────────────────────────────────────────────────

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
if $FORCE_REINSTALL || [[ ! -d "$PI_ROOT" ]] || \
   [[ ! -x "$PI_ROOT/packages/coding-agent/dist/pi" && \
      ! -x "$PI_ROOT/fork/dist/pi-linux-x64/bin/pi" ]]; then
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

if [ ${#PI_ARGS[@]} -eq 0 ]; then
  exec "$PI_BIN" --continue
else
  exec "$PI_BIN" "${PI_ARGS[@]}"
fi
