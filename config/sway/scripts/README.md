# Sway Scripts 目录

本目录包含 Sway 相关的辅助脚本。

## 脚本列表

### install_waybar_deps.sh
安装 Waybar 所需的依赖工具。

**功能：**
- 安装 `light` (亮度控制)
- 安装 `playerctl` (媒体控制)
- 安装 `mpd`, `mpc`, `ncmpcpp` (音乐播放相关)
- 安装 `cava` (音频可视化)

**使用方法：**
```bash
bash ~/.config/sway/scripts/install_waybar_deps.sh
```

### install_hack_nerd_font.sh
安装 Hack Nerd Font 字体（用于 Waybar 图标显示）。

**功能：**
- 从 GitHub 下载 Hack Nerd Font
- 安装到 `~/.fonts` 目录
- 更新字体缓存

**使用方法：**
```bash
bash ~/.config/sway/scripts/install_hack_nerd_font.sh
```

### debug_waybar_fonts.sh
调试 Waybar 字体和图标显示问题。

**功能：**
- 检查已安装的 Nerd Fonts
- 验证字体匹配
- 检查 Waybar CSS 配置
- 创建测试 HTML 文件用于测试图标显示
- 提供调试建议

**使用方法：**
```bash
bash ~/.config/sway/scripts/debug_waybar_fonts.sh
```

**调试步骤：**
1. 运行调试脚本查看当前状态
2. 检查 CSS 中使用的字体名称是否与实际安装的字体匹配
3. 如果字体名称不匹配，修改 `~/.config/waybar/style.css`
4. 重新加载 Sway 配置（`swaymsg reload`）或重启 Waybar

## 新脚本开发指南

1. 所有脚本应放在 `~/.config/sway/scripts/` 目录
2. 脚本应包含：
   - Shebang (`#!/bin/bash`)
   - 清晰的注释说明
   - 错误处理
   - 用户友好的输出信息
3. 脚本创建后添加执行权限：`chmod +x script_name.sh`
4. 在此 README 中添加脚本说明
