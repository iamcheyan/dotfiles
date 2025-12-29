#!/bin/bash
# nvm (Node Version Manager) 安装脚本
# 安装并配置 nvm，用于管理 Node.js 版本
# 用法: install_nvm.sh [--force] [--version VERSION]

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

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

# nvm 安装 URL（默认版本）
NVM_VERSION="v0.39.7"
NVM_DIR="$HOME/.nvm"

# 解析参数
FORCE_INSTALL=false
while [[ $# -gt 0 ]]; do
    case "$1" in
        --force|-f)
            FORCE_INSTALL=true
            shift
            ;;
        --version|-v)
            if [[ -n "${2:-}" ]]; then
                NVM_VERSION="$2"
                shift 2
            else
                print_error "选项 --version 需要指定版本号"
                exit 1
            fi
            ;;
        *)
            # 如果第一个参数不是选项，可能是版本号
            if [[ "$1" =~ ^v?[0-9] ]]; then
                NVM_VERSION="$1"
            else
                print_error "未知参数: $1"
                exit 1
            fi
            shift
            ;;
    esac
done

# 确保版本号以 v 开头
if [[ ! "$NVM_VERSION" =~ ^v ]]; then
    NVM_VERSION="v${NVM_VERSION}"
fi

NVM_INSTALL_URL="https://raw.githubusercontent.com/nvm-sh/nvm/${NVM_VERSION}/install.sh"

# 检查 nvm 是否已安装
check_nvm_installed() {
    if [ -d "$NVM_DIR" ] && [ -f "$NVM_DIR/nvm.sh" ]; then
        return 0
    fi
    return 1
}

# 检查 nvm 是否在 PATH 中
check_nvm_in_path() {
    if command -v nvm >/dev/null 2>&1; then
        return 0
    fi
    # 检查 shell 配置文件中是否有 nvm 配置
    local shell_rc=""
    if [[ "$SHELL" == *"zsh"* ]]; then
        shell_rc="$HOME/.zshrc"
    elif [[ "$SHELL" == *"bash"* ]]; then
        shell_rc="$HOME/.bashrc"
    fi
    
    if [ -f "$shell_rc" ] && grep -q "NVM_DIR" "$shell_rc" 2>/dev/null; then
        return 0
    fi
    return 1
}

# 检测 shell 类型
detect_shell() {
    if [[ "$SHELL" == *"zsh"* ]]; then
        echo "zsh"
    elif [[ "$SHELL" == *"bash"* ]]; then
        echo "bash"
    else
        echo "unknown"
    fi
}

# 获取 shell 配置文件路径
get_shell_rc() {
    local shell_type=$(detect_shell)
    case "$shell_type" in
        zsh)
            echo "$HOME/.zshrc"
            ;;
        bash)
            echo "$HOME/.bashrc"
            ;;
        *)
            # 默认使用 .bashrc
            echo "$HOME/.bashrc"
            ;;
    esac
}

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  nvm (Node Version Manager) 安装脚本"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# 检查是否已安装
if check_nvm_installed; then
    if [ "$FORCE_INSTALL" = true ]; then
        print_warning "检测到 nvm 已安装，使用 --force 参数将删除并重新安装"
        read -p "确定要删除现有 nvm 并重新安装吗？(y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            print_info "正在删除现有 nvm..."
            rm -rf "$NVM_DIR"
            # 从 shell 配置文件中移除 nvm 配置
            local shell_rc=$(get_shell_rc)
            if [ -f "$shell_rc" ]; then
                # 移除 nvm 相关配置（简单处理，移除包含 NVM_DIR 的块）
                sed -i.bak '/NVM_DIR/d' "$shell_rc" 2>/dev/null || true
                sed -i.bak '/nvm.sh/d' "$shell_rc" 2>/dev/null || true
                sed -i.bak '/nvm.sh/d' "$shell_rc" 2>/dev/null || true
            fi
        else
            print_info "已取消操作"
            exit 0
        fi
    else
        print_success "nvm 已安装: $NVM_DIR"
        if check_nvm_in_path; then
            print_success "nvm 已在 PATH 中"
            print_info "当前 shell: $(detect_shell)"
            print_info "如果要重新安装，请使用: install:nvm --force"
        else
            print_warning "nvm 未在 PATH 中，请重新加载 shell 配置"
            local shell_rc=$(get_shell_rc)
            print_info "运行: source $shell_rc"
        fi
        exit 0
    fi
fi

# 检查依赖
print_info "检查依赖..."
if ! command -v curl >/dev/null 2>&1 && ! command -v wget >/dev/null 2>&1; then
    print_error "需要 curl 或 wget 来下载 nvm"
    print_info "请先安装 curl 或 wget:"
    print_info "  Ubuntu/Debian: sudo apt-get install curl"
    exit 1
