#!/bin/bash
# 生成随机字符串脚本
# 用法: random_string [长度，默认 32]

LENGTH="${1:-32}"

# 生成随机字符串
if command -v openssl >/dev/null 2>&1; then
    openssl rand -base64 "$LENGTH" | tr -d "=+/" | cut -c1-"$LENGTH"
elif command -v /dev/urandom >/dev/null 2>&1; then
    cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w "$LENGTH" | head -n 1
else
    echo "错误: 需要 openssl 或 /dev/urandom" >&2
    exit 1
fi

