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

<!-- lang:en -->

> Summary: tmux-fzf uses fzf to find sessions, windows, panes, command history and more, with support for custom menus.

# tmux-fzf

## Purpose

tmux's built-in `Prefix + s` (session list) and `Prefix + w` (window list) are simple text menus. `tmux-fzf` replaces them with an fzf interface: fuzzy search, preview, and multi-select actions.

It also offers more objects: panes, command history, clipboard history, processes, and more.

## How it is loaded

```tmux
set -g @plugin 'sainnhe/tmux-fzf'
```

This repository does not set any options for it.

## Default keybinding

| Key | Effect |
|---|---|
| `Prefix + F` | Open the main menu (choose what to operate on) |
| Custom | You can bind each object type separately |

`F` is capital, i.e. `Ctrl+B` then `Shift+f`.

## What it can operate on

| Object | Description |
|---|---|
| session | Switch, rename, create, delete |
| window | Switch, move, rename, swap |
| pane | Switch, swap, break out into a window |
| command | Browse/run tmux command history |
| keybinding | Look up tmux keybindings |
| clipboard | Browse clipboard history |
| process | View processes running in panes |

After choosing the object, choose the entry, then choose the action.

## Keys in the interface

| Key | Effect |
|---|---|
| Typing | Fuzzy filter |
| `Tab` | Multi-select |
| `Enter` | Confirm |
| `Esc` | Back/exit |

Multi-level menus: object → entry → action, and each level supports `Esc` to go back.

## Binding a specific object type

If you don't want to go through the main menu every time:

```tmux
bind-key -n C-s run-shell "~/.config/tmux/plugins/tmux-fzf/scripts/session.sh"
```

The exact script names depend on the version:

```bash
ls ~/.config/tmux/plugins/tmux-fzf/scripts/
```

## Custom menus

tmux-fzf supports defining your own entries via configuration:

```tmux
set -g @tmux-fzf-custom "\
  edit config<=>tmux new-window -n config '\$EDITOR ~/.tmux.conf' \
  reload<=>tmux source-file ~/.tmux.conf"
```

`<=>` separates the display name from the command to run.

## Relationship with global fzf options

tmux-fzf reads `FZF_DEFAULT_OPTS`. This repository sets:

```zsh
export FZF_DEFAULT_OPTS="--height 90% --layout=reverse --border --wrap --preview ..."
```

So tmux-fzf's interface also gets the right-side preview and border.

If the preview misbehaves inside tmux, you can set options just for tmux-fzf:

```tmux
set -g @tmux-fzf-options '--height 60%'
```

## Troubleshooting

**`Prefix + F` does nothing**: the plugin is not loaded. Check with `ls ~/.config/tmux/plugins/tmux-fzf/`.

**The menu opens but the list is empty**: there really are no objects of that type (e.g. no other sessions).

**The preview pane is garbled**: the preview command in `FZF_DEFAULT_OPTS` fails in the tmux environment. Override it with `@tmux-fzf-options`.

**The key is taken by tmux**: `Prefix + F` conflicts with an existing binding. Check with `tmux list-keys | grep F`.

**fzf is too old**: tmux-fzf requires a reasonably new fzf. Confirm with `fzf --version` that it is 0.30+.

**The status bar doesn't update after an action**: some actions need `tmux refresh-client`. This usually shows up when combined with continuum's status bar indicator; reloading the config fixes it.

<!-- lang:ja -->

> 要約：tmux-fzf は fzf で session・window・pane・コマンド履歴などを探し、カスタムメニューにも対応します。

# tmux-fzf

## 用途

tmux 標準の `Prefix + s`（session 一覧）や `Prefix + w`（window 一覧）は単純なテキストメニューです。`tmux-fzf` はそれらを fzf のインターフェースに置き換えます：あいまい検索・プレビュー・複数選択での操作が可能です。

さらに多くの対象も扱えます：pane、コマンド履歴、クリップボード履歴、プロセスなど。

## 読み込み方法

```tmux
set -g @plugin 'sainnhe/tmux-fzf'
```

本リポジトリではこのプラグインのオプションは設定していません。

## デフォルトのキーバインド

| キー | 役割 |
|---|---|
| `Prefix + F` | メインメニューを開く（何を操作するか選ぶ） |
| カスタム | 対象ごとに個別にバインド可能 |

`F` は大文字で、`Ctrl+B` のあと `Shift+f` を押します。

## 操作できる対象

| 対象 | 説明 |
|---|---|
| session | 切り替え、リネーム、新規作成、削除 |
| window | 切り替え、移動、リネーム、入れ替え |
| pane | 切り替え、入れ替え、window への切り出し |
| command | tmux コマンド履歴の閲覧/実行 |
| keybinding | tmux のキーバインドを検索 |
| clipboard | クリップボード履歴の閲覧 |
| process | pane 内で動いているプロセスを表示 |

対象を選んだあと、具体的なエントリを選び、最後にアクションを選びます。

## 画面上のキー

| キー | 役割 |
|---|---|
| 入力 | あいまいフィルタ |
| `Tab` | 複数選択 |
| `Enter` | 確定 |
| `Esc` | 戻る/終了 |

多段メニュー：対象 → エントリ → アクションの順で選び、各段で `Esc` で戻れます。

## 特定の対象への個別バインド

いちいちメインメニューから入ったくない場合：

```tmux
bind-key -n C-s run-shell "~/.config/tmux/plugins/tmux-fzf/scripts/session.sh"
```

スクリプト名はバージョンによって異なります：

```bash
ls ~/.config/tmux/plugins/tmux-fzf/scripts/
```

## カスタムメニュー

tmux-fzf は設定によって独自のエントリを定義できます：

```tmux
set -g @tmux-fzf-custom "\
  edit config<=>tmux new-window -n config '\$EDITOR ~/.tmux.conf' \
  reload<=>tmux source-file ~/.tmux.conf"
```

`<=>` が表示名と実行するコマンドを区切ります。

## fzf のグローバルオプションとの関係

tmux-fzf は `FZF_DEFAULT_OPTS` を読みます。本リポジトリでは：

```zsh
export FZF_DEFAULT_OPTS="--height 90% --layout=reverse --border --wrap --preview ..."
```

と設定しているため、tmux-fzf の画面にも右側プレビューとボーダーが付きます。

tmux 内でプレビューが崩れる場合は、tmux-fzf 専用に設定できます：

```tmux
set -g @tmux-fzf-options '--height 60%'
```

## トラブルシュート

**`Prefix + F` が反応しない**：プラグインが読み込まれていません。`ls ~/.config/tmux/plugins/tmux-fzf/` で確認します。

**メニューは開くがリストが空**：その種類の対象が本当に存在しない（他の session がない等）場合です。

**プレビューが文字化けする**：`FZF_DEFAULT_OPTS` のプレビューコマンドが tmux 環境で失敗しています。`@tmux-fzf-options` で上書きします。

**キーが tmux に占有されている**：`Prefix + F` が既存のバインドと競合しています。`tmux list-keys | grep F` で確認します。

**fzf のバージョンが古い**：tmux-fzf は比較的新しい fzf に依存します。`fzf --version` で 0.30 以上であることを確認します。

**操作後にステータスバーが更新されない**：一部のアクションは `tmux refresh-client` が必要です。continuum のステータスバー表示と重なったときに出やすいので、設定を再読み込みすれば直ります。
