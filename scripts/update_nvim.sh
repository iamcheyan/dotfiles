#!/usr/bin/env bash
# Upgrade Neovim to GitHub's latest stable release without replacing the OS package.
set -Eeuo pipefail

API_URL="${NVIM_UPDATE_RELEASE_API_URL:-https://api.github.com/repos/neovim/neovim/releases/latest}"
INSTALL_ROOT="${NVIM_UPDATE_INSTALL_ROOT:-$HOME/.local/opt/neovim}"
BIN_DIR="${NVIM_UPDATE_BIN_DIR:-$HOME/.local/bin}"
TMP_BASE="${NVIM_UPDATE_TMPDIR:-${TMPDIR:-/tmp}}"

fail() {
  printf 'nvim-update: %s\n' "$1" >&2
  exit 1
}

need() {
  command -v "$1" >/dev/null 2>&1 || fail "Required command not found: $1"
}

need curl
need jq
need tar

if [[ -r /etc/os-release ]]; then
  # shellcheck disable=SC1091
  . /etc/os-release
  if [[ "${ID:-}" == "nixos" ]]; then
    fail "NixOS detected; update Neovim through your NixOS package configuration instead."
  fi
fi

system="$(uname -s)"
machine="$(uname -m)"
case "$system:$machine" in
  Linux:x86_64|Linux:amd64)
    asset_name="nvim-linux-x86_64.tar.gz"
    ;;
  Linux:aarch64|Linux:arm64)
    asset_name="nvim-linux-arm64.tar.gz"
    ;;
  Darwin:x86_64)
    asset_name="nvim-macos-x86_64.tar.gz"
    ;;
  Darwin:arm64|Darwin:aarch64)
    asset_name="nvim-macos-arm64.tar.gz"
    ;;
  *)
    fail "Unsupported platform: $system/$machine"
    ;;
esac

case "$INSTALL_ROOT:$BIN_DIR:$TMP_BASE" in
  /*:/*:/*) ;;
  *) fail "Install, binary, and temporary directories must be absolute paths." ;;
esac
need mktemp
need readlink

if command -v sha256sum >/dev/null 2>&1; then
  sha256_file() {
    local result
    result="$(sha256sum "$1")"
    printf '%s\n' "${result%% *}"
  }
elif command -v shasum >/dev/null 2>&1; then
  sha256_file() {
    local result
    result="$(shasum -a 256 "$1")"
    printf '%s\n' "${result%% *}"
  }
elif command -v sha256 >/dev/null 2>&1; then
  sha256_file() {
    sha256 -q "$1"
  }
else
  fail "A SHA-256 utility (sha256sum, shasum, or sha256) is required."
fi

mkdir -p "$TMP_BASE" "$INSTALL_ROOT" "$BIN_DIR"
tmp_dir="$(mktemp -d "$TMP_BASE/nvim-update.XXXXXX")"
staging_dir=""
temp_link=""
cleanup() {
  if [[ -n "$staging_dir" && -d "$staging_dir" ]]; then
    rm -rf "$staging_dir"
  fi
  if [[ -n "$temp_link" && -L "$temp_link" ]]; then
    rm -f "$temp_link"
  fi
  if [[ -d "$tmp_dir" ]]; then
    rm -rf "$tmp_dir"
  fi
}
trap cleanup EXIT

release_json="$tmp_dir/release.json"
curl --fail --silent --show-error --location --retry 3 --output "$release_json" "$API_URL"
tag="$(jq -er '.tag_name | strings | select(test("^v[0-9]+\\.[0-9]+\\.[0-9]+$"))' "$release_json")" \
  || fail "GitHub did not return a stable semantic-version release tag."
version="${tag#v}"
asset_url="$(jq -er --arg name "$asset_name" '.assets[] | select(.name == $name) | .browser_download_url | strings | select(length > 0)' "$release_json")" \
  || fail "Release $tag does not contain $asset_name."
expected_digest="$(jq -er --arg name "$asset_name" '.assets[] | select(.name == $name) | .digest | strings | select(test("^sha256:[0-9a-fA-F]{64}$")) | sub("^sha256:"; "")' "$release_json")" \
  || fail "Release $tag does not provide a valid SHA-256 digest for $asset_name."

archive="$tmp_dir/$asset_name"
printf 'Downloading Neovim %s for %s/%s…\n' "$tag" "$system" "$machine"
curl --fail --silent --show-error --location --retry 3 --output "$archive" "$asset_url"
actual_digest="$(sha256_file "$archive")"
if [[ "$actual_digest" != "$expected_digest" ]]; then
  fail "SHA-256 mismatch for $asset_name; refusing to install."
fi

version_dir="$INSTALL_ROOT/$version"
if [[ -d "$version_dir" ]]; then
  candidate="$version_dir/bin/nvim"
  [[ -x "$candidate" && -d "$version_dir/share/nvim/runtime" ]] \
    || fail "Existing version directory is incomplete: $version_dir"
else
  staging_dir="$(mktemp -d "$INSTALL_ROOT/.staging-$version.XXXXXX")"
  tar -xzf "$archive" -C "$staging_dir" --strip-components=1
  candidate="$staging_dir/bin/nvim"
  [[ -x "$candidate" && -d "$staging_dir/share/nvim/runtime" ]] \
    || fail "The release archive is missing Neovim's binary or runtime files."
  version_line="$("$candidate" --version 2>&1)" \
    || fail "The downloaded Neovim binary could not run."
  case "$version_line" in
    *"NVIM v$version"*) ;;
    *) fail "Downloaded binary version did not match release tag $tag." ;;
  esac
  mv "$staging_dir" "$version_dir"
  staging_dir=""
  candidate="$version_dir/bin/nvim"
fi

link="$BIN_DIR/nvim"
if [[ -e "$link" && ! -L "$link" ]]; then
  fail "Refusing to replace non-symlink file at $link. Move it manually if you want this updater to manage that path."
fi
if [[ -L "$link" ]]; then
  existing_target="$(readlink "$link")"
  case "$existing_target" in
    "$INSTALL_ROOT"/*) ;;
    *) fail "Refusing to replace unrelated symlink at $link -> $existing_target" ;;
  esac
fi

if [[ ! -L "$link" || "$(readlink "$link")" != "$candidate" ]]; then
  temp_link="$BIN_DIR/.nvim-update.$$.tmp"
  ln -s "$candidate" "$temp_link"
  mv -f "$temp_link" "$link"
  temp_link=""
fi

installed_line="$("$link" --version 2>&1)" \
  || fail "Installed Neovim did not launch from $link."
case "$installed_line" in
  *"NVIM v$version"*) ;;
  *) fail "Installed command did not resolve to the expected Neovim $tag." ;;
esac

printf 'Neovim %s is ready at %s\n' "$tag" "$link"
case ":${PATH:-}:" in
  *":$BIN_DIR:"*) printf 'The command is on PATH; open a new shell or run: rehash\n' ;;
  *) printf 'Add this directory to PATH to use it as `nvim`: %s\n' "$BIN_DIR" ;;
esac
