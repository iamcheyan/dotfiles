#!/bin/bash

# Generic pipx-package installer
# Usage: install_pipx_tool.sh <package> [app...] [--force]
# Installs <package> via pipx; [app...] are commands that must exist for the
# "already installed" check (defaults to <package>).

set -u

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_info()    { echo -e "${BLUE}${NC} $1"; }
print_success() { echo -e "${GREEN}${NC} $1"; }
print_warning() { echo -e "${YELLOW}${NC} $1"; }
print_error()   { echo -e "${RED}${NC} $1"; }

command_exists() { command -v "$1" >/dev/null 2>&1; }

FORCE=false
PACKAGE=""
APPS=()

while [[ $# -gt 0 ]]; do
    case $1 in
        --force) FORCE=true; shift ;;
        -h|--help)
            echo "Usage: $0 <pipx-package> [app-command...] [--force]"
            exit 0
            ;;
        *)
            if [[ -z "$PACKAGE" ]]; then PACKAGE="$1"; else APPS+=("$1"); fi
            shift
            ;;
    esac
done

if [[ -z "$PACKAGE" ]]; then
    print_error "No package given"
    echo "Usage: $0 <pipx-package> [app-command...] [--force]"
    exit 1
fi
[[ ${#APPS[@]} -eq 0 ]] && APPS=("$PACKAGE")

export PATH="$HOME/.local/bin:$PATH"

for app in "${APPS[@]}"; do
    if command_exists "$app" && [ "$FORCE" != "true" ]; then
        print_success "$app is installed ($(command -v "$app"))"
        exit 0
    fi
done

install_pipx() {
    if command_exists pacman; then
        sudo pacman -S --needed --noconfirm python-pipx
    elif command_exists apt-get; then
        sudo apt-get update -qq && sudo apt-get install -y pipx
    elif command_exists dnf; then
        sudo dnf install -y pipx
    elif command_exists brew; then
        brew install pipx
    else
        print_error "No supported pipx package manager found; install pipx with your system package manager."
        return 1
    fi
}

if ! command_exists pipx; then
    print_info "Installing pipx with the system package manager..."
    install_pipx || exit 1
fi
command_exists pipx || { print_error "pipx is not available after package installation"; exit 1; }
pipx ensurepath || exit 1

install_args=(install)
[[ "$FORCE" == true ]] && install_args+=(--force)

print_info "Installing $PACKAGE via pipx..."
if pipx "${install_args[@]}" "$PACKAGE"; then
    print_success "$PACKAGE installed successfully"
    exit 0
fi

print_error "pipx install $PACKAGE failed"
exit 1
