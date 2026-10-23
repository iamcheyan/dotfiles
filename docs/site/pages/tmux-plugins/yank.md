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

`tmux-copy` is the shared `copy-pipe` command. On SSH it leaves the selected text in tmux's
buffer and returns successfully; tmux `set-clipboard on` generates OSC 52 for the attached
client. Locally it delegates to `scripts/tmux-clipboard-copy`, which chooses the platform
backend. Copy-mode key overrides are documented below.

| 键 | 行为 |
|---|---|
| `y` | 复制选区 |
| `Enter` | 复制选区 |
| `MouseDragEnd1Pane` | 鼠标拖选后自动复制 |
| `M-y` | 复制后 `tmux paste-buffer -p` 粘贴 |
| `!` | 先 `tr -d "\n"` 去掉换行再复制 |
| `DoubleClick1Pane` | 按词选择后复制 |
| `TripleClick1Pane` | 按行选择后复制 |

配置里不允许再出现 `clip.exe`、`wl-copy`、`xclip`、`xsel`、`pbcopy` 的直接调用；
`tmux list-keys -T copy-mode-vi | grep -E 'clip\.exe|wl-copy|xclip|xsel|pbcopy'`
应该没有输出。

### 远程 / SSH

通过 **OSC 52** 转义序列：把文本编码后发给终端，由终端写入本地剪贴板。

这需要两个条件：

```tmux
set -g allow-passthrough on    # 本仓库已设置
```

以及终端支持 OSC 52（Kitty、iTerm2、WezTerm 等支持，某些终端默认关闭）。

本仓库的 `allow-passthrough on` 正是为了让 OSC 52 序列穿过 tmux 到达外层终端。

## 远程 / SSH：OSC 52

在 SSH 场景，tmux 复制会更新 tmux buffer。`set-clipboard on` 让 tmux 将 buffer
更新编码为 OSC 52 发给 terminal client；`allow-passthrough on` 允许应用发出的
OSC/DCS 序列穿过 tmux。每一层嵌套 tmux 都需要相应配置，最外层终端还必须允许
OSC 52 写剪贴板。OSC 52 没有确认回执，因此发送序列不代表终端已接受。

`set-clipboard` 检查的是 tmux server option：

```sh
tmux show-options -g allow-passthrough
tmux show-options -s set-clipboard
```

| 值 | 行为 | 本配置建议 |
|---|---|---|
| `external` | 不允许应用通过 tmux 写终端剪贴板；外部终端剪贴板更新可进入 tmux | 不用于本方案 |
| `on` | 允许应用通过 tmux 读写终端剪贴板；tmux copy-mode 剪贴也会向客户端发送 OSC 52 | 推荐；主配置已启用 |
| `off` | 禁止应用通过 tmux 访问终端剪贴板；仍可用 `copy-pipe` 的本地后端 | 远程 OSC 52 不推荐 |

主配置设置 `allow-passthrough on` 与 `set-clipboard on`。SSH 环境下，
`scripts/tmux-copy` 把 copy-pipe 收到的选区载入专用 tmux buffer，由 tmux 发 OSC 52；
不会向 pane PTY 写转义序列。非 SSH 会话委托 `scripts/tmux-clipboard-copy` 选择本地后端：
WSL 使用 `iconv -f UTF-8 -t UTF-16LE | clip.exe`，Wayland 用 `wl-copy`，X11 用
`xclip`/`xsel`，macOS 用 `pbcopy`。OSC 52 没有接收回执，终端拒绝时无法检测或自动回退。

### 五种连接场景验收

每种场景都应复制下面完整文本，并粘贴到本地编辑器逐字核对（含多行与 emoji）：

```text
中文
日本語
😀
𠮷野家
第一行
第二行
```

1. Windows Terminal → WSL → tmux：验证 OSC 52 接受策略；不支持时验证 WSL 本地 `clip.exe` 后端。
2. Windows Terminal → WSL → SSH → Linux → tmux：验证远端 pane 的 SSH 环境变量与 tmux OSC 52。
3. Windows Terminal → WSL → SSH → Bastion → SSH → Linux → tmux：逐层核实 tmux passthrough，最后粘贴到 Windows Terminal。
4. Linux Desktop → tmux：本地复制使用 Wayland `wl-copy` 或 X11 `xclip`/`xsel`。
5. macOS → tmux：本地复制使用 `pbcopy`。

Windows Terminal、WezTerm、Kitty、iTerm2 均需按实际版本与剪贴板策略验收；终端策略可能要求用户确认。

| 键 | 作用 |
|---|---|
| `y` | 复制选区（本地主配置通过共享脚本处理本地后端） |
| copy mode 里 `Y` | 复制到行尾 |
| `Prefix + ]` | 粘贴 tmux 缓冲区（tmux 自带） |
| `Prefix + y` | tmux-yank 插件复制当前 pane 的命令行内容 |

`y` 在 vi copy mode 下有效，因为本仓库设了 `setw -g mode-keys vi`。

## Local helper check

Outside SSH, `tmux-copy` delegates input unchanged to `tmux-clipboard-copy`. Confirm the
selected bytes at the system clipboard. In SSH, the handler returns success and tmux `set-clipboard on` sends a copy-mode buffer
update as OSC 52. Verify end-to-end by pasting in the outer terminal.

## Typical workflow

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