fi
print_success "依赖检查通过"

# 安装 nvm
print_info "正在安装 nvm ${NVM_VERSION}..."
print_info "安装 URL: $NVM_INSTALL_URL"
print_info "安装目录: $NVM_DIR"
echo ""

# 使用 curl 或 wget 下载并安装
if command -v curl >/dev/null 2>&1; then
    if curl -fsSL "$NVM_INSTALL_URL" | bash; then
        print_success "nvm 安装完成"
    else
        print_error "nvm 安装失败"
        exit 1
    fi
elif command -v wget >/dev/null 2>&1; then
    if wget -qO- "$NVM_INSTALL_URL" | bash; then
        print_success "nvm 安装完成"
    else
        print_error "nvm 安装失败"
        exit 1
    fi
fi

# 验证安装
if check_nvm_installed; then
    print_success "nvm 已安装到: $NVM_DIR"
else
    print_error "nvm 安装验证失败"
    exit 1
fi

# 配置 npm 全局安装路径（避免权限问题）
configure_npm() {
    print_info "正在配置 npm 全局安装路径..."
    
    # 创建 npm 全局包目录
    local npm_global_dir="$HOME/.npm-global"
    if mkdir -p "$npm_global_dir"; then
        print_success "已创建目录: $npm_global_dir"
    else
        print_warning "创建目录失败: $npm_global_dir"
        return 1
    fi
    
    # 临时加载 nvm 以使用 npm
    if [[ -s "$NVM_DIR/nvm.sh" ]]; then
        export NVM_DIR="$NVM_DIR"
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
        
        # 检查是否已安装 Node.js
        if command -v node >/dev/null 2>&1 && command -v npm >/dev/null 2>&1; then
            # 配置 npm 使用用户目录
            if npm config set prefix "$npm_global_dir" 2>/dev/null; then
                print_success "npm 全局安装路径已配置: $npm_global_dir"
                return 0
            else
                print_warning "npm 配置失败（可能 Node.js 未安装）"
                return 1
            fi
        else
            print_info "Node.js 未安装，npm 配置将在安装 Node.js 后自动完成"
            print_info "安装 Node.js 后运行: npm config set prefix '$npm_global_dir'"
            return 0
        fi
    else
        print_warning "无法加载 nvm，跳过 npm 配置"
        return 1
    fi
}

# 检查 shell 配置文件
shell_rc=$(get_shell_rc)
shell_type=$(detect_shell)

# 尝试配置 npm（如果可能）
configure_npm || true

# 自动配置 Node.js 和常用工具
auto_setup_node() {
    print_info "正在自动配置 Node.js 环境..."

    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

    if command -v nvm >/dev/null 2>&1; then
        # 1. 安装 Node.js v20 (LTS)
        print_info "检查并安装 Node.js 20 (LTS)..."
        nvm install 20
        nvm alias default 20
        nvm use default

        # 2. 配置 npm 全局路径
        configure_npm

        # 3. 安装全局工具
        print_info "安装全局工具..."
        
        # 修复 gemini 冲突
        if [[ -f "$HOME/.npm-global/bin/gemini" ]]; then
            # 检查是否是旧的冲突文件 (简单的检查方式，或者直接强制删除)
            print_warning "清理可能冲突的 gemini 二进制文件..."
            rm -f "$HOME/.npm-global/bin/gemini"
        fi

        local tools=(
            "@google/gemini-cli"
            "neovim"
            "tree-sitter-cli"
        )
        
        for tool in "${tools[@]}"; do
            print_info "正在安装 $tool..."
            npm install -g "$tool"
        done

        print_success "Node.js 环境及工具配置完成！"
    else
        print_error "无法加载 nvm，跳过自动配置"
    fi
}

# 运行自动配置
auto_setup_node

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
print_success "nvm 及 Node.js 环境安装完成！"
echo ""
print_info "安装位置: $NVM_DIR"
print_info "Node 版本: $(node -v 2>/dev/null || echo '未加载')"
print_info "npm 路径: $(npm config get prefix 2>/dev/null || echo '未加载')"
echo ""

# 检查配置是否已添加到 shell 配置文件
if [ -f "$shell_rc" ] && grep -q "NVM_DIR" "$shell_rc" 2>/dev/null; then
    print_success "nvm 配置已添加到 $shell_rc"
else
    print_warning "nvm 配置可能未正确添加到 $shell_rc"
    print_info "请确保 $shell_rc 包含 NVM 配置"
fi

echo ""
print_info "现在请重新加载 Shell 或重启终端："
print_info "   exec zsh"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

