> 摘要：Starship 提示符的模块组成、Ghostty 终端外观，以及 tmux 的分工与键位。

# 终端与提示符

三者解决不同问题：Starship 画提示符，Ghostty 提供终端窗口，tmux 管理会话和分屏。

## Starship

### 加载方式

```zsh
zinit ice as"command" from"gh-r" bpick"${_starship_bpick}" pick"starship" sbin"starship"
zinit light starship/starship

if command -v starship >/dev/null 2>&1; then
  eval "$(starship init zsh)"
fi
```

`_starship_bpick` 按 OS 和架构选择 release 包：macOS 分 arm64/x86_64，Linux 分 aarch64/x86_64 且用 musl 版本（静态链接，不依赖系统 glibc）。

### 提示符结构

配置在 `config/starship/starship.toml`。主行：

```text
$hostname$directory$git_branch$git_status$python$nodejs$rust$golang$java$package$docker_context$kubernetes$aws$terraform$time
$character
```

右行：

```text
$status$cmd_duration$jobs
```

### 各模块的显示条件

| 模块 | 出现条件 |
|---|---|
| `hostname` | 只在 SSH 会话显示，格式 `host@ssh` |
| `directory` | 总是；截断到 3 层，进入仓库后显示仓库相对路径 |
| `git_branch` / `git_status` | 在 Git 仓库内 |
| `python` | 检测到 `requirements.txt`、`pyproject.toml`、`.venv` 等 |
| `nodejs` | 检测到 `package.json` 或 `node_modules` |
| `rust` | `Cargo.toml` |
| `golang` | `go.mod` |
| `java` | `pom.xml`、`build.gradle` 等 |
| `docker_context` | 设置了非默认 docker context |
| `kubernetes` | 有 kube context |
| `aws` | 有 AWS profile 或 region |
| `terraform` | 在 Terraform 目录 |
| `cmd_duration` | 命令耗时超过 2000ms |
| `time` | 总是，格式 `%H:%M` |

### 常用命令

```bash
starship explain        # 解释当前提示符每个模块为什么出现
starship prompt         # 打印当前提示符
starship module git_branch   # 单独渲染某模块
starship config         # 打开配置文件
starship preset nerd-font-symbols  # 换预设
```

`starship explain` 是排查「为什么提示符里没有 Python 版本」最快的方法。

### 符号与 Nerd Font

配置里大量使用 Nerd Font 图标（`❯`、``、``、`󰏗`）。终端字体必须是 Nerd Font，否则显示成方框或问号。本仓库用 Meslo Nerd Font，由 `install_font.sh` 安装。

## Ghostty

`config/ghostty/config`：

```text
font-family = MesloLGS Nerd Font Mono
font-size = 11
background = #000000
foreground = #f8f8f2
cursor-color = #50fa7b
copy-on-select = clipboard
window-padding-x = 5
window-padding-y = 5
keybind = f11=toggle_fullscreen
```

配色是 Dracula 风格的 16 色板。`copy-on-select = clipboard` 意味着选中文本立即进系统剪贴板，不需要 `Ctrl+Shift+C`。

**注意**：这个文件当前**没有**列入 `dotlink/dotlinkrc`。要让 Ghostty 用上它，需要手动建立链接：

```bash
mkdir -p ~/.config/ghostty
ln -sf ~/dotfiles/config/ghostty/config ~/.config/ghostty/config
```

## tmux

### 基础选项

```tmux
set -g default-terminal "tmux-256color"
set -as terminal-features ",*:RGB"
set -g mouse on
setw -g mode-keys vi
set -g base-index 1
setw -g pane-base-index 1
set -g renumber-windows on
set -g history-limit 200000
set -g focus-events on
set -g allow-passthrough on
```

| 选项 | 作用 |
|---|---|
| `default-terminal` | 声明支持 256 色 |
| `terminal-features ,*:RGB` | 让应用认为支持真彩色 |
| `mouse on` | 鼠标可选 pane、调大小、滚动 |
| `mode-keys vi` | copy mode 用 vi 键位 |
| `base-index 1` | window 从 1 开始编号 |
| `renumber-windows on` | 关闭窗口后重新编号，不留空号 |
| `history-limit 200000` | 回滚缓冲 20 万行 |
| `focus-events on` | 让 Neovim 感知焦点变化 |
| `allow-passthrough on` | 允许 Kitty 图形协议和 OSC 52 剪贴板穿过 tmux |

### 键位

| 键 | 动作 |
|---|---|
| `Prefix + c` | 新窗口，继承当前 pane 的路径 |
| `Prefix + H/J/K/L` | 向左/下/上/右调整 pane 大小，每次 5 格 |
| `Prefix + X` | 确认后结束整个 session |
| `Prefix + x` | 结束当前 pane |

`H/J/K/L` 用 `-r` 声明为可重复，按住不放会连续调整。

### TPM 插件

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
| `tpm` | 插件管理器本体 |
| `tmux-sensible` | 一组公认合理的默认值 |
| `tmux-persist` | 保存/恢复会话 |
| `tmux-continuum` | 自动保存、自动恢复 |
| `tmux-yank` | 复制到系统剪贴板 |
| `vim-tmux-navigator` | `Ctrl+h/j/k/l` 在 Neovim 和 tmux pane 间无缝切换 |
| `tmux-fzf` | 用 fzf 选择 session/window/pane |

首次安装插件：`Prefix + I`。更新：`Prefix + U`。

### 会话恢复

```tmux
set -g @persist-strategy-vim 'session'
set -g @persist-strategy-nvim 'session'
```

意思是保存会话时，把 vim/nvim 的运行状态也记录下来，恢复时尝试还原编辑现场。

恢复后有一个后置钩子重新编号窗口，避免恢复出 0 号窗口：

```tmux
set -g @persist-hook-post-restore-all 'tmux list-sessions ... tmux move-window -r ...'
```

### 私有覆盖

```tmux
if-shell '[ -f "$HOME/.config/tmux/private.conf" ]' {
  source-file "$HOME/.config/tmux/private.conf"
}
```

文件不存在时静默跳过。这样公开配置不包含私有内容，但允许本机追加。

### 为什么关掉 extended-keys

```tmux
set -g extended-keys off
```

Kitty 的 CSI-u 协议会把 `Ctrl+J` 编码成 `ESC [ 106 ; 5 u`。如果远端 shell 或粘贴工具不认识这个序列，它会作为可见文本泄漏到命令行。关掉之后，普通 Ctrl 和方向键仍用兼容编码。

## 三者如何配合

```text
Ghostty（终端窗口，负责字体与颜色）
  └── tmux（会话、分屏、持久化）
        └── zsh（Starship 提示符）
              └── nvim / 其它 TUI
```

真彩色需要 Ghostty 支持、tmux 传递、应用声明三层都成立。任何一层缺失，颜色会退化成 256 色近似值。
