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

<!-- lang:en -->

> Summary: tmux-continuum saves sessions automatically on a schedule and can restore them automatically when tmux starts.

# tmux-continuum

## Purpose

`tmux-persist` requires manual saving. `tmux-continuum` adds automation on top of it:

- Saves automatically at regular intervals
- Optionally restores the last session when tmux starts
- Shows the save status in the status bar

Its goal is "never having to remember to save".

## How it is loaded

```tmux
set -g @plugin 'tmux-plugins/tmux-continuum'
```

This repository does not set any options for it; everything uses the defaults.

## Default behavior

| Behavior | Default | Description |
|---|---|---|
| Auto-save interval | 15 minutes | `@continuum-save-interval` |
| Auto-restore | **Off** | `@continuum-restore` |
| Status bar indicator | Shown | `@continuum-status` |
| Start tmux at boot | Off | `@continuum-boot` |

**Auto-restore is off by default**. This means that once continuum is installed, it saves, but it will not automatically read your old sessions back when you start tmux.

## Common options

```tmux
set -g @continuum-save-interval '15'        # 保存间隔（分钟）
set -g @continuum-restore 'on'              # 启动 tmux 时自动恢复
set -g @continuum-boot 'on'                 # 开机自动启动 tmux（需额外配置）
set -g @continuum-status 'off'              # 关闭状态栏提示
```

This repository does not set these, so:

- Auto-save runs every 15 minutes
- No auto-restore
- The status bar shows the save status

## Enabling auto-restore

Add the following to `~/.config/tmux/private.conf` (or `private-after.conf`):

```tmux
set -g @continuum-restore 'on'
```

Then reload the config:

```bash
tmux source-file ~/.config/tmux/tmux.conf
```

**Note**: auto-restore will overwrite the blank session you just opened. If you prefer a clean tmux every time, do not enable this option.

## Relationship with persist

continuum relies on persist's saving capability:

```text
continuum（定时器）
    └── 调用 persist 的保存逻辑
          └── 写 ~/.tmux/resurrect/ 或类似目录
```

So both plugins must be installed. continuum alone does not work.

## Save file location

By default it goes to `~/.local/share/tmux/resurrect/` or a directory specified by the plugin. To check:

```bash
ls ~/.config/tmux/plugins/tmux-continuum/
tmux show -g @continuum-save-interval
```

## Status bar indicator

When enabled, the status bar shows the save status, for example:

```text
[saved 2 min ago]
```

If you don't need it, turn it off:

```tmux
set -g @continuum-status 'off'
```

## Troubleshooting

**Never auto-saves**: continuum is not loaded, or persist is not installed. Use `tmux show -g @plugin` to confirm both are present.

**Wrong save interval**: check `@continuum-save-interval`. The unit is minutes, not seconds.

**Old sessions come back when starting tmux**: `@continuum-restore` is set to on. To turn it off, set it explicitly to `off`.

**Status bar gets slow**: the status bar refresh checks the save status. A very small interval (e.g. 1 minute) adds overhead.

**Conflicts with auto-session (Neovim plugin)**: both try to restore the editing state. If duplicate buffers appear after restore, adjust auto-session's configuration on the Neovim side.

<!-- lang:ja -->

> 要約：tmux-continuum はセッションを定期的に自動保存し、tmux 起動時に自動的に復元することもできます。

# tmux-continuum

## 用途

`tmux-persist` は手動での保存が必要です。`tmux-continuum` はその上に自動化を追加します：

- 定期的に自動保存する
- 必要に応じて tmux 起動時に前回のセッションを自動復元する
- ステータスバーに保存状態を表示する

めざすところは「保存を覚えておかなくてよい」状態です。

## 読み込み方法

```tmux
set -g @plugin 'tmux-plugins/tmux-continuum'
```

本リポジトリではこのプラグインのオプションを一切設定しておらず、すべてデフォルト値を使います。

## デフォルトの動作

| 動作 | デフォルト値 | 説明 |
|---|---|---|
| 自動保存間隔 | 15 分 | `@continuum-save-interval` |
| 自動復元 | **オフ** | `@continuum-restore` |
| ステータスバー表示 | 表示 | `@continuum-status` |
| 起動時に tmux を開始 | オフ | `@continuum-boot` |

**自動復元はデフォルトでオフです**。つまり、continuum を導入すると保存は行われますが、tmux 起動時に古いセッションが自動的に読み戻されることはありません。

## よく使う設定項目

```tmux
set -g @continuum-save-interval '15'        # 保存间隔（分钟）
set -g @continuum-restore 'on'              # 启动 tmux 时自动恢复
set -g @continuum-boot 'on'                 # 开机自动启动 tmux（需额外配置）
set -g @continuum-status 'off'              # 关闭状态栏提示
```

本リポジトリではこれらを設定していないため：

- 15 分ごとに自動保存される
- 自動復元されない
- ステータスバーに保存状態が表示される

## 自動復元を有効にするには

`~/.config/tmux/private.conf`（または `private-after.conf`）に以下を追加します：

```tmux
set -g @continuum-restore 'on'
```

その後、設定を再読み込みします：

```bash
tmux source-file ~/.config/tmux/tmux.conf
```

**注意**：自動復元は新しく開いた空のセッションを上書きします。毎回クリーンな tmux で作業したい場合は、このオプションを有効にしないでください。

## persist との関係

continuum は persist の保存機能に依存しています：

```text
continuum（定时器）
    └── 调用 persist 的保存逻辑
          └── 写 ~/.tmux/resurrect/ 或类似目录
```

したがって両方のプラグインをインストールする必要があります。continuum だけでは動作しません。

## 保存ファイルの場所

デフォルトは `~/.local/share/tmux/resurrect/` またはプラグインが指定するディレクトリです。確認方法：

```bash
ls ~/.config/tmux/plugins/tmux-continuum/
tmux show -g @continuum-save-interval
```

## ステータスバー表示

有効にするとステータスバーに保存状態が表示されます。例：

```text
[saved 2 min ago]
```

不要な場合はオフにできます：

```tmux
set -g @continuum-status 'off'
```

## トラブルシュート

**自動保存が一度も行われない**：continuum が読み込まれていないか、persist が未導入です。`tmux show -g @plugin` で両方あることを確認します。

**保存間隔がおかしい**：`@continuum-save-interval` を確認します。単位は秒ではなく分です。

**tmux 起動時に古いセッションが戻ってくる**：`@continuum-restore` が on になっています。オフにしたい場合は明示的に `off` を設定します。

**ステータスバーが遅くなる**：ステータスバーの更新時に保存状態を確認します。間隔を極端に短く（たとえば 1 分）するとオーバーヘッドが出ます。

**auto-session（Neovim プラグイン）との競合**：両者が編集状態の復元を試みます。復元後にバッファが重複する場合は、Neovim 側で auto-session の設定を調整します。
