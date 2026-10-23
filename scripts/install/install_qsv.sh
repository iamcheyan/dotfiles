#!/bin/bash

# qsv installation script — CSV/TSV/parquet data-wrangling toolkit
# https://github.com/dathere/qsv
# Usage: install_qsv.sh [--force]

set -u

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'; NC='\033[0m'
print_info()    { echo -e "${BLUE}ℹ${NC} $1"; }
print_success() { echo -e "${GREEN}✓${NC} $1"; }
print_error()   { echo -e "${RED}✗${NC} $1"; }
command_exists() { command -v "$1" >/dev/null 2>&1; }

FORCE=false
[[ "${1:-}" == "--force" ]] && FORCE=true

if command_exists qsv && [ "$FORCE" != "true" ]; then
    print_success "qsv is installed: $(qsv --version 2>/dev/null | head -c 40)..."
    exit 0
fi

# The prebuilt binaries need AVX2 (x86-64-v3); fall back to cargo otherwise.
if ! grep -q avx2 /proc/cpuinfo 2>/dev/null; then
    print_error "CPU lacks AVX2; the qsv prebuilt would crash with SIGILL"
    print_info "Compile from source instead: cargo install qsv --locked --features apply,fetch,foreach,prompt,self_update,to,Polars"
    exit 1
fi

VERSION=$(curl -s https://api.github.com/repos/dathere/qsv/releases/latest \
    | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
[[ -z "$VERSION" ]] && { print_error "Could not determine the latest qsv release"; exit 1; }

URL="https://github.com/dathere/qsv/releases/download/${VERSION}/qsv-${VERSION}-x86_64-unknown-linux-gnu.zip"
TEMP_DIR="/tmp/qsv-install"
BIN_DIR="$HOME/.local/bin"
mkdir -p "$TEMP_DIR" "$BIN_DIR"

print_info "Latest version: $VERSION"
print_info "Downloading qsv..."
if ! curl -fL "$URL" -o "$TEMP_DIR/qsv.zip"; then
    print_error "Download failed"
    exit 1
fi

python3 -c "
import zipfile
z = zipfile.ZipFile('$TEMP_DIR/qsv.zip')
z.extract('qsv', '$TEMP_DIR')
" || { print_error "Extraction failed"; exit 1; }

if [[ -f "$TEMP_DIR/qsv" ]]; then
    install -m 755 "$TEMP_DIR/qsv" "$BIN_DIR/qsv"
    print_success "qsv installed at: $BIN_DIR/qsv"
    rm -rf "$TEMP_DIR"
else
    print_error "qsv binary not found after extraction"
    exit 1
fi
