#!/usr/bin/env bash

# Install Rainfrog using the native package manager where available, otherwise
# download and verify the official release for this OS and CPU architecture.
# https://github.com/achristmascarl/rainfrog
set -euo pipefail

command -v curl >/dev/null 2>&1 || { echo "error: curl is required" >&2; exit 1; }

os="$(uname -s)"
arch="$(uname -m)"
case "$os" in
    Darwin)
        command -v brew >/dev/null 2>&1 || { echo "error: Homebrew is required to install Rainfrog on macOS" >&2; exit 1; }
        brew install rainfrog
        exit
        ;;
    Linux)
        if command -v pacman >/dev/null 2>&1; then
            if command -v sudo >/dev/null 2>&1; then sudo pacman -S --needed --noconfirm rainfrog; else pacman -S --needed --noconfirm rainfrog; fi
            exit
        fi
        case "$arch" in
            x86_64|amd64) target="x86_64-unknown-linux-gnu" ;;
            aarch64|arm64) target="aarch64-unknown-linux-gnu" ;;
            *) echo "error: unsupported Rainfrog Linux architecture: $arch; install with Cargo or see https://github.com/achristmascarl/rainfrog/releases" >&2; exit 1 ;;
        esac
        ;;
    *)
        echo "error: unsupported Rainfrog OS: $os; install with Cargo or see https://github.com/achristmascarl/rainfrog" >&2
        exit 1
        ;;
esac

command -v sha256sum >/dev/null 2>&1 || { echo "error: sha256sum is required" >&2; exit 1; }
release="$(curl -fsSL https://api.github.com/repos/achristmascarl/rainfrog/releases/latest)"
version="$(printf '%s' "$release" | python3 -c 'import json,sys; print(json.load(sys.stdin)["tag_name"])')"
asset="rainfrog-${version}-${target}"
base="https://github.com/achristmascarl/rainfrog/releases/download/${version}"
temp_dir="$(mktemp -d)"
trap 'rm -rf "$temp_dir"' EXIT
curl -fsSL "${base}/${asset}.tar.gz" -o "$temp_dir/${asset}.tar.gz"
curl -fsSL "${base}/${asset}.sha256" -o "$temp_dir/${asset}.sha256"
(
    cd "$temp_dir"
    sha256sum --check "${asset}.sha256"
)
tar -xzf "$temp_dir/${asset}.tar.gz" -C "$temp_dir"
install -Dm755 "$temp_dir/rainfrog" "$HOME/.local/bin/rainfrog"
printf 'Installed Rainfrog %s to %s\n' "$version" "$HOME/.local/bin/rainfrog"
