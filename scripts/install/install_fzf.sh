#!/bin/bash
# fzf (Fuzzy Finder) 安装脚本
# 从 GitHub 仓库安装最新版本的 fzf
# 用法: install_fzf.sh [--force] [--all|--bin|--key-bindings|--completion]

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

# fzf 安装目录
FZF_DIR="$HOME/.fzf"
FZF_REPO="https://github.com/junegunn/fzf.git"

# 解析参数
FORCE_INSTALL=false
INSTALL_OPTIONS="--bin"  # 默认只安装二进制文件

while [[ $# -gt 0 ]]; do
    case "$1" in
        --force|-f)
            FORCE_INSTALL=true
            shift
            ;;
        --all)
            INSTALL_OPTIONS="--all"
            shift
            ;;
        --bin)
            INSTALL_OPTIONS="--bin"
            shift
            ;;
        --key-bindings)
            INSTALL_OPTIONS="--key-bindings"
            shift
            ;;
        --completion)
            INSTALL_OPTIONS="--completion"
            shift
            ;;
        *)
            print_error "未知参数: $1"
            echo "用法: $0 [--force] [--all|--bin|--key-bindings|--completion]"
            exit 1
            ;;
    esac
done

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  fzf (Fuzzy Finder) 安装脚本"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# 检查是否已安装
check_fzf_installed() {
    if [ -d "$FZF_DIR" ] && [ -f "$FZF_DIR/install" ]; then
        return 0
    fi
    return 1
}

# 检查 fzf 是否在 PATH 中
check_fzf_in_path() {
    if command -v fzf >/dev/null 2>&1; then
        return 0
    fi
    # 检查 ~/.fzf/bin 是否在 PATH 中
    if [[ ":$PATH:" == *":$HOME/.fzf/bin:"* ]]; then
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
            echo "$HOME/.bashrc"
            ;;
    esac
}

# 检查依赖
check_dependencies() {
    print_info "检查依赖..."
    if ! command -v git >/dev/null 2>&1; then
        print_error "需要 git 来克隆 fzf 仓库"
        print_info "请先安装 git:"
        print_info "  Ubuntu/Debian: sudo apt-get install git"
        exit 1
    fi
    print_success "依赖检查通过"
}

# 检查是否已安装
if check_fzf_installed; then
    if [ "$FORCE_INSTALL" = true ]; then
        print_warning "检测到 fzf 已安装，使用 --force 参数将删除并重新安装"
        read -p "确定要删除现有 fzf 并重新安装吗？(y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            print_info "正在删除现有 fzf..."
            rm -rf "$FZF_DIR"
            # 从 shell 配置文件中移除 fzf 配置（如果存在）
            local shell_rc=$(get_shell_rc)
            if [ -f "$shell_rc" ]; then
                # 移除 fzf 相关配置
                if grep -q "fzf" "$shell_rc" 2>/dev/null; then
                    print_info "正在从 $shell_rc 移除 fzf 配置..."
                    # 备份原文件
                    cp "$shell_rc" "${shell_rc}.bak.$(date +%Y%m%d_%H%M%S)"
                    # 移除包含 ~/.fzf 的行
                    sed -i '/\.fzf/d' "$shell_rc" 2>/dev/null || true
                fi
            fi
        else
            print_info "已取消操作"
            exit 0
        fi
    else
        print_success "fzf 已安装: $FZF_DIR"
        if check_fzf_in_path; then
            local fzf_version=""
            if [ -f "$FZF_DIR/bin/fzf" ]; then
                fzf_version=$("$FZF_DIR/bin/fzf" --version 2>/dev/null || echo "未知版本")
            fi
            print_success "fzf 已在 PATH 中"
            if [ -n "$fzf_version" ]; then
                print_info "当前版本: $fzf_version"
            fi
            print_info "当前 shell: $(detect_shell)"
            print_info "如果要重新安装，请使用: install:fzf --force"
            print_info ""
            print_info "安装选项说明："
            print_info "  --bin          : 只安装二进制文件（默认）"
            print_info "  --all          : 安装所有组件（二进制、键绑定、补全）"
            print_info "  --key-bindings : 只安装键绑定"
            print_info "  --completion   : 只安装补全文件"
        else
            print_warning "fzf 未在 PATH 中"
            local shell_rc=$(get_shell_rc)
            print_info "请确保 $shell_rc 包含以下内容："
            print_info "  [ -f ~/.fzf.zsh ] && source ~/.fzf.zsh"
            print_info "或者运行: source $shell_rc"
        fi
        exit 0
    fi
