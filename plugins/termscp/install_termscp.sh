#!/bin/bash

set -euo pipefail

REPO="veeso/termscp"
RELEASES_API="https://api.github.com/repos/${REPO}/releases/latest"
METHOD="auto"
FORCE="false"

print_info() {
    printf '\033[0;34mℹ\033[0m %s\n' "$1"
}

print_success() {
    printf '\033[0;32m✓\033[0m %s\n' "$1"
}

print_warning() {
    printf '\033[1;33m⚠\033[0m %s\n' "$1"
}

print_error() {
    printf '\033[0;31m✗\033[0m %s\n' "$1"
}

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

detect_os() {
    case "$(uname -s)" in
        Linux)
            if command_exists apt-get; then
                echo "debian"
            elif command_exists dnf; then
                if [[ -f /etc/os-release ]]; then
                    . /etc/os-release
                    if [[ "${ID:-}" == "fedora" ]]; then
                        echo "fedora"
                    else
                        echo "rhel"
                    fi
                else
                    echo "rhel"
                fi
            elif command_exists yum; then
                echo "rhel"
            elif command_exists pacman; then
                echo "arch"
            else
                echo "linux"
            fi
            ;;
        Darwin) echo "macos" ;;
        FreeBSD) echo "freebsd" ;;
        NetBSD) echo "netbsd" ;;
        *) echo "unknown" ;;
    esac
}

detect_arch() {
    case "$(uname -m)" in
        x86_64|amd64) echo "x86_64" ;;
        aarch64|arm64) echo "aarch64" ;;
        *) echo "unsupported" ;;
    esac
}

usage() {
    cat <<'EOF'
Usage: install_termscp.sh [--method auto|release|package|cargo] [--force]

Methods:
  auto      macOS prefers GitHub Releases; Linux prefers cargo, then release, then package
  release   Download the latest prebuilt package from GitHub Releases
  package   Use the platform package manager only
  cargo     Install with cargo

Examples:
  bash ~/dotfiles/plugins/termscp/install_termscp.sh
  bash ~/dotfiles/plugins/termscp/install_termscp.sh --method release
  bash ~/dotfiles/plugins/termscp/install_termscp.sh --method cargo --force
EOF
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --method)
            METHOD="${2:-}"
            shift 2
            ;;
        --force)
            FORCE="true"
            shift
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            print_error "Unknown argument: $1"
            usage
            exit 1
            ;;
    esac
done

if command_exists termscp && [[ "$FORCE" != "true" ]]; then
    print_success "termscp is already installed: $(termscp --version 2>/dev/null || echo termscp)"
    exit 0
fi

OS="$(detect_os)"
ARCH="$(detect_arch)"

require_sudo() {
    if ! command_exists sudo; then
        print_error "sudo privileges are required for this install method"
        exit 1
    fi
}

fetch_latest_tag() {
    if ! command_exists curl; then
        print_error "curl is required to fetch the latest release metadata"
        return 1
    fi

    curl -fsSL "$RELEASES_API" | sed -n 's/.*"tag_name": *"\([^"]*\)".*/\1/p' | head -n 1
}

install_release_tarball() {
    local url="$1"
    local tmp_dir
    local archive
    local extracted_bin
    local install_dir="${HOME}/.local/bin"

    tmp_dir="$(mktemp -d)"
    archive="${tmp_dir}/termscp.tar.gz"

    print_info "Downloading $url"
    curl -fsSL "$url" -o "$archive"
    tar -xzf "$archive" -C "$tmp_dir"

    extracted_bin="$(find "$tmp_dir" -type f -name termscp | head -n 1)"
    if [[ -z "$extracted_bin" ]]; then
        print_error "Failed to find termscp in the downloaded archive"
        rm -rf "$tmp_dir"
        return 1
    fi

    mkdir -p "$install_dir"
    install -m 0755 "$extracted_bin" "${install_dir}/termscp"
    rm -rf "$tmp_dir"

    case ":$PATH:" in
        *":${install_dir}:"*) ;;
        *)
            print_warning "${install_dir} is not currently in PATH"
            print_info "Add this to your shell config if needed: export PATH=\"${install_dir}:\$PATH\""
            ;;
    esac
}

