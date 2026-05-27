#!/usr/bin/env bash
# Usage:
#   cx                              # Run Codex with current login
#   cx --profile <name>             # Run with specific profile
#   cx --save-profile <name>        # Save current login as named profile
#   cx --list-profiles              # List saved profiles
#   cx --delete-profile <name>      # Delete a profile
#
# Examples:
#   cx --profile personal           # Use personal account
#   cx --profile work               # Use work account
#   cx --save-profile personal      # Save current login as "personal"
#   cx --list-profiles              # Show all saved profiles

set -euo pipefail

export NVM_DIR="${NVM_DIR:-$HOME/.nvm}"
if [ -s "$NVM_DIR/nvm.sh" ]; then
  \. "$NVM_DIR/nvm.sh"
fi

if ! command -v nvm &>/dev/null; then
  echo "Error: nvm not found. Install nvm first." >&2
  exit 1
fi

nvm use node

if ! command -v codex &>/dev/null; then
  echo "codex not found, installing @openai/codex..."
  npm i -g @openai/codex
fi

CODEX_DIR="$HOME/.codex"
AUTH_FILE="$CODEX_DIR/auth.json"
PROFILES_DIR="$CODEX_DIR/profiles"

mkdir -p "$PROFILES_DIR"

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
    exec codex "$@"
    ;;
esac
