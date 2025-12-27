#!/bin/bash
# 检查 yazi flavor 配置

echo "检查 yazi flavor 配置..."
echo ""

YAZI_CONFIG="$HOME/.config/yazi"
YAZI_SOURCE="$HOME/.dotfiles/config/yazi"

# 1. 检查软链接
echo "1. 检查配置目录链接："
if [ -L "$YAZI_CONFIG" ]; then
    target=$(readlink -f "$YAZI_CONFIG")
    if [ "$target" = "$YAZI_SOURCE" ]; then
        echo "   ✓ 软链接正确: $YAZI_CONFIG -> $target"
    else
        echo "   ✗ 软链接指向错误: $YAZI_CONFIG -> $target"
        echo "     期望: $YAZI_SOURCE"
    fi
elif [ -d "$YAZI_CONFIG" ]; then
    echo "   ✗ $YAZI_CONFIG 是目录，不是软链接"
    echo "     需要创建软链接: ln -sf $YAZI_SOURCE $YAZI_CONFIG"
else
    echo "   ✗ $YAZI_CONFIG 不存在"
    echo "     需要创建软链接: ln -sf $YAZI_SOURCE $YAZI_CONFIG"
fi
echo ""

# 2. 检查 flavors 目录
echo "2. 检查 flavors 目录："
FLAVORS_DIR="$YAZI_CONFIG/flavors"
if [ -d "$FLAVORS_DIR" ]; then
    echo "   ✓ flavors 目录存在: $FLAVORS_DIR"
    echo "   包含的主题："
    for flavor_dir in "$FLAVORS_DIR"/*.yazi; do
        if [ -d "$flavor_dir" ]; then
            flavor_name=$(basename "$flavor_dir" .yazi)
            if [ -f "$flavor_dir/flavor.toml" ]; then
                echo "      ✓ $flavor_name (有 flavor.toml)"
            else
                echo "      ✗ $flavor_name (缺少 flavor.toml)"
            fi
        fi
    done
else
    echo "   ✗ flavors 目录不存在: $FLAVORS_DIR"
fi
echo ""

# 3. 检查 theme.toml
echo "3. 检查 theme.toml 配置："
THEME_FILE="$YAZI_CONFIG/theme.toml"
if [ -f "$THEME_FILE" ]; then
    echo "   ✓ theme.toml 存在"
    if grep -q "catppuccin-mocha" "$THEME_FILE"; then
        echo "   ✓ 配置了 catppuccin-mocha (dark)"
    else
        echo "   ✗ 未配置 catppuccin-mocha"
    fi
    if grep -q "catppuccin-latte" "$THEME_FILE"; then
        echo "   ✓ 配置了 catppuccin-latte (light)"
    else
        echo "   ✗ 未配置 catppuccin-latte"
    fi
    echo "   当前配置："
    grep -A 2 "\[flavor\]" "$THEME_FILE" | sed 's/^/      /'
else
    echo "   ✗ theme.toml 不存在: $THEME_FILE"
fi
echo ""

# 4. 检查 package.toml
echo "4. 检查 package.toml："
PACKAGE_FILE="$YAZI_CONFIG/package.toml"
if [ -f "$PACKAGE_FILE" ]; then
    echo "   ✓ package.toml 存在"
    if grep -q "catppuccin" "$PACKAGE_FILE"; then
        echo "   ℹ 包含 catppuccin flavor 依赖声明"
    else
        echo "   ℹ 未声明 catppuccin flavor 依赖（使用本地文件时不需要）"
    fi
else
    echo "   ✗ package.toml 不存在: $PACKAGE_FILE"
fi
echo ""

# 5. 总结
echo "总结："
if [ -L "$YAZI_CONFIG" ] && [ -d "$FLAVORS_DIR" ] && [ -f "$THEME_FILE" ]; then
    echo "   ✓ 基本配置完整"
    echo "   如果 yazi 仍未使用主题，请尝试："
    echo "   1. 重启 yazi"
    echo "   2. 运行: ya pkg sync (如果使用 package.toml 管理)"
    echo "   3. 检查 yazi 版本是否支持 flavor 功能"
else
    echo "   ✗ 配置不完整，请先修复上述问题"
fi

