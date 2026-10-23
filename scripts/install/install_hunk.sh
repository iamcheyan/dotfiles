#!/bin/bash

# hunk installation script
# hunk is a desktop-inspired terminal diff viewer for agent-authored changesets
# https://www.hunk.dev — repo: modem-dev/hunk
# Usage: install_hunk.sh [--force]
#
# Delegates to the upstream installer (SHA-256 verified, installs to ~/.hunk/bin
# plus bundled skills). Env overrides pass through: HUNK_VERSION, HUNK_INSTALL_DIR.

set -eu

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

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

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

main() {
    local FORCE=false
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
    echo -e "${GREEN}Installing hunk...${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""

    if command_exists hunk && [ "$FORCE" != "true" ]; then
        print_success "hunk is installed: $(hunk --version 2>/dev/null)"
        exit 0
    fi

    if [[ "$(uname -s)" != "Linux" && "$(uname -s)" != "Darwin" ]]; then
        print_error "hunk supports macOS and Linux; on Windows use: npm install -g hunkdiff"
        exit 1
    fi

    # The upstream installer downloads the prebuilt release, verifies it against
    # SHA256SUMS, installs to ~/.hunk/bin and updates PATH in shell startup files.
    # Set HUNK_NO_MODIFY_PATH=1 to keep it from editing those files. --force is
    # forwarded so an existing npm-based hunkdiff install can be overridden.
    local upstream_args=""
    [ "$FORCE" = "true" ] && upstream_args="--force"
    print_info "Running the upstream installer (https://hunk.dev/install.sh)..."
    if curl -fsSL https://hunk.dev/install.sh | sh -s -- $upstream_args; then
        print_success "hunk installed successfully"
    else
        print_error "Upstream installer failed"
        print_info "If an npm-based hunkdiff install blocks it, remove it first:"
        print_info "  npm rm -g hunkdiff   # then rerun with --force"
        print_info "Alternative: npm install -g hunkdiff"
        exit 1
    fi

    echo ""
    echo -e "${YELLOW}📋 Usage:${NC}"
    echo ""
    echo "Review working-tree changes:"
    echo "  hunk diff"
    echo ""
    echo "Review staged changes:"
    echo "  hunk diff --staged"
    echo ""
    echo "Use as the git pager:"
    echo "  git config --global core.pager \"hunk pager\""
    echo ""
}

main "$@"
