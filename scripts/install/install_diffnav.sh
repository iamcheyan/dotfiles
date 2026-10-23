#!/bin/bash

# diffnav installation script
# diffnav is a git diff pager based on delta with a GitHub-style file tree
# https://github.com/dlvhdr/diffnav
# Usage: install_diffnav.sh [--force]

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
            ARCH="arm64"
            ;;
        i386|i686)
            ARCH="i386"
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
            echo "Linux"
            ;;
        Darwin)
            echo "Darwin"
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
    local OS
    ARCH=$(detect_arch) || return 1
    OS=$(detect_os) || return 1

    local VERSION
    VERSION=$(curl -s https://api.github.com/repos/dlvhdr/diffnav/releases/latest \
        | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
    if [[ -z "$VERSION" ]]; then
        print_error "Could not determine the latest diffnav release"
        return 1
    fi
    local VERSION_NUM=${VERSION#v}

    local DOWNLOAD_URL="https://github.com/dlvhdr/diffnav/releases/download/${VERSION}/diffnav_${OS}_${ARCH}.tar.gz"
    local CHECKSUM_URL="https://github.com/dlvhdr/diffnav/releases/download/${VERSION}/diffnav_${VERSION_NUM}_checksums.txt"
    local TEMP_DIR="/tmp/diffnav-install"
    local BIN_DIR="$HOME/.local/bin"

    print_info "Detected platform: ${OS} ${ARCH}"
    print_info "Latest version: $VERSION"
    print_info "Download URL: $DOWNLOAD_URL"

    mkdir -p "$TEMP_DIR" "$BIN_DIR"

    print_info "Downloading diffnav..."
    if command_exists curl; then
        curl -fL "$DOWNLOAD_URL" -o "$TEMP_DIR/diffnav.tar.gz" || {
            print_error "Download failed"
            return 1
        }
        curl -fL "$CHECKSUM_URL" -o "$TEMP_DIR/checksums.txt" || true
    else
        print_error "curl is required to download the file"
        return 1
    fi

    # Verify against the published SHA-256 checksums when available
    if [[ -s "$TEMP_DIR/checksums.txt" ]]; then
        local expected
        expected=$(grep "diffnav_${OS}_${ARCH}.tar.gz" "$TEMP_DIR/checksums.txt" | awk '{print $1}')
        if [[ -n "$expected" ]]; then
            local actual
            actual=$(sha256sum "$TEMP_DIR/diffnav.tar.gz" | awk '{print $1}')
            if [[ "$actual" != "$expected" ]]; then
                print_error "SHA-256 mismatch: expected $expected, got $actual"
                return 1
            fi
            print_success "Checksum verified"
        fi
    fi

    print_info "Extracting..."
    tar -xzf "$TEMP_DIR/diffnav.tar.gz" -C "$TEMP_DIR"

    if [[ -f "$TEMP_DIR/diffnav" ]]; then
        install -m 755 "$TEMP_DIR/diffnav" "$BIN_DIR/diffnav"
        print_success "diffnav installed at: $BIN_DIR/diffnav"

        if [[ ":$PATH:" != *":$BIN_DIR:"* ]]; then
            print_warning "$BIN_DIR is not in PATH"
            print_info "Add the following to ~/.zshrc:"
            echo "  export PATH=\"\$HOME/.local/bin:\$PATH\""
        fi

        rm -rf "$TEMP_DIR"
    else
        print_error "diffnav binary not found after extraction"
        return 1
    fi
}

# diffnav renders through delta; without it the pager cannot draw diffs
check_delta() {
    if command_exists delta; then
        print_success "delta is installed: $(delta --version 2>/dev/null)"
        return 0
    fi

    print_warning "delta is not installed; diffnav needs it to render diffs"
    print_info "Install delta from https://github.com/dandavison/delta#installation"
    print_info "or run scripts/install/install_delta.sh"
    return 1
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
    echo -e "${GREEN}Installing diffnav...${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""

    if command_exists diffnav && [ "$FORCE" != "true" ]; then
        local ver
        ver=$(diffnav --version 2>/dev/null | grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+' | tail -1)
        print_success "diffnav is installed: ${ver:-unknown version}"
        check_delta
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
    echo "  git diff | diffnav"
    echo ""
    echo "Set as the global git diff pager:"
    echo "  git config --global pager.diff diffnav"
    echo ""

    check_delta
}

main "$@"
