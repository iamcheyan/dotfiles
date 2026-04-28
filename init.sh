#!/bin/bash
# Dotfiles initialization script
# Used for first-time setup after cloning the repository
# Usage: bash init.sh
# Usage: bash init.sh --repair  # Repair broken zinit plugins (e.g., atuin)

set -e

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # Reset color

# Print colored messages
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

# Check whether a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Detect the operating system
detect_os() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if command_exists apt-get; then
            OS="debian"
        elif command_exists yum || command_exists dnf; then
            # Distinguish Fedora from RHEL/CentOS
            if [[ -f /etc/os-release ]]; then
                source /etc/os-release
                if [[ "$ID" == "fedora" ]]; then
                    OS="fedora"
                else
                    OS="rhel"
                fi
            else
                OS="rhel"
            fi
        elif command_exists pacman; then
            OS="arch"
        else
            OS="linux"
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        OS="macos"
    else
        OS="unknown"
    fi
    echo "$OS"
}

# Install zsh
install_zsh() {
    if command_exists zsh; then
        print_success "zsh is already installed: $(zsh --version)"
        return 0
    fi

    print_info "zsh was not found. Installing..."

    OS=$(detect_os)
    case "$OS" in
        debian)
            if command_exists sudo; then
                sudo apt-get update
                sudo apt-get install -y zsh
            else
                print_error "sudo privileges are required to install zsh"
                return 1
            fi
            ;;
        rhel|fedora)
            if command_exists sudo; then
                if command_exists dnf; then
                    sudo dnf install -y zsh
                else
                    sudo yum install -y zsh
                fi
            else
                print_error "sudo privileges are required to install zsh"
                return 1
            fi
            ;;
        arch)
            if command_exists sudo; then
                sudo pacman -S --noconfirm zsh
            else
                print_error "sudo privileges are required to install zsh"
                return 1
            fi
            ;;
        macos)
            if command_exists brew; then
                brew install zsh
            else
                print_warning "On macOS, install Homebrew first or install zsh manually"
                return 1
            fi
            ;;
        *)
            print_warning "Could not detect the operating system automatically. Please install zsh manually"
            print_info "Ubuntu/Debian: sudo apt-get install zsh"
            print_info "Fedora/RHEL: sudo dnf install zsh"
            print_info "Arch Linux: sudo pacman -S zsh"
            print_info "macOS: brew install zsh"
            return 1
            ;;
    esac

    if command_exists zsh; then
        print_success "zsh installed successfully: $(zsh --version)"
    else
        print_error "Failed to install zsh"
        return 1
    fi
}

# Install zinit
install_zinit() {
    local zinit_dir="$HOME/.zinit/bin"
    
    if [[ -f "$zinit_dir/zinit.zsh" ]]; then
        print_success "zinit is already installed: $zinit_dir"
        return 0
    fi

    print_info "Installing zinit..."

    if ! command_exists git; then
        print_error "git is required to install zinit. Please install git first"
        return 1
    fi

    mkdir -p "$zinit_dir"
    if git clone https://github.com/zdharma-continuum/zinit.git "$zinit_dir" 2>/dev/null; then
        print_success "zinit installed successfully: $zinit_dir"
    else
        print_error "Failed to install zinit"
        return 1
    fi
}

