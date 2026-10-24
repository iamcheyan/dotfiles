#!/usr/bin/env bash
set -euo pipefail

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

detect_os() {
  if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    if command_exists apt-get; then
      echo "debian"
    elif command_exists dnf; then
      echo "fedora"
    elif command_exists yum; then
      echo "rhel"
    elif command_exists pacman; then
      echo "arch"
    else
      echo "linux"
    fi
  elif [[ "$OSTYPE" == "darwin"* ]]; then
    echo "macos"
  else
    echo "unknown"
  fi
}

FORCE=0
METHOD="auto"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --force)
      FORCE=1
      ;;
    --method)
      METHOD="${2:-}"
      shift
      ;;
    *)
      print_error "Unknown option: $1"
      echo "Usage: install:httpie [--force] [--method auto|package|pipx|pip]"
      exit 1
      ;;
  esac
  shift
done

if command_exists http && [[ "$FORCE" -ne 1 ]]; then
  print_success "HTTPie is already installed: $(http --version)"
  exit 0
fi

install_with_package_manager() {
  local os
  os="$(detect_os)"
  case "$os" in
    debian)
      command_exists sudo || return 1
      sudo apt-get update
      sudo apt-get install -y httpie
      ;;
    fedora)
      command_exists sudo || return 1
      sudo dnf install -y httpie
      ;;
    rhel)
      command_exists sudo || return 1
      if command_exists dnf; then
        sudo dnf install -y httpie
      else
        sudo yum install -y httpie
      fi
      ;;
    arch)
      command_exists sudo || return 1
      sudo pacman -S --noconfirm httpie
      ;;
    macos)
      command_exists brew || return 1
      brew install httpie
      ;;
    *)
      return 1
      ;;
  esac
}

install_with_pipx() {
  command_exists pipx || return 1
  pipx install --force httpie
}

install_with_pip() {
  if command_exists python3; then
    python3 -m pip install --user --upgrade httpie
    return
  fi
  if command_exists python; then
    python -m pip install --user --upgrade httpie
    return
  fi
  return 1
}

print_info "Installing HTTPie..."

case "$METHOD" in
  auto)
    install_with_package_manager || install_with_pipx || install_with_pip || {
      print_error "Failed to install HTTPie"
      exit 1
    }
    ;;
  package)
    install_with_package_manager || {
      print_error "Package-manager installation failed"
      exit 1
    }
    ;;
  pipx)
    install_with_pipx || {
      print_error "pipx installation failed"
      exit 1
    }
    ;;
  pip)
    install_with_pip || {
      print_error "pip installation failed"
      exit 1
    }
    ;;
  *)
    print_error "Unknown method: $METHOD"
    exit 1
    ;;
esac

if command_exists http; then
  print_success "HTTPie installed successfully: $(http --version)"
else
  print_warning "HTTPie may have been installed, but 'http' is not yet in PATH for this shell"
  print_info "Open a new shell or run: source ~/.zshrc"
fi
