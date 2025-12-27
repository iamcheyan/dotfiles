#!/bin/bash
# Meslo 字体安装脚本
# 支持交互式询问和命令行直接调用

# 字体压缩包路径
MESLO_TAR="$HOME/.dotfiles/resources/Meslo.tar.xz"

# 安装字体的函数
install_meslo_font() {
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

# 检查是否已安装字体
check_font_installed() {
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
    # 如果使用 --force 或 -f 参数，强制安装
    if [ "${1:-}" = "--force" ] || [ "${1:-}" = "-f" ]; then
        install_meslo_font
        return $?
    fi

    # 交互模式：询问用户
    if [ -t 0 ]; then
        if check_font_installed; then
            echo "Meslo 字体似乎已安装。"
            read -p "是否要重新安装？(y/N): " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                install_meslo_font
            else
                echo "已取消安装"
                return 0
            fi
        else
            read -p "是否要安装 Meslo 字体？(y/N): " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                install_meslo_font
            else
                echo "已取消安装"
                return 0
            fi
        fi
    else
        # 非交互模式，直接安装
        install_meslo_font
    fi
}

# 如果作为脚本运行，执行主函数
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    main "$@"
fi