# Repair broken zinit plugins (e.g., atuin downloaded wrong binary)
repair_zinit_plugins() {
    local atuin_dir="$HOME/.zinit/plugins/atuinsh---atuin"
    local broot_dir="$HOME/.zinit/plugins/Canop---broot"
    
    # Repair atuin
    if [[ -d "$atuin_dir" ]]; then
        if [[ ! -f "$atuin_dir/atuin" ]] || [[ ! -x "$atuin_dir/atuin" ]]; then
            print_warning "Detected broken atuin installation (wrong binary downloaded)"
            print_info "Removing broken atuin plugin..."
            rm -rf "$atuin_dir"
            print_success "Broken atuin plugin removed. It will be reinstalled on next zsh launch"
        else
            print_success "atuin binary looks correct"
        fi
    fi
    
    # Repair broot: zinit mv sometimes fails to move binary from subdir to root
    if [[ -d "$broot_dir" ]]; then
        if [[ ! -f "$broot_dir/broot" ]] || [[ ! -x "$broot_dir/broot" ]]; then
            print_warning "Detected broken broot installation (binary not in PATH)"
            # Find the actual broot binary in subdirectories
            local broot_binary
            broot_binary=$(find "$broot_dir" -name "broot" -type f -executable 2>/dev/null | head -n 1)
            if [[ -n "$broot_binary" ]]; then
                print_info "Copying broot binary from $(dirname "$broot_binary") to plugin root..."
                cp "$broot_binary" "$broot_dir/broot"
                chmod +x "$broot_dir/broot"
                print_success "broot binary fixed"
            else
                print_error "broot binary not found in subdirectories, removing plugin..."
                rm -rf "$broot_dir"
                print_success "Broken broot plugin removed. It will be reinstalled on next zsh launch"
            fi
        else
            print_success "broot binary looks correct"
        fi
        
        # Regenerate br shell function if needed
        local broot_launcher="${XDG_CONFIG_HOME:-$HOME/.config}/broot/launcher/br"
        local broot_init_script="$HOME/.dotfiles/config/broot/init.sh"
        if [[ -f "$broot_dir/broot" ]] && [[ -f "$broot_init_script" ]]; then
            if [[ ! -f "$broot_launcher" ]]; then
                print_info "Regenerating br shell function..."
                bash "$broot_init_script" >/dev/null 2>&1 || true
                print_success "br shell function regenerated"
            fi
        fi
    fi
    
    # Add more plugin repairs here as needed
}

# Install essential tools
install_essentials() {
    print_info "Checking essential tools..."
    
    local common_packages="git curl wget unzip git-extras ffmpeg"
    local debian_packages="build-essential ripgrep fd-find bat lsd zoxide translate-shell glow mdcat yt-dlp tealdeer gping jq httpie broot"
    local rhel_packages="make automake gcc gcc-c++ ripgrep fd-find bat lsd zoxide translate-shell glow mdcat yt-dlp tealdeer gping jq httpie broot"
    local arch_packages="base-devel ripgrep fd bat lsd zoxide translate-shell glow mdcat yt-dlp tealdeer gping jq httpie broot"
    local brew_packages="ripgrep fd bat lsd zoxide translate-shell glow mdcat viu yt-dlp tealdeer gping jq httpie broot"

    OS=$(detect_os)
    if [[ "$OS" == "debian" ]]; then
        if command_exists sudo; then
            sudo apt-get update
            # Only install packages that are available in the configured repositories
            local install_list=""
            for pkg in $common_packages $debian_packages; do
                if apt-cache policy "$pkg" | grep "Candidate:" | grep -v "(none)" >/dev/null 2>&1; then
                    install_list="$install_list $pkg"
                else
                    print_warning "Package '$pkg' is not available in the current repositories and will be skipped"
                fi
            done
            
            if [[ -n "$install_list" ]]; then
                sudo apt-get install -y $install_list
            else
                print_warning "No installable packages were found"
            fi
            # On Debian, bat and fd may require aliases, but aliases.conf already handles that
        else
            print_error "sudo privileges are required to install essential tools"
            return 1
        fi
    elif [[ "$OS" == "rhel" ]]; then
         if command_exists sudo; then
            if command_exists dnf; then
                sudo dnf install -y epel-release
                sudo dnf groupinstall -y "Development Tools"
                sudo dnf install -y $common_packages $rhel_packages
            else
                sudo yum groupinstall -y "Development Tools"
                sudo yum install -y $common_packages $rhel_packages
            fi
        else
            print_error "sudo privileges are required to install essential tools"
            return 1
        fi
    elif [[ "$OS" == "fedora" ]]; then
        if command_exists sudo; then
            # Fedora does not need epel-release
            # dnf5 uses "group install" instead of "groupinstall"
            # Using the group ID is more reliable than the display name
            sudo dnf group install -y development-tools || sudo dnf group install -y "Development Tools" || sudo dnf groupinstall -y "Development Tools" || true
            # Skip packages that are not available
            sudo dnf install -y --skip-unavailable $common_packages $rhel_packages || true
        else
            print_error "sudo privileges are required to install essential tools"
            return 1
        fi
    elif [[ "$OS" == "arch" ]]; then
        if command_exists sudo; then
             sudo pacman -S --noconfirm $common_packages $arch_packages
        else
            print_error "sudo privileges are required to install essential tools"
            return 1
        fi
    elif [[ "$OS" == "macos" ]]; then
        if command_exists brew; then
            brew install $common_packages $brew_packages
        else
            print_warning "On macOS, install Homebrew first"
            return 1
        fi
    else
         print_warning "Could not install essential tools automatically. Please install these manually: git, curl, wget, build-essential, ripgrep, fd, bat, lsd, zoxide"
         return 1
    fi
    
    print_success "Essential tools installation/check completed"
}

