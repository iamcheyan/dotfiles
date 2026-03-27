#!/bin/bash
# ==========================================
# WSL 全盘清理脚本
# 清理 Rust, Python, apt, Snap, 日志, 临时文件
# ==========================================

echo "===== 开始 WSL 清理 ====="

# 1️⃣ 清理 Cargo 缓存
if command -v cargo >/dev/null 2>&1; then
    echo ">>> 清理 Cargo 缓存"
    cargo cache -a
fi

# 2️⃣ 清理 Rust 工具链旧版本
if command -v rustup >/dev/null 2>&1; then
    echo ">>> 清理 Rust 旧工具链"
    rustup cleanup -y 2>/dev/null || echo "⚠️ rustup cleanup 失败，请手动执行 rustup cleanup"
fi

# 3️⃣ 清理 pip 缓存
if command -v pip >/dev/null 2>&1; then
    echo ">>> 清理 pip 缓存"
    rm -rf ~/.cache/pip
fi

# 4️⃣ 清理 apt 缓存和未使用包
if command -v apt >/dev/null 2>&1; then
    echo ">>> 清理 apt 缓存"
    sudo apt clean
    sudo apt autoremove -y
fi

# 5️⃣ 清理 journal 日志（只保留最近3天）
if command -v journalctl >/dev/null 2>&1; then
    echo ">>> 清理系统日志"
    sudo journalctl --vacuum-time=3d
fi

# 6️⃣ 清理 Snap 缓存
if command -v snap >/dev/null 2>&1; then
    echo ">>> 清理 Snap 缓存"
    sudo du -hx /var/lib/snapd/snaps 2>/dev/null | sort -hr | head -n 10
    # 可选：删除旧版本
    # sudo snap remove <旧版本包名>
fi

# 7️⃣ 清理临时文件
echo ">>> 清理 /tmp 目录"
sudo rm -rf /tmp/*

# 8️⃣ 查找大文件（>500MB）
echo ">>> 列出大于500MB的文件（不跨 /mnt）"
sudo find / -xdev -type f -size +500M 2>/dev/null | sort -hr | head -n 20

# 9️⃣ 输出各目录占用情况
echo ">>> 各顶级目录占用情况（不跨 /mnt）"
sudo du -hx --max-depth=1 / 2>/dev/null | sort -hr


echo "===== 清理完成 ====="