#!/bin/bash

# dekit installation script
# dekit is a process manager for dev and prod (https://github.com/pvolok/dekit)
# Usage: install_dekit.sh [--force]

set -u

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'; NC='\033[0m'
print_info()    { echo -e "${BLUE}ℹ${NC} $1"; }
print_success() { echo -e "${GREEN}✓${NC} $1"; }
print_error()   { echo -e "${RED}✗${NC} $1"; }
command_exists() { command -v "$1" >/dev/null 2>&1; }

FORCE=false
[[ "${1:-}" == "--force" ]] && FORCE=true

if command_exists dekit && [ "$FORCE" != "true" ]; then
    print_success "dekit is installed: $(dekit --version 2>/dev/null | head -1)"
    exit 0
fi

print_info "Running the upstream installer (https://dekit.run/install.sh)..."
if curl -fsSL https://dekit.run/install.sh | sh; then
    print_success "dekit installed successfully"
else
    print_error "Upstream installer failed"
    print_info "Alternative: npm install -g @dekit/cli"
    exit 1
fi
