# Zellij Theme: Green (tmux-style)

## 色板总览

| 名称 | 用途 | HEX | ANSI 8-bit | RGB |
|------|------|-----|-----------|-----|
| Background | 状态栏背景、面板边框背景 | `#1a1b26` | 234 | 26,27,38 |
| Foreground | 正文默认前景色 | `#c0caf5` | 188 | 192,202,245 |
| Green | 状态栏背景(zellij-cb)、高亮边框 | `#51fa7a` | 10 (bright) | 0,255,0 |
| Black | 状态栏文字(zellij-cb) | `#000000` | 0 | 0,0,0 |
| Tab Green | Tab 非选中背景 | `#51fa79` | 10 | — |
| Tab Active BG | Tab 选中背景 | `#f3f8f4` | — | 243,248,244 |
| Tab Text | Tab 文字 | `#0e1116` | — | 14,17,22 |
| Session Name | 会话名颜色 | `#00fd7f` | — | 0,253,127 |
| Red | 错误/退出码 | `#f7768e` | — | 247,118,142 |
| Yellow | 警告 | `#e0af68` | — | 224,175,104 |
| Blue | 信息 | `#7aa2f7` | — | 122,162,247 |
| Magenta | 关键字 | `#bb9af7` | — | 187,154,247 |
| Cyan | 类型 | `#7dcfff` | — | 125,207,255 |
| Orange | 强调 | `#ff9e64` | — | 255,158,100 |
| White | 等同 Foreground | `#c0caf5` | 188 | — |
| Frame Unselected | 非焦点面板边框 | `#222222` | — | 34,34,34 |
| Frame Selected | 焦点面板边框 | `#333333` | — | 51,51,51 |
| Frame Highlight | 高亮边框 | `#51fa7a` | — | 81,250,122 |

## 配色分组

### 状态栏 (zellij-cb)

| 元素 | 前景色 | 背景色 |
|------|--------|--------|
| 状态栏整体 | Black `0` | Green `10` |
| Tab 文字 | Black `0` | Green `10` |
| 活动 Tab | Black `0` | White `#f3f8f4` |

### 面板边框 (Pane Frames)

| 状态 | 颜色 |
|------|------|
| 非选中 | `#222222` (深灰) |
| 选中 | `#333333` (中灰) |
| 高亮 | `#51fa7a` (绿色) |

### Tab Bar (ribbon)

| 状态 | 前景色 | 背景色 |
|------|--------|--------|
| 选中 | `#0e1116` | `#f3f8f4` |
| 非选中 | `#0e1116` | `#51fa79` |

### 会话名 (text_unselected)

| 元素 | 前景色 | 背景色 |
|------|--------|--------|
| 会话名 | `#00fd7f` | `#000000` |

## ANSI 转义序列参考

```bash
# 前景色
\e[38;5;Nm          # 8-bit (N = 0-255)
\e[38;2;R;G;Bm      # RGB

# 背景色
\e[48;5;Nm          # 8-bit
\e[48;2;R;G;Bm      # RGB

# 重置
\e[0m

# 常用色值
# 0   = Black       # 10  = Bright Green
# 1   = Red         # 11  = Bright Yellow
# 2   = Green       # 12  = Bright Blue
# 3   = Yellow      # 13  = Bright Magenta
# 4   = Blue        # 14  = Bright Cyan
# 5   = Magenta     # 15  = Bright White
# 6   = Cyan        # 234 = Dark BG (#1a1b26)
# 7   = White       # 188 = Light FG (#c0caf5)
```

## 文件索引

| 文件 | 内容 |
|------|------|
| `config.kdl` | 主配置：theme_dir、keybindings、plugins |
| `themes/default.kdl` | 主题定义：所有色值 |
| `layouts/default.kdl` | 布局：zellij-cb 状态栏 |
| `plugins/zellij-cb/` | 状态栏插件 (fork) |
