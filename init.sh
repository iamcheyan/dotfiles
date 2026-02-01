#!/bin/bash
# Dotfiles Initialization Script
# Used for initialization after cloning the repository for the first time
# Usage: bash init.sh

set -e

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Print message with color
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

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Detect Operating System
detect_os() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if command_exists apt-get; then
            OS="debian"
        elif command_exists yum || command_exists dnf; then
            # Distinguish between Fedora and RHEL/CentOS
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

    print_info "zsh is not installed, installing..."

    OS=$(detect_os)
    case "$OS" in
        debian)
            if command_exists sudo; then
                sudo apt-get update
                sudo apt-get install -y zsh
            else
                print_error "sudo privileges required to install zsh"
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
                print_error "sudo privileges required to install zsh"
                return 1
            fi
            ;;
        arch)
            if command_exists sudo; then
                sudo pacman -S --noconfirm zsh
            else
                print_error "sudo privileges required to install zsh"
                return 1
            fi
            ;;
        macos)
            if command_exists brew; then
                brew install zsh
            else
                print_warning "On macOS, please install Homebrew first, or install zsh manually"
                return 1
            fi
            ;;
        *)
            print_warning "Unable to automatically detect OS, please install zsh manually"
            print_info "Ubuntu/Debian: sudo apt-get install zsh"
            print_info "Fedora/RHEL: sudo dnf install zsh"
            print_info "Arch: sudo pacman -S zsh"
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
        print_error "Git is required to install zinit, please install git first"
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

# Install essentials
install_essentials() {
    print_info "Checking essential tools..."
    
    local common_packages="git curl wget unzip"
    local debian_packages="build-essential ripgrep fd-find bat lsd zoxide translate-shell"
    local rhel_packages="make automake gcc gcc-c++ ripgrep fd-find bat lsd zoxide translate-shell"
    local arch_packages="base-devel ripgrep fd bat lsd zoxide translate-shell"
    local brew_packages="ripgrep fd bat lsd zoxide translate-shell"

    OS=$(detect_os)
    if [[ "$OS" == "debian" ]]; then
        if command_exists sudo; then
            sudo apt-get update
            # Safe install function for apt
            local install_list=""
            for pkg in $common_packages $debian_packages; do
                if apt-cache policy "$pkg" | grep "Candidate:" | grep -v "(none)" >/dev/null 2>&1; then
                    install_list="$install_list $pkg"
                else
                    print_warning "Package '$pkg' is not available in current sources, skipping installation"
                fi
            done
            
            if [[ -n "$install_list" ]]; then
                sudo apt-get install -y $install_list
            else
                print_warning "No packages to install"
            fi
            # For bat and fd, manual alias creation might be needed on Debian, but handled in aliases.conf
        else
            print_error "sudo privileges required to install essential tools"
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
            print_error "sudo privileges required to install essential tools"
            return 1
        fi
    elif [[ "$OS" == "fedora" ]]; then
        if command_exists sudo; then
            # Fedora does not need epel-release
            # dnf5 uses "group install" instead of "groupinstall"
            sudo dnf group install -y "Development Tools" || sudo dnf groupinstall -y "Development Tools" || true
            # Use --skip-unavailable to skip packages that are not available
            sudo dnf install -y --skip-unavailable $common_packages $rhel_packages || true
        else
            print_error "sudo privileges required to install essential tools"
            return 1
        fi
    elif [[ "$OS" == "arch" ]]; then
        if command_exists sudo; then
             sudo pacman -S --noconfirm $common_packages $arch_packages
        else
            print_error "sudo privileges required to install essential tools"
            return 1
        fi
    elif [[ "$OS" == "macos" ]]; then
        if command_exists brew; then
            brew install $common_packages $brew_packages
        else
            print_warning "On macOS, please install Homebrew first"
            return 1
        fi
    else
         print_warning "Unable to automatically install basic tools, please install manually: git, curl, wget, build-essential, ripgrep, fd, bat, lsd, zoxide"
         return 1
    fi
    
    print_success "Essential tools checked/installed"
}

