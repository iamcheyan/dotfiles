#!/bin/bash

# topgrade installation script — upgrade all the things
# https://github.com/topgrade-rs/topgrade
# Usage: install_topgrade.sh [--force]

set -u

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'; NC='\033[0m'
print_info()    { echo -e "${BLUE}ℹ${NC} $1"; }
print_success() { echo -e "${GREEN}✓${NC} $1"; }
print_error()   { echo -e "${RED}✗${NC} $1"; }
command_exists() { command -v "$1" >/dev/null 2>&1; }

detect_arch() {
    case "$(uname -m)" in
        x86_64|amd64) echo "x86_64" ;;
        aarch64|arm64) echo "aarch64" ;;
        *) return 1 ;;
    esac
}

FORCE=false
[[ "${1:-}" == "--force" ]] && FORCE=true

if command_exists topgrade && [ "$FORCE" != "true" ]; then
    print_success "topgrade is installed: $(topgrade --version 2>/dev/null)"
    exit 0
fi

ARCH=$(detect_arch) || { print_error "Unsupported architecture"; exit 1; }

VERSION=$(curl -s https://api.github.com/repos/topgrade-rs/topgrade/releases/latest \
    | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
[[ -z "$VERSION" ]] && { print_error "Could not determine the latest topgrade release"; exit 1; }

URL="https://github.com/topgrade-rs/topgrade/releases/download/${VERSION}/topgrade-${VERSION}-x86_64-unknown-linux-gnu.tar.gz"
[[ "$ARCH" == "aarch64" ]] && URL="https://github.com/topgrade-rs/topgrade/releases/download/${VERSION}/topgrade-${VERSION}-aarch64-unknown-linux-gnu.tar.gz"

TEMP_DIR="/tmp/topgrade-install"
BIN_DIR="$HOME/.local/bin"
mkdir -p "$TEMP_DIR" "$BIN_DIR"

print_info "Latest version: $VERSION"
print_info "Downloading topgrade..."
if ! curl -fL "$URL" -o "$TEMP_DIR/topgrade.tar.gz"; then
    print_error "Download failed"
    exit 1
fi

tar -xzf "$TEMP_DIR/topgrade.tar.gz" -C "$TEMP_DIR"
BIN_PATH=$(find "$TEMP_DIR" -name topgrade -type f | head -1)
if [[ -n "$BIN_PATH" ]]; then
    install -m 755 "$BIN_PATH" "$BIN_DIR/topgrade"
    print_success "topgrade installed at: $BIN_DIR/topgrade"
    rm -rf "$TEMP_DIR"
else
    print_error "topgrade binary not found after extraction"
    exit 1
fi
