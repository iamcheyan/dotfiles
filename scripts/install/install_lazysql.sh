#!/usr/bin/env bash

# Install the official LazySQL release for Linux/macOS.
# https://github.com/jorgerojas26/lazysql
set -euo pipefail

command -v curl >/dev/null 2>&1 || { echo "error: curl is required" >&2; exit 1; }
command -v tar >/dev/null 2>&1 || { echo "error: tar is required" >&2; exit 1; }

os="$(uname -s)"
arch="$(uname -m)"
case "$os:$arch" in
    Linux:x86_64|Linux:amd64) asset="Linux_x86_64" ;;
    Linux:aarch64|Linux:arm64) asset="Linux_arm64" ;;
    Darwin:x86_64) asset="Darwin_x86_64" ;;
    Darwin:arm64|Darwin:aarch64) asset="Darwin_arm64" ;;
    *) echo "error: unsupported LazySQL platform: $os/$arch; see https://github.com/jorgerojas26/lazysql/releases" >&2; exit 1 ;;
esac

release="$(curl -fsSL https://api.github.com/repos/jorgerojas26/lazysql/releases/latest)"
version="$(printf '%s' "$release" | python3 -c 'import json,sys; print(json.load(sys.stdin)["tag_name"])')"
url="https://github.com/jorgerojas26/lazysql/releases/download/${version}/lazysql_${version#v}_${asset}.tar.gz"
temp_dir="$(mktemp -d)"
trap 'rm -rf "$temp_dir"' EXIT
curl -fsSL "$url" -o "$temp_dir/lazysql.tar.gz"
tar -xzf "$temp_dir/lazysql.tar.gz" -C "$temp_dir" lazysql
mkdir -p "$HOME/.local/bin"
install -m 755 "$temp_dir/lazysql" "$HOME/.local/bin/lazysql"
printf 'Installed LazySQL %s to %s\n' "$version" "$HOME/.local/bin/lazysql"
