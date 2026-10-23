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

<!-- lang:en -->

> Summary: tmux-persist manually saves sessions and restores them when needed, and can also preserve the vim/Neovim editing state.

# tmux-persist

## Purpose

tmux itself has no session persistence: close tmux or reboot the machine and every window, pane layout, and running program is gone.

`tmux-persist` provides manual save/restore: it writes the complete state of the current tmux to disk and reads it back when needed. It can also remember whether vim or Neovim was running in each pane, and try to restore the editing state.

The difference from continuum: persist is **manual**, continuum is **automatic**. They are usually used together.

## How it is loaded

```tmux
set -g @plugin 'hyoretsu/tmux-persist'

set -g @persist-strategy-vim 'session'
set -g @persist-strategy-nvim 'session'

set -g @persist-hook-post-restore-all 'tmux list-sessions 2>/dev/null | cut -d: -f1 | while read -r s; do tmux move-window -r -t "$s:" 2>/dev/null || true; done'
```

## Keybindings

| Key | Effect |
|---|---|
| `Prefix + Ctrl+s` | Save |
| `Prefix + Ctrl+r` | Restore |

Note that these are **capital** S and R, i.e. you press `Ctrl+Shift+s`.

## Restore strategy

```tmux
set -g @persist-strategy-vim 'session'
set -g @persist-strategy-nvim 'session'
```

The `session` strategy means: on save, record the location of the vim/Neovim session file for that pane; on restore, reopen vim and source that session.

| Strategy | Behavior |
|---|---|
| `session` | Restores using vim/Neovim's `:mksession` mechanism |
| `simple` | Only reruns vim, without restoring the session |
| Unset | Only restarts the command, ignoring editor state |

This repository chooses `session`, so after restoring, the buffer splits and cursor positions are all there.

## Renumbering after restore

```tmux
set -g @persist-hook-post-restore-all 'tmux list-sessions ... tmux move-window -r ...'
```

Why this is needed: persist rebuilds windows using the indexes they had at save time. If `base-index` is 1 but a window numbered 0 is restored, the numbering is inconsistent with normal.

This hook iterates over all sessions after the restore completes and calls `tmux move-window -r` to renumber them uniformly.

## What gets saved

| Content | Saved? |
|---|---|
| session / window / pane structure | Yes |
| Current directory of each pane | Yes |
| Command running in each pane | Yes |
| Pane layout (split ratios) | Yes |
| vim/Neovim editing state | Yes (`session` strategy) |
| Internal state of ordinary programs | No |

The last line is a limitation: a pane running `top` comes back as a fresh `top`, not the original scroll position.

## Division of labor with continuum

| | persist | continuum |
|---|---|---|
| Trigger | Manual `Prefix + Ctrl+s` | Scheduled, automatic |
| Restore | Manual `Prefix + Ctrl+r` | Optionally automatic at boot |
| Suited for | Moments when you know you want to save | Everyday, unobtrusive protection |

continuum depends on persist's capability internally, so both must be installed.

## Troubleshooting

**`Prefix + Ctrl+s` does nothing**: persist is not loaded. Check `ls ~/.config/tmux/plugins/tmux-persist/`.

**Window numbering starts at 0 after restore**: the post hook did not run. Check whether `@persist-hook-post-restore-all` is set correctly.

**vim is empty after restore**: the `session` strategy requires vim/Neovim to support `:mksession`. Check whether Neovim is configured for session saving (the auto-session plugin in this repository does this).

**Saving is slow**: many panes each need to be queried. It usually finishes within a few seconds; over 30 seconds indicates something is wrong.

**Programs are gone after restore**: this is normal; ordinary programs do not save their internal state.

<!-- lang:ja -->

> 要約：tmux-persist はセッションを手動で保存し、必要なときに復元します。vim/Neovim の編集状態も一緒に保存できます。

# tmux-persist

## 用途

tmux 自体にはセッションの永続化機能がありません：tmux を閉じたりマシンを再起動すると、すべての window・pane レイアウト・実行中のプログラムは消えてしまいます。

