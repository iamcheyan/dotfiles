#!/usr/bin/env bash
# Usage:
#   agy                          # Run Antigravity CLI
#   agy -f                       # Force reinstall Antigravity
#   agy -s, --select             # Interactive account selection
#   agy --profile <email>        # Run with specific account
#   agy --list-profiles          # List all accounts
#   agy --switch <email>         # Switch active account
#
# Examples:
#   agy --profile iamcheyan@gmail.com    # Use specific account
#   agy --select                         # Interactive account selection
#   agy --list-profiles                  # Show all accounts

set -euo pipefail

export NVM_DIR="${NVM_DIR:-$HOME/.nvm}"
if [ -s "$NVM_DIR/nvm.sh" ]; then
  \. "$NVM_DIR/nvm.sh"
fi

# Check for -f flag (force reinstall)
FORCE_REINSTALL=false
for arg in "$@"; do
  if [ "$arg" = "-f" ]; then
    FORCE_REINSTALL=true
    break
  fi
done

# Install if needed
if $FORCE_REINSTALL || ! command -v agy &>/dev/null; then
  if command -v nvm &>/dev/null; then
    nvm use node
  fi
  echo "agy not found, installing..."
  curl -fsSL https://antigravity.google/cli/install.sh | bash
fi

ACCOUNTS_FILE="$HOME/.config/opencode/antigravity-accounts.json"
AUTH_FILE="$HOME/.local/share/opencode/auth.json"
GEMINI_ACCOUNTS="$HOME/.gemini/google_accounts.json"
GEMINI_OAUTH="$HOME/.gemini/oauth_creds.json"

