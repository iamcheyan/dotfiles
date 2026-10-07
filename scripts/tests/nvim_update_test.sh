#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd)"
updater="$repo_root/scripts/update_nvim.sh"
tmp="$(mktemp -d)"
cleanup() { rm -rf -- "$tmp"; }
trap cleanup EXIT

fixture="$tmp/fixture/nvim-linux-x86_64"
mkdir -p "$fixture/bin" "$fixture/share/nvim/runtime" "$tmp/home/.local/bin"
printf '#!/usr/bin/env sh\nprintf "NVIM v0.12.5\\n"\n' > "$fixture/bin/nvim"
chmod +x "$fixture/bin/nvim"
printf 'runtime fixture\n' > "$fixture/share/nvim/runtime/doc.txt"
archive="$tmp/nvim-linux-x86_64.tar.gz"
tar -czf "$archive" -C "$tmp/fixture" nvim-linux-x86_64
if command -v sha256sum >/dev/null 2>&1; then
  digest="$(sha256sum "$archive")"
else
  digest="$(shasum -a 256 "$archive")"
fi
digest="${digest%% *}"
asset_url="file://$archive"
api="$tmp/release.json"
jq -n --arg tag 'v0.12.5' --arg name 'nvim-linux-x86_64.tar.gz' \
  --arg url "$asset_url" --arg digest "sha256:$digest" \
  '{tag_name:$tag,assets:[{name:$name,browser_download_url:$url,digest:$digest}]}' > "$api"

NVIM_UPDATE_RELEASE_API_URL="file://$api" \
NVIM_UPDATE_INSTALL_ROOT="$tmp/home/.local/opt/neovim" \
NVIM_UPDATE_BIN_DIR="$tmp/home/.local/bin" \
  "$updater"

link="$tmp/home/.local/bin/nvim"
test -L "$link"
test "$(readlink "$link")" = "$tmp/home/.local/opt/neovim/0.12.5/bin/nvim"
test "$("$link" --version)" = 'NVIM v0.12.5'

# Re-running with the same release should be safe and keep the same link.
NVIM_UPDATE_RELEASE_API_URL="file://$api" \
NVIM_UPDATE_INSTALL_ROOT="$tmp/home/.local/opt/neovim" \
NVIM_UPDATE_BIN_DIR="$tmp/home/.local/bin" \
  "$updater"
test "$(readlink "$link")" = "$tmp/home/.local/opt/neovim/0.12.5/bin/nvim"

# Never overwrite a regular user-owned file at the command path.
rm -- "$link"
printf 'user file\n' > "$link"
if NVIM_UPDATE_RELEASE_API_URL="file://$api" \
  NVIM_UPDATE_INSTALL_ROOT="$tmp/home/.local/opt/neovim" \
  NVIM_UPDATE_BIN_DIR="$tmp/home/.local/bin" \
  "$updater" > "$tmp/conflict.log" 2>&1; then
  printf 'Expected conflict refusal for a regular ~/.local/bin/nvim file\n' >&2
  exit 1
fi
test "$(<"$link")" = 'user file'

# A digest mismatch must fail before publishing a new command.
wrong_api="$tmp/wrong-release.json"
jq -n --arg tag 'v0.12.5' --arg name 'nvim-linux-x86_64.tar.gz' \
  --arg url "$asset_url" --arg digest "sha256:$(printf '%064d' 0)" \
  '{tag_name:$tag,assets:[{name:$name,browser_download_url:$url,digest:$digest}]}' > "$wrong_api"
wrong_bin="$tmp/wrong-home/.local/bin"
if NVIM_UPDATE_RELEASE_API_URL="file://$wrong_api" \
  NVIM_UPDATE_INSTALL_ROOT="$tmp/wrong-home/.local/opt/neovim" \
  NVIM_UPDATE_BIN_DIR="$wrong_bin" \
  "$updater" > "$tmp/digest.log" 2>&1; then
  printf 'Expected digest mismatch to be rejected\n' >&2
  exit 1
fi
test ! -e "$wrong_bin/nvim"

zsh -n "$repo_root/aliases.conf"
stub_bin="$tmp/stub-bin"
mkdir -p "$stub_bin"
printf '#!/usr/bin/env sh\nexit 0\n' > "$stub_bin/fnm"
chmod +x "$stub_bin/fnm"
alias_output="$(PATH="$stub_bin:$PATH" DOTFILES_ROOT="$repo_root" zsh -f -c 'source "$DOTFILES_ROOT/aliases.conf"; alias nvim-update' 2>/dev/null)"
case "$alias_output" in
  *"scripts/update_nvim.sh"*) ;;
  *) printf 'nvim-update alias does not invoke the updater script\n' >&2; exit 1 ;;
esac
alias_help="$(PATH="$stub_bin:$PATH" DOTFILES_ROOT="$repo_root" zsh -f -i -c 'source "$DOTFILES_ROOT/aliases.conf"; eval "nvim-update --help"' 2>/dev/null)"
case "$alias_help" in
  *"Usage: nvim-update"*) ;;
  *) printf 'nvim-update alias did not execute its --help branch' >&2; exit 1 ;;
esac
printf 'nvim_update_test: OK\n'
