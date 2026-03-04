#!/bin/bash

# 获取当前脚本所在目录
CURRENT_DIR=$(pwd)

echo "🚀 开始打包 Lambda 函数..."

# 遍历当前目录下的所有子目录
for dir in */; do
    # 去掉目录名末尾的斜杠
    dirname=${dir%/}
    
    # 排除不是代码目录的情况（比如 .git 或 venv）
    if [[ "$dirname" == "venv" || "$dirname" == "__pycache__" ]]; then
        continue
    fi

    echo "📦 正在处理目录: $dirname"

    # 进入子目录进行打包，确保 .py 文件在 zip 的根路径
    # -r: 递归压缩, -q: 安静模式, -j: 不记录目录名(但我们需要保留内部结构时通常不用-j)
    # 我们采用进入目录再打包的方式：
    (cd "$dirname" && zip -rq "../$dirname.zip" .)

    if [ $? -eq 0 ]; then
        echo "✅ 成功生成: $dirname.zip"
    else
        echo "❌ 打包失败: $dirname"
    fi
done

echo "✨ 所有打包任务已完成！"