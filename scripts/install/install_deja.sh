#!/bin/bash

# deja 安装脚本
# deja 是一个 zsh 预测性自动补全工具
# 用法: install_deja.sh [--force]

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

# 检测架构 (转换为 release 文件名格式)
detect_arch() {
    ARCH=$(uname -m)
    case "$ARCH" in
        x86_64)
            ARCH="amd64"
            ;;
        aarch64|arm64)
            ARCH="arm64"
            ;;
        *)
            print_warning "未识别的架构: $ARCH，默认使用 amd64"
            ARCH="amd64"
            ;;
    esac
    echo "$ARCH"
}

# 检测操作系统
detect_os() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        echo "linux"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        echo "darwin"
    else
        echo "unknown"
    fi
}

# 检查命令是否存在
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# 检查是否已安装
check_installed() {
    if command_exists deja; then
        print_success "deja 已安装: $(deja --version 2>/dev/null || echo '未知版本')"
        return 0
    fi
    return 1
}

# 安装 deja
install_deja() {
    local OS=$(detect_os)
    local ARCH=$(detect_arch)
    local BIN_DIR="$HOME/.local/bin"
    
    if [[ "$OS" == "unknown" ]]; then
        print_error "不支持的操作系统"
        return 1
    fi
    
    # 获取最新版本
    print_info "正在获取最新版本信息..."
    local VERSION=$(curl -s https://api.github.com/repos/Giammarco-Ferranti/deja/releases/latest | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/' 2>/dev/null || echo "")
    
    if [[ -z "$VERSION" ]]; then
        print_warning "无法获取最新版本，使用默认版本 v0.2.6"
        VERSION="v0.2.6"
    fi
    
    # 构建下载 URL
    local FILENAME="deja_${VERSION#v}_${OS}_${ARCH}.tar.gz"
    local DOWNLOAD_URL="https://github.com/Giammarco-Ferranti/deja/releases/download/${VERSION}/${FILENAME}"
    local TEMP_DIR="/tmp/deja-install"
    
    print_info "检测到系统: $OS, 架构: $ARCH"
    print_info "版本: $VERSION"
    print_info "下载 URL: $DOWNLOAD_URL"
    
    # 创建临时目录
    mkdir -p "$TEMP_DIR"
    mkdir -p "$BIN_DIR"
    
    # 下载
    print_info "正在下载 deja..."
    if command_exists curl; then
        if ! curl -L -f "$DOWNLOAD_URL" -o "$TEMP_DIR/deja.tar.gz" 2>/dev/null; then
            print_error "下载失败"
            return 1
        fi
    elif command_exists wget; then
        if ! wget --timeout=30 "$DOWNLOAD_URL" -O "$TEMP_DIR/deja.tar.gz" 2>/dev/null; then
            print_error "下载失败"
            return 1
        fi
    else
        print_error "需要 curl 或 wget 来下载文件"
        return 1
    fi
    
    if [[ ! -f "$TEMP_DIR/deja.tar.gz" ]]; then
        print_error "下载失败"
        return 1
    fi
    
    # 解压
    print_info "正在解压..."
    cd "$TEMP_DIR"
    if ! tar -xzf deja.tar.gz 2>/dev/null; then
        print_error "解压失败"
        return 1
    fi
    
    # 安装
    if [[ -f "$TEMP_DIR/deja" ]]; then
        cp "$TEMP_DIR/deja" "$BIN_DIR/deja"
        chmod +x "$BIN_DIR/deja"
        print_success "deja 已安装到: $BIN_DIR/deja"
        
        # 检查 PATH
        if [[ ":$PATH:" != *":$BIN_DIR:"* ]]; then
            print_warning "$BIN_DIR 不在 PATH 中"
            print_info "请将以下内容添加到 ~/.zshrc:"
            echo "  export PATH=\"\$HOME/.local/bin:\$PATH\""
        fi
        
        # 清理
        rm -rf "$TEMP_DIR"
        return 0
    else
        print_error "解压后未找到 deja 二进制文件"
        return 1
    fi
}

# 导入历史记录
import_history() {
    if command_exists deja; then
        print_info "正在导入 zsh 历史记录..."
        if deja import 2>/dev/null; then
            print_success "历史记录导入完成"
        else
            print_warning "历史记录导入失败（可能历史文件为空），将在使用时自动学习"
        fi
    fi
}

# 主函数
main() {
    local FORCE=false
    
    # 解析参数
    while [[ $# -gt 0 ]]; do
        case $1 in
            --force)
                FORCE=true
                shift
                ;;
            *)
                print_error "未知参数: $1"
                echo "用法: $0 [--force]"
                exit 1
                ;;
        esac
    done
    
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}正在安装 deja...${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    
    # 检查是否已安装
    if check_installed && [[ "$FORCE" != "true" ]]; then
        print_info "deja 已安装，跳过安装步骤"
        import_history
        exit 0
    fi
    
    # 执行安装
    if install_deja; then
        # 导入历史记录
        import_history
        
        echo ""
        echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "${GREEN}✅ deja 安装完成！${NC}"
        echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo ""
        echo -e "${YELLOW}📋 重要提示：${NC}"
        echo ""
        echo "1. 确保以下命令已添加到你的 ~/.zshrc 中："
        echo "   eval \"\$(deja init zsh)\""
        echo ""
        echo "2. 重新加载 zsh："
        echo "   exec zsh"
        echo ""
        echo -e "${YELLOW}🎮 快捷键：${NC}"
        echo "   → (右箭头)     - 接受完整建议"
        echo "   Ctrl+→         - 接受下一个词"
        echo "   Tab            - 打开备选建议选择器"
        echo "   Ctrl+X         - 临时禁用建议"
        echo ""
        echo -e "${YELLOW}💡 提示：${NC}"
        echo "   - deja 会在首次使用时自动启动后台守护进程"
        echo "   - 所有数据存储在本地 ~/.local/share/deja/ 中"
        echo "   - 如果不使用 zsh-autosuggestions，deja 会自动接管"
        echo ""
        exit 0
    else
        print_error "安装失败"
        exit 1
    fi
}

main "$@"
