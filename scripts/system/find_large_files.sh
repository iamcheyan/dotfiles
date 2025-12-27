#!/bin/bash
# 查找大文件脚本
# 用法: find_large_files [路径] [大小阈值，默认 100M]

set -e

TARGET_DIR="${1:-.}"
SIZE_THRESHOLD="${2:-100M}"

# 检查目录是否存在
if [ ! -d "$TARGET_DIR" ]; then
    echo "错误: 目录不存在: $TARGET_DIR" >&2
    exit 1
fi

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  查找大于 $SIZE_THRESHOLD 的文件: $TARGET_DIR"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# 使用 find 查找大文件
if command -v find >/dev/null 2>&1; then
    find "$TARGET_DIR" -type f -size +"$SIZE_THRESHOLD" -exec ls -lh {} \; 2>/dev/null | \
        awk '{print $5 "\t" $9}' | \
        sort -hr | \
        head -20
else
    echo "错误: 未找到 find 命令" >&2
    exit 1
fi