# Install pyenv
install_pyenv() {
    local pyenv_dir="$HOME/.pyenv"
    
    if [[ -d "$pyenv_dir" ]]; then
        print_success "pyenv is already installed: $pyenv_dir"
        return 0
    fi

    print_info "Installing pyenv..."

    if ! command_exists git; then
        print_error "git is required to install pyenv"
        return 1
    fi

    git clone https://github.com/pyenv/pyenv.git "$pyenv_dir"
    if [[ $? -eq 0 ]]; then
        print_success "pyenv installed successfully: $pyenv_dir"
        
        # Install the pyenv-virtualenv plugin
        if [[ ! -d "$pyenv_dir/plugins/pyenv-virtualenv" ]]; then
            print_info "Installing pyenv-virtualenv..."
            git clone https://github.com/pyenv/pyenv-virtualenv.git "$pyenv_dir/plugins/pyenv-virtualenv"
            print_success "pyenv-virtualenv installed successfully"
        fi
    else
        print_error "Failed to install pyenv"
        return 1
    fi
}

# Install nvm
install_nvm() {
    local nvm_dir="$HOME/.nvm"
    
    if [[ -d "$nvm_dir" ]]; then
        print_success "nvm is already installed: $nvm_dir"
        return 0
    fi

    print_info "Installing nvm..."

    if ! command_exists git; then
        print_error "git is required to install nvm"
        return 1
    fi

    git clone https://github.com/nvm-sh/nvm.git "$nvm_dir"
    if [[ $? -eq 0 ]]; then
        print_success "nvm installed successfully: $nvm_dir"
    else
        print_error "Failed to install nvm"
        return 1
    fi
}

# Install direnv
install_direnv() {
    local direnv_bin="$HOME/.local/bin/direnv"
    
    if [[ -x "$direnv_bin" ]]; then
        print_success "direnv is already installed: $($direnv_bin --version)"
        return 0
    fi

    print_info "Installing direnv..."

    local os_type="linux"
    [[ "$OSTYPE" == "darwin"* ]] && os_type="darwin"

    local arch
    if [[ "$(uname -m)" == "x86_64" ]]; then
        arch="amd64"
    elif [[ "$(uname -m)" == "aarch64" ]] || [[ "$(uname -m)" == "arm64" ]]; then
        arch="arm64"
    else
        print_error "Unsupported architecture: $(uname -m)"
        return 1
    fi

    local version=$(curl -sL https://api.github.com/repos/direnv/direnv/releases/latest 2>/dev/null | grep '"tag_name"' | sed 's/.*v\([0-9.]*\).*/\1/')
    if [[ -z "$version" ]]; then
        version="2.35.0"
    fi

    mkdir -p "$HOME/.local/bin"
    if curl -sL "https://github.com/direnv/direnv/releases/download/v${version}/direnv.${os_type}-${arch}" -o "$direnv_bin"; then
        chmod +x "$direnv_bin"
        print_success "direnv installed successfully: v$($direnv_bin --version)"
    else
        print_error "Failed to install direnv"
        return 1
    fi
}

# Install fzf
install_fzf() {
    if command_exists fzf; then
        print_success "fzf is already installed: $(fzf --version | head -n 1)"
        return 0
    fi

    print_info "fzf was not found. Installing..."

    OS=$(detect_os)
    case "$OS" in
        debian)
            if command_exists sudo; then
                sudo apt-get update
                sudo apt-get install -y fzf
            else
                print_error "sudo privileges are required to install fzf"
                return 1
            fi
            ;;
        rhel|fedora)
            if command_exists sudo; then
                if command_exists dnf; then
                    sudo dnf install -y fzf
                else
                    sudo yum install -y fzf
                fi
            else
                print_error "sudo privileges are required to install fzf"
                return 1
            fi
            ;;
        arch)
            if command_exists sudo; then
                sudo pacman -S --noconfirm fzf
            else
                print_error "sudo privileges are required to install fzf"
                return 1
            fi
            ;;
        macos)
            if command_exists brew; then
                brew install fzf
            else
                print_warning "On macOS, install Homebrew first or install fzf manually"
                return 1
            fi
            ;;
        *)
            print_warning "Could not detect the operating system automatically. Please install fzf manually"
            print_info "Ubuntu/Debian: sudo apt-get install fzf"
            print_info "Fedora/RHEL: sudo dnf install fzf"
            print_info "Arch Linux: sudo pacman -S fzf"
            print_info "macOS: brew install fzf"
            return 1
            ;;
    esac

    if command_exists fzf; then
        print_success "fzf installed successfully: $(fzf --version | head -n 1)"
    else
        print_error "Failed to install fzf"
        return 1
    fi
}