# Load OAuth credentials from local .env if available
ANTIGRAVITY_CLIENT_ID=""
ANTIGRAVITY_CLIENT_SECRET=""
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -f "$SCRIPT_DIR/.env" ]; then
  ANTIGRAVITY_CLIENT_ID=$(grep -E "^ANTIGRAVITY_CLIENT_ID=" "$SCRIPT_DIR/.env" | cut -d'=' -f2- | tr -d '"'\' | tr -d '\r')
  ANTIGRAVITY_CLIENT_SECRET=$(grep -E "^ANTIGRAVITY_CLIENT_SECRET=" "$SCRIPT_DIR/.env" | cut -d'=' -f2- | tr -d '"'\' | tr -d '\r')
fi

iso8601_utc_from_epoch() {
  local epoch="$1"
  if date -u -r "$epoch" "+%Y-%m-%dT%H:%M:%S.000000Z" >/dev/null 2>&1; then
    date -u -r "$epoch" "+%Y-%m-%dT%H:%M:%S.000000Z"
  else
    date -u -d "@$epoch" "+%Y-%m-%dT%H:%M:%S.000000Z"
  fi
}

refresh_antigravity_access_token() {
  local refresh_token="$1"
  curl -fsS --retry 2 --connect-timeout 10 \
    -H "Content-Type: application/x-www-form-urlencoded" \
    --data-urlencode "grant_type=refresh_token" \
    --data-urlencode "refresh_token=$refresh_token" \
    --data-urlencode "client_id=$ANTIGRAVITY_CLIENT_ID" \
    --data-urlencode "client_secret=$ANTIGRAVITY_CLIENT_SECRET" \
    "https://oauth2.googleapis.com/token"
}

update_antigravity_keychain() {
  local refresh_token="$1"
  local response access_token expires_in expiry_epoch expiry payload encoded

  if ! command -v security >/dev/null 2>&1; then
    return 0
  fi

  if ! response=$(refresh_antigravity_access_token "$refresh_token"); then
    echo "Error: failed to refresh Antigravity access token; Keychain not updated" >&2
    return 1
  fi
  access_token=$(jq -r '.access_token // empty' <<<"$response")
  expires_in=$(jq -r '.expires_in // 3600' <<<"$response")

  if [ -z "$access_token" ]; then
    echo "Error: failed to refresh Antigravity access token; Keychain not updated" >&2
    return 1
  fi

  expiry_epoch=$(($(date +%s) + expires_in))
  expiry=$(iso8601_utc_from_epoch "$expiry_epoch")
  payload=$(jq -cn \
    --arg access "$access_token" \
    --arg refresh "$refresh_token" \
    --arg expiry "$expiry" \
    '{
      token: {
        access_token: $access,
        token_type: "Bearer",
        refresh_token: $refresh,
        expiry: $expiry
      },
      auth_method: "consumer"
    }')
  encoded=$(printf '%s' "$payload" | base64 | tr -d '\n')

  security delete-generic-password -s gemini -a antigravity >/dev/null 2>&1 || true
  if ! security add-generic-password -s gemini -a antigravity -w "go-keyring-base64:$encoded" -A >/dev/null; then
    echo "Error: failed to write Antigravity credentials to Keychain" >&2
    return 1
  fi
}

# Update all auth files with the selected account's google refresh token
update_auth() {
  local index="$1"
  local refresh_token email project_id packed_refresh
  refresh_token=$(jq -r ".accounts[$index].refreshToken" "$ACCOUNTS_FILE")
  email=$(jq -r ".accounts[$index].email" "$ACCOUNTS_FILE")
  project_id=$(jq -r ".accounts[$index].projectId // empty" "$ACCOUNTS_FILE")
  packed_refresh="$refresh_token"
  if [ -n "$project_id" ]; then
    packed_refresh="${refresh_token}|${project_id}"
  fi

  # Update opencode auth.json
  if [ -f "$AUTH_FILE" ] && [ "$refresh_token" != "null" ] && [ -n "$refresh_token" ]; then
    jq --arg rt "$packed_refresh" '.google.refresh = $rt | .google.access = "" | .google.expires = 0' "$AUTH_FILE" > "${AUTH_FILE}.tmp" && mv "${AUTH_FILE}.tmp" "$AUTH_FILE"
  fi

  # Update Gemini CLI google_accounts.json (active account)
  if [ -f "$GEMINI_ACCOUNTS" ] && [ "$email" != "null" ] && [ -n "$email" ]; then
    jq --arg email "$email" '.active = $email' "$GEMINI_ACCOUNTS" > "${GEMINI_ACCOUNTS}.tmp" && mv "${GEMINI_ACCOUNTS}.tmp" "$GEMINI_ACCOUNTS"
  fi

  # Update Gemini CLI oauth_creds.json (refresh token, clear cached tokens)
  if [ -f "$GEMINI_OAUTH" ] && [ "$refresh_token" != "null" ] && [ -n "$refresh_token" ]; then
    jq --arg rt "$refresh_token" '.refresh_token = $rt | .id_token = null | .access_token = null' "$GEMINI_OAUTH" > "${GEMINI_OAUTH}.tmp" && mv "${GEMINI_OAUTH}.tmp" "$GEMINI_OAUTH"
  fi

  # Update Antigravity CLI keyring used by native `antigravity`.
  if [ "$refresh_token" != "null" ] && [ -n "$refresh_token" ]; then
    update_antigravity_keychain "$refresh_token"
  fi
}

if [ ! -f "$ACCOUNTS_FILE" ]; then
  echo "Error: Accounts file not found at $ACCOUNTS_FILE" >&2
  exit 1
fi

# Parse arguments
SELECT_MODE=false
LIST_PROFILES=false
PROFILE_EMAIL=""
SWITCH_EMAIL=""
EXTRA_ARGS=()

while [ "$#" -gt 0 ]; do
  arg="$1"
  if [ "$arg" = "-s" ] || [ "$arg" = "--select" ]; then
    SELECT_MODE=true
    shift
  elif [ "$arg" = "--list-profiles" ]; then
    LIST_PROFILES=true
    shift
  elif [ "$arg" = "--profile" ]; then
    if [ "$#" -lt 2 ]; then
      echo "Error: --profile requires an email address" >&2
      exit 1
    fi
    PROFILE_EMAIL="$2"
    shift 2
  elif [ "$arg" = "--switch" ]; then
    if [ "$#" -lt 2 ]; then
      echo "Error: --switch requires an email address" >&2
      exit 1
    fi
    SWITCH_EMAIL="$2"
    shift 2
  else
    EXTRA_ARGS+=("$arg")
    shift
  fi
done

# Handle --list-profiles
if $LIST_PROFILES; then
  echo "Available accounts:"
  jq -r '.accounts[] | "  - \(.email)"' "$ACCOUNTS_FILE"
  echo ""
  echo "Active account:"
  ACTIVE_INDEX=$(jq -r '.activeIndex' "$ACCOUNTS_FILE")
  ACTIVE_EMAIL=$(jq -r ".accounts[$ACTIVE_INDEX].email" "$ACCOUNTS_FILE")
  echo "  $ACTIVE_EMAIL"
  exit 0
fi

# Handle --profile
if [ -n "$PROFILE_EMAIL" ] || [ -n "$SWITCH_EMAIL" ]; then
  if [ -n "$SWITCH_EMAIL" ]; then
    PROFILE_EMAIL="$SWITCH_EMAIL"
  fi
  PROFILE_INDEX=""

  if [ -z "$PROFILE_EMAIL" ]; then
    echo "Error: --profile requires an email address" >&2
    exit 1
  fi

  # Find the index of the account with the given email
  PROFILE_INDEX=$(jq -r --arg email "$PROFILE_EMAIL" '.accounts | to_entries[] | select(.value.email == $email) | .key' "$ACCOUNTS_FILE")
  
  if [ -z "$PROFILE_INDEX" ]; then
    echo "Error: Account '$PROFILE_EMAIL' not found" >&2
    echo "Available accounts:"
    jq -r '.accounts[].email' "$ACCOUNTS_FILE"
    exit 1
  fi

  # Update activeIndex
  jq --argjson index "$PROFILE_INDEX" '.activeIndex = $index' "$ACCOUNTS_FILE" > "${ACCOUNTS_FILE}.tmp" && mv "${ACCOUNTS_FILE}.tmp" "$ACCOUNTS_FILE"
  update_auth "$PROFILE_INDEX"
  echo "Switched to account: $PROFILE_EMAIL"
fi

# Handle interactive selection
if $SELECT_MODE; then
  echo "Available accounts:"
  ACCOUNTS=()
  while IFS= read -r email; do
    ACCOUNTS+=("$email")
  done < <(jq -r '.accounts[].email' "$ACCOUNTS_FILE")

  ACTIVE_INDEX=$(jq -r '.activeIndex' "$ACCOUNTS_FILE")
  ACTIVE_EMAIL=$(jq -r ".accounts[$ACTIVE_INDEX].email" "$ACCOUNTS_FILE")

  echo ""
  for i in "${!ACCOUNTS[@]}"; do
    if [ "${ACCOUNTS[$i]}" = "$ACTIVE_EMAIL" ]; then
      echo "  $((i+1)). ${ACCOUNTS[$i]} (active)"
    else
      echo "  $((i+1)). ${ACCOUNTS[$i]}"
    fi
  done

  echo ""
  read -p "Select account (1-${#ACCOUNTS[@]}): " CHOICE

  if [[ "$CHOICE" =~ ^[0-9]+$ ]] && [ "$CHOICE" -ge 1 ] && [ "$CHOICE" -le "${#ACCOUNTS[@]}" ]; then
    SELECTED_EMAIL="${ACCOUNTS[$((CHOICE-1))]}"
    SELECTED_INDEX=$((CHOICE-1))
    
    # Update activeIndex
    jq --argjson index "$SELECTED_INDEX" '.activeIndex = $index' "$ACCOUNTS_FILE" > "${ACCOUNTS_FILE}.tmp" && mv "${ACCOUNTS_FILE}.tmp" "$ACCOUNTS_FILE"
    update_auth "$SELECTED_INDEX"
    echo "Switched to account: $SELECTED_EMAIL"
  else
    echo "Invalid choice" >&2
    exit 1
  fi
fi

exec antigravity "${EXTRA_ARGS[@]+"${EXTRA_ARGS[@]}"}"
