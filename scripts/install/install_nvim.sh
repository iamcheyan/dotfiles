#!/bin/bash
# Neovim 安装脚本
# 从 GitHub Releases 安装最新版本的 Neovim
# 用法: install_nvim.sh [--force] [--version VERSION]

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

# 检测操作系统和架构
detect_system() {
    local os=""
    local arch=""
    
    # 检测操作系统
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        os="linux"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        os="macos"
    else
        print_error "不支持的操作系统: $OSTYPE"
        return 1
    fi
    
    # 检测架构
    local machine=$(uname -m)
    case "$machine" in
        x86_64|amd64)
            arch="x86_64"
            ;;
        aarch64|arm64)
            arch="aarch64"
            ;;
        armv7l|armv6l)
            arch="armv7l"
            ;;
        *)
            print_error "不支持的架构: $machine"
            return 1
            ;;
    esac
    
    export NVIM_OS="$os"
    export NVIM_ARCH="$arch"
    print_info "检测到系统: $os ($arch)"
    return 0
}

# 获取最新版本号（用于显示和检查）
get_latest_version() {
    local version=""
    
    if command -v curl >/dev/null 2>&1; then
        version=$(curl -s https://api.github.com/repos/neovim/neovim/releases/latest | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/' | sed 's/^v//')
    elif command -v wget >/dev/null 2>&1; then
        version=$(wget -qO- https://api.github.com/repos/neovim/neovim/releases/latest | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/' | sed 's/^v//')
    else
        print_error "需要 curl 或 wget 来获取版本信息"
        return 1
    fi
    
    if [[ -z "$version" ]]; then
        print_error "无法获取最新版本号"
        return 1
    fi
    
    echo "$version"
}

# 下载并安装 Neovim (Linux)
install_nvim_linux() {
    local version="$1"
    local arch="$2"
    local install_dir="$HOME/.local/nvim"
    local download_url=""
    local filename=""
    
    # 构建下载 URL 和文件名
    if [[ "$arch" == "x86_64" ]]; then
        filename="nvim-linux-x86_64.tar.gz"
        if [[ -z "$version" ]]; then
            download_url="https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz"
        else
            download_url="https://github.com/neovim/neovim/releases/download/v${version}/nvim-linux-x86_64.tar.gz"
        fi
    elif [[ "$arch" == "aarch64" ]]; then
        filename="nvim-linux-arm64.tar.gz"
        if [[ -z "$version" ]]; then
            download_url="https://github.com/neovim/neovim/releases/latest/download/nvim-linux-arm64.tar.gz"
        else
            download_url="https://github.com/neovim/neovim/releases/download/v${version}/nvim-linux-arm64.tar.gz"
        fi
    else
        print_error "Linux 架构 $arch 不支持，请使用包管理器安装"
        return 1
    fi
    
    local tmp_file="/tmp/$filename"
    
    # Step 1: 下载
    if [[ -n "$version" ]]; then
        print_info "正在下载 Neovim ${version}..."
    else
        print_info "正在下载 Neovim 最新版本..."
    fi
    
    if [[ -f "$tmp_file" ]] && [[ "$force" != "true" ]]; then
        print_info "临时文件已存在: $tmp_file"
    else
        if command -v curl >/dev/null 2>&1; then
            curl -L -o "$tmp_file" "$download_url" || {
                print_error "下载失败"
                return 1
            }
        elif command -v wget >/dev/null 2>&1; then
            wget -q --show-progress -O "$tmp_file" "$download_url" || {
                print_error "下载失败"
                return 1
            }
        else
            print_error "需要 curl 或 wget 来下载"
            return 1
        fi
        print_success "下载完成: $tmp_file"
    fi
    
    # Step 2: 验证文件类型
    print_info "验证文件类型..."
    local file_type=$(file "$tmp_file" 2>/dev/null | grep -o "gzip compressed data" || echo "")
    if [[ -z "$file_type" ]]; then
        print_error "文件类型不正确，不是 gzip 压缩文件"
        print_info "文件信息: $(file "$tmp_file" 2>/dev/null || echo '无法读取')"
        return 1
    fi
    print_success "文件类型验证通过"
    
    # Step 3: 安装到 ~/.local/nvim
    print_info "正在安装到 $install_dir..."
    rm -rf "$install_dir"
    mkdir -p "$install_dir"
    
    tar xf "$tmp_file" -C "$install_dir" --strip-components=1 || {
        print_error "解压失败"
        return 1
    }
    
    # 验证安装
    if [[ ! -f "$install_dir/bin/nvim" ]]; then
        print_error "二进制文件不存在: $install_dir/bin/nvim"
        return 1
    fi
    
    if [[ ! -d "$install_dir/share/nvim/runtime" ]]; then
        print_error "运行时文件目录不存在: $install_dir/share/nvim/runtime"
        return 1
    fi
    
    chmod +x "$install_dir/bin/nvim"
    print_success "Neovim 已安装到 $install_dir"
    
    # Step 4: 验证安装
    print_info "验证安装..."
    local vimruntime=$("$install_dir/bin/nvim" --clean +'lua print(vim.env.VIMRUNTIME)' +q 2>/dev/null | grep -v "^$" | tail -1)
    if [[ "$vimruntime" == "$install_dir/share/nvim/runtime" ]]; then
        print_success "安装验证通过: VIMRUNTIME=$vimruntime"
    else
        print_warning "VIMRUNTIME 验证异常: $vimruntime (期望: $install_dir/share/nvim/runtime)"
    fi
    
    # 添加到 PATH（提示）
    local nvim_bin="$install_dir/bin"
    if [[ ":$PATH:" != *":$nvim_bin:"* ]]; then
        print_warning "请将 $nvim_bin 添加到 PATH"
        print_info "可以添加到 ~/.zshrc 或 ~/.bashrc:"
        print_info "  export PATH=\"\$HOME/.local/nvim/bin:\$PATH\""
    else
        print_success "PATH 已包含 $nvim_bin"
    fi
}

# 下载并安装 Neovim (macOS)
install_nvim_macos() {
    local version="$1"
    local arch="$2"
    local install_dir="$HOME/.local/bin"
    local cache_dir="$HOME/.cache/nvim"
    local download_url=""
    local filename=""
    
    # 构建下载 URL（使用官方推荐的格式）
    if [[ "$arch" == "aarch64" ]] || [[ "$arch" == "arm64" ]]; then
        filename="nvim-macos-arm64.tar.gz"
        # 如果版本为空，使用 /latest/download/，否则使用指定版本
        if [[ -z "$version" ]]; then
            download_url="https://github.com/neovim/neovim/releases/latest/download/nvim-macos-arm64.tar.gz"
        else
            download_url="https://github.com/neovim/neovim/releases/download/v${version}/nvim-macos-arm64.tar.gz"
        fi
    elif [[ "$arch" == "x86_64" ]]; then
        filename="nvim-macos-x86_64.tar.gz"
        # 如果版本为空，使用 /latest/download/，否则使用指定版本
        if [[ -z "$version" ]]; then
            download_url="https://github.com/neovim/neovim/releases/latest/download/nvim-macos-x86_64.tar.gz"
        else
            download_url="https://github.com/neovim/neovim/releases/download/v${version}/nvim-macos-x86_64.tar.gz"
        fi
    else
        print_error "macOS 架构 $arch 不支持"
        return 1
    fi
    
    local cache_file="$cache_dir/$filename"
    mkdir -p "$cache_dir" "$install_dir"
    
    # 下载
    if [[ -n "$version" ]]; then
        print_info "正在下载 Neovim ${version}..."
    else
        print_info "正在下载 Neovim 最新版本..."
    fi
    if [[ -f "$cache_file" ]]; then
        print_info "缓存文件已存在，跳过下载"
    else
        if command -v curl >/dev/null 2>&1; then
            curl -L -o "$cache_file" "$download_url" || {
                print_error "下载失败"
                return 1
            }
        else
            print_error "需要 curl 来下载"
            return 1
        fi
        print_success "下载完成"
    fi
    
    # 解压
    print_info "正在解压..."
    local extract_dir="$cache_dir/nvim-${version:-latest}"
    rm -rf "$extract_dir"
    mkdir -p "$extract_dir"
    tar -xzf "$cache_file" -C "$extract_dir" --strip-components=1 || {
        print_error "解压失败"
        return 1
    }
    
    # 安装
    print_info "正在安装到 $install_dir..."
    if [[ -d "$extract_dir/bin" ]]; then
        # 复制 nvim 二进制文件
        cp -f "$extract_dir/bin/nvim" "$install_dir/nvim" || {
            print_error "安装失败"
            return 1
        }
        chmod +x "$install_dir/nvim"
        
        # 安装运行时文件到 ~/.local/share/nvim（Neovim 会在这里查找）
        local runtime_dir="$HOME/.local/share/nvim"
        if [[ -d "$extract_dir/share/nvim" ]]; then
            print_info "正在安装运行时文件到 $runtime_dir..."
            mkdir -p "$runtime_dir"
            # 复制所有运行时文件（包括 runtime 目录）
            if [[ -d "$extract_dir/share/nvim/runtime" ]]; then
                cp -rf "$extract_dir/share/nvim/runtime" "$runtime_dir/" || {
                    print_warning "复制运行时文件失败，但二进制文件已安装"
                }
            fi
            # 也复制其他可能的运行时文件（如 lua 模块）
            if [[ -d "$extract_dir/share/nvim" ]]; then
                # 复制所有非 runtime 的运行时文件
                for item in "$extract_dir/share/nvim"/*; do
                    if [[ -e "$item" ]] && [[ "$(basename "$item")" != "runtime" ]]; then
                        cp -rf "$item" "$runtime_dir/" 2>/dev/null || true
                    fi
                done
            fi
        fi
        
        print_success "Neovim 已安装到 $install_dir/nvim"
    else
        print_error "解压后的目录结构不正确"
        return 1
    fi
    
    # 清理
    rm -rf "$extract_dir"
    
    # 添加到 PATH（如果还没有）
    if [[ ":$PATH:" != *":$install_dir:"* ]]; then
        print_warning "请确保 $install_dir 在 PATH 中"
        print_info "可以添加到 ~/.zshrc:"
        print_info "  export PATH=\"\$HOME/.local/bin:\$PATH\""
    fi
}

# 检查是否已安装
check_installed() {
    local version="$1"
    
    if command -v nvim >/dev/null 2>&1; then
        local installed_version=$(nvim --version | head -n 1 | grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+' | sed 's/^v//')
        
        # 检查版本是否符合最低要求（0.9.0）
        if [[ -n "$installed_version" ]]; then
            local major=$(echo "$installed_version" | cut -d. -f1)
            local minor=$(echo "$installed_version" | cut -d. -f2)
            
            if [[ $major -lt 0 ]] || [[ $major -eq 0 && $minor -lt 9 ]]; then
                print_warning "检测到已安装版本: ${installed_version}"
                print_error "LazyVim 需要 Neovim 0.9.0 或更高版本！"
                print_info "当前版本太旧，建议升级到最新版本"
                return 1
            fi
        fi
        
        if [[ "$installed_version" == "$version" ]]; then
            print_success "Neovim ${version} 已安装"
            return 0
        else
            print_info "检测到已安装版本: ${installed_version}"
            if [[ -n "$version" ]]; then
                print_info "目标版本: ${version}"
            fi
            return 1
        fi
    else
        return 1
    fi
}

# 主函数
main() {
    local force_install=false
    local target_version=""
    
    # 解析参数
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --force|-f)
                force_install=true
                shift
                ;;
            --version|-v)
                target_version="$2"
                shift 2
                ;;
            *)
                print_error "未知参数: $1"
                echo "用法: $0 [--force] [--version VERSION]"
                exit 1
                ;;
        esac
    done
    
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  Neovim 安装脚本"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    print_info "注意: LazyVim 需要 Neovim 0.9.0 或更高版本"
    echo ""
    
    # 检测系统
    if ! detect_system; then
        exit 1
    fi
    
    # 获取版本（用于显示和检查，下载时使用 /latest/download/）
    if [[ -z "$target_version" ]]; then
        print_info "正在获取最新版本信息..."
        target_version=$(get_latest_version)
        if [[ -z "$target_version" ]]; then
            print_warning "无法获取版本号，将使用 /latest/download/ 下载"
            target_version="latest"
        else
            print_success "最新版本: ${target_version}"
        fi
    else
        print_info "目标版本: ${target_version}"
    fi
    
    # 检查是否已安装（只有在指定了具体版本时才检查）
    if [[ "$target_version" != "latest" ]]; then
        if ! $force_install && check_installed "$target_version"; then
            print_info "已是最新版本，无需安装"
            print_info "使用 --force 参数强制重新安装"
            exit 0
        fi
        
        # 询问确认（如果不是强制安装）
        if ! $force_install; then
            if check_installed "$target_version" 2>/dev/null; then
                read -p "是否要重新安装 Neovim ${target_version}? (y/N): " -n 1 -r
                echo
                if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                    print_info "已取消安装"
                    exit 0
                fi
            fi
        fi
    fi
    
    # 安装
    # 如果版本是 "latest"，传递空字符串给安装函数以使用 /latest/download/
    local install_version=""
    if [[ "$target_version" != "latest" ]]; then
        install_version="$target_version"
    fi
    
    print_info "开始安装 Neovim ${target_version}..."
    if [[ "$NVIM_OS" == "linux" ]]; then
        install_nvim_linux "$install_version" "$NVIM_ARCH"
    elif [[ "$NVIM_OS" == "macos" ]]; then
        install_nvim_macos "$install_version" "$NVIM_ARCH"
    else
        print_error "不支持的操作系统"
        exit 1
    fi
    
    if [[ $? -eq 0 ]]; then
        echo ""
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        if [[ "$target_version" == "latest" ]]; then
            print_success "Neovim 最新版本安装完成！"
        else
            print_success "Neovim ${target_version} 安装完成！"
        fi
        echo ""
        print_info "安装位置: ~/.local/nvim/"
        print_info "二进制文件: ~/.local/nvim/bin/nvim"
        print_info "运行时文件: ~/.local/nvim/share/nvim/runtime"
        echo ""
        print_info "验证安装:"
        print_info "  ~/.local/nvim/bin/nvim --version"
        print_info "  ~/.local/nvim/bin/nvim --clean +'lua print(vim.env.VIMRUNTIME)' +q"
        echo ""
        
        # 检查 PATH 和版本
        local nvim_bin="$HOME/.local/nvim/bin"
        if [[ ":$PATH:" == *":$nvim_bin:"* ]]; then
            local nvim_path=$(command -v nvim 2>/dev/null || echo "")
            if [[ -n "$nvim_path" ]] && [[ "$nvim_path" == "$nvim_bin/nvim" ]]; then
                print_success "PATH 已配置，可直接使用 nvim 命令"
                local installed_version=$("$nvim_path" --version 2>/dev/null | head -n 1 | grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+' | sed 's/^v//' || echo "")
                if [[ -n "$installed_version" ]]; then
                    local major=$(echo "$installed_version" | cut -d. -f1)
                    local minor=$(echo "$installed_version" | cut -d. -f2)
                    if [[ $major -lt 0 ]] || [[ $major -eq 0 && $minor -lt 9 ]]; then
                        print_warning "检测到旧版本: ${installed_version}"
                        print_error "LazyVim 需要 Neovim 0.9.0 或更高版本！"
                    else
                        print_success "版本检查通过: ${installed_version}"
                    fi
                fi
            fi
        else
            print_warning "请将 $nvim_bin 添加到 PATH"
            print_info "添加到 ~/.zshrc:"
            print_info "  export PATH=\"\$HOME/.local/nvim/bin:\$PATH\""
            print_info "然后重新加载: source ~/.zshrc"
        fi
        echo ""
        print_info "启动 Neovim:"
        if [[ ":$PATH:" == *":$nvim_bin:"* ]]; then
            print_info "  nvim  # PATH 已配置，可直接使用"
        else
            print_info "  ~/.local/nvim/bin/nvim  # 或添加到 PATH 后使用 nvim"
        fi
        echo ""
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    else
        print_error "安装失败"
        exit 1
    fi
}

# 运行主函数
main "$@"