# Create the Dotfiles symlink (make ~/.dotfiles point to ~/Dotfiles)
# ~/Dotfiles is the real directory, ~/.dotfiles is the symlink
create_dotfiles_link() {
    local dotfiles_real="$HOME/Dotfiles"
    local dotfiles_link="$HOME/.dotfiles"

    # If ~/Dotfiles does not exist, the repository is not in the standard location
    if [[ ! -d "$dotfiles_real" ]]; then
        print_warning "~/Dotfiles does not exist. Skipping symlink creation"
        return 0
    fi

    # Check whether ~/.dotfiles already exists and points to the correct target
    if [[ -L "$dotfiles_link" ]]; then
        local current_target=$(readlink -f "$dotfiles_link")
        if [[ "$current_target" == "$dotfiles_real" ]]; then
            print_success "Symlink already exists: $dotfiles_link -> $dotfiles_real"
            return 0
        else
            print_warning "Symlink points to a different target: $dotfiles_link -> $current_target"
            read -p "Recreate the symlink? (y/N): " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                rm -f "$dotfiles_link"
            else
                return 0
            fi
        fi
    elif [[ -e "$dotfiles_link" ]]; then
        print_info "Removing existing $dotfiles_link"
        rm -rf "$dotfiles_link"
    fi

    # Create ~/.dotfiles -> ~/Dotfiles
    if ln -s "$dotfiles_real" "$dotfiles_link" 2>/dev/null; then
        print_success "Created symlink: $dotfiles_link -> $dotfiles_real"
    else
        print_error "Failed to create symlink"
        return 1
    fi
}

# Use dotlink to create symlinks for config files
run_dotlink() {
    local dotlink_script="${DOTFILES_DIR:-$HOME/.dotfiles}/dotlink/dotlink"

    if [[ ! -f "$dotlink_script" ]]; then
        print_error "dotlink script not found: $dotlink_script"
        return 1
    fi

    if [[ ! -x "$dotlink_script" ]]; then
        chmod +x "$dotlink_script"
    fi

    print_info "Creating config file symlinks with dotlink..."
    
    # Set backup directory environment variable to enable dotlink backup behavior
    export DOTLINK_BACKUP_DIR="$HOME/.dotfiles_backup_$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$DOTLINK_BACKUP_DIR"
    print_info "Backup directory: $DOTLINK_BACKUP_DIR"

    bash "$dotlink_script" link
    
    # Remove the backup directory if nothing was backed up
    if [[ -d "$DOTLINK_BACKUP_DIR" ]] && [[ -z "$(ls -A "$DOTLINK_BACKUP_DIR")" ]]; then
        rmdir "$DOTLINK_BACKUP_DIR"
    fi

    if [[ $? -eq 0 ]]; then
        print_success "dotlink completed successfully"
    else
        print_warning "dotlink may have encountered issues. Please review the output"
    fi
}

