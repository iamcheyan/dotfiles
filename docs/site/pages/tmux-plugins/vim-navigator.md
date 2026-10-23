> 摘要：vim-tmux-navigator 让 Ctrl+h/j/k/l 在 Neovim 分屏和 tmux pane 之间无缝移动。

# vim-tmux-navigator

## 用途

没有它时有两个独立的世界：

- Neovim 里用 `Ctrl+w h` 在分屏间移动
- tmux 里用 `Prefix + 方向键` 在 pane 间移动

在 Neovim 分屏边缘想移到旁边的 tmux pane，需要先退出 Neovim 的思维，按 tmux 的键。

装上之后，`Ctrl+h` 会智能判断：如果在 Neovim 分屏边缘，就交给 tmux；否则在 Neovim 内移动。

## 加载方式

```tmux
set -g @plugin 'christoomey/vim-tmux-navigator'
```

**两端都要装**：

| 端 | 需要什么 |
|---|---|
| tmux | 本插件 |
| Neovim | `christoomey/vim-tmux-navigator` 的 Neovim 部分 |

本仓库的 Neovim 配置已包含对应的插件，所以只需在 tmux 侧声明即可。

## 默认键位

| 键 | 方向 |
|---|---|
| `Ctrl+h` | 左 |
| `Ctrl+j` | 下 |
| `Ctrl+k` | 上 |
| `Ctrl+l` | 右 |
| `Ctrl+\` | 上一个 pane |

不需要 `Prefix`，直接按。

## 判断逻辑

```text
按 Ctrl+h
├── 当前 pane 是 Neovim？
│     ├── 是 → 在 Neovim 内部向左移动
│     │         └── 已经在最左边？ → 转发给 tmux
│     └── 否 → tmux 向左移动 pane
```

判断依据：tmux 检查当前 pane 运行的程序名，以及 Neovim 是否处于特定状态（比如命令行模式、终端模式）。

## 与 Neovim 终端模式的冲突

在 Neovim 的内置终端（`:terminal`）里，`Ctrl+h` 可能被终端程序占用。插件会检测这个状态，不转发给 tmux。

如果你在 Neovim 终端里跑 tmux（嵌套），行为会复杂。通常不建议嵌套。

## 常见问题：Ctrl+h 被当成退格

某些终端把 `Ctrl+h` 映射成 Backspace（历史上如此）。这会让 `Ctrl+h` 在 Neovim 里删除字符而不是左移。

解决：在终端配置里明确发送正确的序列，或在 Neovim 里重映射。

## 自定义键位

不想用 `Ctrl+h/j/k/l`：

```tmux
# 在 private.conf 里覆盖
bind -n C-Left select-pane -L
```

或者在 Neovim 侧改映射（见 Neovim 配置的 keymaps）。

## 排错

**`Ctrl+h` 没反应**：插件没加载，或 Neovim 侧的插件没装。两端都要有。

**在 Neovim 里删除了字符**：终端把 `Ctrl+h` 当退格。检查终端的键位设置。

**只能在一端移动，跨不到另一端**：Neovim 侧的插件没生效。在 Neovim 里检查：

```vim
:map <C-h>
```

**和某个 Neovim 插件冲突**：比如某个插件也绑了 `Ctrl+h`。检查谁后加载。

**tmux 嵌套时行为异常**：避免嵌套，或在内层 tmux 改 prefix 和键位。

**在 fzf 弹窗里方向错乱**：fzf 自己处理按键，不受 navigator 影响。属预期。
