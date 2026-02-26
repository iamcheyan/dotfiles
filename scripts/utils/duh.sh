#!/usr/bin/env bash
# duh.sh - WSL 轻量版磁盘占用查看脚本
# 用法: ./duh.sh [路径] [max-depth]

# 默认路径 /
PATH_TO_SCAN="${1:-/}"
MAX_DEPTH="${2:-1}"

# 检查 du 和 sort 是否可用
for cmd in du sort; do
  command -v $cmd >/dev/null 2>&1 || {
    echo "$cmd 命令未安装，请先安装"
    exit 1
  }
done

# 提示排除 /mnt
echo "扫描目录: $PATH_TO_SCAN (排除 /mnt 挂载)"
echo "--------------------------------------------"

# 扫描目录，占用 >500MB 高亮
sudo du -h --max-depth="$MAX_DEPTH" "$PATH_TO_SCAN" 2>/dev/null |
  grep -v "^/mnt" |
  awk '{
        size=$1
        # 将单位转换成 MB 方便比较
        if (size ~ /G/) { val=substr(size,1,length(size)-1)*1024 }
        else if (size ~ /M/) { val=substr(size,1,length(size)-1) }
        else { val=0 }
        if(val>=500) {print "\033[1;31m"$0"\033[0m"} else {print $0}
    }' |
  /usr/bin/sort -hr