# Create the .zshrc symlink if needed
create_zshrc_link() {
    local zshrc_target="$HOME/.zshrc"
    local zshrc_source="${DOTFILES_DIR:-$HOME/.dotfiles}/zshrc"
    local zshrc_source_abs=$(readlink -f "$zshrc_source" 2>/dev/null || echo "$zshrc_source")

    if [[ -L "$zshrc_target" ]]; then
        local current_target=$(readlink -f "$zshrc_target")
        # Compare resolved real paths
        if [[ "$current_target" == "$zshrc_source_abs" ]]; then
            print_success ".zshrc symlink already exists: $zshrc_target -> $current_target"
            return 0
        else
            print_warning ".zshrc symlink points to a different target: $current_target"
            print_info "Expected target: $zshrc_source_abs"
        fi
    elif [[ -f "$zshrc_target" ]]; then
        print_info "Removing existing .zshrc"
        rm -f "$zshrc_target"
    fi

    if [[ ! -L "$zshrc_target" ]]; then
        # Use a relative or absolute path when creating the symlink
        # If DOTFILES_DIR is itself a symlink, an absolute path may be more stable
        local link_target
        if [[ -L "${DOTFILES_DIR:-$HOME/.dotfiles}" ]]; then
            # DOTFILES_DIR itself is a symlink, so use the absolute path
            link_target="$zshrc_source_abs"
        else
            # Use a path relative to HOME
            link_target="${DOTFILES_DIR:-$HOME/.dotfiles}/zshrc"
        fi
        
        if ln -s "$link_target" "$zshrc_target" 2>/dev/null; then
            print_success "Created .zshrc symlink: $zshrc_target -> $link_target"
        else
            print_error "Failed to create .zshrc symlink"
            return 1
        fi
    fi
}

