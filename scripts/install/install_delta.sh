#!/bin/bash

# delta installation script
# delta is a syntax-highlighting pager for git diffs; diffnav builds on it
# https://github.com/dandavison/delta
# Usage: install_delta.sh [--force]

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

detect_arch() {
    ARCH=$(uname -m)
    case "$ARCH" in
        x86_64|amd64)
            ARCH="x86_64"
            ;;
        aarch64|arm64)
            ARCH="aarch64"
            ;;
        *)
            print_error "Unsupported architecture: $ARCH"
            return 1
            ;;
    esac
    echo "$ARCH"
}

detect_os() {
    OS=$(uname -s)
    case "$OS" in
        Linux)
            echo "unknown-linux-gnu"
            ;;
        Darwin)
            echo "apple-darwin"
            ;;
        *)
            print_error "Unsupported OS: $OS"
            return 1
            ;;
    esac
}

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

install_with_binary() {
    local ARCH
    local TARGET_OS
    ARCH=$(detect_arch) || return 1
    TARGET_OS=$(detect_os) || return 1

    # The apt package is ancient (2006-era version number); prefer the upstream
    # release tarball, falling back to apt only when the download fails.
    local VERSION
    VERSION=$(curl -s https://api.github.com/repos/dandavison/delta/releases/latest \
        | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
    if [[ -z "$VERSION" ]]; then
        print_warning "Could not determine the latest delta release; falling back to apt"
        if command_exists apt-get; then
            sudo apt-get install -y delta
            return $?
        fi
        return 1
    fi

    local DOWNLOAD_URL="https://github.com/dandavison/delta/releases/download/${VERSION}/delta-${VERSION}-x86_64-${TARGET_OS}.tar.gz"
    local TEMP_DIR="/tmp/delta-install"
    local BIN_DIR="$HOME/.local/bin"

    print_info "Latest version: $VERSION"
    print_info "Download URL: $DOWNLOAD_URL"

    mkdir -p "$TEMP_DIR" "$BIN_DIR"

    print_info "Downloading delta..."
    if command_exists curl; then
        curl -fL "$DOWNLOAD_URL" -o "$TEMP_DIR/delta.tar.gz" || {
            print_error "Download failed"
            return 1
        }
    else
        print_error "curl is required to download the file"
        return 1
    fi

    print_info "Extracting..."
    tar -xzf "$TEMP_DIR/delta.tar.gz" -C "$TEMP_DIR"

    local extracted_dir="$TEMP_DIR/delta-${VERSION}-x86_64-${TARGET_OS}"
    if [[ -f "$extracted_dir/delta" ]]; then
        install -m 755 "$extracted_dir/delta" "$BIN_DIR/delta"
        print_success "delta installed at: $BIN_DIR/delta"

        if [[ ":$PATH:" != *":$BIN_DIR:"* ]]; then
            print_warning "$BIN_DIR is not in PATH"
            print_info "Add the following to ~/.zshrc:"
            echo "  export PATH=\"\$HOME/.local/bin:\$PATH\""
        fi

        rm -rf "$TEMP_DIR"
    else
        print_error "delta binary not found after extraction"
        return 1
    fi
}

main() {
    FORCE=false
    while [[ $# -gt 0 ]]; do
        case $1 in
            --force)
                FORCE=true
                shift
                ;;
            *)
                print_error "Unknown option: $1"
                echo "Usage: $0 [--force]"
                exit 1
                ;;
        esac
    done

    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}Installing delta...${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""

    if command_exists delta && [ "$FORCE" != "true" ]; then
        print_success "delta is installed: $(delta --version 2>/dev/null)"
        exit 0
    fi

    install_with_binary
    if [ $? -ne 0 ]; then
        print_error "Installation failed"
        exit 1
    fi

    echo ""
    echo -e "${YELLOW}📋 Usage:${NC}"
    echo ""
    echo "Pipe a diff into it:"
    echo "  git diff | delta"
    echo ""
    echo "Set as the global git pager:"
    echo "  git config --global core.pager delta"
    echo ""
}

main "$@"
