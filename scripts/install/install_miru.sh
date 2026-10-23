#!/usr/bin/env bash
# Install miru (terminal Markdown/source viewer) for this dotfiles setup.
#
# miru is distributed as a signed static binary by upstream. The official
# bootstrap (https://github.com/hir4ta/miru/blob/main/install.sh) downloads the
# tarball, verifies its SHA-256 against checksums.txt, then hands off to
# `miru install`, a Bubble Tea installer that copies the binary into place
# and wires up the shell rc PATH.
#
# This wrapper only documents and guards that flow so it fits the
# init.sh step pattern. It does not duplicate the download logic.
#
# Usage:
#   bash scripts/install/install_miru.sh
#   VERSION=v0.8.0 bash scripts/install/install_miru.sh
#   MIRU_NO_MODIFY_PATH=1 bash scripts/install/install_miru.sh

set -euo pipefail

print_info() { echo -e "\033[0;34mℹ\033[0m $1"; }
print_success() { echo -e "\033[0;32m✓\033[0m $1"; }
print_warning() { echo -e "\033[1;33m⚠\033[0m $1"; }
print_error() { echo -e "\033[0;31m✗\033[0m $1"; }

if command -v miru >/dev/null 2>&1; then
    print_success "miru is already installed: $(miru version 2>/dev/null || echo unknown)"
    return 0 2>/dev/null || exit 0
fi

if ! command -v curl >/dev/null 2>&1; then
    print_error "curl is required"
    exit 1
fi
if ! command -v tar >/dev/null 2>&1; then
    print_error "tar is required"
    exit 1
fi

print_info "Installing miru via the upstream bootstrap..."
print_info "VERSION=${VERSION:-latest} INSTALL_DIR=${INSTALL_DIR:-$HOME/.local/bin} MIRU_NO_MODIFY_PATH=${MIRU_NO_MODIFY_PATH:-0}"

if curl -fsSL https://raw.githubusercontent.com/hir4ta/miru/main/install.sh | sh; then
    print_success "miru installed: $(command -v miru 2>/dev/null || echo 'check PATH')"
else
    print_error "miru bootstrap failed"
    exit 1
fi
