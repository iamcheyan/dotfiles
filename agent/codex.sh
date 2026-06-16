#!/usr/bin/env bash
# Usage:
#   cx                              # Run Codex with current login
#   cx -s, --select                 # Interactive profile selection
#   cx --profile <name>             # Run with specific profile
#   cx --save-profile <name>        # Save current login as named profile
#   cx --list-profiles              # List saved profiles
#   cx --delete-profile <name>      # Delete a profile
#   cx -n                           # New profile (clear login, prompt for name, re-login)
#   cx -f                           # Force reinstall Codex
#   cx -u, --update                 # Update Codex to latest version
#
# Examples:
#   cx --profile personal           # Use personal account
#   cx --profile work               # Use work account
#   cx --save-profile personal      # Save current login as "personal"
#   cx --list-profiles              # Show all saved profiles
#
# ── Codex CLI Reference ──────────────────────────────────────────────────────
#
# Subcommands:
#   exec (e)            Run Codex non-interactively
#   review              Non-interactive code review
#   login               Manage login
#   logout              Remove stored auth credentials
#   mcp                 Manage external MCP servers
#   plugin              Manage Codex plugins
#   mcp-server          Run as MCP server (stdio)
#   app-server          [experimental] Run the app server
#   remote-control      [experimental] Manage app-server daemon
#   completion          Generate shell completion scripts
#   update              Update Codex to latest version
#   doctor              Diagnose installation, config, auth, runtime
#   sandbox             Run commands in a Codex sandbox
#   debug               Debugging tools
#   apply (a)           Apply latest agent diff via git apply
#   resume              Resume previous session (--last to skip picker)
#   fork                Fork previous session (--last to skip picker)
#   archive             Archive a session by id or name
#   delete              Permanently delete a session
#   unarchive           Unarchive a session
#   cloud               [experimental] Browse Codex Cloud tasks
#   exec-server         [experimental] Run standalone exec-server
#   features            Inspect feature flags
#
# Options (passed through to codex):
#   -m, --model <MODEL>           Model to use
#   -p, --profile <NAME>          Layer $CODEX_HOME/<name>.config.toml on top
#   -c, --config <key=value>      Override config.toml value (dotted path, TOML)
#   --enable <FEATURE>            Enable a feature flag (repeatable)
#   --disable <FEATURE>           Disable a feature flag (repeatable)
#   -i, --image <FILE>...         Attach image(s) to initial prompt
#   -C, --cd <DIR>                Set agent working root directory
#   --add-dir <DIR>               Additional writable directory
#   --search                      Enable live web search
#   --oss                         Use open-source provider
#   --local-provider <PROVIDER>   lmstudio or ollama
#   --remote <ADDR>               Connect to remote app server (ws/wss/unix)
#   --remote-auth-token-env <VAR> Bearer token env var for remote
#   --strict-config               Error on unrecognized config fields
#   --no-alt-screen               Inline TUI mode (preserve scrollback)
#   -V, --version                 Show version
#   -h, --help                    Show help
#
# Sandbox & Approval:
#   -s, --sandbox <MODE>          read-only | workspace-write | danger-full-access
#   -a, --ask-for-approval <POLICY>
#       untrusted   Only untrusted commands need approval
#       on-request  Model decides when to ask (interactive default)
#       never       Never ask for approval
#   --dangerously-bypass-approvals-and-sandbox   Skip all prompts & sandbox
#   --dangerously-bypass-hook-trust              Run hooks without trust check
#
# ─────────────────────────────────────────────────────────────────────────────

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

# fnm env only links node/npm/npx into PATH, not globally installed binaries.
# Add the actual npm global bin dir so installed tools (codex, etc.) are found.
NPM_GLOBAL_BIN="$(npm config get prefix 2>/dev/null)/bin"
[ -d "$NPM_GLOBAL_BIN" ] && export PATH="$NPM_GLOBAL_BIN:$PATH"