fi

# 检查依赖
check_dependencies

# 克隆 fzf 仓库
print_info "正在从 GitHub 克隆 fzf 仓库..."
print_info "仓库: $FZF_REPO"
print_info "安装目录: $FZF_DIR"
echo ""

if [ -d "$FZF_DIR" ]; then
    print_warning "目录 $FZF_DIR 已存在，正在更新..."
    cd "$FZF_DIR"
    git pull origin master || {
        print_error "更新失败"
        exit 1
    }
    print_success "更新完成"
else
    if git clone --depth 1 "$FZF_REPO" "$FZF_DIR"; then
        print_success "克隆完成"
    else
        print_error "克隆失败"
        exit 1
    fi
fi

# 运行安装脚本
print_info "正在运行 fzf 安装脚本..."
print_info "安装选项: $INSTALL_OPTIONS"
echo ""

cd "$FZF_DIR"
if bash install "$INSTALL_OPTIONS"; then
    print_success "fzf 安装完成"
else
    print_error "fzf 安装失败"
    exit 1
fi

# 验证安装
if check_fzf_installed; then
    print_success "fzf 已安装到: $FZF_DIR"
    
    # 检查二进制文件
    if [ -f "$FZF_DIR/bin/fzf" ]; then
        print_success "二进制文件已安装: $FZF_DIR/bin/fzf"
        local fzf_version=$("$FZF_DIR/bin/fzf" --version 2>/dev/null || echo "未知版本")
        print_info "版本: $fzf_version"
    else
        print_warning "二进制文件未找到，可能需要编译"
        if command -v make >/dev/null 2>&1 && command -v go >/dev/null 2>&1; then
            print_info "检测到 Go 和 make，正在编译..."
            cd "$FZF_DIR"
            make install || {
                print_warning "编译失败，但其他组件可能已安装"
            }
        else
            print_warning "需要 Go 和 make 来编译二进制文件"
        fi
    fi
else
    print_error "fzf 安装验证失败"
    exit 1
fi

# 检查 shell 配置文件
shell_rc=$(get_shell_rc)
shell_type=$(detect_shell)

# 检查是否已配置到 shell 配置文件
if [ -f "$shell_rc" ] && grep -q "fzf" "$shell_rc" 2>/dev/null; then
    print_success "fzf 配置已添加到 $shell_rc"
else
    print_warning "fzf 配置可能未正确添加到 $shell_rc"
    if [ "$INSTALL_OPTIONS" != "--bin" ]; then
        print_info "安装脚本应该已经添加了配置，但请检查 $shell_rc 是否包含："
        if [ "$shell_type" = "zsh" ]; then
            print_info "  [ -f ~/.fzf.zsh ] && source ~/.fzf.zsh"
        elif [ "$shell_type" = "bash" ]; then
            print_info "  [ -f ~/.fzf.bash ] && source ~/.fzf.bash"
        fi
    fi
fi

# 检查 PATH
if [[ ":$PATH:" != *":$HOME/.fzf/bin:"* ]]; then
    print_warning "$HOME/.fzf/bin 不在 PATH 中"
    print_info "如果 fzf 命令未找到，请将以下内容添加到 $shell_rc:"
    print_info "  export PATH=\"\$HOME/.fzf/bin:\$PATH\""
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
print_success "fzf 安装完成！"
echo ""
print_info "安装位置: $FZF_DIR"
print_info "二进制文件: $FZF_DIR/bin/fzf"
if command -v fzf >/dev/null 2>&1; then
    print_info "fzf 版本: $(fzf --version 2>/dev/null || echo '未加载')"
else
    print_info "fzf 版本: $(test -f $FZF_DIR/bin/fzf && $FZF_DIR/bin/fzf --version 2>/dev/null || echo '未加载')"
fi
echo ""
print_info "现在请重新加载 Shell 或重启终端："
print_info "   exec zsh"
echo ""
print_info "使用说明："
print_info "  查看帮助: fzf --help"
print_info "  交互式文件搜索: fzf"
print_info "  结合其他命令使用: ls | fzf"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

