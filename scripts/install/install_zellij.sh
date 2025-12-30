#!/bin/bash

# zellij 安装脚本
# zellij 是一个终端多路复用器（类似 tmux）
# 用法: install_zellij.sh [--method cargo|binary] [--force]

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 打印带颜色的消息
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

# 检测架构
detect_arch() {
    ARCH=$(uname -m)
    case "$ARCH" in
        x86_64)
            ARCH="x86_64"
            ;;
        aarch64|arm64)
            ARCH="aarch64"
            ;;
        *)
            print_warning "未识别的架构: $ARCH，默认使用 x86_64"
            ARCH="x86_64"
            ;;
    esac
    echo "$ARCH"
}

# 检查命令是否存在
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# 检查是否已安装
check_installed() {
    if command_exists zellij; then
        print_success "zellij 已安装: $(zellij --version 2>/dev/null || echo '未知版本')"
        return 0
    fi
    return 1
}

# 使用 cargo 安装
install_with_cargo() {
    if ! command_exists cargo; then
        print_error "未找到 cargo，请先安装 Rust"
        return 1
    fi

    # 检查是否已安装
    local was_installed=false
    if command_exists zellij; then
        was_installed=true
        print_info "检测到已安装的版本: $(zellij --version 2>/dev/null || echo '未知')"
    fi

    print_info "正在使用 cargo 安装 zellij（这可能需要几分钟）..."
    cargo install zellij

    if [ $? -eq 0 ]; then
        print_success "zellij 安装成功！"
        return 0
    else
        if [ "$was_installed" = "true" ]; then
            print_warning "重新安装失败，但之前的版本仍然可用"
            print_info "当前版本: $(zellij --version 2>/dev/null || echo '未知')"
            print_info "如果编译失败（如 SIGKILL），可能是内存不足或系统资源限制"
            print_info "可以尝试使用二进制文件安装: install:zellij --method binary"
            return 0  # 返回成功，因为旧版本仍然可用
        else
            print_error "cargo 安装失败"
            print_info "可以尝试使用二进制文件安装: install:zellij --method binary"
            return 1
        fi
    fi
}

# 使用二进制文件安装
install_with_binary() {
    ARCH=$(detect_arch)
    VERSION=$(curl -s https://api.github.com/repos/zellij-org/zellij/releases/latest | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/' || echo "v0.40.0")
    VERSION_NUM=${VERSION#v}
    
    DOWNLOAD_URL="https://github.com/zellij-org/zellij/releases/download/${VERSION}/zellij-${ARCH}-unknown-linux-musl.tar.gz"
    TEMP_DIR="/tmp/zellij-install"
    BIN_DIR="$HOME/.local/bin"

    print_info "检测到架构: $ARCH"
    print_info "最新版本: $VERSION"
    print_info "下载 URL: $DOWNLOAD_URL"

    # 创建临时目录
    mkdir -p "$TEMP_DIR"
    mkdir -p "$BIN_DIR"

    # 下载
    print_info "正在下载 zellij..."
    if command_exists curl; then
        curl -L "$DOWNLOAD_URL" -o "$TEMP_DIR/zellij.tar.gz"
    elif command_exists wget; then
        wget "$DOWNLOAD_URL" -O "$TEMP_DIR/zellij.tar.gz"
    else
        print_error "需要 curl 或 wget 来下载文件"
        return 1
    fi

    if [ ! -f "$TEMP_DIR/zellij.tar.gz" ]; then
        print_error "下载失败"
        return 1
    fi

    # 解压
    print_info "正在解压..."
    cd "$TEMP_DIR"
    tar -xzf zellij.tar.gz

    # 安装
    if [ -f "$TEMP_DIR/zellij" ]; then
        cp "$TEMP_DIR/zellij" "$BIN_DIR/zellij"
        chmod +x "$BIN_DIR/zellij"
        print_success "zellij 已安装到: $BIN_DIR/zellij"
        
        # 检查 PATH
        if [[ ":$PATH:" != *":$BIN_DIR:"* ]]; then
            print_warning "$BIN_DIR 不在 PATH 中"
            print_info "请将以下内容添加到 ~/.zshrc 或 ~/.bashrc:"
            echo "  export PATH=\"\$HOME/.local/bin:\$PATH\""
        fi
        
        # 清理
        rm -rf "$TEMP_DIR"
        return 0
    else
        print_error "解压后未找到 zellij 二进制文件"
        return 1
    fi
}

# 主函数
main() {
    INSTALL_METHOD="auto"
    FORCE=false

    # 解析参数
    while [[ $# -gt 0 ]]; do
        case $1 in
            --method)
                INSTALL_METHOD="$2"
                shift 2
                ;;
            --force)
                FORCE=true
                shift
                ;;
            *)
                print_error "未知参数: $1"
                echo "用法: $0 [--method cargo|binary] [--force]"
                exit 1
                ;;
        esac
    done

    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}正在安装 zellij...${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""

    # 检查是否已安装
    if check_installed && [ "$FORCE" != "true" ]; then
        read -p "zellij 已安装，是否重新安装？(y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            print_info "已取消安装"
            exit 0
        fi
    fi

    # 选择安装方法
    if [ "$INSTALL_METHOD" = "auto" ]; then
        if command_exists cargo; then
            INSTALL_METHOD="cargo"
        else
            INSTALL_METHOD="binary"
        fi
    fi

    case "$INSTALL_METHOD" in
        cargo)
            install_with_cargo
            ;;
        binary)
            install_with_binary
            ;;
        *)
            print_error "未知的安装方法: $INSTALL_METHOD"
            exit 1
            ;;
    esac

    if [ $? -eq 0 ]; then
        echo ""
        echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "${GREEN}✅ zellij 安装完成！${NC}"
        echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo ""
        echo -e "${YELLOW}📋 使用说明：${NC}"
        echo ""
        echo "启动 zellij:"
        echo "  zellij"
        echo ""
        echo "查看帮助:"
        echo "  zellij --help"
        echo ""
        echo "快捷键（默认）:"
        echo "  Ctrl+g  - 进入命令模式"
        echo "  Ctrl+o  - 切换窗格"
        echo "  Alt+n    - 新建标签页"
        echo ""
        echo -e "${YELLOW}💡 提示：${NC}"
        echo "  如果命令未找到，请确保 ~/.local/bin 或 ~/.cargo/bin 在 PATH 中"
        echo "  重新加载 shell 配置: source ~/.zshrc"
        echo ""
    else
        print_error "安装失败"
        exit 1
    fi
}

main "$@"

