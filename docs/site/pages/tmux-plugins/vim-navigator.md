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

<!-- lang:en -->

> Summary: vim-tmux-navigator lets `Ctrl+h/j/k/l` move seamlessly between Neovim splits and tmux panes.

# vim-tmux-navigator

## Purpose

Without it there are two separate worlds:

- Inside Neovim, `Ctrl+w h` moves between splits
- Inside tmux, `Prefix + arrow keys` moves between panes

When you are at the edge of a Neovim split and want to move to the adjacent tmux pane, you first have to step out of the Neovim mindset and press tmux's keys.

Once installed, `Ctrl+h` decides intelligently: if you are at the edge of a Neovim split, it hands over to tmux; otherwise it moves within Neovim.

## How it is loaded

```tmux
set -g @plugin 'christoomey/vim-tmux-navigator'
```

**Both sides must be installed**:

| Side | What is needed |
|---|---|
| tmux | This plugin |
| Neovim | The Neovim part of `christoomey/vim-tmux-navigator` |

This repository's Neovim config already includes the corresponding plugin, so declaring it on the tmux side is enough.

## Default keybindings

| Key | Direction |
|---|---|
| `Ctrl+h` | Left |
| `Ctrl+j` | Down |
| `Ctrl+k` | Up |
| `Ctrl+l` | Right |
| `Ctrl+\` | Previous pane |

No `Prefix` needed; press them directly.

## Decision logic

```text
按 Ctrl+h
├── 当前 pane 是 Neovim？
│     ├── 是 → 在 Neovim 内部向左移动
│     │         └── 已经在最左边？ → 转发给 tmux
│     └── 否 → tmux 向左移动 pane
```

The decision is based on: tmux checks the name of the program running in the current pane, and whether Neovim is in a specific state (such as command-line mode or terminal mode).

## Conflict with Neovim terminal mode

In Neovim's built-in terminal (`:terminal`), `Ctrl+h` may be taken by the terminal program. The plugin detects this state and does not forward to tmux.

If you run tmux inside a Neovim terminal (nesting), the behavior gets complicated. Nesting is generally not recommended.

## Common problem: Ctrl+h treated as backspace

Some terminals map `Ctrl+h` to Backspace (for historical reasons). This makes `Ctrl+h` delete a character in Neovim instead of moving left.

Fix: make the terminal send the correct sequence in its configuration, or remap it in Neovim.

## Custom keybindings

If you don't want `Ctrl+h/j/k/l`:

```tmux
# 在 private.conf 里覆盖
bind -n C-Left select-pane -L
```

Or change the mappings on the Neovim side (see the keymaps in the Neovim config).

## Troubleshooting

**`Ctrl+h` does nothing**: the plugin is not loaded, or the Neovim-side plugin is missing. Both sides must be present.

**A character is deleted in Neovim**: the terminal treats `Ctrl+h` as backspace. Check the terminal's key settings.

**Movement works on one side only, can't cross over**: the Neovim-side plugin is not active. Check in Neovim:

```vim
:map <C-h>
```

**Conflicts with some Neovim plugin**: for example, another plugin also binds `Ctrl+h`. Check which one loads later.

**Weird behavior when tmux is nested**: avoid nesting, or change the prefix and keys of the inner tmux.

**Arrow keys misbehave inside an fzf popup**: fzf handles its own keys and is unaffected by navigator. This is expected.

<!-- lang:ja -->

> 要約：vim-tmux-navigator は `Ctrl+h/j/k/l` で Neovim の分割と tmux pane の間をシームレスに移動できるようにします。

# vim-tmux-navigator

## 用途

これがないときは独立した 2 つの世界があります：

- Neovim 内では `Ctrl+w h` で分割間を移動
- tmux 内では `Prefix + 方向キー` で pane 間を移動

Neovim の分割の端から隣の tmux pane に移りたいとき、まず Neovim の考え方を離れて tmux のキーを押す必要がありました。

導入後は、`Ctrl+h` が賢く判断します：Neovim の分割の端にいれば tmux に委譲し、そうでなければ Neovim 内で移動します。

## 読み込み方法

```tmux
set -g @plugin 'christoomey/vim-tmux-navigator'
```

**両側にインストールが必要です**：

| 側 | 必要なもの |
|---|---|
| tmux | 本プラグイン |
| Neovim | `christoomey/vim-tmux-navigator` の Neovim 側 |

本リポジトリの Neovim 設定には対応するプラグインが既に含まれているため、tmux 側で宣言するだけで済みます。

## デフォルトのキーバインド

| キー | 方向 |
|---|---|
| `Ctrl+h` | 左 |
| `Ctrl+j` | 下 |
| `Ctrl+k` | 上 |
| `Ctrl+l` | 右 |
| `Ctrl+\` | 前の pane |

`Prefix` は不要で、直接押します。

## 判断のロジック

```text
按 Ctrl+h
├── 当前 pane 是 Neovim？
│     ├── 是 → 在 Neovim 内部向左移动
│     │         └── 已经在最左边？ → 转发给 tmux
│     └── 否 → tmux 向左移动 pane
```

判断の根拠：tmux は現在の pane で動いているプログラム名と、Neovim が特定の状態（コマンドラインモードやターミナルモードなど）かどうかを確認します。

## Neovim のターミナルモードとの競合

Neovim の内蔵ターミナル（`:terminal`）では、`Ctrl+h` がターミナル上のプログラムに占有されることがあります。プラグインはこの状態を検出し、tmux には転送しません。

Neovim ターミナルの中で tmux を動かす（ネスト）と挙動が複雑になります。通常はネストしないことを推奨します。

## よくある問題：Ctrl+h がバックスペースとして扱われる

一部のターミナルは歴史的経緯で `Ctrl+h` を Backspace に割り当てています。そのため `Ctrl+h` が Neovim で左移動ではなく文字削除になります。

対策：ターミナルの設定で正しいシーケンスを送るようにするか、Neovim 側でリマップします。

## キーバインドのカスタマイズ

`Ctrl+h/j/k/l` を使いたくない場合：

```tmux
# 在 private.conf 里覆盖
bind -n C-Left select-pane -L
```

または Neovim 側でマッピングを変更します（Neovim 設定の keymaps を参照）。

## トラブルシュート

**`Ctrl+h` が反応しない**：プラグインが読み込まれていないか、Neovim 側のプラグインが未導入です。両側に必要です。

**Neovim で文字が削除される**：ターミナルが `Ctrl+h` をバックスペースとして扱っています。ターミナルのキー設定を確認します。

**片側でしか移動できず、もう片側に渡れない**：Neovim 側のプラグインが効いていません。Neovim で確認します：

```vim
:map <C-h>
```

**ある Neovim プラグインと競合する**：たとえば別のプラグインも `Ctrl+h` にバインドしている場合です。どちらが後に読み込まれるか確認します。

**tmux をネストしたときに挙動がおかしい**：ネストを避けるか、内側の tmux で prefix とキーを変更します。

**fzf のポップアップ内で方向がおかしくなる**：fzf は自身でキーを処理するため、navigator の影響を受けません。想定内の動作です。