# Detect and configure the dotfiles directory
# ~/Dotfiles is the real directory, ~/.dotfiles is the symlink
detect_dotfiles_dir() {
    local current_dir="$(pwd)"
    local dotfiles_real=""
    local dotfiles_link="$HOME/.dotfiles"
    
    # Prefer ~/Dotfiles first
    if [[ -d "$HOME/Dotfiles" ]] && [[ -f "$HOME/Dotfiles/zshrc" ]]; then
        dotfiles_real="$HOME/Dotfiles"
        print_info "Detected dotfiles real directory: $dotfiles_real"
        
        # Ensure ~/.dotfiles points to ~/Dotfiles
        if [[ ! -e "$dotfiles_link" ]]; then
            print_info "Creating ~/.dotfiles symlink..."
            if ln -s "$dotfiles_real" "$dotfiles_link" 2>/dev/null; then
                print_success "Created symlink: ~/.dotfiles -> ~/Dotfiles"
            else
                print_error "Failed to create symlink"
                return 1
            fi
        elif [[ -L "$dotfiles_link" ]]; then
            local target=$(readlink -f "$dotfiles_link")
            if [[ "$target" == "$dotfiles_real" ]]; then
                print_success "Symlink already exists: ~/.dotfiles -> ~/Dotfiles"
            else
                print_warning "~/.dotfiles points to a different target: $target"
                print_info "Expected target: $dotfiles_real"
                read -p "Recreate the symlink? (y/N): " -n 1 -r
                echo
                if [[ $REPLY =~ ^[Yy]$ ]]; then
                    rm -f "$dotfiles_link"
                    if ln -s "$dotfiles_real" "$dotfiles_link" 2>/dev/null; then
                        print_success "Recreated symlink: ~/.dotfiles -> ~/Dotfiles"
                    else
                        print_error "Failed to recreate symlink"
                        return 1
                    fi
                fi
            fi
        elif [[ -d "$dotfiles_link" ]]; then
            print_warning "~/.dotfiles already exists but is a directory, not a symlink"
            print_info "Removing ~/.dotfiles and creating a symlink"
            rm -rf "$dotfiles_link"
            if ln -s "$dotfiles_real" "$dotfiles_link" 2>/dev/null; then
                print_success "Created symlink: ~/.dotfiles -> ~/Dotfiles"
            else
                print_error "Failed to create symlink"
                return 1
            fi
        fi
    # If the current directory is a dotfiles repository, but not ~/Dotfiles
    elif [[ -f "$current_dir/zshrc" ]] && [[ -f "$current_dir/init.sh" ]]; then
        dotfiles_real="$current_dir"
        print_info "Detected dotfiles repository at: $dotfiles_real"
        
        # If the current directory is not ~/Dotfiles, ask whether to create symlinks
        if [[ "$dotfiles_real" != "$HOME/Dotfiles" ]]; then
            print_info "The current directory is not ~/Dotfiles. Create symlinks?"
            print_info "  Option 1: Create ~/.dotfiles -> $dotfiles_real"
            print_info "  Option 2: Create ~/Dotfiles -> $dotfiles_real, then ~/.dotfiles -> ~/Dotfiles"
            read -p "Choose an option (1/2/N to skip): " -n 1 -r
            echo
            if [[ $REPLY == "1" ]]; then
                if [[ -e "$dotfiles_link" ]]; then
                    print_warning "~/.dotfiles already exists and must be removed first"
                    read -p "Continue? (y/N): " -n 1 -r
                    echo
                    if [[ $REPLY =~ ^[Yy]$ ]]; then
                        rm -rf "$dotfiles_link"
                    else
                        return 1
                    fi
                fi
                if ln -s "$dotfiles_real" "$dotfiles_link" 2>/dev/null; then
                    print_success "Created symlink: ~/.dotfiles -> $dotfiles_real"
                else
                    print_error "Failed to create symlink"
                    return 1
                fi
            elif [[ $REPLY == "2" ]]; then
                if [[ ! -e "$HOME/Dotfiles" ]]; then
                    if ln -s "$dotfiles_real" "$HOME/Dotfiles" 2>/dev/null; then
                        print_success "Created symlink: ~/Dotfiles -> $dotfiles_real"
                        dotfiles_real="$HOME/Dotfiles"
                    else
                        print_error "Failed to create symlink"
                        return 1
                    fi
                fi
                # Then create ~/.dotfiles -> ~/Dotfiles
                if [[ ! -e "$dotfiles_link" ]]; then
                    if ln -s "$HOME/Dotfiles" "$dotfiles_link" 2>/dev/null; then
                        print_success "Created symlink: ~/.dotfiles -> ~/Dotfiles"
                    else
                        print_error "Failed to create symlink"
                        return 1
                    fi
                fi
            fi
        fi
    fi
    
    # Final check for ~/.dotfiles
    if [[ ! -e "$dotfiles_link" ]]; then
        print_error "~/.dotfiles was not found"
        print_info "Please make sure:"
        print_info "  1. You run this script inside the dotfiles repository, or"
        print_info "  2. The repository has been cloned into ~/Dotfiles or the current directory"
        return 1
    fi
    
    if [[ ! -f "$dotfiles_link/zshrc" ]]; then
        print_error "~/.dotfiles/zshrc does not exist"
        return 1
    fi
    
    export DOTFILES_DIR="$dotfiles_link"
    print_success "Dotfiles directory: $DOTFILES_DIR"
    return 0
}

# Install Neovim
install_neovim() {
    local install_script="${DOTFILES_DIR:-$HOME/.dotfiles}/scripts/install/install_nvim.sh"
    if [[ -f "$install_script" ]]; then
        print_info "Installing Neovim..."
        bash "$install_script"
    else
        print_warning "Neovim install script not found: $install_script"
    fi
}

# Install fonts
install_fonts() {
    local install_script="${DOTFILES_DIR:-$HOME/.dotfiles}/scripts/install/install_font.sh"
    if [[ -f "$install_script" ]]; then
        print_info "Installing fonts..."
        bash "$install_script"
    else
        print_warning "Font install script not found: $install_script"
    fi
}

