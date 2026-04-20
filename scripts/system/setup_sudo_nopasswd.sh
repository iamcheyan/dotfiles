#!/bin/bash

# 为当前用户设置 sudo 免密脚本
# 路径: scripts/system/setup_sudo_nopasswd.sh

set -e

USER_NAME=$(whoami)

echo "🚀 正在为用户 $USER_NAME 设置 sudo 免密..."

# 创建 sudoers 配置文件
# 使用 tee 命令写入 /etc/sudoers.d/ 下的独立文件
echo "$USER_NAME ALL=(ALL) NOPASSWD: ALL" | sudo tee "/etc/sudoers.d/$USER_NAME" > /dev/null

# 设置正确的权限 (必须是 0440)
sudo chmod 0440 "/etc/sudoers.d/$USER_NAME"

echo "✅ 设置完成！现在执行 sudo 命令将不再需要输入密码。"
