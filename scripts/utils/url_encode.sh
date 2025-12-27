#!/bin/bash
# URL 编码脚本
# 用法: url_encode "要编码的文本" 或 echo "文本" | url_encode

if [ -t 0 ]; then
    # 从参数读取
    if [ $# -eq 0 ]; then
        echo "用法: url_encode <文本>" >&2
        echo "  或: echo '文本' | url_encode" >&2
        exit 1
    fi
    TEXT="$*"
else
    # 从标准输入读取
    TEXT=$(cat)
fi

# URL 编码
python3 -c "import sys, urllib.parse; print(urllib.parse.quote(sys.argv[1]))" "$TEXT" 2>/dev/null || \
python -c "import sys, urllib; print(urllib.quote(sys.argv[1]))" "$TEXT" 2>/dev/null || \
echo "错误: 需要 Python 来执行 URL 编码" >&2