install_release_deb() {
    local url="$1"
    local tmp_dir
    local package_file

    require_sudo
    tmp_dir="$(mktemp -d)"
    package_file="${tmp_dir}/termscp.deb"

    print_info "Downloading $url"
    curl -fsSL "$url" -o "$package_file"
    sudo apt-get install -y "$package_file"
    rm -rf "$tmp_dir"
}

install_with_release() {
    local tag
    local asset
    local url

    if [[ "$ARCH" == "unsupported" ]]; then
        print_warning "Unsupported architecture for prebuilt release assets: $(uname -m)"
        return 1
    fi

    tag="$(fetch_latest_tag)"
    if [[ -z "$tag" ]]; then
        print_error "Failed to detect the latest termscp release tag"
        return 1
    fi

    case "$OS" in
        macos)
            asset="termscp-${tag}-${ARCH}-apple-darwin.tar.gz"
            ;;
        debian)
            asset="termscp-${tag}-${ARCH}-unknown-linux-gnu.tar.gz"
            ;;
        fedora|rhel|arch|linux)
            asset="termscp-${tag}-${ARCH}-unknown-linux-gnu.tar.gz"
            ;;
        *)
            print_warning "No prebuilt release asset strategy is configured for $OS"
            return 1
        ;;
    esac

    url="https://github.com/${REPO}/releases/download/${tag}/${asset}"

    case "$asset" in
        *.deb) install_release_deb "$url" ;;
        *.tar.gz) install_release_tarball "$url" ;;
        *)
            print_error "Unsupported release asset type: $asset"
            return 1
            ;;
    esac
}

install_with_package_manager() {
    case "$OS" in
        macos)
            if ! command_exists brew; then
                print_warning "Homebrew was not found"
                return 1
            fi
            brew install veeso/termscp/termscp
            ;;
        arch)
            require_sudo
            sudo pacman -S --noconfirm termscp
            ;;
        freebsd)
            require_sudo
            sudo pkg install -y termscp
            ;;
        netbsd)
            require_sudo
            sudo pkgin -y install termscp
            ;;
        debian|fedora|rhel|linux)
            print_warning "No package-manager install path is configured for $OS; use --method release instead"
            return 1
            ;;
        *)
            print_warning "Unsupported OS for package-manager install: $OS"
            return 1
            ;;
    esac
}

install_with_cargo() {
    if ! command_exists cargo; then
        print_error "cargo is required for cargo installation"
        print_info "Install Rust first: https://rustup.rs/"
        return 1
    fi
    cargo install termscp --locked
}

attempt_install() {
    local method="$1"
    print_info "Trying install method: $method"
    case "$method" in
        release)
            install_with_release
            ;;
        package)
            install_with_package_manager
            ;;
        cargo)
            install_with_cargo
            ;;
        *)
            print_error "Unsupported install method: $method"
            return 1
            ;;
    esac
}

case "$METHOD" in
    auto)
        case "$OS" in
            macos)
                attempt_install release || attempt_install package || attempt_install cargo
                ;;
            debian|fedora|rhel|arch|linux)
                attempt_install cargo || attempt_install release || attempt_install package
                ;;
            *)
                attempt_install release || attempt_install package || attempt_install cargo
                ;;
        esac
        ;;
    release|package|cargo)
        attempt_install "$METHOD"
        ;;
    official)
        print_warning "--method official is deprecated; using --method release instead"
        attempt_install release
        ;;
    *)
        print_error "Invalid method: $METHOD"
        usage
        exit 1
        ;;
esac

if command_exists termscp; then
    print_success "termscp installed successfully: $(termscp --version 2>/dev/null || echo termscp)"
else
    print_error "termscp installation finished but the command was not found in PATH"
    exit 1
fi
