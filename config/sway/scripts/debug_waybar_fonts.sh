#!/bin/bash
# Waybar 字体调试脚本

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Waybar 字体和图标调试工具"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

echo "📋 1. 检查已安装的 Nerd Fonts："
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
fc-list | grep -i "nerd font" | cut -d: -f2 | sort -u | head -20
echo ""

echo "📋 2. 检查常用 Nerd Font 字体匹配："
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Hack Nerd Font:"
fc-match "Hack Nerd Font"
echo ""
echo "MesloLGS Nerd Font Mono:"
fc-match "MesloLGS Nerd Font Mono"
echo ""
echo "JetBrainsMono Nerd Font:"
fc-match "JetBrainsMono Nerd Font"
echo ""

echo "📋 3. 检查 Waybar CSS 中使用的字体："
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
if [ -f ~/.config/waybar/style.css ]; then
    grep -i "font-family" ~/.config/waybar/style.css
else
    echo "❌ 找不到 ~/.config/waybar/style.css"
fi
echo ""

echo "📋 4. 创建测试 HTML 文件（用于测试图标显示）："
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
TEST_FILE="/tmp/waybar_icon_test.html"
cat > "$TEST_FILE" << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Waybar Icon Test</title>
    <style>
        body {
            background: #24283b;
            color: #c0caf5;
            font-family: "Hack Nerd Font", "MesloLGS Nerd Font Mono", monospace;
            padding: 20px;
            font-size: 24px;
        }
        .test-section {
            margin: 20px 0;
            padding: 10px;
            border: 1px solid #414868;
        }
        .icon-row {
            display: flex;
            gap: 20px;
            margin: 10px 0;
        }
        .icon-item {
            padding: 10px;
            background: #1f222d;
            border-radius: 4px;
        }
    </style>
</head>
<body>
    <h1>Waybar 图标测试</h1>
    
    <div class="test-section">
        <h2>常用 Waybar 图标：</h2>
        <div class="icon-row">
            <div class="icon-item">温度:  󰔏</div>
            <div class="icon-item">电池:  󰁹</div>
            <div class="icon-item">网络:  󰤨</div>
            <div class="icon-item">音量:  󰕾</div>
        </div>
        <div class="icon-row">
            <div class="icon-item">音乐:  󰎈</div>
            <div class="icon-item">亮度:  󰃟</div>
            <div class="icon-item">CPU:   󰍛</div>
            <div class="icon-item">内存:  󰍛</div>
        </div>
    </div>
    
    <div class="test-section">
        <h2>工作区图标（如果有）：</h2>
        <div class="icon-row">
            <div class="icon-item">工作区 1-6: 1 2 3 4 5 6</div>
        </div>
    </div>
    
    <div class="test-section">
        <h2>测试 Unicode 字符：</h2>
        <div class="icon-row">
            <div class="icon-item">普通符号: | { } [ ]</div>
            <div class="icon-item">特殊符号: → ← ↑ ↓</div>
        </div>
    </div>
    
    <p style="margin-top: 30px; font-size: 14px; color: #888888;">
        如果上面的图标显示为方块或问号，说明字体未正确安装或配置。
        <br>
        请在浏览器中打开此文件查看效果。
    </p>
</body>
</html>
EOF
echo "✅ 测试文件已创建: $TEST_FILE"
echo "   使用浏览器打开查看图标是否正常显示"
echo ""

echo "📋 5. 检查 Waybar 进程和配置："
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
if pgrep -x waybar > /dev/null; then
    echo "✅ Waybar 正在运行"
    echo "   PID: $(pgrep -x waybar)"
else
    echo "❌ Waybar 未运行"
fi
echo ""

echo "📋 6. 验证 Waybar 配置文件："
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
if command -v waybar > /dev/null 2>&1; then
    if waybar --validate 2>&1 | head -5; then
        echo "✅ 配置文件格式正确"
    else
        echo "⚠️  配置文件可能有问题"
    fi
else
    echo "❌ waybar 命令未找到"
fi
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "💡 调试建议："
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "1. 检查 style.css 中的字体名称是否与实际安装的字体匹配"
echo "2. 如果字体名称不匹配，使用 'fc-match \"字体名称\"' 检查"
echo "3. 更新字体缓存: fc-cache -fv ~/.fonts"
echo "4. 重启 Waybar: pkill waybar && waybar -c ~/.config/waybar/config -s ~/.config/waybar/style.css &"
echo "5. 查看浏览器测试文件: $TEST_FILE"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

