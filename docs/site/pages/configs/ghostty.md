> 摘要：Ghostty 配置字体、配色、选中复制和窗口行为，但当前不在 dotlink 映射里。

# Ghostty 配置

## 文件位置

| 项目 | 路径 |
|---|---|
| 仓库源文件 | `config/ghostty/config` |
| 部署目标 | `~/.config/ghostty/config` |
| 是否自动链接 | **否** |

这是本章最重要的提醒：文件在仓库里，但 `dotlink/dotlinkrc` 没有它。安装完 dotfiles 后 Ghostty 不会自动用上这个配置。

## 手动部署

```bash
mkdir -p ~/.config/ghostty
ln -sf ~/dotfiles/config/ghostty/config ~/.config/ghostty/config
```

macOS 上 Ghostty 的配置路径可能不同，按官方文档确认。

## 字体

```text
font-family = MesloLGS Nerd Font Mono
font-size = 11
```

Meslo 由 `scripts/install/install_font.sh` 安装。字体名必须完全匹配，`fc-list | grep -i meslo` 查看实际名称。

## 配色

```text
background = #0000aa
foreground = #ffff55
cursor-color = #ffffff
selection-background = #1e1ec8
selection-foreground = #ffffff
```

与 Neovim 内置 Blue 的 Nostalgia 配色一致：深蓝底、黄字、白色光标，选区用亮蓝底。

### 16 色板

```text
palette = 0=#000080
palette = 1=#aa0000
palette = 2=#00aa00
palette = 3=#aaaa00
palette = 4=#0000aa
palette = 5=#aa00aa
palette = 6=#00aaaa
palette = 7=#aaaaaa
palette = 8=#555555
palette = 9=#ff5555
palette = 10=#00ff00
palette = 11=#ffff55
palette = 12=#5555ff
palette = 13=#ff55ff
palette = 14=#55ffff
palette = 15=#ffffff
```

| 索引 | 用途 | 颜色 |
|---|---|---|
| 0 | 深蓝 | `#000080` |
| 1 | 红 | `#aa0000` |
| 2 | 绿 | `#00aa00` |
| 3 | 黄 | `#aaaa00` |
| 4 | 蓝 | `#0000aa` |
| 5 | 品红 | `#aa00aa` |
| 6 | 青 | `#00aaaa` |
| 7 | 灰白 | `#aaaaaa` |
| 8–15 | 亮色版本 | 红、绿、黄、蓝、品红、青、白的亮色变体 |

8–15 是 0–7 的明亮版本，程序用它们表示「加粗」或「高亮」。

## 剪贴板

```text
copy-on-select = clipboard
```

选中文本立即写入系统剪贴板，不需要 `Ctrl+Shift+C`。

代价：不小心选中就会覆盖剪贴板内容。习惯 `Ctrl+C` 复制别的内容时要注意。

## 窗口

```text
window-padding-x = 5
window-padding-y = 5
window-decoration = auto
window-theme = dark
window-border-color = #55ffff
quit-after-last-window-closed = false
```

| 设置 | 作用 |
|---|---|
| `window-padding-x/y = 5` | 内容四周留白 5px |
| `window-decoration = auto` | 由系统决定是否显示标题栏 |
| `window-theme = dark` | 强制暗色窗口装饰 |
| `quit-after-last-window-closed = false` | 关闭最后窗口时不退出应用（macOS 习惯） |

## 按键

```text
keybind = f11=toggle_fullscreen
```

F11 切换全屏。其它按键用 Ghostty 默认值。

## 与 tmux 的配合

Ghostty 提供终端能力和颜色，tmux 在其内部管理 pane。真彩色需要：

1. Ghostty 支持真彩色（默认支持）
2. tmux 配置 `terminal-features ,*:RGB`
3. 应用声明 `termguicolors`

本仓库的 tmux 配置已处理第 2 步。

## 为什么不在 dotlink 里

可能的原因：

- Ghostty 相对较新，配置路径在不同平台不一致
- 用户可能用别的终端（Kitty、Alacritty、WezTerm）
- 强制部署会覆盖用户已有的 Ghostty 配置

所以它作为「可选的参考配置」存在，需要的人手动链接。

## 验证

```bash
ls -l ~/.config/ghostty/config
ghostty +show-config | head -20
```

`ghostty +show-config` 会打印实际生效的配置，包括默认值和覆盖值。

## 排错

**配置不生效**：确认软链接建立了。`ls -l ~/.config/ghostty/config`。

**图标是方框**：Meslo 字体没装，或 `font-family` 名字不对。

**颜色不对**：`ghostty +show-config` 看实际值，可能有更高优先级的配置文件。

**选中复制太敏感**：把 `copy-on-select` 改成 `false` 或 `clipboard` 之外的值。

**F11 无反应**：窗口管理器可能拦截了 F11。换一个键。

**在 tmux 里颜色退化**：检查 tmux 的 `default-terminal` 和 `terminal-features`。