# Install fzf
install_fzf() {
    if command_exists fzf; then
        print_success "fzf is already installed: $(fzf --version | head -n 1)"
        return 0
    fi

    print_info "fzf is not installed, installing..."

    OS=$(detect_os)
    case "$OS" in
        debian)
            if command_exists sudo; then
                sudo apt-get update
                sudo apt-get install -y fzf
            else
                print_error "需要 sudo 权限来安装 fzf"
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
                print_error "需要 sudo 权限来安装 fzf"
                return 1
            fi
            ;;
        arch)
            if command_exists sudo; then
                sudo pacman -S --noconfirm fzf
            else
                print_error "需要 sudo 权限来安装 fzf"
                return 1
            fi
            ;;
        macos)
            if command_exists brew; then
                brew install fzf
            else
                print_warning "On macOS, please install Homebrew first, or install fzf manually"
                return 1
            fi
            ;;
        *)
            print_warning "Unable to automatically detect OS, please install fzf manually"
            print_info "Ubuntu/Debian: sudo apt-get install fzf"
            print_info "Fedora/RHEL: sudo dnf install fzf"
            print_info "Arch: sudo pacman -S fzf"
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

# Create Dotfiles symlink (ensure ~/.dotfiles points to ~/Dotfiles)
# Note: ~/Dotfiles is the real directory, ~/.dotfiles is the symlink
create_dotfiles_link() {
    local dotfiles_real="$HOME/Dotfiles"
    local dotfiles_link="$HOME/.dotfiles"

    # If ~/Dotfiles does not exist, the repo is not in standard location, skip this step
    if [[ ! -d "$dotfiles_real" ]]; then
        print_warning "~/Dotfiles directory not found, skipping symlink creation"
        return 0
    fi

    # Check if ~/.dotfiles already exists and points correctly
    if [[ -L "$dotfiles_link" ]]; then
        local current_target=$(readlink -f "$dotfiles_link")
        if [[ "$current_target" == "$dotfiles_real" ]]; then
            print_success "Symlink already exists: $dotfiles_link -> $dotfiles_real"
            return 0
        else
            print_warning "Symlink points to different target: $dotfiles_link -> $current_target"
            read -p "Recreate symlink? (y/N): " -n 1 -r
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

    # Create ~/.dotfiles -> ~/Dotfiles symlink
    if ln -s "$dotfiles_real" "$dotfiles_link" 2>/dev/null; then
        print_success "Created symlink: $dotfiles_link -> $dotfiles_real"
    else
        print_error "Failed to create symlink"
        return 1
    fi
}



# Use dotlink to create config file symlinks
run_dotlink() {
    local dotlink_script="${DOTFILES_DIR:-$HOME/.dotfiles}/dotlink/dotlink"

    if [[ ! -f "$dotlink_script" ]]; then
        print_error "dotlink script not found: $dotlink_script"
        return 1
    fi

    if [[ ! -x "$dotlink_script" ]]; then
        chmod +x "$dotlink_script"
    fi

    print_info "Using dotlink to create config symlinks..."
    
    # Set backup directory env var to trigger dotlink backup
    export DOTLINK_BACKUP_DIR="$HOME/.dotfiles_backup_$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$DOTLINK_BACKUP_DIR"
    print_info "Backup directory: $DOTLINK_BACKUP_DIR"

    bash "$dotlink_script" link
    
    # If backup dir is empty (no files backed up), remove it
    if [[ -d "$DOTLINK_BACKUP_DIR" ]] && [[ -z "$(ls -A "$DOTLINK_BACKUP_DIR")" ]]; then
        rmdir "$DOTLINK_BACKUP_DIR"
    fi

    if [[ $? -eq 0 ]]; then
        print_success "dotlink executed successfully"
    else
        print_warning "dotlink execution might have errors, please check output"
    fi
}

