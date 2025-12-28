#!/bin/bash
# Waybar 依赖工具安装脚本

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "正在安装 Waybar 所需工具..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# 更新包列表
echo "📦 更新包列表..."
sudo apt update

echo ""
echo "🔧 安装必需工具："
echo ""

# 安装必需工具
echo "1️⃣  安装 light (亮度控制 - waybar backlight 模块需要)..."
sudo apt install -y light

echo ""
echo "2️⃣  安装 playerctl (媒体控制 - 键盘快捷键需要)..."
sudo apt install -y playerctl

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🎵 安装可选工具（音乐播放相关）："
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

echo "3️⃣  安装 mpd (音乐播放器守护进程)..."
sudo apt install -y mpd

echo ""
echo "4️⃣  安装 mpc (mpd 命令行客户端)..."
sudo apt install -y mpc

echo ""
echo "5️⃣  安装 ncmpcpp (mpd 终端界面)..."
sudo apt install -y ncmpcpp

echo ""
echo "6️⃣  安装 cava (音频可视化 - waybar 音频可视化模块需要)..."
sudo apt install -y cava

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔤 安装字体和图标（重要！）："
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

echo "7️⃣  安装 Nerd Fonts (Hack 或 JetBrains Mono)..."
echo "   注意：Nerd Fonts 需要通过 GitHub 下载安装"
echo "   当前系统已安装：MesloLGS Nerd Font"
echo ""
echo "   如果需要 Hack Nerd Font 或 JetBrains Mono Nerd Font："
echo "   - 访问: https://www.nerdfonts.com/font-downloads"
echo "   - 下载字体并安装到 ~/.fonts/ 目录"
echo "   - 运行: fc-cache -fv"
echo ""

echo "8️⃣  检查是否需要安装其他图标字体..."
# 检查 Font Awesome
if fc-list | grep -qi "Font Awesome\|fontawesome"; then
    echo "   ✅ Font Awesome 已安装"
else
    echo "   ⚠️  Font Awesome 未安装（可选）"
    echo "   安装: sudo apt install fonts-font-awesome"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ 安装完成！"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📝 配置说明："
echo ""
echo "1. cava 配置：已从仓库复制到 ~/.config/cava/config"
echo ""
echo "2. mpd 配置：需要配置 ~/.config/mpd/mpd.conf"
echo "   - 如果需要使用 mpd，请确保配置文件正确"
echo "   - 启动 mpd: systemctl --user start mpd"
echo "   - 开机自启: systemctl --user enable mpd"
echo ""
echo "3. 如果某些模块不工作，可以在 ~/.config/waybar/config 中注释掉对应模块"
echo ""
echo "4. 重新加载 Sway 配置: swaymsg reload"


echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📋 字体安装说明："
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Waybar 配置使用了 'Hack Nerd Font'，你需要安装对应的字体。"
echo ""
echo "方法1: 如果已有其他 Nerd Font（如 MesloLGS），可以修改样式文件："
echo "  编辑 ~/.config/waybar/style.css"
echo "  将 'Hack Nerd Font' 改为你已安装的 Nerd Font 名称"
echo ""
echo "方法2: 安装 Hack Nerd Font："
echo "  1. 访问: https://www.nerdfonts.com/font-downloads"
echo "  2. 下载 'Hack' 字体"
echo "  3. 解压并复制到 ~/.fonts/ 目录"
echo "  4. 运行: fc-cache -fv ~/.fonts"
echo "  5. 重启 waybar 或 Sway"
echo ""
echo "方法3: 使用 apt 安装（如果可用）："
echo "  sudo apt install fonts-hack-ttf"
echo "  （但通常不包含 Nerd Font 版本，需要手动安装）"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📋 字体和图标总结："
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "✅ 字体：已使用 MesloLGS Nerd Font Mono（系统已安装）"
echo "✅ waybar 样式文件已更新，图标应该能正常显示"
echo ""
echo "如果图标显示不正常，可以："
echo "1. 重启 waybar: pkill waybar && waybar &"
echo "2. 或重新加载 Sway: swaymsg reload"

