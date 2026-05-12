#!/usr/bin/env bash
set -euo pipefail

NVM_DIR="${NVM_DIR:-$HOME/.nvm}"

if [[ -s "$NVM_DIR/nvm.sh" ]]; then
  # shellcheck disable=SC1090
  . "$NVM_DIR/nvm.sh"
else
  echo "Error: nvm.sh not found at $NVM_DIR/nvm.sh" >&2
  exit 1
fi

resolve_hunk_bin() {
  local current_version default_version version

  current_version="$(nvm current 2>/dev/null || true)"
  if [[ -n "$current_version" && "$current_version" != "none" ]]; then
    version="${current_version#v}"
    if [[ -x "$NVM_DIR/versions/node/v${version}/bin/hunk" ]]; then
      printf '%s\n' "$NVM_DIR/versions/node/v${version}/bin/hunk"
      return 0
    fi
  fi

  default_version="$(nvm version default 2>/dev/null || true)"
  if [[ -n "$default_version" && "$default_version" != "N/A" && "$default_version" != "system" ]]; then
    version="${default_version#v}"
    if [[ -x "$NVM_DIR/versions/node/v${version}/bin/hunk" ]]; then
      nvm use "$version" >/dev/null 2>&1 || true
      printf '%s\n' "$NVM_DIR/versions/node/v${version}/bin/hunk"
      return 0
    fi
  fi

  for candidate in "$NVM_DIR"/versions/node/*/bin/hunk; do
    if [[ -x "$candidate" ]]; then
      version="$(basename "$(dirname "$(dirname "$candidate")")")"
      version="${version#v}"
      nvm use "$version" >/dev/null 2>&1 || true
      printf '%s\n' "$candidate"
      return 0
    fi
  done

  return 1
}

if ! hunk_bin="$(resolve_hunk_bin)"; then
  echo "Error: hunk not found in any nvm-managed Node version under $NVM_DIR/versions/node" >&2
  exit 1
fi

exec "$hunk_bin" "$@"
