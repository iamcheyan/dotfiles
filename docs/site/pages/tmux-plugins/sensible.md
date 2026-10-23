> 摘要：tmux-sensible 提供一组社区公认合理的默认选项，不改变行为只补默认值。

# tmux-sensible

## 用途

tmux 的某些历史默认值现在看并不合理（比如 history-limit 只有 2000 行、escape-time 偏长）。`tmux-sensible` 收集社区共识，把这些选项设成更合适的值。

它**不做任何花哨的事**：只是 `set -g` 一批选项。没有新键位，没有新命令。

## 加载方式

```tmux
set -g @plugin 'tmux-plugins/tmux-sensible'
```

第一个功能插件，在 TPM 之后声明，这样它设置的默认会被后面的插件覆盖（如果冲突）。

## 设置了什么

上游的设置项（版本不同可能微调）：

| 选项 | 值 | 为什么 |
|---|---|---|
| `history-limit` | 50000 | 默认 2000 太少 |
| `escape-time` | 0 | 消除 Vim 里 Esc 的延迟 |
| `base-index` | 1 | 窗口从 1 开始 |
| `pane-base-index` | 1 | pane 从 1 开始 |
| `renumber-windows` | on | 关闭窗口后不留空号 |
| `display-time` | 4000 | 提示信息显示时长 |
| `display-panes-time` | 2000 | pane 编号显示时长 |
| `repeat-time` | 1000 | 可重复按键的窗口 |
| `status-interval` | 5 | 状态栏刷新间隔 |
| `set-titles` | on | 设置终端标题 |
| `mouse` | on | 启用鼠标 |

## 与本仓库配置的关系

本仓库在 `tmux.conf` 里**重复设置**了其中几项：

```tmux
set -g mouse on
set -g base-index 1
setw -g pane-base-index 1
set -g renumber-windows on
set -g history-limit 200000
```

| 项 | sensible 设的 | 本仓库设的 | 结果 |
|---|---|---|---|
| mouse | on | on | 一致 |
| base-index | 1 | 1 | 一致 |
| renumber-windows | on | on | 一致 |
| history-limit | 50000 | 200000 | 本仓库更大，覆盖 |

重复设置不是错误：后面的覆盖前面的。而且即使不加 sensible 插件，这些选项自己也生效——这让配置在插件没装时也能工作。

## 为什么还需要它

即使本仓库显式设了一部分，sensible 仍提供其他没覆盖的项：

- `escape-time 0`（对 Vim 用户很重要）
- `display-time` / `display-panes-time`
- `repeat-time`
- `set-titles`
- `status-interval`

这些不设也能用，但设了体验更好。

## escape-time 为什么重要

tmux 收到 Esc 后会等待一小段时间，判断它是不是某个功能键序列的开头。默认是 500ms。

在 Vim 里按 Esc 退出插入模式时，这 500ms 会让退出感觉"卡顿"。设成 0 后立刻响应。

代价：某些终端的功能键序列可能被误判。但在现代终端里基本没问题。

## 排错

**Esc 在 Vim 里仍然延迟**：sensible 没加载，或被后面的 `set -g escape-time` 覆盖。

```bash
tmux show -g escape-time
```

**窗口编号从 0 开始**：`base-index` 被覆盖了。本仓库显式设了 1，检查 `tmux.conf` 是否被正确加载。

**鼠标不能选 pane**：`mouse on` 没生效。`tmux show -g mouse` 确认。

**想关掉某个 sensible 设置**：在自己的配置里重新 `set -g` 覆盖。sensible 在 TPM 之后、其它插件之前加载，所以后面的设置会覆盖它。

```tmux
# private.conf 里
set -g escape-time 50
```
