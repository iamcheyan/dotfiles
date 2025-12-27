#!/bin/bash
# 磁盘使用情况查看脚本
# 用法: disk_usage [路径] [深度]

set -e

TARGET_DIR="${1:-.}"
MAX_DEPTH="${2:-2}"

# 检查目录是否存在
if [ ! -d "$TARGET_DIR" ]; then
    echo "错误: 目录不存在: $TARGET_DIR" >&2
    exit 1
fi

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  磁盘使用情况: $TARGET_DIR"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# 使用 du 命令显示目录大小（如果可用）
if command -v du >/dev/null 2>&1; then
    echo "目录大小（前 20 个）:"
    du -h --max-depth="$MAX_DEPTH" "$TARGET_DIR" 2>/dev/null | \
        sort -rh | \
        head -20 | \
        awk '{printf "  %-8s %s\n", $1, substr($0, index($0,$2))}'
    echo ""
fi

# 显示总大小
if command -v du >/dev/null 2>&1; then
    TOTAL_SIZE=$(du -sh "$TARGET_DIR" 2>/dev/null | cut -f1)
    echo "总大小: $TOTAL_SIZE"
fi

