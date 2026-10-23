> 摘要：tmux-fzf 用 fzf 查找 session、window、pane、命令行等，并支持自定义菜单。

# tmux-fzf

## 用途

tmux 自带的 `Prefix + s`（session 列表）、`Prefix + w`（window 列表）是简单的文本菜单。`tmux-fzf` 把它们换成 fzf 界面：可模糊搜索、可预览、可多选操作。

它还提供更多对象：pane、命令行历史、剪贴板历史、进程等。

## 加载方式

```tmux
set -g @plugin 'sainnhe/tmux-fzf'
```

本仓库没有为它设置任何选项。

## 默认快捷键

| 键 | 作用 |
|---|---|
| `Prefix + F` | 打开主菜单（选择要操作什么） |
| 自定义 | 可以为每类对象单独绑定 |

`F` 是大写，即 `Ctrl+B` 然后 `Shift+f`。

## 能操作什么

| 对象 | 说明 |
|---|---|
| session | 切换、重命名、新建、删除 |
| window | 切换、移动、重命名、交换 |
| pane | 切换、交换、打断成 window |
| command | 浏览/执行 tmux 命令历史 |
| keybinding | 查找 tmux 键位 |
| clipboard | 浏览剪贴板历史 |
| process | 查看 pane 里运行的进程 |

选完对象后再选具体条目，然后选动作。

## 界面按键

| 键 | 作用 |
|---|---|
| 输入 | 模糊过滤 |
| `Tab` | 多选 |
| `Enter` | 确认 |
| `Esc` | 返回/退出 |

多级菜单：选对象 → 选条目 → 选动作，每级都可以 `Esc` 返回。

## 为某类对象单独绑定

不想每次都从主菜单进：

```tmux
bind-key -n C-s run-shell "~/.config/tmux/plugins/tmux-fzf/scripts/session.sh"
```

具体脚本名依版本而定：

```bash
ls ~/.config/tmux/plugins/tmux-fzf/scripts/
```

## 自定义菜单

tmux-fzf 支持通过配置定义自己的条目：

```tmux
set -g @tmux-fzf-custom "\
  edit config<=>tmux new-window -n config '\$EDITOR ~/.tmux.conf' \
  reload<=>tmux source-file ~/.tmux.conf"
```

`<=>` 分隔显示名和要执行的命令。

## 与 fzf 全局选项的关系

tmux-fzf 会读 `FZF_DEFAULT_OPTS`。本仓库设了：

```zsh
export FZF_DEFAULT_OPTS="--height 90% --layout=reverse --border --wrap --preview ..."
```

所以 tmux-fzf 的界面也有右侧预览和边框。

如果预览在 tmux 里显示异常，可以给 tmux-fzf 单独设：

```tmux
set -g @tmux-fzf-options '--height 60%'
```

## 排错

**`Prefix + F` 没反应**：插件没加载。`ls ~/.config/tmux/plugins/tmux-fzf/` 检查。

**菜单打开了但列表为空**：确实没有该类型的对象（比如没有其它 session）。

**预览区乱码**：`FZF_DEFAULT_OPTS` 里的预览命令在 tmux 环境下失败。用 `@tmux-fzf-options` 覆盖。

**按键被 tmux 占用**：`Prefix + F` 和某个已有绑定冲突。`tmux list-keys | grep F` 查看。

**fzf 版本太旧**：tmux-fzf 依赖较新的 fzf。`fzf --version` 确认在 0.30+。

**操作后状态栏没更新**：部分动作需要 `tmux refresh-client`。通常与 continuum 的状态栏提示叠加时出现，重载配置即可。