# Initialize Yazi config
install_yazi_config() {
    local install_script="${DOTFILES_DIR:-$HOME/.dotfiles}/config/yazi/init.sh"
    if [[ -f "$install_script" ]]; then
        print_info "Initializing Yazi config..."
        chmod +x "$install_script"
        bash "$install_script"
    else
        print_warning "Yazi init script not found: $install_script"
    fi
}

# Install additional tools (Zellij, Codex, Gemini, Opencode, Sbzr, Tree-sitter, etc.)
install_extra_tools() {
    local install_dir="${DOTFILES_DIR:-$HOME/.dotfiles}/scripts/install"
    
    print_info "Checking and installing additional tools..."

    # Zellij
    if ! command_exists zellij; then
        print_info "Installing Zellij..."
        [[ -f "$install_dir/install_zellij.sh" ]] && bash "$install_dir/install_zellij.sh"
    else
        print_success "Zellij is already installed"
    fi

    # Codex
    if ! command_exists codex; then
        print_info "Installing Codex..."
        [[ -f "$install_dir/install_codex.sh" ]] && bash "$install_dir/install_codex.sh"
    else
        print_success "Codex is already installed"
    fi

    # Gemini
    if ! command_exists gemini; then
        print_info "Checking/installing Gemini..."
        [[ -f "$install_dir/install_gemini.sh" ]] && bash "$install_dir/install_gemini.sh"
    else
        print_success "Gemini is already installed"
    fi

    # Opencode
    if ! command_exists opencode; then
        print_info "Installing Opencode..."
        [[ -f "$install_dir/install_opencode.sh" ]] && bash "$install_dir/install_opencode.sh"
    else
        print_success "Opencode is already installed"
    fi

    # Sbzr
    if ! command_exists sbzr; then
        print_info "Installing Sbzr..."
        [[ -f "$install_dir/install_sbzr.sh" ]] && bash "$install_dir/install_sbzr.sh"
    else
        print_success "Sbzr is already installed"
    fi

    # tree-sitter
    if ! command_exists tree-sitter; then
        print_info "Installing Tree-sitter..."
        [[ -f "$install_dir/install_treesitter.sh" ]] && bash "$install_dir/install_treesitter.sh"
    else
        print_success "Tree-sitter is already installed"
    fi

    # Firefox theme (Linux only)
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if command_exists firefox || command_exists firefox-developer-edition; then
            print_info "Linux environment detected. Configuring Firefox theme..."
            [[ -f "$install_dir/firefox_theme_install.sh" ]] && bash "$install_dir/firefox_theme_install.sh"
        fi
    fi
}

