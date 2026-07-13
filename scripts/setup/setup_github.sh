#!/usr/bin/env bash
#
# GitHub 配置脚本 (gh CLI)
# 作用：安装 gh、登录认证、配置 SSH key 和 git 全局设置
# 用法：./setup_github.sh
#

set -euo pipefail

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_info()    { echo -e "${BLUE}[INFO]${NC} $1"; }
print_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
print_error()   { echo -e "${RED}[ERROR]${NC} $1"; }

# --- OS 检测 ---
detect_os() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macos"
    elif command -v apt-get &>/dev/null; then
        echo "debian"
    elif command -v dnf &>/dev/null; then
        echo "fedora"
    elif command -v yum &>/dev/null; then
        echo "rhel"
    elif command -v pacman &>/dev/null; then
        echo "arch"
    else
        echo "unknown"
    fi
}

# --- Step 1: 安装 gh ---
install_gh() {
    if command -v gh &>/dev/null; then
        print_success "gh 已安装: $(gh --version | head -1)"
        return 0
    fi

    print_info "正在安装 gh CLI..."

    local os
    os=$(detect_os)
    case "$os" in
        debian)
            # 官方 APT 源
            if [[ ! -f /etc/apt/keyrings/githubcli-archive-keyring.gpg ]]; then
                sudo mkdir -p /etc/apt/keyrings
                curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
                    | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null
                sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg
            fi
            echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
                | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
            sudo apt-get update -qq
            sudo apt-get install -y gh
            ;;
        fedora)
            sudo dnf install -y 'dnf-command(config-manager)' || true
            sudo dnf config-manager --add-repo https://cli.github.com/packages/rpm/gh-cli.repo
            sudo dnf install -y gh
            ;;
        rhel)
            sudo dnf install -y 'dnf-command(config-manager)' || true
            sudo dnf config-manager --add-repo https://cli.github.com/packages/rpm/gh-cli.repo
            sudo dnf install -y gh
            ;;
        arch)
            sudo pacman -S --noconfirm github-cli
            ;;
        macos)
            brew install gh
            ;;
        *)
            print_error "不支持的系统，请手动安装: https://github.com/cli/cli#installation"
            return 1
            ;;
    esac

    if command -v gh &>/dev/null; then
        print_success "gh 安装成功: $(gh --version | head -1)"
    else
        print_error "gh 安装失败"
        return 1
    fi
}

# --- Step 2: 登录认证 ---
login_gh() {
    if gh auth status &>/dev/null; then
        print_success "gh 已登录"
        return 0
    fi

    print_info "正在登录 GitHub..."
    print_info "将通过浏览器完成认证 (如在远程服务器上，请选择 'Login with a web browser')"
    echo ""

    gh auth login --git-protocol https --web --hostname github.com -s admin:public_key || {
        print_warning "浏览器认证失败，尝试设备码方式..."
        gh auth login --git-protocol https --hostname github.com -s admin:public_key
    }

    if gh auth status &>/dev/null; then
        print_success "GitHub 登录成功"
    else
        print_error "GitHub 登录失败"
        return 1
    fi
}

# --- Step 3: 配置 SSH key ---
setup_ssh() {
    local ssh_key="$HOME/.ssh/id_ed25519"

    # 生成 SSH key（如果不存在）
    if [[ ! -f "$ssh_key" ]]; then
        print_info "正在生成 SSH key (ed25519)..."
        ssh-keygen -t ed25519 -C "$(gh api user -q '.email // .login')" -f "$ssh_key" -N ""
        print_success "SSH key 已生成: $ssh_key"
    else
        print_success "SSH key 已存在: $ssh_key"
    fi

    # 检查是否已添加到 GitHub
    local pub_key
    pub_key=$(cat "${ssh_key}.pub")
    local key_title
    key_title="$(hostname)-$(date +%Y%m%d)"

    if gh ssh-key list --json key --jq '.[].key' 2>/dev/null | grep -qF "${pub_key##* }"; then
        print_success "SSH key 已添加到 GitHub"
    else
        print_info "正在将 SSH key 添加到 GitHub..."
        gh ssh-key add "${ssh_key}.pub" --title "$key_title"
        print_success "SSH key 已添加到 GitHub: $key_title"
    fi

    # 配置 git 使用 SSH 协议访问 github.com
    if ! git config --global --get url."git@github.com:".insteadOf &>/dev/null | grep -q "https://github.com/"; then
        git config --global url."git@github.com:".insteadOf "https://github.com/"
        print_success "git 已配置: https://github.com/* -> git@github.com:* (SSH)"
    else
        print_success "git SSH 重写规则已存在"
    fi
}

# --- Step 4: 配置 git 用户信息 ---
setup_git_config() {
    local gh_user gh_email gh_name

    gh_user=$(gh api user -q '.login')
    gh_name=$(gh api user -q '.name // .login')
    # 优先用 noreply 邮箱，避免暴露真实邮箱
    gh_email="${gh_user}+${gh_user}@users.noreply.github.com"

    # user.name
    if [[ -z "$(git config --global user.name 2>/dev/null)" ]]; then
        git config --global user.name "$gh_name"
        print_success "git user.name = $gh_name"
    else
        print_info "git user.name 已配置: $(git config --global user.name)"
    fi

    # user.email
    if [[ -z "$(git config --global user.email 2>/dev/null)" ]]; then
        git config --global user.email "$gh_email"
        print_success "git user.email = $gh_email"
    else
        print_info "git user.email 已配置: $(git config --global user.email)"
    fi
}

# --- Step 5: 配置 gh 为 git credential helper ---
setup_credential() {
    gh auth setup-git 2>/dev/null && \
        print_success "gh 已设置为 git credential helper" || \
        print_warning "设置 credential helper 失败（非致命）"
}

# --- Main ---
main() {
    echo -e "${BLUE}"
    cat << 'BANNER'
   ____ _ _   _   _       _
  / ___| | |_| | | |_ __ | |__   __ _ _ __
 | |  _| | __| |_| | '_ \| '_ \ / _` | '__|
 | |_| | | |_|  _  | |_) | | | | (_| |
  \____|_|\__|_| |_| .__/|_| |_|\__,_|_|
                    |_|
BANNER
    echo -e "${NC}"

    echo ""
    print_info "Step 1/5: 安装 gh CLI"
    install_gh || exit 1
    echo ""

    print_info "Step 2/5: 登录 GitHub"
    login_gh || exit 1
    echo ""

    print_info "Step 3/5: 配置 SSH key"
    setup_ssh || exit 1
    echo ""

    print_info "Step 4/5: 配置 git 用户信息"
    setup_git_config
    echo ""

    print_info "Step 5/5: 配置 credential helper"
    setup_credential
    echo ""

    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    print_success "GitHub 配置完成"
    echo ""
    print_info "验证: gh auth status"
    gh auth status
    echo ""
    print_info "验证: ssh -T git@github.com"
    ssh -T git@github.com 2>&1 || true
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
}

main "$@"
