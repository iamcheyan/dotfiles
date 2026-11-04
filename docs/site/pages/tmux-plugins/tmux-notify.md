> 摘要：tmux-notify 监控后台分屏中的长耗时任务，在命令执行完毕回归空闲时发送通知。

# tmux-notify

## 用途

在某个分屏里启动了长时间的编译、测试或任务后，可以在该分屏按下监控快捷键，然后切去别的窗口继续工作。当该分屏的进程执行完毕时，`tmux-notify` 会通过 tmux 消息和桌面通知（`notify-send`）提醒你。

## 本仓库配置

`tmux-notify` 默认会占用 `Prefix + m` 与 `Prefix + M`，而 `Prefix + m` 是 tmux 原生非常常用的「标记分屏（`select-pane -m`）」。因此本仓库在 TPM 加载后恢复了 `m` / `M` 的原生绑定，并将通知监控绑定到 **`Prefix + N`** 与 **`Prefix + Alt+N`**：

```tmux
set -g @plugin 'rickstaa/tmux-notify'

# TPM 加载后恢复 m / M 标记分屏，将 tmux-notify 绑定到 N / M-N
bind m select-pane -m
bind M select-pane -M
unbind M-m
unbind C-m
unbind C-M-m
bind N run-shell -b "$HOME/.config/tmux/plugins/tmux-notify/scripts/notify.sh"
bind M-N run-shell -b "$HOME/.config/tmux/plugins/tmux-notify/scripts/cancel.sh"
```

## 快捷键

| 键 | 作用 |
|---|---|
| `Prefix + N` | 开始监控当前 pane，命令结束时发送通知 |
| `Prefix + Alt+N` | 取消当前 pane 的完成通知监控 |

<!-- lang:en -->

> Summary: tmux-notify monitors long-running commands in background panes and sends a notification when they finish.

# tmux-notify

## Purpose

When running a long build, test suite, or task in a pane, trigger `tmux-notify` on that pane and switch to another window. Once the command finishes, `tmux-notify` alerts you via tmux status messages and desktop notifications (`notify-send`).

## Configuration in this repository

By default, `tmux-notify` binds `Prefix + m` and `Prefix + M`, which conflicts with tmux's native `select-pane -m` (Mark Pane). After TPM initializes, this configuration restores `m` / `M` for marking panes and binds `tmux-notify` to **`Prefix + N`** and **`Prefix + Alt+N`**:

```tmux
set -g @plugin 'rickstaa/tmux-notify'

bind m select-pane -m
bind M select-pane -M
unbind M-m
unbind C-m
unbind C-M-m
bind N run-shell -b "$HOME/.config/tmux/plugins/tmux-notify/scripts/notify.sh"
bind M-N run-shell -b "$HOME/.config/tmux/plugins/tmux-notify/scripts/cancel.sh"
```

## Keybindings

| Key | Effect |
|---|---|
| `Prefix + N` | Monitor the current pane and notify when its active process finishes |
| `Prefix + Alt+N` | Cancel monitoring for the current pane |

<!-- lang:ja -->

> 要約：tmux-notify はバックグラウンド pane の長時間コマンドを監視し、完了時に通知を送ります。

# tmux-notify

## 用途

ビルドやテストなどの時間がかかる処理を pane で実行中に監視を開始しておくと、別のウィンドウで作業していても処理完了時に tmux メッセージとデスクトップ通知（`notify-send`）で知らせてくれます。

## 本リポジトリの設定

既定では `Prefix + m` / `M` が使われますが、tmux 標準の pane マーク機能（`select-pane -m`）と競合するため、TPM 読み込み後に `m` / `M` を復元し、`tmux-notify` は **`Prefix + N`** と **`Prefix + Alt+N`** に割り当てています。

## キーバインド

| キー | 役割 |
|---|---|
| `Prefix + N` | 現在の pane の監視を開始（完了時に通知） |
| `Prefix + Alt+N` | 現在の pane の監視をキャンセル |
