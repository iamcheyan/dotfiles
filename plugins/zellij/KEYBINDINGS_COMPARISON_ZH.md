# Zellij 默认键位学习手册

本文以 Zellij 官方默认键位为主，只补充你额外增加的键位。

当前结论：

- 你的 `zellij` 键位主体已经回到官方默认
- 以后以“官方默认”为基线学习即可
- 你之后的策略是：只增加键位，不修改默认键位

基准环境：

- Zellij 版本：`0.43.1`
- 默认配置来源：`zellij setup --dump-config`
- 当前配置文件：[`config/zellij/config.kdl`](${DOTFILES_DIR:-$HOME/dotfiles}/config/zellij/config.kdl)

官方文档：

- https://zellij.dev/documentation/keybindings
- https://zellij.dev/documentation/keybinding-presets
- https://zellij.dev/documentation/keybindings-possible-actions.html

## 核心思路

Zellij 的学习重点不是“背一堆散键位”，而是先记住 mode：

- `pane`：切 pane、开 pane、关 pane
- `move`：移动 pane 位置
- `resize`：调 pane 尺寸
- `tab`：切 tab、开 tab、关 tab
- `scroll`：滚动历史
- `search`：搜索 scrollback
- `session`：会话管理
- `tmux`：tmux 兼容模式

最重要的习惯是：

1. 先进入某个 mode
2. 在 mode 里用 `h/j/k/l` 或方向键做动作
3. 用 `Esc` 或 `Enter` 退回 `normal`

## 最先记住的 10 个键

1. `Ctrl+p`：进入 `pane` 模式
2. `Ctrl+h`：进入 `move` 模式
3. `Ctrl+n`：进入 `resize` 模式
4. `Ctrl+t`：进入 `tab` 模式
5. `Ctrl+s`：进入 `scroll` 模式
6. `Ctrl+o`：进入 `session` 模式
7. `Ctrl+b`：进入 `tmux` 模式
8. `Alt+h/j/k/l`：平时快速切 pane / tab 焦点
9. `Alt+n`：平时直接新建 pane
10. `Esc` / `Enter`：退出大多数 mode

## 全局共享键位

这些键在大多数 mode 下都能用。

| 快捷键 | 作用 |
|---|---|
| `Ctrl+g` | 进入 `locked` 模式 |
| `Ctrl+p` | 进入 `pane` 模式 |
| `Ctrl+n` | 进入 `resize` 模式 |
| `Ctrl+s` | 进入 `scroll` 模式 |
| `Ctrl+o` | 进入 `session` 模式 |
| `Ctrl+t` | 进入 `tab` 模式 |
| `Ctrl+h` | 进入 `move` 模式 |
| `Ctrl+b` | 进入 `tmux` 模式 |
| `Ctrl+q` | 退出 Zellij |
| `Enter` / `Esc` | 回到 `normal` |
| `Alt+n` | 直接新建 pane |
| `Alt+h` / `Alt+Left` | 焦点左移，必要时切 tab |
| `Alt+l` / `Alt+Right` | 焦点右移，必要时切 tab |
| `Alt+j` / `Alt+Down` | 焦点下移 |
| `Alt+k` / `Alt+Up` | 焦点上移 |
| `Alt+i` | tab 左移 |
| `Alt+o` | tab 右移 |
| `Alt+=` / `Alt++` | 增大尺寸 |
| `Alt+-` | 减小尺寸 |
| `Alt+[` | 上一个布局 |
| `Alt+]` | 下一个布局 |
| `Alt+f` | 切换浮动 pane |
| `Alt+p` | 切换 pane group |
| `Alt+Shift+p` | 切换 group marking |

## `pane` 模式

进入方式：`Ctrl+p`

| 快捷键 | 作用 |
|---|---|
| `Ctrl+p` | 退出 `pane` 模式 |
| `h/j/k/l` 或方向键 | 在 pane 之间移动焦点 |
| `n` | 新建 pane |
| `d` | 向下分 pane |
| `r` | 向右分 pane |
| `s` | 新建 stacked pane |
| `x` | 关闭当前 pane |
| `f` | 当前 pane 全屏 |
| `z` | 切换 pane frame |
| `w` | 切换浮动 pane 集合 |
| `e` | 浮动 / 嵌入切换 |
| `c` | 重命名 pane |
| `i` | pin 当前 pane |
| `p` | 切换焦点 |

## `move` 模式

进入方式：`Ctrl+h`

| 快捷键 | 作用 |
|---|---|
| `Ctrl+h` | 退出 `move` 模式 |
| `h/j/k/l` 或方向键 | 按方向移动当前 pane |
| `n` / `Tab` | 切换到下一种移动方式 |
| `p` | 反向移动 |

例子：把右边 pane 移到左边

