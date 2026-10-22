> 摘要：tmux 是终端复用器，本仓库的配置管真彩色、会话恢复、pane 导航和插件。

# tmux

## 用途

tmux 在终端里创建持久会话：断开 SSH 后进程继续运行，重连后恢复；把终端分成多个 pane 和 window；多人共享同一会话。

本仓库的配置重点在：真彩色、鼠标、vi copy mode、会话恢复、pane 导航。

## 来源与安装

| 项目 | 说明 |
|---|---|
| 来源 | 系统包管理器 |
| 配置 | `config/tmux/tmux.conf` → `~/.config/tmux/tmux.conf` |
| 插件管理 | TPM（tmux plugin manager） |

```bash
# Debian / Ubuntu
sudo apt install tmux
# Arch
pacman -S tmux
# macOS
brew install tmux
```

## 基本用法

```bash
tmux                    # 新建会话
tmux new -s work        # 命名会话
tmux ls                 # 列出会话
tmux attach -t work     # 连接
tmux kill-session -t work
```

在 tmux 里，所有快捷键都要先按 **prefix**（默认 `Ctrl+B`）。

## 本仓库的配置要点

### 真彩色

```tmux
set -g default-terminal "tmux-256color"
set -as terminal-features ",*:RGB"
set -as terminal-overrides ",*:Tc"
```

三行缺一不可：声明 terminfo、告诉应用支持 RGB、覆盖终端能力检测。否则 Neovim 的配色会退化成 256 色近似。

### 鼠标

```tmux
set -g mouse on
```

可以点选 pane、拖动边框调整大小、滚轮滚动。

### vi copy mode

```tmux
setw -g mode-keys vi
```

进入 copy mode 后用 `hjkl` 移动、`v` 选择、`y` 复制。

### 编号从 1 开始

```tmux
set -g base-index 1
setw -g pane-base-index 1
set -g renumber-windows on
```

`base-index` 只影响新窗口。会话恢复后可能仍停在 0，所以配置里有个 `run-shell` 重新编号：

```tmux
run-shell 'tmux list-sessions 2>/dev/null | cut -d: -f1 | while read -r s; do tmux move-window -r -t "$s:" 2>/dev/null || true; done'
```

### 历史与焦点

```tmux
set -g history-limit 200000
set -g focus-events on
```

`focus-events on` 让 Neovim 知道窗口是否聚焦，用于自动保存、autoread 等特性。

### 新窗口继承路径

```tmux
bind c new-window -c "#{pane_current_path}"
```

默认新窗口从 home 开始，改成继承当前 pane 的目录。

### 关闭 extended-keys

```tmux
set -g extended-keys off
```

原因：Kitty 的 CSI-u 协议会把 `Ctrl+J` 编码成 `ESC [ 106 ; 5 u`，远端不认识时会在命令行显示成乱码。关掉后按键仍用兼容编码。

## 本仓库的键位

| 键 | 作用 |
|---|---|
| `Prefix + c` | 新窗口（继承当前路径） |
| `Prefix + H` | pane 向左扩 5 格 |
| `Prefix + J` | pane 向下扩 5 格 |
| `Prefix + K` | pane 向上扩 5 格 |
| `Prefix + L` | pane 向右扩 5 格 |
| `Prefix + X` | 确认后结束 session |
| `Prefix + x` | 结束当前 pane |

`H/J/K/L` 用 `-r` 声明可重复，按住连续调整。

## TPM 插件

```tmux
set -g @plugin 'tmux-plugins/tpm'
set -g @plugin 'tmux-plugins/tmux-sensible'
set -g @plugin 'hyoretsu/tmux-persist'
set -g @plugin 'tmux-plugins/tmux-continuum'
set -g @plugin 'tmux-plugins/tmux-yank'
set -g @plugin 'christoomey/vim-tmux-navigator'
set -g @plugin 'sainnhe/tmux-fzf'
```

| 插件 | 作用 |
|---|---|
| tpm | 插件管理器 |
| tmux-sensible | 公认合理的默认值 |
| tmux-persist | 保存/恢复会话 |
| tmux-continuum | 自动保存、自动恢复 |
| tmux-yank | 复制到系统剪贴板 |
| vim-tmux-navigator | `Ctrl+h/j/k/l` 跨 Neovim/tmux 切换 |
| tmux-fzf | fzf 选择 session/window/pane |

**安装插件**：`Prefix + I`。**更新**：`Prefix + U`。

插件路径：

```tmux
run-shell 'tmux set-environment -g TMUX_PLUGIN_MANAGER_PATH "$HOME/.config/tmux/plugins/"'
```

## 会话恢复

```tmux
set -g @persist-strategy-vim 'session'
set -g @persist-strategy-nvim 'session'
```

保存时把 vim/nvim 的运行状态也记录。恢复后有一个钩子重新编号窗口：

```tmux
set -g @persist-hook-post-restore-all 'tmux list-sessions ... tmux move-window -r ...'
```

## 私有覆盖

```tmux
if-shell '[ -f "$HOME/.config/tmux/private.conf" ]' {
  source-file "$HOME/.config/tmux/private.conf"
}
```

文件不存在时静默跳过。公开配置不含私有内容，但允许本机追加。

## 常用命令

```bash
tmux source-file ~/.config/tmux/tmux.conf   # 重载配置
tmux list-sessions                          # 列出会话
tmux list-windows -a                        # 所有窗口
tmux show -g default-terminal               # 查选项
tmux capture-pane -p > scrollback.txt       # 导出当前 pane 内容
```

## 排错

**颜色不对**：三层检查——`echo $TERM`、`tmux show -g default-terminal`、`tmux show -g terminal-features`。

**插件没装**：`Prefix + I` 安装。检查 `~/.config/tmux/plugins/` 是否有目录。

**`Ctrl+h/j/k/l` 在 Neovim 里不切换 pane**：vim-tmux-navigator 需要 Neovim 侧也有对应插件。Neovim 配置里已包含。

**会话恢复后窗口编号从 0 开始**：后置钩子没执行。检查 `@persist-hook-post-restore-all` 是否被正确设置。

**`Prefix + X` 无反应**：可能和某个插件冲突。`tmux list-keys | grep -w X` 查看实际绑定。

**中文显示宽度错乱**：`tmux-256color` 需要正确编译的 terminfo。检查 `infocmp tmux-256color` 是否可用。
