# Zellij Theme: tmux-color

## 色板总览

| 名称 | 用途 | HEX | ANSI 8-bit |
|------|------|-----|-----------|
| Background | 主背景、状态栏 | `#0a1a0a` | 22 (dark green-black) |
| Foreground | 正文、状态栏文字 | `#a0f0a0` | 157 (light green) |
| Green | 高亮、边框焦点、状态栏 | `#51fa7a` | 10 (bright green) |
| Session Name | 会话名 | `#00fd7f` | 48 |
| Tab Text | Tab 文字 | `#0e1116` | — |
| Tab Active BG | Tab 选中背景 | `#f3f8f4` | — |
| Tab Green | Tab 非选中背景 | `#51fa79` | 10 |
| Frame Unselected | 非焦点边框 | `#222222` | — |
| Frame Selected | 焦点边框 | `#333333` | — |
| Frame Highlight | 高亮边框 | `#444444` | — |
| Red | 错误 | `#f7768e` | — |
| Yellow | 警告 | `#e0af68` | — |
| Blue | 信息 | `#7aa2f7` | — |
| Magenta | 关键字 | `#bb9af7` | — |
| Cyan | 类型 | `#7dcfff` | — |
| Orange | 强调 | `#ff9e64` | — |

## 配色分组

### 状态栏 (内置 tab-bar)

| 元素 | 前景色 | 背景色 |
|------|--------|--------|
| 状态栏整体 | Black `0` | Green `10` |
| Tab 文字 | Black `0` | Green `10` |
| 活动 Tab | Black `0` | White `#f3f8f4` |

### 面板边框 (Pane Frames)

| 状态 | 颜色 |
|------|------|
| 非选中 | `#222222` (深灰) |
| 选中 | `#333333` (浅灰) |
| 高亮 | `#444444` (亮灰) |

### Tab Bar (ribbon)

| 状态 | 前景色 | 背景色 |
|------|--------|--------|
| 选中 | `#0e1116` | `#f3f8f4` |
| 非选中 | `#0e1116` | `#51fa79` |

### 会话名 (text_unselected)

| 元素 | 前景色 | 背景色 |
|------|--------|--------|
| 会话名 | `#00fd7f` | `#000000` |

## 设计思路

- **基调**：深绿黑底 (`#0a1a0a`) + 亮绿文字 (`#a0f0a0`)
- **强调**：高亮绿 (`#51fa7a`) 用于边框焦点和状态栏
- **状态栏**：ANSI bright green (`0,255,0`) 底 + 黑色文字，tmux 风格
- **面板边框**：深灰 (`#222222`) 非焦点 / 浅灰 (`#333333`) 焦点，高亮时亮绿

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

# 本主题常用色值
# 0   = Black (状态栏文字)
# 10  = Bright Green (状态栏背景、高亮)
# 22  = Dark Green-Black (主背景)
# 48  = Spring Green (会话名)
# 157 = Light Green (主前景)
# 235 = Very Dark Green (#1a2e1a, 非焦点边框)
```

## 文件索引

| 文件 | 内容 |
|------|------|
| `config.kdl` | 主配置：theme_dir、keybindings、plugins |
| `themes/tmux-color.kdl` | 主题定义：所有色值 |
| `layouts/default.kdl` | 布局：内置 tab-bar 状态栏 |
| `THEME.md` | 本文件 |
