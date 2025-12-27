#!/bin/bash
# Git 清理脚本：清理未跟踪的文件和目录
# 用法: git_clean [--force] [--dry-run]

set -e

DRY_RUN=false
FORCE=false

# 解析参数
while [[ $# -gt 0 ]]; do
    case $1 in
        --dry-run|-n)
            DRY_RUN=true
            shift
            ;;
        --force|-f)
            FORCE=true
            shift
            ;;
        *)
            echo "未知参数: $1" >&2
            echo "用法: git_clean [--dry-run] [--force]" >&2
            exit 1
            ;;
    esac
done

# 检查是否在 Git 仓库中
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo "错误: 当前目录不是 Git 仓库" >&2
    exit 1
fi

echo "正在检查未跟踪的文件和目录..."
UNTRACKED=$(git clean -n -d 2>/dev/null | wc -l)

if [ "$UNTRACKED" -eq 0 ]; then
    echo "✓ 没有需要清理的文件"
    exit 0
fi

echo ""
echo "以下文件和目录将被清理："
git clean -n -d

if [ "$DRY_RUN" = true ]; then
    echo ""
    echo "（这是预览模式，不会实际删除）"
    exit 0
fi

if [ "$FORCE" = true ]; then
    echo ""
    echo "正在清理..."
    git clean -fd
    echo "✓ 清理完成"
else
    echo ""
    read -p "确定要删除这些文件吗？(y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        git clean -fd
        echo "✓ 清理完成"
    else
        echo "已取消"
        exit 0
    fi
fi