1. 先聚焦右边 pane
2. 按 `Ctrl+h`
3. 按 `h`

## `resize` 模式

进入方式：`Ctrl+n`

| 快捷键 | 作用 |
|---|---|
| `Ctrl+n` | 退出 `resize` 模式 |
| `h/j/k/l` 或方向键 | 朝对应方向增大 |
| `H/J/K/L` | 朝对应方向减小 |
| `=` / `+` | 整体增大 |
| `-` | 整体减小 |

## `tab` 模式

进入方式：`Ctrl+t`

| 快捷键 | 作用 |
|---|---|
| `Ctrl+t` | 退出 `tab` 模式 |
| `h/k/Left/Up` | 上一个 tab |
| `l/j/Right/Down` | 下一个 tab |
| `n` | 新建 tab |
| `x` | 关闭 tab |
| `r` | 重命名 tab |
| `s` | tab 同步输入 |
| `b` | 把当前 pane 拆到新 tab |
| `[` | 把当前 pane 拆到左侧 tab |
| `]` | 把当前 pane 拆到右侧 tab |
| `1..9` | 跳到指定编号 tab |
| `Tab` | toggle tab |

## `scroll` 模式

进入方式：`Ctrl+s`

| 快捷键 | 作用 |
|---|---|
| `Ctrl+s` | 回到 `normal` |
| `Ctrl+c` | 滚到底并回到 `normal` |
| `e` | 用编辑器打开 scrollback |
| `s` | 进入搜索输入 |
| `j/k` 或方向键 | 向下 / 向上滚动 |
| `Ctrl+f` / `PageDown` / `l` / `Right` | 整页向下 |
| `Ctrl+b` / `PageUp` / `h` / `Left` | 整页向上 |
| `d` | 半页向下 |
| `u` | 半页向上 |
| `Esc` / `Enter` | 回到 `normal` |

## `search` 模式

| 快捷键 | 作用 |
|---|---|
| `n` | 下一个匹配 |
| `p` | 上一个匹配 |
| `c` | 大小写开关 |
| `w` | wrap 开关 |
| `o` | whole word 开关 |
| `j/k` 或方向键 | 滚动 |
| `Ctrl+f` / `PageDown` / `l` / `Right` | 整页向下 |
| `Ctrl+b` / `PageUp` / `h` / `Left` | 整页向上 |
| `d` | 半页向下 |
| `u` | 半页向上 |
| `Ctrl+s` / `Ctrl+c` / `Esc` / `Enter` | 退出或回到正常流程 |

## `session` 模式

进入方式：`Ctrl+o`

| 快捷键 | 作用 |
|---|---|
| `Ctrl+o` | 回到 `normal` |
| `d` | detach |
| `w` | 打开 session manager |
| `c` | 打开 configuration |
| `p` | 打开 plugin manager |
| `a` | 打开 about |
| `s` | 打开 share |

## `tmux` 模式

进入方式：`Ctrl+b`

| 快捷键 | 作用 |
|---|---|
| `[` | 进入 scroll |
| `Ctrl+b` | 发送前缀本身 |
| `"` | 向下分 pane |
| `%` | 向右分 pane |
| `z` | 当前 pane 全屏 |
| `c` | 新建 tab |
| `,` | 重命名 tab |
| `p` | 前一个 tab |
| `n` | 后一个 tab |
| `h/j/k/l` 或方向键 | 在 pane 之间移动焦点 |
| `o` | 切到下一个 pane |
| `d` | detach |
| `Space` | 切换下一个布局 |
| `x` | 关闭当前 pane |

## 重命名与搜索输入模式

### `renametab`

| 快捷键 | 作用 |
|---|---|
| `Ctrl+c` | 回到 `normal` |
| `Esc` | 取消并回到 `tab` |

### `renamepane`

| 快捷键 | 作用 |
|---|---|
| `Ctrl+c` | 回到 `normal` |
| `Esc` | 取消并回到 `pane` |

### `entersearch`

| 快捷键 | 作用 |
|---|---|
| `Ctrl+c` / `Esc` | 回到 `scroll` |
| `Enter` | 进入 `search` |

## 你额外增加的键位

下面这 3 个不是官方默认，是你在默认基础上额外加的：

| 位置 | 快捷键 | 作用 |
|---|---|---|
| 全局共享键位 | 无 `Ctrl+q` | 你移除了官方默认的退出键 |
| `tab` 模式 | `a` | 打开 `zellij-pane-picker` |
| `session` 模式 | `x` | 直接 `Quit` |

## 学习建议

你现在的学习方式可以很简单：

1. 把官方默认键位当成唯一主线
2. 最后只补记上面那 3 个额外键位

这样以后升级配置时也更稳，因为你不会再偏离官方默认太多。
