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

detect_broot_target() {
  local os arch libc
  os="$(uname -s)"
  arch="$(uname -m)"

  case "$os" in
    Linux)
      libc="gnu"
      if command_exists ldd && ldd --version 2>&1 | grep -qi musl; then
        libc="musl"
      fi
      case "$arch" in
        x86_64)
          if [[ "$libc" == "musl" ]]; then
            echo "x86_64-unknown-linux-musl"
          else
            echo "x86_64-unknown-linux-gnu-glibc2.28"
          fi
          ;;
        aarch64|arm64)
          if [[ "$libc" == "musl" ]]; then
            echo "aarch64-unknown-linux-musl"
          else
            echo "aarch64-unknown-linux-gnu"
          fi
          ;;
        armv7l|armv7)
          if [[ "$libc" == "musl" ]]; then
            echo "armv7-unknown-linux-musleabi"
          else
            echo "armv7-unknown-linux-gnueabihf"
          fi
          ;;
        *)
          return 1
          ;;
      esac
      ;;
    Darwin)
      case "$arch" in
        aarch64|arm64)
          echo "aarch64-apple-darwin"
          ;;
        *)
          return 1
          ;;
      esac
      ;;
    *)
      return 1
      ;;
  esac
}

FORCE=0
METHOD="auto"
INSTALL_DIR="${HOME}/.local/bin"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --force)
      FORCE=1
      ;;
    --method)
      METHOD="${2:-}"
      shift
      ;;
    --install-dir)
      INSTALL_DIR="${2:-}"
      shift
      ;;
    *)
      print_error "Unknown option: $1"
      echo "Usage: install:broot [--force] [--method auto|package|binary|cargo] [--install-dir DIR]"
      exit 1
      ;;
  esac
  shift
done

if command_exists broot && [[ "$FORCE" -ne 1 ]]; then
  print_success "broot is already installed: $(broot --version)"
  if [[ -x "$HOME/.dotfiles/config/broot/init.sh" ]]; then
    bash "$HOME/.dotfiles/config/broot/init.sh" >/dev/null 2>&1 || true
  fi
  exit 0
fi

install_with_package_manager() {
  local os
  os="$(detect_os)"
  case "$os" in
    debian)
      command_exists sudo || return 1
      sudo apt-get update
      sudo apt-get install -y broot
      ;;
    fedora)
      command_exists sudo || return 1
      sudo dnf install -y broot
      ;;
    rhel)
      command_exists sudo || return 1
      if command_exists dnf; then
        sudo dnf install -y broot
      else
        sudo yum install -y broot
      fi
      ;;
    arch)
      command_exists sudo || return 1
      sudo pacman -S --noconfirm broot
      ;;
    macos)
      command_exists brew || return 1
      brew install broot
      ;;
    *)
      return 1
      ;;
  esac
}

install_with_binary() {
  local target version tag zip_name tmpdir download_url extracted_root source_bin

  target="$(detect_broot_target)" || {
    print_error "Unsupported platform for broot binary: $(uname -s) / $(uname -m)"
    return 1
  }

  command_exists curl || {
    print_error "curl is required for binary installation"
    return 1
  }
  command_exists python3 || {
    print_error "python3 is required to extract broot release zip"
    return 1
  }

  print_info "Resolving latest broot release..."
  tag="$(curl -fsSL https://api.github.com/repos/Canop/broot/releases/latest | python3 -c 'import json,sys; print(json.load(sys.stdin)["tag_name"])')" || return 1
  version="${tag#v}"
  zip_name="broot_${version}.zip"
  download_url="https://github.com/Canop/broot/releases/download/${tag}/${zip_name}"

  tmpdir="$(mktemp -d)"
  trap 'rm -rf "$tmpdir"' RETURN

  print_info "Downloading ${zip_name} for target ${target}..."
  curl -fL "$download_url" -o "$tmpdir/$zip_name" || return 1

  extracted_root="$tmpdir/extracted"
  mkdir -p "$extracted_root"
  python3 - "$tmpdir/$zip_name" "$extracted_root" <<'PY'
import sys, zipfile
zip_path, out_dir = sys.argv[1], sys.argv[2]
with zipfile.ZipFile(zip_path) as zf:
    zf.extractall(out_dir)
PY

  source_bin="$(find "$extracted_root" -path "*/${target}/broot" -type f | head -n 1)"
  [[ -n "$source_bin" ]] || {
    print_error "Could not find broot binary for target ${target} in ${zip_name}"
    return 1
  }

  mkdir -p "$INSTALL_DIR"
  install -m 0755 "$source_bin" "$INSTALL_DIR/broot"
  print_success "Installed broot binary to $INSTALL_DIR/broot"
}

install_with_cargo() {
  command_exists cargo || return 1
  cargo install --locked broot
}

print_info "Installing broot..."
print_info "Available methods: package | binary | cargo"

case "$METHOD" in
  auto)
    install_with_package_manager || install_with_binary || install_with_cargo || {
      print_error "Failed to install broot"
      exit 1
    }
    ;;
  package)
    install_with_package_manager || {
      print_error "Package-manager installation failed"
      exit 1
    }
    ;;
  binary)
    install_with_binary || {
      print_error "Binary installation failed"
      exit 1
    }
    ;;
  cargo)
    install_with_cargo || {
      print_error "cargo installation failed"
      exit 1
    }
    ;;
  *)
    print_error "Unknown method: $METHOD"
    exit 1
    ;;
esac

if command_exists broot; then
  if [[ -x "$HOME/.dotfiles/config/broot/init.sh" ]]; then
    bash "$HOME/.dotfiles/config/broot/init.sh"
  fi
  print_success "broot installed successfully: $(broot --version)"
  print_info "Open a new shell or run: source ~/.zshrc"
else
  print_warning "broot was installed, but 'broot' is not yet in PATH for this shell"
  print_info "Ensure ${INSTALL_DIR} is in PATH, then run: source ~/.zshrc"
fi
