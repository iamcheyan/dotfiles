#!/bin/bash
# 修复 zellij 插件权限缓存
# 当权限弹窗无法点击时，运行此脚本重新生成权限缓存文件

set -e

# 支持 Linux/macOS 标准缓存路径与 macOS Library 缓存路径
CACHE_DIRS=(
    "$HOME/.cache/zellij"
    "$HOME/Library/Caches/zellij"
)

for CACHE_DIR in "${CACHE_DIRS[@]}"; do
    mkdir -p "$CACHE_DIR"
    
    cat > "$CACHE_DIR/permissions.kdl" <<EOF
"$HOME/.config/zellij/plugins/zellij-cb.wasm" {
    ReadApplicationState
    ChangeApplicationState
    RunCommands
}
EOF
    echo "✓ Zellij permissions cache fixed: $CACHE_DIR/permissions.kdl"
done
