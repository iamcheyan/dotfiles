#!/bin/bash
# 安装 Hack Nerd Font 脚本

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "正在安装 Hack Nerd Font..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

FONT_DIR="$HOME/.fonts"
TEMP_DIR="/tmp/hack-nerd-font-install"

# 创建临时目录
mkdir -p "$TEMP_DIR"
cd "$TEMP_DIR"

echo "📥 下载 Hack Nerd Font..."
# 下载字体
if ! curl -L -o hack-nerd-font.zip "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/Hack.zip" 2>/dev/null; then
    echo "❌ 下载失败，请检查网络连接"
    echo ""
    echo "手动安装方法："
    echo "1. 访问: https://www.nerdfonts.com/font-downloads"
    echo "2. 下载 'Hack' 字体"
    echo "3. 解压到 ~/.fonts/ 目录"
    echo "4. 运行: fc-cache -fv ~/.fonts"
    exit 1
fi

echo "✅ 下载完成"
echo ""
echo "📦 解压字体文件..."
if ! unzip -q hack-nerd-font.zip -d "$TEMP_DIR" 2>/dev/null; then
    echo "❌ 解压失败"
    exit 1
fi

echo "✅ 解压完成"
echo ""
echo "📋 复制字体文件到 ~/.fonts/ ..."
mkdir -p "$FONT_DIR"
find "$TEMP_DIR" -name "*.ttf" -exec cp {} "$FONT_DIR/" \; 2>/dev/null

if [ $? -eq 0 ]; then
    echo "✅ 字体文件已复制"
else
    echo "❌ 复制失败"
    exit 1
fi

echo ""
echo "🔄 更新字体缓存..."
fc-cache -fv "$FONT_DIR" > /dev/null 2>&1

echo "✅ 字体缓存已更新"
echo ""
echo "🔍 验证字体安装..."
if fc-list | grep -qi "hack.*nerd"; then
    echo "✅ Hack Nerd Font 安装成功！"
    echo ""
    echo "字体名称: $(fc-list | grep -i 'hack.*nerd' | head -1 | cut -d: -f2 | sed 's/^[[:space:]]*//')"
else
    echo "⚠️  字体可能未正确安装，请检查 ~/.fonts/ 目录"
fi

echo ""
echo "🧹 清理临时文件..."
rm -rf "$TEMP_DIR" hack-nerd-font.zip 2>/dev/null

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ 安装完成！"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "下一步："
echo "1. 重启 waybar: pkill waybar && waybar &"
echo "2. 或重新加载 Sway: swaymsg reload"