# Create zshrc symlink (if not exists)
create_zshrc_link() {
    local zshrc_target="$HOME/.zshrc"
    local zshrc_source="${DOTFILES_DIR:-$HOME/.dotfiles}/zshrc"
    local zshrc_source_abs=$(readlink -f "$zshrc_source" 2>/dev/null || echo "$zshrc_source")

    if [[ -L "$zshrc_target" ]]; then
        local current_target=$(readlink -f "$zshrc_target")
        # Compare actual file paths (after resolving all symlinks)
        if [[ "$current_target" == "$zshrc_source_abs" ]]; then
            print_success ".zshrc symlink already exists: $zshrc_target -> $current_target"
            return 0
        else
            print_warning ".zshrc symlink points to different target: $current_target"
            print_info "Expected target: $zshrc_source_abs"
        fi
    elif [[ -f "$zshrc_target" ]]; then
        print_info "Removing existing .zshrc"
        rm -f "$zshrc_target"
    fi

    if [[ ! -L "$zshrc_target" ]]; then
        # Create symlink using relative or absolute path
        # If DOTFILES_DIR is a symlink, relative path might be more stable
        local link_target
        if [[ -L "${DOTFILES_DIR:-$HOME/.dotfiles}" ]]; then
            # DOTFILES_DIR is a symlink, use absolute path
            link_target="$zshrc_source_abs"
        else
            # Use relative path (relative from HOME)
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

# Detect and set dotfiles directory
# Note: ~/Dotfiles is the real directory, ~/.dotfiles is the symlink
detect_dotfiles_dir() {
    local current_dir="$(pwd)"
    local dotfiles_real=""
    local dotfiles_link="$HOME/.dotfiles"
    
    # Prioritize checking ~/Dotfiles (real directory)
    if [[ -d "$HOME/Dotfiles" ]] && [[ -f "$HOME/Dotfiles/zshrc" ]]; then
        dotfiles_real="$HOME/Dotfiles"
        print_info "Detected dotfiles real directory: $dotfiles_real"
        
        # Ensure ~/.dotfiles symlink points to ~/Dotfiles
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
                print_warning "~/.dotfiles symlink points to different target: $target"
                print_info "Expected target: $dotfiles_real"
                read -p "Recreate symlink? (y/N): " -n 1 -r
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
            print_warning "~/.dotfiles exists but is a directory (not a symlink)"
            print_info "Removing ~/.dotfiles and creating symlink"
            rm -rf "$dotfiles_link"
            if ln -s "$dotfiles_real" "$dotfiles_link" 2>/dev/null; then
                print_success "Created symlink: ~/.dotfiles -> ~/Dotfiles"
            else
                print_error "Failed to create symlink"
                return 1
            fi
        fi
    # If current directory is dotfiles repo (but not ~/Dotfiles)
    elif [[ -f "$current_dir/zshrc" ]] && [[ -f "$current_dir/init.sh" ]]; then
        dotfiles_real="$current_dir"
        print_info "Detected dotfiles repo at: $dotfiles_real"
        
        # If current directory is not ~/Dotfiles, ask if symlink should be created
        if [[ "$dotfiles_real" != "$HOME/Dotfiles" ]]; then
            print_info "Current directory is not ~/Dotfiles, create symlink?"
            print_info "  Option 1: Create ~/.dotfiles -> $dotfiles_real"
            print_info "  Option 2: Create ~/Dotfiles -> $dotfiles_real (then ~/.dotfiles -> ~/Dotfiles)"
            read -p "Select option (1/2/N, skip): " -n 1 -r
            echo
            if [[ $REPLY == "1" ]]; then
                if [[ -e "$dotfiles_link" ]]; then
                    print_warning "~/.dotfiles already exists, need to remove first"
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
    
    # Final check if ~/.dotfiles exists and is accessible
    if [[ ! -e "$dotfiles_link" ]]; then
        print_error "~/.dotfiles not found"
        print_info "Please ensure:"
        print_info "  1. Run this script inside the dotfiles repo directory, or"
        print_info "  2. Clone the repo to ~/Dotfiles or current directory"
        return 1
    fi
    
    if [[ ! -f "$dotfiles_link/zshrc" ]]; then
        print_error "~/.dotfiles/zshrc does not exist"
        return 1
    fi
    
    export DOTFILES_DIR="$dotfiles_link"
    print_success "Dotfiles Directory: $DOTFILES_DIR"
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

# Initialize Yazi Configuration
install_yazi_config() {
    local install_script="${DOTFILES_DIR:-$HOME/.dotfiles}/config/yazi/init.sh"
    if [[ -f "$install_script" ]]; then
        print_info "Initializing Yazi configuration..."
        # Ensure script is executable
        chmod +x "$install_script"
        bash "$install_script"
    else
        print_warning "Yazi init script not found: $install_script"
    fi
}

# Main Function
main() {
    echo -e "${BLUE}"
    cat << "EOF"
   ___  ____  ________   _____  ____ __
  / _ \/ __ \/_  __/ /  /  _/ |/ / //_/
 / // / /_/ / / / / /___/ //    / ,<   
/____/\____/ /_/ /____/___/_/|_/_/|_|  
                                       
EOF
    echo -e "${NC}"

    # Usage and confirmation
    echo -e "${YELLOW}⚠  IMPORTANT NOTICE: ${NC}"
    echo ""
    echo "This script will:"
    echo "  1. Create symlinks for config files (overwrite existing)"
    echo "  2. Create ~/.zshrc symlink (overwrite existing)"
    echo ""
    echo -e "${RED}WARNING: Existing config files will be overwritten!${NC}"
    echo ""
    # 3 seconds countdown
    echo "Script will start in 3 seconds..."
    for i in {3..1}; do
        echo -ne "$i... \r"
        sleep 1
    done
    echo "Starting!      "
    echo ""

    # Detect and set dotfiles directory
    print_info "Step 0/10: Detect dotfiles repo location"
    if ! detect_dotfiles_dir; then
        exit 1
    fi
    echo ""



    # 1. Install zsh
    print_info "Step 1/10: Check and install zsh"
    install_zsh
    echo ""

    # 2. Install essential tools
    print_info "Step 2/10: Install essential tools (git, curl, build-essential, etc.)"
    install_essentials
    echo ""

    # 3. Install zinit
    print_info "Step 3/10: Check and install zinit"
    install_zinit
    echo ""

    # 4. Install fzf
    print_info "Step 4/10: Check and install fzf"
    install_fzf
    echo ""

    # 5. Create Dotfiles symlink (if not exists)
    print_info "Step 5/10: Create Dotfiles symlink"
    create_dotfiles_link
    echo ""

    # 6. Use dotlink to create config symlinks
    print_info "Step 6/10: Use dotlink to create config symlinks"
    run_dotlink
    echo ""

    # 7. Create .zshrc symlink
    print_info "Step 7/10: Create .zshrc symlink"
    create_zshrc_link
    echo ""

    # 8. Install Neovim
    print_info "Step 8/10: Install Neovim"
    install_neovim
    echo ""

    # 9. Install fonts
    print_info "Step 9/10: Install fonts"
    install_fonts
    echo ""

    # 10. Initialize Yazi Configuration
    print_info "Step 10/10: Initialize Yazi Configuration"
    install_yazi_config
    echo ""

    # Completion message
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    print_success "Initialization Complete!"
    echo ""
    

    
    print_info "Next Steps:"
    echo -e "  1. Switch to zsh:"
    echo -e "     ${GREEN}zsh${NC}"
    echo ""
    echo "  2. On first launch, zsh will automatically:"
    echo "     - Install Powerlevel10k theme"
    echo "     - Install all configured plugins and tools"
    echo "     - Ask to install Meslo fonts"
    echo ""
    echo -e "  3. Refer to documentation for further configuration"
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""

    # Show backup info
    if [[ -d "$DOTLINK_BACKUP_DIR" ]]; then
        echo -e "${YELLOW}📦 Backup Info:${NC}"
        echo "  Backup Location: $DOTLINK_BACKUP_DIR"
        echo "  To restore, copy files from backup directory back to original location"
        echo ""
    fi

    # Ask to switch to zsh and set as default shell
    if command_exists zsh && [[ "$SHELL" != "$(command -v zsh)" ]]; then
        read -p "Switch to zsh and set as default shell now? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            ZSH_PATH=$(command -v zsh)
            print_info "Setting zsh as default shell..."
            
            # Check if zsh is in /etc/shells
            if ! grep -Fxq "$ZSH_PATH" /etc/shells 2>/dev/null; then
                print_warning "zsh not in /etc/shells, admin privileges needed to add"
                if command_exists sudo; then
                    echo "$ZSH_PATH" | sudo tee -a /etc/shells >/dev/null
                    print_success "Added zsh to /etc/shells"
                else
                    print_warning "Unable to automatically add zsh to /etc/shells, please add manually:"
                    echo "  sudo echo '$ZSH_PATH' >> /etc/shells"
                fi
            fi
            
            # Set zsh as default shell
            if command_exists chsh; then
                print_info "Please enter user password to set default shell:"
                if chsh -s "$ZSH_PATH"; then
                    print_success "Set zsh as default shell"
                else
                    print_warning "Failed to set default shell"
                    print_info "Please run manually: chsh -s $ZSH_PATH"
                fi
            else
                print_warning "chsh command not found, cannot set default shell"
            fi
            
            print_info "Switching to zsh..."
            exec zsh
        fi
    fi
}

# Run main function
main "$@"

