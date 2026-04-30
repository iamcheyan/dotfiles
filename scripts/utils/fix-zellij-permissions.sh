#!/bin/bash
# 修复 zellij 插件权限缓存
# 当权限弹窗无法点击时，运行此脚本重新生成权限缓存文件

set -e

CACHE_DIR="$HOME/.cache/zellij"
mkdir -p "$CACHE_DIR"

cat > "$CACHE_DIR/permissions.kdl" <<EOF
"$HOME/.config/zellij/plugins/zellij-pane-picker.wasm" {
    ReadApplicationState
    ChangeApplicationState
    Reconfigure
}
"$HOME/.config/zellij/plugins/notepad.wasm" {
    ReadApplicationState
    ChangeApplicationState
    OpenFiles
}
"$HOME/.config/zellij/plugins/zjstatus.wasm" {
    ChangeApplicationState
    RunCommands
    ReadApplicationState
}
"$HOME/.config/zellij/plugins/zellij-attention.wasm" {
    ReadApplicationState
    ChangeApplicationState
    MessageAndLaunchOtherPlugins
    ReadCliPipes
}
EOF

echo "Zellij permissions cache fixed: $CACHE_DIR/permissions.kdl"
