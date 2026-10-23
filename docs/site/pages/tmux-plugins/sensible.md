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

<!-- lang:en -->

> Summary: tmux-sensible provides a set of community-accepted sensible default options; it changes no behavior beyond filling in defaults.

# tmux-sensible

## Purpose

Some of tmux's historical defaults look unreasonable today (for example, history-limit of only 2000 lines, or an overly long escape-time). `tmux-sensible` collects community consensus and sets these options to more appropriate values.

It **does nothing fancy**: it just `set -g`s a batch of options. No new keybindings, no new commands.

## How it is loaded

```tmux
set -g @plugin 'tmux-plugins/tmux-sensible'
```

It is the first feature plugin, declared right after TPM, so the defaults it sets get overridden by later plugins (in case of conflicts).

## What it sets

The upstream settings (may vary slightly between versions):

| Option | Value | Why |
|---|---|---|
| `history-limit` | 50000 | The default 2000 is too small |
| `escape-time` | 0 | Removes Esc delay in Vim |
| `base-index` | 1 | Windows start at 1 |
| `pane-base-index` | 1 | Panes start at 1 |
| `renumber-windows` | on | No gaps left after closing a window |
| `display-time` | 4000 | How long messages are shown |
| `display-panes-time` | 2000 | How long pane numbers are shown |
| `repeat-time` | 1000 | Window for repeatable key presses |
| `status-interval` | 5 | Status bar refresh interval |
| `set-titles` | on | Sets the terminal title |
| `mouse` | on | Enables the mouse |

## Relationship with this repository's config

This repository **re-sets** several of these options in `tmux.conf`:

```tmux
set -g mouse on
set -g base-index 1
setw -g pane-base-index 1
set -g renumber-windows on
set -g history-limit 200000
```

| Option | sensible sets | This repo sets | Result |
|---|---|---|---|
| mouse | on | on | Same |
| base-index | 1 | 1 | Same |
| renumber-windows | on | on | Same |
| history-limit | 50000 | 200000 | This repo's is larger and wins |

Setting something twice is not an error: the later one overrides the earlier. And even without the sensible plugin, these options take effect on their own — so the config works even when the plugin isn't installed.

## Why it is still needed

Even though this repository explicitly sets some of them, sensible still provides the options it doesn't cover:

- `escape-time 0` (important for Vim users)
- `display-time` / `display-panes-time`
- `repeat-time`
- `set-titles`
- `status-interval`

The config is usable without them, but setting them makes the experience better.

## Why escape-time matters

After receiving Esc, tmux waits briefly to judge whether it is the start of some function key sequence. The default is 500ms.

Pressing Esc in Vim to leave insert mode, those 500ms make exiting feel "laggy". Setting it to 0 makes it respond immediately.

The cost: some terminals' function key sequences may be misdetected. But on modern terminals this is rarely a problem.

## Troubleshooting

**Esc is still delayed in Vim**: sensible is not loaded, or was overridden by a later `set -g escape-time`.

```bash
tmux show -g escape-time
```

**Window numbering starts at 0**: `base-index` was overridden. This repository explicitly sets 1; check that `tmux.conf` is loaded correctly.

**Cannot select panes with the mouse**: `mouse on` did not take effect. Confirm with `tmux show -g mouse`.

**Want to disable one of sensible's settings**: re-`set -g` it in your own config to override. sensible loads after TPM and before the other plugins, so later settings override it.

```tmux
# private.conf 里
set -g escape-time 50
```

<!-- lang:ja -->

> 要約：tmux-sensible はコミュニティの合意による妥当なデフォルトオプションを提供します。デフォルト値を補う以外に動作を変えません。

# tmux-sensible

## 用途

tmux の歴史的なデフォルト値には、今見ると妥当でないものがあります（たとえば history-limit が 2000 行しかない、escape-time が長すぎるなど）。`tmux-sensible` はコミュニティの合意を集め、これらのオプションをより適切な値に設定します。

派手なことは**何もしません**：`set -g` でオプションを一括設定するだけです。新しいキーバインドも新コマンドもありません。

## 読み込み方法

```tmux
set -g @plugin 'tmux-plugins/tmux-sensible'
```

最初の機能プラグインで、TPM の直後に宣言します。こうすることで、競合があった場合に後続のプラグインがこのデフォルトを上書きできます。

## 設定される内容

上流の設定項目（バージョンにより微妙に異なることがあります）：

| オプション | 値 | 理由 |
|---|---|---|
| `history-limit` | 50000 | デフォルトの 2000 は少なすぎる |
| `escape-time` | 0 | Vim での Esc 遅延をなくす |
| `base-index` | 1 | ウィンドウを 1 から始める |
| `pane-base-index` | 1 | pane を 1 から始める |
| `renumber-windows` | on | ウィンドウを閉じた後に番号を空けない |
| `display-time` | 4000 | メッセージの表示時間 |
| `display-panes-time` | 2000 | pane 番号の表示時間 |
| `repeat-time` | 1000 | 連続押下が有効な時間 |
| `status-interval` | 5 | ステータスバーの更新間隔 |
| `set-titles` | on | ターミナルのタイトルを設定 |
| `mouse` | on | マウスを有効化 |

## 本リポジトリの設定との関係

本リポジトリは `tmux.conf` でそのうちのいくつかを**重ねて設定**しています：

```tmux
set -g mouse on
set -g base-index 1
setw -g pane-base-index 1
set -g renumber-windows on
set -g history-limit 200000
```

| 項目 | sensible の設定 | 本リポジトリの設定 | 結果 |
|---|---|---|---|
| mouse | on | on | 一致 |
| base-index | 1 | 1 | 一致 |
| renumber-windows | on | on | 一致 |
| history-limit | 50000 | 200000 | 本リポジトリの方が大きく、そちらが有効 |

重ねて設定してもエラーではありません：後のものが前のものを上書きします。さらに、sensible プラグインがなくてもこれらのオプションは単独で効きます——そのため、プラグイン未導入でも設定が機能します。

## それでも必要な理由

本リポジトリが明示的に設定している項目以外にも、sensible は残りの項目を提供します：

- `escape-time 0`（Vim ユーザーには重要）
- `display-time` / `display-panes-time`
- `repeat-time`
- `set-titles`
- `status-interval`

設定しなくても使えますが、設定した方が体験が良くなります。

## escape-time が重要な理由

tmux は Esc を受け取ると、それが何らかのファンクションキーシーケンスの先頭かどうかを判断するため、短い時間待ちます。デフォルトは 500ms です。

Vim で Esc を押してインサートモードを抜けるとき、この 500ms のせいで抜けるのが「もたつく」ように感じます。0 に設定すると即座に反応します。

代償：一部のターミナルのファンクションキーシーケンスが誤判定される可能性があります。ただし現代のターミナルではまず問題になりません。

## トラブルシュート

**Vim で Esc が依然として遅い**：sensible が読み込まれていないか、後の `set -g escape-time` に上書きされています。

```bash
tmux show -g escape-time
```

**ウィンドウ番号が 0 から始まる**：`base-index` が上書きされています。本リポジトリは明示的に 1 を設定しているので、`tmux.conf` が正しく読み込まれているか確認します。

**マウスで pane を選べない**：`mouse on` が効いていません。`tmux show -g mouse` で確認します。

**sensible の設定の一部を無効化したい**：自分の設定で `set -g` し直して上書きします。sensible は TPM の後、他のプラグインより前に読み込まれるため、後の設定がそれを上書きします。

```tmux
# private.conf 里
set -g escape-time 50
```
