> 摘要：tmux-persist 手动保存会话并在需要时恢复，能连带保存 vim/Neovim 的编辑现场。

# tmux-persist

## 用途

tmux 本身没有会话持久化：关闭 tmux 或重启机器，所有 window、pane 布局、运行中的程序都没了。

`tmux-persist` 提供手动保存/恢复：把当前 tmux 的完整状态写入磁盘，需要时再读回来。它还能记住每个 pane 里跑的是 vim 还是 Neovim，并尝试恢复编辑现场。

与 continuum 的区别：persist 是**手动**，continuum 是**自动**。两者通常一起用。

## 加载方式

```tmux
set -g @plugin 'hyoretsu/tmux-persist'

set -g @persist-strategy-vim 'session'
set -g @persist-strategy-nvim 'session'

set -g @persist-hook-post-restore-all 'tmux list-sessions 2>/dev/null | cut -d: -f1 | while read -r s; do tmux move-window -r -t "$s:" 2>/dev/null || true; done'
```

## 快捷键

| 键 | 作用 |
|---|---|
| `Prefix + Ctrl+s` | 保存 |
| `Prefix + Ctrl+r` | 恢复 |

注意是**大写** S 和 R，即要按 `Ctrl+Shift+s`。

## 恢复策略

```tmux
set -g @persist-strategy-vim 'session'
set -g @persist-strategy-nvim 'session'
```

`session` 策略的含义：保存时记录该 pane 里 vim/Neovim 的 session 文件位置，恢复时重新打开 vim 并 source 该 session。

| 策略 | 行为 |
|---|---|
| `session` | 用 vim/Neovim 的 `:mksession` 机制恢复 |
| `simple` | 只重新运行 vim，不恢复 session |
| 不设 | 只重启命令，不管编辑器状态 |

本仓库选 `session`，这样恢复后缓冲区分屏、光标位置都在。

## 恢复后重编号

```tmux
set -g @persist-hook-post-restore-all 'tmux list-sessions ... tmux move-window -r ...'
```

为什么需要这个：persist 恢复时按保存时的索引重建窗口。如果 `base-index` 是 1 但恢复出 0 号窗口，编号就和平时不一致了。

这个钩子在恢复完成后遍历所有 session，调用 `tmux move-window -r` 统一重编号。

## 保存的内容

| 内容 | 是否保存 |
|---|---|
| session / window / pane 结构 | 是 |
| 每个 pane 的当前目录 | 是 |
| 每个 pane 运行的命令 | 是 |
| pane 布局（分屏比例） | 是 |
| vim/Neovim 的编辑现场 | 是（`session` 策略） |
| 普通程序的内部状态 | 否 |

最后一条是限制：一个跑着 `top` 的 pane 恢复后是新的 `top`，不是原来的滚动位置。

## 与 continuum 的分工

| | persist | continuum |
|---|---|---|
| 触发 | 手动 `Prefix + Ctrl+s` | 定时自动 |
| 恢复 | 手动 `Prefix + Ctrl+r` | 可选开机自动 |
| 适合 | 明确知道要保存的时刻 | 日常无感知保护 |

continuum 内部依赖 persist 的能力，所以两个都要装。

## 排错

**`Prefix + Ctrl+s` 没反应**：persist 没加载。检查 `ls ~/.config/tmux/plugins/tmux-persist/`。

**恢复后窗口编号从 0 开始**：后置钩子没执行。检查 `@persist-hook-post-restore-all` 是否被正确设置。

**vim 恢复后是空的**：`session` 策略需要 vim/Neovim 支持 `:mksession`。检查 Neovim 是否配置了 session 保存（本仓库的 auto-session 插件做这件事）。

**保存很慢**：pane 多、每个都要查询状态。通常几秒内完成，超过 30 秒说明有异常。

**恢复后程序没了**：正常，普通程序不保存内部状态。
