> 摘要：tmux-yank 把 copy mode 或命令行里选中的文本送到系统剪贴板。

# tmux-yank

## 用途

tmux 的 copy mode 默认把文本复制到 tmux 自己的缓冲区，不是系统剪贴板。所以复制后无法粘贴到其它应用。

`tmux-yank` 补上这一步：把 tmux 缓冲区的内容同时送进系统剪贴板。它支持本机直接复制和 OSC 52 远程复制两条路径。

## 加载方式

```tmux
set -g @plugin 'tmux-plugins/tmux-yank'
```

本仓库没有为它设置任何选项，用上游默认值。

## 复制路径

### 本机

| 平台 | 使用的命令 |
|---|---|
| Linux (X11) | `xsel` 或 `xclip` |
| Linux (Wayland) | `wl-copy` |
| macOS | `pbcopy` |
| WSL | `clip.exe` |
| 其它 | `reattach-to-user-namespace`（旧版 macOS） |

插件按环境自动探测。

本仓库不依赖插件自己的探测：`config/tmux/tmux.conf` 在 TPM 之后把
copy-mode-vi 的 `y` 和 `Enter` 重新绑定到仓库脚本
`scripts/tmux-clipboard-copy`，由脚本统一选择后端，优先级为
WSL → Wayland → X11 → macOS。

### 远程 / SSH

通过 **OSC 52** 转义序列：把文本编码后发给终端，由终端写入本地剪贴板。

这需要两个条件：

```tmux
set -g allow-passthrough on    # 本仓库已设置
```

以及终端支持 OSC 52（Kitty、iTerm2、WezTerm 等支持，某些终端默认关闭）。

本仓库的 `allow-passthrough on` 正是为了让 OSC 52 序列穿过 tmux 到达外层终端。

## 快捷键

| 键 | 作用 |
|---|---|
| copy mode 里 `y` | 复制选区并退出 copy mode |
| copy mode 里 `Y` | 复制到行尾 |
| `Prefix + ]` | 粘贴 tmux 缓冲区（tmux 自带） |
| `Prefix + y` | 复制当前 pane 的命令行内容（部分版本） |

`y` 在 vi copy mode 下有效，因为本仓库设了 `setw -g mode-keys vi`。

## 典型流程

```text
1. Prefix + [              进入 copy mode
2. Space / v               开始选择（vi 模式）
3. hjkl 移动                扩展选区
4. Enter 或 y               复制并退出
5. 到其它应用 Ctrl+V         粘贴
```

第 4 步用 `y` 是 yank 插件提供的；用 `Enter` 则只进 tmux 缓冲区，不进系统剪贴板（取决于版本）。

## 依赖项

| 依赖 | 用途 | 安装 |
|---|---|---|
| `xsel` / `xclip` | X11 复制 | `apt install xsel` |
| `wl-copy` | Wayland 复制 | `apt install wl-clipboard` |
| `pbcopy` | macOS | 系统自带 |

**没有这些命令时插件不工作**。Linux 桌面环境通常自带，服务器环境需要手动装。

```bash
command -v xsel xclip wl-copy pbcopy
```

## 排错

**复制后其它应用粘贴不到**：剪贴板命令没装。按上面的命令检查。

**SSH 里复制失败**：终端不支持 OSC 52，或 `allow-passthrough` 没开。

```bash
tmux show -g allow-passthrough
```

**vi 模式下 `y` 没反应**：`mode-keys` 不是 vi，或 yank 没加载。

```bash
tmux show -gw mode-keys
```

**复制内容带换行**：tmux 会保留选区的换行。想要单行可以先用 `Y`（复制到行尾）或手动清理。

**Wayland 下失效**：需要 `wl-copy`。X11 的 `xclip` 在纯 Wayland 下不工作。

## 与 vim-tmux-navigator 的关系

两者独立：navigator 管光标在 pane 间移动，yank 管文本复制到剪贴板。没有冲突。