# Check for updates on normal run (not when flags are passed)
if [ $# -eq 0 ]; then
  CURRENT=$(npm list -g @openai/codex --depth=0 2>/dev/null | grep '@openai/codex' | sed 's/.*@//' || true)
  LATEST=$(npm view @openai/codex version 2>/dev/null || true)
  if [ -n "$CURRENT" ] && [ -n "$LATEST" ] && [ "$CURRENT" != "$LATEST" ]; then
    echo "⬆️  Update available: $CURRENT -> $LATEST (run: cx -u)"
  fi
fi

# Check for -f flag (force reinstall) and -u flag (update)
FORCE_REINSTALL=false
UPDATE_MODE=false
for arg in "$@"; do
  if [ "$arg" = "-f" ]; then
    FORCE_REINSTALL=true
  elif [ "$arg" = "-u" ] || [ "$arg" = "--update" ]; then
    UPDATE_MODE=true
  fi
done

# Handle -u/--update: update codex and exit
if $UPDATE_MODE; then
  echo "Updating @openai/codex..."
  npm install -g @openai/codex@latest
  echo "Done."
  exit 0
fi

if $FORCE_REINSTALL || ! command -v codex &>/dev/null; then
  echo "Installing/reinstalling @openai/codex..."
  npm install -g @openai/codex@latest
fi

CODEX_DIR="$HOME/.codex"
AUTH_FILE="$CODEX_DIR/auth.json"
PROFILES_DIR="$CODEX_DIR/profiles"

mkdir -p "$PROFILES_DIR"

SELECT_MODE=false
NEW_PROFILE=false
EXTRA_ARGS=()

for arg in "$@"; do
  if [ "$arg" = "-s" ] || [ "$arg" = "--select" ]; then
    SELECT_MODE=true
  elif [ "$arg" = "-n" ]; then
    NEW_PROFILE=true
  elif [ "$arg" = "-u" ] || [ "$arg" = "--update" ]; then
    : # handled above, skip
  else
    EXTRA_ARGS+=("$arg")
  fi
done

# Handle -n flag: new profile with fresh login
if $NEW_PROFILE; then
  read -rp "Enter profile name: " PROFILE_NAME
  if [ -z "$PROFILE_NAME" ]; then
    echo "Error: Profile name cannot be empty." >&2
    exit 1
  fi

  # Check if profile already exists
  if [ -f "$PROFILES_DIR/$PROFILE_NAME.json" ]; then
    read -rp "Profile '$PROFILE_NAME' already exists. Overwrite? (y/N): " CONFIRM
    if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
      echo "Aborted."
      exit 0
    fi
  fi

  # Clear current auth (start fresh)
  rm -f "$AUTH_FILE"
  echo "Cleared login state. Please login..."
  codex login

  # Save new profile
  if [ -f "$AUTH_FILE" ]; then
    cp "$AUTH_FILE" "$PROFILES_DIR/$PROFILE_NAME.json"
    echo "Profile '$PROFILE_NAME' created and saved."
  else
    echo "Error: Login failed. No auth.json created." >&2
    exit 1
  fi
  exec codex
fi

# Interactive profile selection via fzf
if $SELECT_MODE; then
  if ! ls "$PROFILES_DIR"/*.json 1>/dev/null 2>&1; then
    echo "Error: No profiles found. Save one with: cx --save-profile <name>" >&2
    exit 1
  fi

  PROFILE_NAME=$(ls "$PROFILES_DIR"/*.json | while read -r f; do basename "$f" .json; done | command fzf \
    --header 'Select profile' \
    --height 90% --layout=reverse --border \
  ) || exit 1

  echo "Selected: $PROFILE_NAME"

  # Apply selected profile
  if [ ! -f "$PROFILES_DIR/$PROFILE_NAME.json" ]; then
    echo "Error: Profile '$PROFILE_NAME' not found." >&2
    exit 1
  fi
  cp "$PROFILES_DIR/$PROFILE_NAME.json" "$AUTH_FILE"
  echo "Switched to profile '$PROFILE_NAME'."
  exec codex ${EXTRA_ARGS[@]+"${EXTRA_ARGS[@]}"}
fi

case "${1:-}" in
  --save-profile)
    PROFILE_NAME="${2:-}"
    if [ -z "$PROFILE_NAME" ]; then
      echo "Usage: cx --save-profile <name>" >&2
      exit 1
    fi
    if [ ! -f "$AUTH_FILE" ]; then
      echo "Error: No auth.json found. Please login first with: codex login" >&2
      exit 1
    fi
    cp "$AUTH_FILE" "$PROFILES_DIR/$PROFILE_NAME.json"
    echo "Profile '$PROFILE_NAME' saved."
    ;;

  --list-profiles)
    echo "Saved profiles:"
    if ls "$PROFILES_DIR"/*.json 1>/dev/null 2>&1; then
      for f in "$PROFILES_DIR"/*.json; do
        name=$(basename "$f" .json)
        echo "  - $name"
      done
    else
      echo "  (none)"
    fi
    ;;

  --delete-profile)
    PROFILE_NAME="${2:-}"
    if [ -z "$PROFILE_NAME" ]; then
      echo "Usage: cx --delete-profile <name>" >&2
      exit 1
    fi
    if [ -f "$PROFILES_DIR/$PROFILE_NAME.json" ]; then
      rm "$PROFILES_DIR/$PROFILE_NAME.json"
      echo "Profile '$PROFILE_NAME' deleted."
    else
      echo "Error: Profile '$PROFILE_NAME' not found." >&2
      exit 1
    fi
    ;;

  --profile)
    PROFILE_NAME="${2:-}"
    if [ -z "$PROFILE_NAME" ]; then
      echo "Usage: cx --profile <name>" >&2
      exit 1
    fi
    if [ ! -f "$PROFILES_DIR/$PROFILE_NAME.json" ]; then
      echo "Profile '$PROFILE_NAME' not found. Please login to create it."
      codex login
      if [ -f "$AUTH_FILE" ]; then
        cp "$AUTH_FILE" "$PROFILES_DIR/$PROFILE_NAME.json"
        echo "Profile '$PROFILE_NAME' created."
      else
        echo "Error: Login failed." >&2
        exit 1
      fi
    else
      cp "$PROFILES_DIR/$PROFILE_NAME.json" "$AUTH_FILE"
      echo "Switched to profile '$PROFILE_NAME'."
    fi
    shift 2
    exec codex "$@"
    ;;

  *)
    if [ $# -eq 0 ]; then
      exec codex resume --last -a never
    else
      exec codex "$@"
    fi
    ;;
esac