# Main function
main() {
    echo -e "${BLUE}"
    cat << "EOF"
   ___  ____  ________   _____  ____ __
  / _ \/ __ \/_  __/ /  /  _/ |/ / //_/
 / // / /_/ / / / / /___/ //    / ,<   
/____/\____/ /_/ /____/___/_/|_/_/|_|  
                                       
EOF
    echo -e "${NC}"

    # Important notice
    echo -e "${YELLOW}⚠  Important Notice:${NC}"
    echo ""
    echo "This script will:"
    echo "  1. Create symlinks for config files (replacing existing files)"
    echo "  2. Create a ~/.zshrc symlink (replacing the existing file)"
    echo ""
    echo -e "${RED}Warning: existing config files will be overwritten.${NC}"
    echo ""
    # 3-second countdown
    echo "The script will start in 3 seconds..."
    for i in {3..1}; do
        echo -ne "$i... \r"
        sleep 1
    done
    echo "Starting...      "
    echo ""

    # Detect and configure the dotfiles directory
    print_info "Step 1/15: Detecting the dotfiles repository location"
    if ! detect_dotfiles_dir; then
        exit 1
    fi
    echo ""

    # 1. Install zsh
    print_info "Step 2/15: Checking and installing zsh"
    install_zsh
    echo ""

    # 2. Install essential tools
    print_info "Step 3/15: Installing essential tools (git, curl, build-essential, etc.)"
    install_essentials
    echo ""

    # 3. Install zinit
    print_info "Step 4/15: Checking and installing zinit"
    install_zinit
    echo ""

    # 3.5 Repair broken zinit plugins (if --repair flag is passed)
    if [[ "$1" == "--repair" ]]; then
        print_info "Repair mode: Checking for broken zinit plugins..."
        repair_zinit_plugins
        echo ""
    fi

    # 4. Install pyenv
    print_info "Step 5/15: Checking and installing pyenv"
    install_pyenv
    echo ""

    # 5. Install nvm
    print_info "Step 6/15: Checking and installing nvm"
    install_nvm
    echo ""

    # 6. Install fzf
    print_info "Step 7/15: Checking and installing fzf"
    install_fzf
    echo ""

    # 7. Install direnv
    print_info "Step 8/15: Checking and installing direnv"
    install_direnv
    echo ""

    # 8. Create the Dotfiles symlink
    print_info "Step 9/15: Creating the Dotfiles symlink"
    create_dotfiles_link
    echo ""

    # 9. Create config file symlinks with dotlink
    print_info "Step 10/15: Creating config file symlinks with dotlink"
    run_dotlink
    echo ""

    # 10. Create the .zshrc symlink
    print_info "Step 11/15: Creating the .zshrc symlink"
    create_zshrc_link
    echo ""

    # 11. Install Neovim
    print_info "Step 12/15: Installing Neovim"
    install_neovim
    echo ""

    # 12. Install fonts
    print_info "Step 13/15: Installing fonts"
    install_fonts
    echo ""

    # 13. Initialize Yazi config
    print_info "Step 14/15: Initializing Yazi config"
    install_yazi_config
    echo ""

    # 14. Install additional tools
    print_info "Step 15/15: Checking and installing additional tools (Zellij, Gemini, Codex, etc.)"
    install_extra_tools
    echo ""

    # Completion message
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    print_success "Initialization completed"
    echo ""

    print_info "Next steps:"
    echo -e "  1. Switch to zsh:"
    echo -e "     ${GREEN}zsh${NC}"
    echo ""
    echo "  2. On the first zsh launch, it will automatically:"
    echo "     - Install the Powerlevel10k theme"
    echo "     - Install all configured plugins and tools"
    echo "     - Ask whether to install the Meslo font"
    echo ""
    echo -e "  3. If you need additional configuration, refer to the documentation"
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""

    # Show backup information
    if [[ -d "$DOTLINK_BACKUP_DIR" ]]; then
        echo -e "${YELLOW}📦 Backup Information:${NC}"
        echo "  Backup location: $DOTLINK_BACKUP_DIR"
        echo "  To restore, copy the files from the backup directory back to their original locations"
        echo ""
    fi

    # Ask whether to switch to zsh immediately and set it as the default shell
    if command_exists zsh && [[ "$SHELL" != "$(command -v zsh)" ]]; then
        read -p "Switch to zsh now and set it as the default shell? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            ZSH_PATH=$(command -v zsh)
            print_info "Setting zsh as the default shell..."
            
            # Check whether zsh is listed in /etc/shells
            if ! grep -Fxq "$ZSH_PATH" /etc/shells 2>/dev/null; then
                print_warning "zsh is not listed in /etc/shells. Administrator privileges may be required to add it"
                if command_exists sudo; then
                    echo "$ZSH_PATH" | sudo tee -a /etc/shells >/dev/null
                    print_success "Added zsh to /etc/shells"
                else
                    print_warning "Could not add zsh to /etc/shells automatically. Please add it manually:"
                    echo "  sudo echo '$ZSH_PATH' >> /etc/shells"
                fi
            fi
            
            # Set zsh as the default shell
            if command_exists chsh; then
                print_info "Authentication may be required to set the default shell:"
                if chsh -s "$ZSH_PATH"; then
                    print_success "zsh has been set as the default shell"
                else
                    print_warning "Failed to set the default shell"
                    print_info "Please run this manually: chsh -s $ZSH_PATH"
                fi
            else
                print_warning "The chsh command was not found. Cannot set the default shell"
            fi
            
            print_info "Switching to zsh..."
            exec zsh
        fi
    fi
}

# Run the main function
main "$@"
