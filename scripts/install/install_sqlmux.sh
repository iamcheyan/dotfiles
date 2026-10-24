#!/usr/bin/env bash

# Install the official sqlmux release for Linux/macOS.
# https://github.com/kackerx/sqlmux
set -euo pipefail

command -v curl >/dev/null 2>&1 || { echo "error: curl is required" >&2; exit 1; }
command -v tar >/dev/null 2>&1 || { echo "error: tar is required" >&2; exit 1; }
command -v sha256sum >/dev/null 2>&1 || { echo "error: sha256sum is required" >&2; exit 1; }
command -v python3 >/dev/null 2>&1 || { echo "error: python3 is required" >&2; exit 1; }

os="$(uname -s)"
arch="$(uname -m)"
case "$os:$arch" in
    Linux:x86_64|Linux:amd64) asset="linux_amd64" ;;
    Linux:aarch64|Linux:arm64) asset="linux_arm64" ;;
    Darwin:x86_64) asset="darwin_amd64" ;;
    Darwin:arm64|Darwin:aarch64) asset="darwin_arm64" ;;
    *) echo "error: unsupported sqlmux platform: $os/$arch; see https://github.com/kackerx/sqlmux/releases" >&2; exit 1 ;;
esac

release="$(curl -fsSL https://api.github.com/repos/kackerx/sqlmux/releases/latest)"
read -r version digest < <(printf '%s' "$release" | python3 -c '
import json, sys
release = json.load(sys.stdin)
version = release["tag_name"]
asset_name = next((a for a in release["assets"] if a["name"].startswith("sqlmux_") and a["name"].endswith("_" + sys.argv[1] + ".tar.gz")), None)
if not asset_name or not asset_name.get("digest", "").startswith("sha256:"):
    raise SystemExit("error: release asset or SHA-256 digest is missing")
print(version, asset_name["digest"].split(":", 1)[1])
' "$asset")
archive="sqlmux_${version#v}_${asset}.tar.gz"
base="https://github.com/kackerx/sqlmux/releases/download/${version}"
temp_dir="$(mktemp -d)"
trap 'rm -rf "$temp_dir"' EXIT
curl -fsSL "${base}/${archive}" -o "$temp_dir/$archive"
printf '%s  %s\n' "$digest" "$temp_dir/$archive" | sha256sum --check --status || { echo "error: sqlmux archive checksum mismatch" >&2; exit 1; }
tar -xzf "$temp_dir/$archive" -C "$temp_dir" sqlmux
mkdir -p "$HOME/.local/bin"
install -m 755 "$temp_dir/sqlmux" "$HOME/.local/bin/sqlmux"
printf 'Installed sqlmux %s to %s\n' "$version" "$HOME/.local/bin/sqlmux"
