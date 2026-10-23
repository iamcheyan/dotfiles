#!/bin/bash

# tabiew installation script
# tabiew (tw) is a TUI for querying CSV/TSV/parquet files
# https://github.com/shshemi/tabiew
# Usage: install_tabiew.sh [--force]

set -u

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'; NC='\033[0m'
print_info()    { echo -e "${BLUE}ℹ${NC} $1"; }
print_success() { echo -e "${GREEN}✓${NC} $1"; }
print_error()   { echo -e "${RED}✗${NC} $1"; }
command_exists() { command -v "$1" >/dev/null 2>&1; }

FORCE=false
[[ "${1:-}" == "--force" ]] && FORCE=true

if command_exists tw && [ "$FORCE" != "true" ]; then
    print_success "tabiew is installed: $(tw --version 2>/dev/null | head -1)"
    exit 0
fi

print_info "Running the upstream installer (tabiew install.sh)..."
if curl -sS https://raw.githubusercontent.com/shshemi/tabiew/main/install.sh | sh; then
    print_success "tabiew installed successfully (command: tw)"
else
    print_error "Upstream installer failed"
    print_info "Alternative: download the .deb from https://github.com/shshemi/tabiew/releases"
    exit 1
fi
