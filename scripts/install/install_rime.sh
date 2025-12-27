#!/bin/bash
# Rime 配置安装脚本
# 从 GitHub 克隆 Rime 配置仓库到 ~/.dotfiles/rime
# 用法: install_rime [--force]

set -e

RIME_REPO_URL="https://github.com/iamcheyan/rime.git"
RIME_DIR="$HOME/.dotfiles/rime"

# 检查目录是否已存在
if [ -d "$RIME_DIR" ]; then
    if [ -d "$RIME_DIR/.git" ]; then
        # 目录存在且是 Git 仓库
        if [ "${1:-}" = "--force" ] || [ "${1:-}" = "-f" ]; then
            echo "检测到 Rime 配置目录已存在，使用 --force 参数将删除并重新克隆"
            read -p "确定要删除现有配置并重新克隆吗？(y/N): " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                echo "正在删除现有配置..."
                rm -rf "$RIME_DIR"
            else
                echo "已取消操作"
                exit 0
            fi
        else
            echo "Rime 配置目录已存在: $RIME_DIR"
            echo "目录已包含 Git 仓库，跳过克隆"
            echo ""
            echo "如果要重新克隆，请使用:"
            echo "  install:rime --force"
            exit 0
        fi
    else
        # 目录存在但不是 Git 仓库
        if [ "${1:-}" = "--force" ] || [ "${1:-}" = "-f" ]; then
            echo "检测到 Rime 配置目录已存在（非 Git 仓库），使用 --force 参数将删除并重新克隆"
            read -p "确定要删除现有目录并重新克隆吗？(y/N): " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                echo "正在删除现有目录..."
                rm -rf "$RIME_DIR"
            else
                echo "已取消操作"
                exit 0
            fi
        else
            echo "警告: Rime 配置目录已存在但不是 Git 仓库: $RIME_DIR"
            echo "如果要重新克隆，请使用:"
            echo "  install:rime --force"
            exit 1
        fi
    fi
fi

# 克隆仓库
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  正在克隆 Rime 配置仓库"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "仓库地址: $RIME_REPO_URL"
echo "目标目录: $RIME_DIR"
echo ""

if git clone "$RIME_REPO_URL" "$RIME_DIR"; then
    echo ""
    echo "✓ Rime 配置已成功克隆到: $RIME_DIR"
    echo ""
    echo "下一步："
    echo "  1. 使用 dotlink 创建符号链接到 Rime 配置目录"
    echo "  2. 或手动复制配置到对应的 Rime 配置目录"
    echo ""
    echo "Linux (fcitx5): ~/.local/share/fcitx5/rime"
    echo "Linux (ibus):   ~/.config/ibus/rime"
    echo "macOS:          ~/Library/Rime"
    echo "Windows:        %APPDATA%\\Rime"
else
    echo "错误: 克隆 Rime 配置仓库失败" >&2
    exit 1
fi

