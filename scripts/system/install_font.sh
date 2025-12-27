#!/bin/bash
# 字体安装脚本
# 支持 Meslo 字体和 Noto Serif 字体安装
# 用法: install_font.sh [--meslo] [--noto] [--all] [--force]

# Meslo 字体下载链接
MESLO_URL="https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/Meslo.tar.xz"
MESLO_TAR="$HOME/.cache/fonts/Meslo.tar.xz"
MESLO_VERSION="v3.4.0"

# 下载 Meslo 字体的函数
download_meslo_font() {
    local cache_dir=$(dirname "$MESLO_TAR")
    
    # 创建缓存目录
    mkdir -p "$cache_dir"
    
    # 检查文件是否已存在
    if [ -f "$MESLO_TAR" ]; then
        echo "Meslo 字体文件已存在，跳过下载"
        return 0
    fi
    
    echo "正在从 GitHub 下载 Meslo 字体 ($MESLO_VERSION)..."
    
    # 使用 wget 或 curl 下载
    if command -v wget >/dev/null 2>&1; then
        if wget -q --show-progress -O "$MESLO_TAR" "$MESLO_URL"; then
            echo "✓ Meslo 字体下载完成"
            return 0
        else
            echo "错误: 下载 Meslo 字体失败" >&2
            return 1
        fi
    elif command -v curl >/dev/null 2>&1; then
        if curl -L -o "$MESLO_TAR" "$MESLO_URL"; then
            echo "✓ Meslo 字体下载完成"
            return 0
        else
            echo "错误: 下载 Meslo 字体失败" >&2
            return 1
        fi
    else
        echo "错误: 未找到 wget 或 curl 命令" >&2
        return 1
    fi
}

# 安装 Meslo 字体的函数
install_meslo_font() {
    # 先下载字体文件
    if ! download_meslo_font; then
        return 1
    fi
    
    # 检查文件是否存在
    if [ ! -f "$MESLO_TAR" ]; then
        echo "错误: 未找到 Meslo 字体压缩包：$MESLO_TAR" >&2
        return 1
    fi

    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        # Linux 系统字体安装
        FONTS_DIR="$HOME/.fonts"
        mkdir -p "$FONTS_DIR"
        
        echo "正在解压 Meslo 字体..."
        if tar -xJf "$MESLO_TAR" -C "$FONTS_DIR" 2>/dev/null; then
            if command -v fc-cache >/dev/null 2>&1; then
                echo "正在刷新字体缓存..."
                fc-cache -fv "$FONTS_DIR" >/dev/null 2>&1
                echo "✓ Meslo 字体已安装到 $FONTS_DIR 并刷新了字体缓存"
            else
                echo "✓ Meslo 字体已安装到 $FONTS_DIR"
                echo "警告: 未找到 fc-cache，请手动刷新字体缓存"
            fi
            return 0
        else
            echo "错误: 解压字体文件失败" >&2
            return 1
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS 系统字体安装
        FONTS_DIR="$HOME/Library/Fonts"
        mkdir -p "$FONTS_DIR"
        
        echo "正在解压 Meslo 字体..."
        if tar -xJf "$MESLO_TAR" -C "$FONTS_DIR" 2>/dev/null; then
            echo "✓ Meslo 字体已安装到 $FONTS_DIR"
            echo "在 macOS 上，字体会自动加载，无需手动刷新缓存。"
            return 0
        else
            echo "错误: 解压字体文件失败" >&2
            return 1
        fi
    else
        echo "错误: 不支持的操作系统类型：$OSTYPE" >&2
        return 1
    fi
}

