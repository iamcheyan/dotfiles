#!/bin/bash

# Fedora 系统更新与升级脚本 (2026 Edition)
# 适用场景：常规更新、跳版本升级、BTRFS 自动备份

set -e

# --- 变量配置 ---
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
SNAPSHOT_NAME="/.root_system_update_$TIMESTAMP"
CURRENT_VER=$(rpm -E %fedora)
LATEST_VER=44 # 设定 2026 年的目标版本

echo "🚀 开始 Fedora 系统检查 (当前版本: $CURRENT_VER)..."

# --- 1. 执行 BTRFS 快照备份 ---
# 注意：这需要 sudo 权限且 / 是 BTRFS 子卷
echo "💾 正在尝试创建 BTRFS 系统快照..."
if sudo btrfs subvolume snapshot / "$SNAPSHOT_NAME" 2>/dev/null; then
    echo "✅ 快照已创建: $SNAPSHOT_NAME"
else
    echo "⚠️ 快照创建失败 (可能不是 BTRFS 或权限问题)，继续操作..."
fi

# --- 2. 常规软件包更新 ---
echo "📦 正在执行常规软件包更新 (dnf upgrade)..."
sudo dnf upgrade --refresh -y

# --- 3. 检查大版本升级 ---
# 如果当前版本低于目标版本，则询问是否升级
if [ "$CURRENT_VER" -lt "$LATEST_VER" ]; then
    echo "📣 发现更高版本 Fedora $LATEST_VER (当前: $CURRENT_VER)!"
    echo "❓ 是否尝试升级？[y/N]"
    read -r response
    if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
        echo "🎯 正在安装升级插件..."
        sudo dnf install -y dnf-plugin-system-upgrade

        echo "🌍 正在下载 Fedora $LATEST_VER 升级包 (这可能需要较长时间)..."
        if sudo dnf system-upgrade download --releasever=$LATEST_VER -y --allowerasing; then
            echo "✅ 下载成功！系统即将重启并开始升级..."
            echo "💡 重启后将进入离线升级界面，请勿断电。"
            sleep 5
            sudo dnf system-upgrade reboot
        else
            echo "❌ 下载失败，可能版本 $LATEST_VER 尚未发布或镜像未就绪。"
        fi
    else
        echo "⏭️ 跳过大版本升级。"
    fi
else
    echo "✅ 你的系统已是最新版本 (Fedora $CURRENT_VER)。"
fi

# --- 4. 清理无用残留 ---
echo "🧹 正在清理 DNF 缓存与孤儿包..."
sudo dnf autoremove -y
sudo dnf clean all

echo "✨ 更新流程结束！建议重启以确保所有内核更新生效。"