`tmux-persist` は手動の保存/復元を提供します：現在の tmux の完全な状態をディスクに書き出し、必要なときに読み戻します。さらに、各 pane で vim か Neovim のどちらが動いていたかを覚えており、編集状態の復元を試みます。

continuum との違いは、persist が**手動**、continuum が**自動**である点です。通常は両方を併用します。

## 読み込み方法

```tmux
set -g @plugin 'hyoretsu/tmux-persist'

set -g @persist-strategy-vim 'session'
set -g @persist-strategy-nvim 'session'

set -g @persist-hook-post-restore-all 'tmux list-sessions 2>/dev/null | cut -d: -f1 | while read -r s; do tmux move-window -r -t "$s:" 2>/dev/null || true; done'
```

## キーバインド

| キー | 役割 |
|---|---|
| `Prefix + Ctrl+s` | 保存 |
| `Prefix + Ctrl+r` | 復元 |

**大文字**の S と R である点、つまり `Ctrl+Shift+s` を押すことに注意してください。

## 復元ストラテジー

```tmux
set -g @persist-strategy-vim 'session'
set -g @persist-strategy-nvim 'session'
```

`session` ストラテジーの意味：保存時にその pane の vim/Neovim の session ファイルの場所を記録し、復元時に vim を開き直してその session を source します。

| ストラテジー | 動作 |
|---|---|
| `session` | vim/Neovim の `:mksession` 仕組みを使って復元する |
| `simple` | vim を再実行するだけで session は復元しない |
| 未設定 | コマンドを再起動するだけでエディタの状態は扱わない |

本リポジトリは `session` を選んでおり、復元後もバッファの分割やカーソル位置が保たれます。

## 復元後のリナンバリング

```tmux
set -g @persist-hook-post-restore-all 'tmux list-sessions ... tmux move-window -r ...'
```

なぜ必要か：persist は保存時のインデックスに従ってウィンドウを再構築します。`base-index` が 1 なのに 0 番のウィンドウが復元されると、番号が普段と一致しなくなります。

このフックは復元完了後にすべての session を走査し、`tmux move-window -r` を呼んで番号を統一します。

## 保存される内容

| 内容 | 保存されるか |
|---|---|
| session / window / pane 構造 | はい |
| 各 pane のカレントディレクトリ | はい |
| 各 pane で実行中のコマンド | はい |
| pane レイアウト（分割比率） | はい |
| vim/Neovim の編集状態 | はい（`session` ストラテジー） |
| 一般プログラムの内部状態 | いいえ |

最後の行が制限です：`top` を実行していた pane は復元後も新しい `top` で、元のスクロール位置ではありません。

## continuum との役割分担

| | persist | continuum |
|---|---|---|
| トリガー | 手動 `Prefix + Ctrl+s` | 定時で自動 |
| 復元 | 手動 `Prefix + Ctrl+r` | 必要に応じて起動時に自動 |
| 向いている場面 | 保存したい瞬間が明確なとき | 日常の意識しない保護 |

continuum は内部で persist の機能に依存するため、両方をインストールする必要があります。

## トラブルシュート

**`Prefix + Ctrl+s` が反応しない**：persist が読み込まれていません。`ls ~/.config/tmux/plugins/tmux-persist/` を確認します。

**復元後にウィンドウ番号が 0 から始まる**：ポストフックが実行されていません。`@persist-hook-post-restore-all` が正しく設定されているか確認します。

**復元後に vim が空**：`session` ストラテジーには vim/Neovim の `:mksession` 対応が必要です。Neovim に session 保存の設定があるか確認します（本リポジトリの auto-session プラグインがそれを行います）。

**保存が遅い**：pane が多く、それぞれ状態を問い合わせる必要があります。通常は数秒で完了し、30 秒を超える場合は異常です。

**復元後にプログラムがない**：正常です。一般のプログラムは内部状態を保存しません。
