#!/bin/bash
# 备份配置文件脚本
# 用法: backup_config [配置文件路径]

set -e

CONFIG_FILE="${1:-}"

if [ -z "$CONFIG_FILE" ]; then
    echo "用法: backup_config <配置文件路径>" >&2
    echo "示例: backup_config ~/.zshrc" >&2
    exit 1
fi

# 检查文件是否存在
if [ ! -f "$CONFIG_FILE" ]; then
    echo "错误: 文件不存在: $CONFIG_FILE" >&2
    exit 1
fi

# 生成备份文件名（添加时间戳）
BACKUP_DIR="$HOME/.config_backups"
mkdir -p "$BACKUP_DIR"

TIMESTAMP=$(date +%Y%m%d_%H%M%S)
FILENAME=$(basename "$CONFIG_FILE")
BACKUP_FILE="$BACKUP_DIR/${FILENAME}.${TIMESTAMP}.bak"

# 复制文件
cp "$CONFIG_FILE" "$BACKUP_FILE"

echo "✓ 备份完成: $BACKUP_FILE"
echo "  原文件: $CONFIG_FILE"

