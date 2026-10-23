> 摘要：tmux-continuum 定时自动保存会话，并可在 tmux 启动时自动恢复。

# tmux-continuum

## 用途

`tmux-persist` 需要手动保存。`tmux-continuum` 在它之上加自动化：

- 每隔一段时间自动保存
- 可选在 tmux 启动时自动恢复上次的会话
- 状态栏显示保存状态

它的目标是"不用记得保存"。

## 加载方式

```tmux
set -g @plugin 'tmux-plugins/tmux-continuum'
```

本仓库没有为它设置任何选项，全部用默认值。

## 默认行为

| 行为 | 默认值 | 说明 |
|---|---|---|
| 自动保存间隔 | 15 分钟 | `@continuum-save-interval` |
| 自动恢复 | **关闭** | `@continuum-restore` |
| 状态栏提示 | 显示 | `@continuum-status` |
| 开机启动 tmux | 关闭 | `@continuum-boot` |

**自动恢复默认是关闭的**。这意味着装上 continuum 后，它会保存，但不会在你启动 tmux 时自动把旧会话读回来。

## 常用配置项

```tmux
set -g @continuum-save-interval '15'        # 保存间隔（分钟）
set -g @continuum-restore 'on'              # 启动 tmux 时自动恢复
set -g @continuum-boot 'on'                 # 开机自动启动 tmux（需额外配置）
set -g @continuum-status 'off'              # 关闭状态栏提示
```

本仓库没设这些，所以：

- 每 15 分钟自动保存一次
- 不会自动恢复
- 状态栏有保存状态提示

## 想开启自动恢复

在 `~/.config/tmux/private.conf`（或 `private-after.conf`）里加：

```tmux
set -g @continuum-restore 'on'
```

然后重载配置：

```bash
tmux source-file ~/.config/tmux/tmux.conf
```

**注意**：自动恢复会覆盖你当前新开的空白会话。如果你习惯每次开干净的 tmux，不要开这个选项。

## 与 persist 的关系

continuum 依赖 persist 的保存能力：

```text
continuum（定时器）
    └── 调用 persist 的保存逻辑
          └── 写 ~/.tmux/resurrect/ 或类似目录
```

所以两个插件都要装。只装 continuum 不工作。

## 保存文件位置

默认在 `~/.local/share/tmux/resurrect/` 或插件指定的目录。具体：

```bash
ls ~/.config/tmux/plugins/tmux-continuum/
tmux show -g @continuum-save-interval
```

## 状态栏提示

开启时状态栏会显示保存状态，比如：

```text
[saved 2 min ago]
```

不需要时可以关掉：

```tmux
set -g @continuum-status 'off'
```

## 排错

**从不自动保存**：continuum 没加载，或 persist 没装。`tmux show -g @plugin` 确认两个都在。

**保存间隔不对**：检查 `@continuum-save-interval`。单位是分钟，不是秒。

**启动 tmux 时旧会话回来了**：`@continuum-restore` 被设成了 on。想关掉就显式设成 `off`。

**状态栏变慢**：状态栏刷新会检查保存状态。间隔设太小（比如 1 分钟）会有开销。

**和 auto-session（Neovim 插件）冲突**：两者都尝试恢复编辑现场。如果恢复后出现重复缓冲区，在 Neovim 侧调整 auto-session 的配置。
