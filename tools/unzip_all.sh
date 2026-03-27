#!/bin/bash

# 遍历当前目录下所有 zip 文件
for f in *.zip; do
  # 如果没有匹配到 zip 文件，避免报错
  [ -e "$f" ] || continue

  # 去掉 .zip 后缀作为目录名
  dir="${f%.zip}"

  # 创建目录（如果不存在）
  mkdir -p "$dir"

  # 解压到对应目录（-n 表示不覆盖已存在文件）
  unzip -n "$f" -d "$dir"

  echo "已解压: $f -> $dir/"
done

echo "全部解压完成"
