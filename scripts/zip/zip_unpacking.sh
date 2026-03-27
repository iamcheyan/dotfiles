#!/bin/bash

echo "🚀 开始批量解压 Lambda 压缩包..."

# 遍历当前目录下所有 zip 文件
for zipfile in *.zip; do
    # 如果没有匹配到 zip 文件，避免报错
    [ -e "$zipfile" ] || continue

    # 去掉 .zip 后缀作为目录名
    dirname="${zipfile%.zip}"

    echo "📦 正在解压: $zipfile -> $dirname/"

    # 如果目录不存在就创建
    if [ ! -d "$dirname" ]; then
        mkdir "$dirname"
    fi

    # 解压到对应目录
    unzip -oq "$zipfile" -d "$dirname"

    if [ $? -eq 0 ]; then
        echo "✅ 解压成功: $dirname/"
    else
        echo "❌ 解压失败: $zipfile"
    fi
done

echo "✨ 所有解压任务已完成！"