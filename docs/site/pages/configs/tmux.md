> 摘要：tmux.conf 的选项分组、键位、TPM 插件和会话恢复策略。

# tmux 配置

## 文件位置

| 项目 | 路径 |
|---|---|
| 仓库源文件 | `config/tmux/tmux.conf` |
| 部署目标 | `~/.config/tmux/tmux.conf` |
| 是否自动链接 | 是 |

## 终端能力

```tmux
set -g default-terminal "tmux-256color"
set -as terminal-features ",*:RGB"
set -as terminal-overrides ",*:Tc"
set -g status-style "bg=#00aaaa,fg=#000000"
```

| 行 | 作用 |
|---|---|
| `default-terminal` | 声明 tmux 使用 256 色 terminfo |
| `terminal-features` | 告诉应用支持 RGB |
| `terminal-overrides` | 覆盖终端能力检测 |
| `status-style` | 状态栏青底黑字，与 Neovim Blue 的状态区一致 |

三行真彩色配置缺一不可。只有 `default-terminal` 时，Neovim 的 `termguicolors` 可能不生效。

## 鼠标与键位

```tmux
set -g mouse on
setw -g mode-keys vi
```

`mouse on` 让鼠标可以选 pane、拖边框、滚动。`mode-keys vi` 让 copy mode 用 `hjkl`。

## 编号

```tmux
set -g base-index 1
setw -g pane-base-index 1
set -g renumber-windows on
```

从 1 开始编号，关闭窗口后不留空号。

`base-index` 只影响新窗口。会话恢复后可能仍是 0，所以有这段：

```tmux
run-shell 'tmux list-sessions 2>/dev/null | cut -d: -f1 | while read -r s; do tmux move-window -r -t "$s:" 2>/dev/null || true; done'
```

重载配置时统一重编号。

## 历史与焦点

```tmux
set -g history-limit 200000
set -g focus-events on
set -g allow-passthrough on
```

| 选项 | 作用 |
|---|---|
| `history-limit 200000` | 回滚缓冲 20 万行 |
| `focus-events on` | 让 Neovim 感知焦点变化（autoread、自动保存） |
| `allow-passthrough on` | 允许 Kitty 图形协议和 OSC 52 穿过 tmux |

## 环境变量传递

```tmux
set -ga update-environment "SSH_CLIENT SSH_CONNECTION SSH_TTY"
```

新 pane 会继承这些变量，用于判断是否在 SSH 会话中。

## 窗口

```tmux
bind c new-window -c "#{pane_current_path}"
set -g automatic-rename-format '#{b:pane_current_path}'
```

`bind c` 让新窗口继承当前 pane 的目录，而不是从 home 开始。`automatic-rename-format` 用目录名做窗口名。

## 边框

```tmux
set -g pane-border-style fg=#000080
set -g pane-active-border-style fg=#55ffff
```

非活动边框用深蓝，活动边框用青色，和 Neovim Blue 的分隔线一致。

## 关闭 extended-keys

```tmux
set -g extended-keys off
```

**原因**：Kitty 的 CSI-u 协议会把 `Ctrl+J` 编码成 `ESC [ 106 ; 5 u`。远端 shell 或粘贴工具不认识时，序列会作为可见文本泄漏到命令行。

关掉后普通 Ctrl 和方向键仍用兼容编码。

## pane 调整

```tmux
bind -r H resize-pane -L 5
bind -r J resize-pane -D 5
bind -r K resize-pane -U 5
bind -r L resize-pane -R 5
```

`-r` 表示可重复：按住不放会连续调整，每次 5 格。

## 结束会话

```tmux
bind X confirm-before -p "kill-session #S? (y/n)" kill-session
```

大写 `X` 结束整个 session，带确认。小写 `x` 是 tmux 默认的「结束 pane」。

## TPM 插件

```tmux
run-shell 'tmux set-environment -g TMUX_PLUGIN_MANAGER_PATH "$HOME/.config/tmux/plugins/"'

set -g @plugin 'tmux-plugins/tpm'
set -g @plugin 'tmux-plugins/tmux-sensible'
set -g @plugin 'hyoretsu/tmux-persist'
set -g @plugin 'tmux-plugins/tmux-continuum'
set -g @plugin 'tmux-plugins/tmux-yank'
set -g @plugin 'christoomey/vim-tmux-navigator'
set -g @plugin 'sainnhe/tmux-fzf'

run '~/.config/tmux/plugins/tpm/tpm'
```

| 插件 | 作用 |
|---|---|
| tpm | 插件管理器 |
| tmux-sensible | 公认合理的默认值 |
| tmux-persist | 保存/恢复会话 |
| tmux-continuum | 自动保存与恢复 |
| tmux-yank | 复制到系统剪贴板 |
| vim-tmux-navigator | `Ctrl+h/j/k/l` 跨 Neovim/tmux |
| tmux-fzf | fzf 选择 session/window/pane |

首次安装：`Prefix + I`。更新：`Prefix + U`。

## 会话恢复

```tmux
set -g @persist-strategy-vim 'session'
set -g @persist-strategy-nvim 'session'
```

保存时记录 vim/nvim 的运行状态，恢复时尝试还原编辑现场。

恢复后重新编号：

```tmux
set -g @persist-hook-post-restore-all 'tmux list-sessions 2>/dev/null | cut -d: -f1 | while read -r s; do tmux move-window -r -t "$s:" 2>/dev/null || true; done'
```

## 私有覆盖

```tmux
if-shell '[ -f "$HOME/.config/tmux/private.conf" ]' {
  source-file "$HOME/.config/tmux/private.conf"
}

if-shell '[ -f "$HOME/.config/tmux/private-after.conf" ]' \
  'source-file "$HOME/.config/tmux/private-after.conf"'
```

两个接入点：

| 文件 | 时机 |
|---|---|
| `private.conf` | 在插件声明之前，可覆盖前面的选项 |
| `private-after.conf` | 在所有配置之后，可覆盖包括插件设置 |

文件不存在时静默跳过。

## 常用命令

```bash
tmux source-file ~/.config/tmux/tmux.conf    # 重载
tmux list-keys                                # 所有绑定
tmux list-keys | grep -w X                    # 查某个键
tmux show -g                                  # 所有全局选项
tmux show -g default-terminal                 # 查单个
```

## 排错

**颜色不对**：三层检查 `echo $TERM`、`tmux show -g default-terminal`、`tmux show -g terminal-features`。

**插件没装**：`Prefix + I`。检查 `~/.config/tmux/plugins/`。

**`Ctrl+h/j/k/l` 不切 pane**：vim-tmux-navigator 需要 Neovim 侧配合。Neovim 配置已含。

**窗口编号从 0 开始**：后置钩子没执行。手动 `tmux move-window -r`。

**`Prefix + X` 无反应**：可能被插件覆盖。`tmux list-keys | grep -w X` 查看。

**中文宽度错乱**：`tmux-256color` 的 terminfo 不完整。`infocmp tmux-256color` 检查。

**粘贴内容错乱**：`extended-keys off` 已处理大部分情况。仍有问题时检查终端的 bracketed paste 设置。
