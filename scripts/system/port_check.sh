#!/bin/bash
# 端口检查脚本
# 用法: port_check [端口号]

set -e

PORT="${1:-}"

if [ -z "$PORT" ]; then
    echo "用法: port_check <端口号>" >&2
    echo "示例: port_check 8080" >&2
    exit 1
fi

# 检查端口是否被占用
if command -v lsof >/dev/null 2>&1; then
    if lsof -i :"$PORT" >/dev/null 2>&1; then
        echo "端口 $PORT 已被占用:"
        lsof -i :"$PORT"
    else
        echo "✓ 端口 $PORT 未被占用"
    fi
elif command -v netstat >/dev/null 2>&1; then
    if netstat -tuln | grep -q ":$PORT "; then
        echo "端口 $PORT 已被占用:"
        netstat -tuln | grep ":$PORT "
    else
        echo "✓ 端口 $PORT 未被占用"
    fi
elif command -v ss >/dev/null 2>&1; then
    if ss -tuln | grep -q ":$PORT "; then
        echo "端口 $PORT 已被占用:"
        ss -tuln | grep ":$PORT "
    else
        echo "✓ 端口 $PORT 未被占用"
    fi
else
    echo "错误: 未找到端口检查工具（lsof/netstat/ss）" >&2
    exit 1
fi

