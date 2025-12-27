#!/bin/bash
# 通用解压脚本：根据文件扩展名自动选择解压方法
# 用法: extract <压缩文件>

set -e

if [ $# -eq 0 ]; then
    echo "用法: extract <压缩文件>" >&2
    echo "支持格式: .tar, .tar.gz, .tar.bz2, .tar.xz, .zip, .rar, .7z, .gz, .bz2" >&2
    exit 1
fi

FILE="$1"

if [ ! -f "$FILE" ]; then
    echo "错误: 文件不存在: $FILE" >&2
    exit 1
fi

FILENAME=$(basename "$FILE")
EXTENSION="${FILENAME##*.}"

case "$EXTENSION" in
    tar)
        tar -xf "$FILE"
        ;;
    gz)
        if [[ "$FILENAME" == *.tar.gz ]]; then
            tar -xzf "$FILE"
        else
            gunzip "$FILE"
        fi
        ;;
    bz2)
        if [[ "$FILENAME" == *.tar.bz2 ]]; then
            tar -xjf "$FILE"
        else
            bunzip2 "$FILE"
        fi
        ;;
    xz)
        if [[ "$FILENAME" == *.tar.xz ]]; then
            tar -xJf "$FILE"
        else
            unxz "$FILE"
        fi
        ;;
    zip)
        if command -v unzip >/dev/null 2>&1; then
            unzip "$FILE"
        else
            echo "错误: 需要 unzip 命令" >&2
            exit 1
        fi
        ;;
    rar)
        if command -v unrar >/dev/null 2>&1; then
            unrar x "$FILE"
        else
            echo "错误: 需要 unrar 命令" >&2
            exit 1
        fi
        ;;
    7z)
        if command -v 7z >/dev/null 2>&1; then
            7z x "$FILE"
        else
            echo "错误: 需要 7z 命令" >&2
            exit 1
        fi
        ;;
    *)
        echo "错误: 不支持的文件格式: .$EXTENSION" >&2
        exit 1
        ;;
esac

echo "✓ 解压完成: $FILE"