# 安装 Noto Serif 字体的函数
install_noto_font() {
    echo "正在从 GitHub 拉取字体仓库..."
    
    # 定义目标目录
    fonts_dir="$HOME/.cache/fonts"
    
    # 检查目录是否存在，如果不存在则创建
    if [ ! -d "$fonts_dir" ]; then
        mkdir -p "$fonts_dir"
    fi
    
    # 拉取或更新仓库
    if [ -d "$fonts_dir/.git" ]; then
        echo "字体仓库已存在，正在更新..."
        git -C "$fonts_dir" pull
    else
        echo "正在克隆字体仓库..."
        git clone https://github.com/iamcheyan/fonts.git "$fonts_dir"
    fi
    
    # 检查操作是否成功
    if [ $? -ne 0 ]; then
        echo "警告: 拉取字体仓库时出错，继续使用下载方式" >&2
    else
        echo "字体仓库已成功拉取到 $fonts_dir"
    fi

    # 下载 Noto Serif CJK 和 Noto Serif 字体
    echo "正在下载 Noto Serif 字体..."
    
    # 定义下载链接数组
    download_links=(
        "https://github.com/notofonts/noto-cjk/releases/download/Serif2.003/07_NotoSerifCJKjp.zip"
        "https://github.com/notofonts/noto-cjk/releases/download/Serif2.003/12_NotoSerifJP.zip"
        "https://github.com/notofonts/noto-cjk/releases/download/Serif2.003/09_NotoSerifCJKsc.zip"
        "https://github.com/notofonts/noto-cjk/releases/download/Serif2.003/14_NotoSerifSC.zip"
    )
    
    # 遍历下载链接并下载文件
    for link in "${download_links[@]}"; do
        filename=$(basename "$link")
        if [ -f "$fonts_dir/$filename" ]; then
            echo "文件已存在，跳过下载: $filename"
        else
            if command -v wget >/dev/null 2>&1; then
                if wget -q --show-progress -P "$fonts_dir" "$link"; then
                    echo "成功下载: $filename"
                else
                    echo "下载失败: $filename" >&2
                fi
            elif command -v curl >/dev/null 2>&1; then
                if curl -L -o "$fonts_dir/$filename" "$link"; then
                    echo "成功下载: $filename"
                else
                    echo "下载失败: $filename" >&2
                fi
            else
                echo "错误: 未找到 wget 或 curl 命令" >&2
                return 1
            fi
        fi
    done
    
    echo "Noto Serif 字体下载完成"

    # 安装字体
    echo "正在安装字体..."
    
    # 解压所有 zip 文件
    echo "正在解压字体文件..."
    if command -v unzip >/dev/null 2>&1; then
        find "$fonts_dir" -name "*.zip" -exec unzip -q -o {} -d "$fonts_dir" \;
        if [ $? -eq 0 ]; then
            echo "所有字体文件已成功解压"
        else
            echo "解压字体文件时出错" >&2
            return 1
        fi
    else
        echo "错误: 未找到 unzip 命令" >&2
        return 1
    fi

    # 复制字体文件到 $HOME/.fonts 目录
    echo "正在复制字体文件..."
    mkdir -p "$HOME/.fonts"
    find "$fonts_dir" -type f \( -name "*.ttc" -o -name "*.ttf" -o -name "*.otf" \) -exec cp -f {} "$HOME/.fonts" \;

    # 整理 $HOME/.fonts 目录
    echo "正在整理字体文件..."
    find "$HOME/.fonts" -type f \( -name "*.ttc" -o -name "*.ttf" -o -name "*.otf" \) -exec mv -f {} "$HOME/.fonts" \;
    find "$HOME/.fonts" -type d -empty -delete
    echo "字体文件整理完成"

    # 清除字体缓存
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if command -v fc-cache >/dev/null 2>&1; then
            echo "正在清除字体缓存..."
            fc-cache -f -v
        else
            echo "警告: 未找到 fc-cache，请手动刷新字体缓存"
        fi
    fi

    echo "Noto Serif 字体安装完成"
}

# 检查是否已安装 Meslo 字体
check_meslo_installed() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if command -v fc-list >/dev/null 2>&1 && fc-list | grep -qi "meslo" 2>/dev/null; then
            return 0
        fi
        # 检查字体文件是否存在
        if [ -d "$HOME/.fonts" ] && find "$HOME/.fonts" -name "*Meslo*" -o -name "*meslo*" 2>/dev/null | grep -q .; then
            return 0
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        if [ -d "$HOME/Library/Fonts" ] && find "$HOME/Library/Fonts" -name "*Meslo*" -o -name "*meslo*" 2>/dev/null | grep -q .; then
            return 0
        fi
    fi
    return 1
}

# 主函数
main() {
    local install_meslo=false
    local install_noto=false
    local force=false
    
    # 解析参数
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --meslo|-m)
                install_meslo=true
                shift
                ;;
            --noto|-n)
                install_noto=true
                shift
                ;;
            --all|-a)
                install_meslo=true
                install_noto=true
                shift
                ;;
            --force|-f)
                force=true
                shift
                ;;
            *)
                echo "未知参数: $1" >&2
                echo "用法: $0 [--meslo] [--noto] [--all] [--force]" >&2
                exit 1
                ;;
        esac
    done
    
    # 如果没有指定字体类型，默认安装 Meslo（保持向后兼容）
    if [ "$install_meslo" = false ] && [ "$install_noto" = false ]; then
        install_meslo=true
    fi
    
    # 安装 Meslo 字体
    if [ "$install_meslo" = true ]; then
        if [ "$force" = false ] && [ -t 0 ]; then
            # 交互模式
            if check_meslo_installed; then
                echo "Meslo 字体似乎已安装。"
                read -p "是否要重新安装？(y/N): " -n 1 -r
                echo
                if [[ $REPLY =~ ^[Yy]$ ]]; then
                    install_meslo_font
                else
                    echo "已跳过 Meslo 字体安装"
                fi
            else
                read -p "是否要安装 Meslo 字体？(y/N): " -n 1 -r
                echo
                if [[ $REPLY =~ ^[Yy]$ ]]; then
                    install_meslo_font
                else
                    echo "已跳过 Meslo 字体安装"
                fi
            fi
        else
            # 非交互模式或强制模式
            install_meslo_font
        fi
    fi
    
    # 安装 Noto Serif 字体
    if [ "$install_noto" = true ]; then
        if [ "$force" = false ] && [ -t 0 ]; then
            # 交互模式
            read -p "是否要安装 Noto Serif 字体？(y/N): " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                install_noto_font
            else
                echo "已跳过 Noto Serif 字体安装"
            fi
        else
            # 非交互模式或强制模式
            install_noto_font
        fi
    fi
}

# 如果作为脚本运行，执行主函数
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    main "$@"
fi

