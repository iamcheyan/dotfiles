#!/bin/bash
# tree-sitter-cli 安装脚本
# 使用 Rust cargo 安装 tree-sitter-cli，解决 GLIBC 版本问题
# 用法: install_treesitter.sh [--force]

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

# 解析参数
FORCE_INSTALL=false
while [[ $# -gt 0 ]]; do
    case "$1" in
        --force|-f)
            FORCE_INSTALL=true
            shift
            ;;
        *)
            print_error "未知参数: $1"
            echo "用法: $0 [--force]"
            exit 1
            ;;
    esac
done

# 检测操作系统
detect_os() {
    if [[ "$OSTYPE" != "linux-gnu"* ]]; then
        print_error "此脚本仅支持 Linux 系统"
        exit 1
    fi
    print_info "检测到系统: Linux"
}

# 检测架构
detect_arch() {
    local machine=$(uname -m)
    case "$machine" in
        x86_64|amd64)
            echo "x86_64"
            ;;
        aarch64|arm64)
            echo "aarch64"
            ;;
        *)
            print_error "不支持的架构: $machine"
            print_info "支持的架构: x86_64, aarch64"
            exit 1
            ;;
    esac
}

# 检查 tree-sitter 是否已安装
check_treesitter_installed() {
    if command -v tree-sitter >/dev/null 2>&1; then
        local treesitter_path=$(command -v tree-sitter)
        # 检查是否是 cargo 安装的版本
        if [[ "$treesitter_path" == "$HOME/.cargo/bin/tree-sitter" ]]; then
            return 0
        fi
    fi
    return 1
}

# 检查 Rust 是否已安装
check_rust_installed() {
    if command -v rustc >/dev/null 2>&1 && command -v cargo >/dev/null 2>&1; then
        return 0
    fi
    return 1
}

# 安装 Rust
install_rust() {
    print_info "正在安装 Rust..."
    if curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y; then
        print_success "Rust 安装完成"
        # 加载 Rust 环境
        if [[ -s "$HOME/.cargo/env" ]]; then
            source "$HOME/.cargo/env"
        fi
        return 0
    else
        print_error "Rust 安装失败"
        return 1
    fi
}

# 检查并安装 clang
check_and_install_clang() {
    if command -v clang >/dev/null 2>&1 && command -v clang++ >/dev/null 2>&1; then
        print_success "clang 已安装"
        return 0
    fi
    
    print_info "正在安装 clang 和 libclang-dev..."
    if command -v apt-get >/dev/null 2>&1; then
        if sudo apt-get install -y clang libclang-dev; then
            print_success "clang 安装完成"
            return 0
        else
            print_error "clang 安装失败"
            return 1
        fi
    else
        print_error "未找到 apt-get，请手动安装 clang 和 libclang-dev"
        return 1
    fi
}

# 删除 npm 版本的 tree-sitter
remove_npm_treesitter() {
    local npm_treesitter="$HOME/.npm-global/bin/tree-sitter"
    if [[ -f "$npm_treesitter" ]] || [[ -L "$npm_treesitter" ]]; then
        print_info "检测到 npm 版本的 tree-sitter，正在删除..."
        if rm -f "$npm_treesitter"; then
            print_success "已删除 npm 版本的 tree-sitter"
        else
            print_warning "删除 npm 版本的 tree-sitter 失败"
        fi
    fi
}

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  tree-sitter-cli 安装脚本"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# 检测系统
detect_os
arch=$(detect_arch)
print_info "检测到架构: $arch"

# 检查是否已安装
if check_treesitter_installed; then
    if [ "$FORCE_INSTALL" = true ]; then
        print_warning "检测到 tree-sitter 已安装，使用 --force 参数将重新安装"
        read -p "确定要重新安装吗？(y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            print_info "已取消操作"
            exit 0
        fi
    else
        local treesitter_path=$(command -v tree-sitter)
        print_success "tree-sitter 已安装: $treesitter_path"
        print_info "如果要重新安装，请使用: install:treesitter --force"
        exit 0
    fi
fi

# 检查并安装 Rust
if ! check_rust_installed; then
    print_info "Rust 未安装，正在安装..."
    if ! install_rust; then
        print_error "Rust 安装失败，无法继续"
        exit 1
    fi
    # 确保 cargo 在 PATH 中
    if [[ -s "$HOME/.cargo/env" ]]; then
        source "$HOME/.cargo/env"
    fi
else
    print_success "Rust 已安装"
    local rust_version=$(rustc --version 2>/dev/null || echo "unknown")
    print_info "Rust 版本: $rust_version"
fi

# 检查并安装 clang
if ! check_and_install_clang; then
    print_error "clang 安装失败，无法继续"
    exit 1
fi

# 删除 npm 版本的 tree-sitter（如果存在）
remove_npm_treesitter

# 安装 tree-sitter-cli
print_info "正在使用 cargo 安装 tree-sitter-cli..."
print_info "这可能需要几分钟时间，请耐心等待..."
echo ""

if cargo install tree-sitter-cli; then
    print_success "tree-sitter-cli 安装完成"
else
    print_error "tree-sitter-cli 安装失败"
    exit 1
fi

# 确保 cargo bin 在 PATH 中
if [[ -s "$HOME/.cargo/env" ]]; then
    source "$HOME/.cargo/env"
fi

# 验证安装
echo ""
print_info "验证安装..."
if check_treesitter_installed; then
    local treesitter_path=$(command -v tree-sitter)
    print_success "tree-sitter 已安装到: $treesitter_path"
    
    # 检查版本
    if tree-sitter --version >/dev/null 2>&1; then
        local version=$(tree-sitter --version 2>/dev/null | head -n 1 || echo "unknown")
        print_success "版本: $version"
    else
        print_warning "无法获取版本信息"
    fi
else
    print_error "安装验证失败"
    print_info "请检查 PATH 是否包含 ~/.cargo/bin"
    exit 1
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
print_success "tree-sitter-cli 安装完成！"
echo ""
print_info "安装位置: ~/.cargo/bin/tree-sitter"
print_info "架构: $arch"
echo ""
print_info "下一步操作："
echo ""
print_info "1. 重新加载 shell 配置（如果还未加载）:"
print_info "   source ~/.zshrc"
echo ""
print_info "2. 验证安装:"
print_info "   which tree-sitter  # 应该显示 ~/.cargo/bin/tree-sitter"
print_info "   tree-sitter --version"
echo ""
print_info "3. 在 Neovim 中验证:"
print_info "   :checkhealth nvim-treesitter"
print_info "   应该看到 'tree-sitter (CLI)' 显示为 ✓"
echo ""
print_info "4. 安装解析器（如果需要）:"
print_info "   :TSInstall <language>"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

