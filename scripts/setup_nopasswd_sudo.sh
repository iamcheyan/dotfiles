#!/bin/bash

# 获取当前用户名
CURRENT_USER=$(whoami)
SUDOERS_FILE="/etc/sudoers.d/${CURRENT_USER}"

echo "正在为用户 ${CURRENT_USER} 配置 sudo 免密..."

# 创建免密配置文件
# 使用 sudo tee 写入，确保有权限执行
echo "${CURRENT_USER} ALL=(ALL) NOPASSWD: ALL" | sudo tee "${SUDOERS_FILE}" > /dev/null

# 设置正确的权限 (0440 是 sudoers 文件的标准权限)
sudo chmod 0440 "${SUDOERS_FILE}"

# 使用 visudo 检查语法是否正确
if sudo visudo -cf "${SUDOERS_FILE}"; then
    echo "配置成功！现在您可以免密使用 sudo 了。"
else
    echo "配置失败：语法错误。正在移除损坏的配置文件..."
    sudo rm -f "${SUDOERS_FILE}"
    exit 1
fi
