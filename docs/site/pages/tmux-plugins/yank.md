> 摘要：tmux-yank 把 copy mode 或命令行里选中的文本送到系统剪贴板。

# tmux-yank

## 用途

tmux 的 copy mode 默认把文本复制到 tmux 自己的缓冲区，不是系统剪贴板。所以复制后无法粘贴到其它应用。

`tmux-yank` 补上这一步：把 tmux 缓冲区的内容同时送进系统剪贴板。它支持本机直接复制和 OSC 52 远程复制两条路径。

## 加载方式

```tmux
set -g @plugin 'tmux-plugins/tmux-yank'
```

本仓库没有为它设置任何选项，用上游默认值。

## 复制路径

### 本机

| 平台 | 使用的命令 |
|---|---|
| Linux (X11) | `xsel` 或 `xclip` |
| Linux (Wayland) | `wl-copy` |
| macOS | `pbcopy` |
| WSL | `clip.exe` |
| 其它 | `reattach-to-user-namespace`（旧版 macOS） |

插件按环境自动探测。

copy-mode-vi copy-pipe bindings call `scripts/tmux-copy`. SSH detection checks `SSH_SESSION`,
`SSH_CONNECTION`, `SSH_CLIENT`, `SSH_TTY`, and tmux context; WSL, Wayland and X11 detection
remains in the existing local helper. The SSH helper captures the UTF-8 selection and runs
`tmux set-buffer`, letting the tmux server emit OSC 52. It does not write escape sequences
to the pane PTY. Local sessions delegate to `scripts/tmux-clipboard-copy`.


| 键 | 行为 |
|---|---|
| `y` | 复制选区 |
| `Enter` | 复制选区 |
| `MouseDragEnd1Pane` | 鼠标拖选后自动复制 |
| `M-y` | 复制后 `tmux paste-buffer -p` 粘贴 |
| `!` | 先 `tr -d "\n"` 去掉换行再复制 |
| `DoubleClick1Pane` | 按词选择后复制 |
| `TripleClick1Pane` | 按行选择后复制 |

配置里不允许再出现 `clip.exe`、`wl-copy`、`xclip`、`xsel`、`pbcopy` 的直接调用；
`tmux list-keys -T copy-mode-vi | grep -E 'clip\.exe|wl-copy|xclip|xsel|pbcopy'`
应该没有输出。

### 远程 / SSH

通过 **OSC 52** 转义序列：把文本编码后发给终端，由终端写入本地剪贴板。

这需要两个条件：

```tmux
set -g allow-passthrough on    # 本仓库已设置
```

以及终端支持 OSC 52（Kitty、iTerm2、WezTerm 等支持，某些终端默认关闭）。

本仓库的 `allow-passthrough on` 正是为了让 OSC 52 序列穿过 tmux 到达外层终端。

## 远程 / SSH：OSC 52

在 SSH 场景，tmux 复制会更新 tmux buffer。`set-clipboard on` 让 tmux 将 buffer
更新编码为 OSC 52 发给 terminal client；`allow-passthrough on` 允许应用发出的
OSC/DCS 序列穿过 tmux。每一层嵌套 tmux 都需要相应配置，最外层终端还必须允许
OSC 52 写剪贴板。OSC 52 没有确认回执，因此发送序列不代表终端已接受。

`set-clipboard` 检查的是 tmux server option：

```sh
tmux show-options -g allow-passthrough
tmux show-options -s set-clipboard
```

`set-clipboard` 取值：

| 值 | 行为 | 本配置建议 |
|---|---|---|
| `external` | tmux 接受应用发来的 OSC 52 并据此创建内部 buffer；不把 buffer 复制到终端剪贴板 | 不适合本方案 |
| `on` | tmux 接受应用发来的 OSC 52，并把 copy-mode buffer 发到终端剪贴板 | 推荐；主配置已启用 |
| `off` | 忽略应用发来的 OSC 52，也不把 copy-mode buffer 发给终端 | 远程剪贴板不可用 |

主配置设置 `allow-passthrough on` 与 `set-clipboard on`。`set-clipboard on` 配合终端的
`Ms` terminfo 能力，让 tmux 在复制 buffer 时给当前 client 发 OSC 52；`external`
只接受应用发来的 OSC 52 更新 tmux 内部 buffer，`off` 两者都禁用。SSH copy-mode
由 tmux 处理 clipboard 上送；`scripts/tmux-copy` 通过 `tmux load-buffer` 更新选区
并保留末尾换行。它不向 pane PTY 写转义序列。非 SSH 会话委托
`scripts/tmux-clipboard-copy` 选择本地后端：WSL 使用 `iconv -f UTF-8 -t UTF-16LE | clip.exe`，
Wayland 用 `wl-copy`，X11 用 `xclip`/`xsel`，macOS 用 `pbcopy`。
外层终端可能拒绝 OSC 52，协议没有接收回执，脚本无法据此自动回退。

### 五种连接场景验收

每种场景都应复制下面完整文本，并粘贴到本地编辑器逐字核对（含多行与 emoji）：

```text
中文
日本語
😀
𠮷野家
第一行
第二行
```

1. Windows Terminal → WSL → tmux：验证 OSC 52 接受策略；不支持时验证 WSL 本地 `clip.exe` 后端。
2. Windows Terminal → WSL → SSH → Linux → tmux：验证远端 pane 的 SSH 环境变量与 tmux OSC 52。
3. Windows Terminal → WSL → SSH → Bastion → SSH → Linux → tmux：逐层核实 tmux passthrough，最后粘贴到 Windows Terminal。
4. Linux Desktop → tmux：本地复制使用 Wayland `wl-copy` 或 X11 `xclip`/`xsel`。
5. macOS → tmux：本地复制使用 `pbcopy`。

Windows Terminal、WezTerm、Kitty、iTerm2 均需按实际版本与剪贴板策略验收；终端策略可能要求用户确认。

| 键 | 作用 |
|---|---|
| `y` | 复制选区（本地主配置通过共享脚本处理本地后端） |
| copy mode 里 `Y` | 复制到行尾 |
| `Prefix + ]` | 粘贴 tmux 缓冲区（tmux 自带） |
| `Prefix + y` | tmux-yank 插件复制当前 pane 的命令行内容 |

`y` 在 vi copy mode 下有效，因为本仓库设了 `setw -g mode-keys vi`。

## Local clipboard helper check

Outside SSH, `tmux-copy` delegates unchanged input to `tmux-clipboard-copy`; verify the
selected bytes by pasting from the host clipboard. OSC 52 cannot be proven by a detached
tmux server because it needs an attached terminal client with `Ms` capability.

## Typical workflow

```text
1. Prefix + [              进入 copy mode
2. Space / v               开始选择（vi 模式）
3. hjkl 移动                扩展选区
4. Enter 或 y               复制并退出
5. 到其它应用 Ctrl+V         粘贴
```

第 4 步用 `y` 是 yank 插件提供的；用 `Enter` 则只进 tmux 缓冲区，不进系统剪贴板（取决于版本）。

## 依赖项

| 依赖 | 用途 | 安装 |
|---|---|---|
| `xsel` / `xclip` | X11 复制 | `apt install xsel` |
| `wl-copy` | Wayland 复制 | `apt install wl-clipboard` |
| `pbcopy` | macOS | 系统自带 |

**没有这些命令时插件不工作**。Linux 桌面环境通常自带，服务器环境需要手动装。

```bash
command -v xsel xclip wl-copy pbcopy
```

## 排错

**复制后其它应用粘贴不到**：剪贴板命令没装。按上面的命令检查。

**SSH 里复制失败**：终端不支持 OSC 52，或 `allow-passthrough` 没开。

```bash
tmux show -g allow-passthrough
```

**vi 模式下 `y` 没反应**：`mode-keys` 不是 vi，或 yank 没加载。

```bash
tmux show -gw mode-keys
```

**复制内容带换行**：tmux 会保留选区的换行。想要单行可以先用 `Y`（复制到行尾）或手动清理。

**Wayland 下失效**：需要 `wl-copy`。X11 的 `xclip` 在纯 Wayland 下不工作。

## 与 vim-tmux-navigator 的关系

两者独立：navigator 管光标在 pane 间移动，yank 管文本复制到剪贴板。没有冲突。

<!-- lang:en -->

> Summary: tmux-yank sends text selected in copy mode or the command line to the system clipboard.

# tmux-yank

## Purpose

By default, tmux's copy mode copies text into tmux's own buffers, not the system clipboard. So after copying you cannot paste into other applications.

`tmux-yank` fills in this step: it also sends the contents of the tmux buffer to the system clipboard. It supports two paths: direct local copying and remote copying via OSC 52.

## How it is loaded

```tmux
set -g @plugin 'tmux-plugins/tmux-yank'
```

This repository does not set any options for it; upstream defaults are used.

## Copy paths

### Local

| Platform | Command used |
|---|---|
| Linux (X11) | `xsel` or `xclip` |
| Linux (Wayland) | `wl-copy` |
| macOS | `pbcopy` |
| WSL | `clip.exe` |
| Others | `reattach-to-user-namespace` (older macOS) |

The plugin auto-detects the environment.

copy-mode-vi copy-pipe bindings call `scripts/tmux-copy`. SSH detection checks `SSH_SESSION`,
`SSH_CONNECTION`, `SSH_CLIENT`, `SSH_TTY`, and tmux context; WSL, Wayland and X11 detection
remains in the existing local helper. The SSH helper captures the UTF-8 selection and runs
`tmux set-buffer`, letting the tmux server emit OSC 52. It does not write escape sequences
to the pane PTY. Local sessions delegate to `scripts/tmux-clipboard-copy`.

| Key | Behavior |
|---|---|
| `y` | Copy the selection |
| `Enter` | Copy the selection |
| `MouseDragEnd1Pane` | Automatically copy after a mouse drag selection |
| `M-y` | After copying, paste with `tmux paste-buffer -p` |
| `!` | Strip newlines with `tr -d "\n"` before copying |
| `DoubleClick1Pane` | Select by word, then copy |
| `TripleClick1Pane` | Select by line, then copy |

The config must not contain any direct calls to `clip.exe`, `wl-copy`, `xclip`, `xsel`, or `pbcopy`;
`tmux list-keys -T copy-mode-vi | grep -E 'clip\.exe|wl-copy|xclip|xsel|pbcopy'`
should produce no output.

### Remote / SSH

Via the **OSC 52** escape sequence: the text is encoded and sent to the terminal, which writes it to the local clipboard.

This requires two conditions:

```tmux
set -g allow-passthrough on    # 本仓库已设置
```

And a terminal that supports OSC 52 (Kitty, iTerm2, WezTerm and others support it; some terminals disable it by default).

This repository's `allow-passthrough on` exists precisely to let OSC 52 sequences pass through tmux to the outer terminal.

## Remote / SSH: OSC 52

In SSH scenarios, a tmux copy updates the tmux buffer. `set-clipboard on` makes tmux encode the buffer update as OSC 52 and send it to the terminal client; `allow-passthrough on` allows OSC/DCS sequences emitted by applications to pass through tmux. Every layer of nested tmux needs the corresponding configuration, and the outermost terminal must also allow OSC 52 to write the clipboard. OSC 52 has no acknowledgment, so sending the sequence does not mean the terminal accepted it.

`set-clipboard` is a tmux server option:

```sh
tmux show-options -g allow-passthrough
tmux show-options -s set-clipboard
```

Values of `set-clipboard`:

| Value | Behavior | Recommendation for this config |
|---|---|---|
| `external` | tmux accepts OSC 52 sent by applications and creates an internal buffer from it; it does not copy the buffer to the terminal clipboard | Not suitable for this setup |
| `on` | tmux accepts OSC 52 sent by applications, and sends copy-mode buffers to the terminal clipboard | Recommended; enabled in the main config |
| `off` | Ignores OSC 52 sent by applications, and does not send copy-mode buffers to the terminal either | Remote clipboard unavailable |

The main config sets `allow-passthrough on` and `set-clipboard on`. `set-clipboard on` works with the terminal's
`Ms` terminfo capability so that tmux sends OSC 52 to the current client when copying a buffer; `external`
only accepts application-sent OSC 52 to update tmux's internal buffer, and `off` disables both. SSH copy-mode
clipboard upload is handled by tmux; `scripts/tmux-copy` updates the selection via `tmux load-buffer`
and preserves the trailing newline. It does not write escape sequences to the pane PTY. Non-SSH sessions delegate
to `scripts/tmux-clipboard-copy`, which picks a local backend: WSL uses `iconv -f UTF-8 -t UTF-16LE | clip.exe`,
Wayland uses `wl-copy`, X11 uses `xclip`/`xsel`, and macOS uses `pbcopy`.
The outer terminal may reject OSC 52; the protocol has no receipt of acceptance, so the script cannot automatically fall back based on it.

### Acceptance across five connection scenarios

For each scenario, copy the full text below and paste it into a local editor to verify character by character (including the multi-line text and the emoji):

```text
中文
日本語
😀
𠮷野家
第一行
第二行
```

1. Windows Terminal → WSL → tmux: verify the OSC 52 acceptance policy; if unsupported, verify the WSL local `clip.exe` backend.
2. Windows Terminal → WSL → SSH → Linux → tmux: verify the SSH environment variables on the remote pane and tmux's OSC 52.
3. Windows Terminal → WSL → SSH → Bastion → SSH → Linux → tmux: verify tmux passthrough layer by layer, then paste into Windows Terminal.
4. Linux Desktop → tmux: local copying uses Wayland `wl-copy` or X11 `xclip`/`xsel`.
5. macOS → tmux: local copying uses `pbcopy`.

Windows Terminal, WezTerm, Kitty and iTerm2 must each be accepted according to the actual version and clipboard policy; the terminal's policy may require user confirmation.

| Key | Effect |
|---|---|
| `y` | Copy the selection (in the local main config, the local backend is handled through the shared script) |
| `Y` in copy mode | Copy to end of line |
| `Prefix + ]` | Paste the tmux buffer (built into tmux) |
| `Prefix + y` | tmux-yank plugin copies the command-line content of the current pane |

`y` works in vi copy mode because this repository sets `setw -g mode-keys vi`.

## Local clipboard helper check

Outside SSH, `tmux-copy` delegates unchanged input to `tmux-clipboard-copy`; verify the
selected bytes by pasting from the host clipboard. OSC 52 cannot be proven by a detached
tmux server because it needs an attached terminal client with `Ms` capability.

## Typical workflow

```text
1. Prefix + [              进入 copy mode
2. Space / v               开始选择（vi 模式）
3. hjkl 移动                扩展选区
4. Enter 或 y               复制并退出
5. 到其它应用 Ctrl+V         粘贴
```

Step 4's `y` is provided by the yank plugin; using `Enter` puts the text only into the tmux buffer, not the system clipboard (depending on the version).

## Dependencies

| Dependency | Used for | Install |
|---|---|---|
| `xsel` / `xclip` | X11 copying | `apt install xsel` |
| `wl-copy` | Wayland copying | `apt install wl-clipboard` |
| `pbcopy` | macOS | Built into the system |

**Without these commands the plugin does not work**. Linux desktop environments usually have them built in; server environments need manual installation.

```bash
command -v xsel xclip wl-copy pbcopy
```

## Troubleshooting

**Cannot paste into other applications after copying**: the clipboard command is not installed. Check with the commands above.

**Copying fails over SSH**: the terminal does not support OSC 52, or `allow-passthrough` is not enabled.

```bash
tmux show -g allow-passthrough
```

**`y` does nothing in vi mode**: `mode-keys` is not vi, or yank is not loaded.

```bash
tmux show -gw mode-keys
```

**Copied text includes newlines**: tmux preserves the selection's newlines. For a single line, use `Y` (copy to end of line) first or clean it up manually.

**Does not work under Wayland**: `wl-copy` is required. X11's `xclip` does not work on pure Wayland.

## Relationship with vim-tmux-navigator

The two are independent: navigator handles moving the cursor between panes, yank handles copying text to the clipboard. No conflict.

<!-- lang:ja -->

> 要約：tmux-yank は copy mode やコマンドラインで選択したテキストをシステムクリップボードに送ります。

# tmux-yank

## 用途

tmux の copy mode はデフォルトではテキストを tmux 自身のバッファにコピーし、システムクリップボードには入れません。そのため、コピーしても他のアプリケーションに貼り付けられません。

`tmux-yank` はこの一手間を補います：tmux バッファの内容をシステムクリップボードにも送ります。ローカルでの直接コピーと、OSC 52 によるリモートコピーの 2 経路に対応しています。

## 読み込み方法

```tmux
set -g @plugin 'tmux-plugins/tmux-yank'
```

本リポジトリではこのプラグインのオプションは設定しておらず、上流のデフォルト値を使います。

## コピーの経路

### ローカル

| プラットフォーム | 使用するコマンド |
|---|---|
| Linux (X11) | `xsel` または `xclip` |
| Linux (Wayland) | `wl-copy` |
| macOS | `pbcopy` |
| WSL | `clip.exe` |
| その他 | `reattach-to-user-namespace`（旧 macOS） |

プラグインが環境を自動判定します。

copy-mode-vi copy-pipe bindings call `scripts/tmux-copy`. SSH detection checks `SSH_SESSION`,
`SSH_CONNECTION`, `SSH_CLIENT`, `SSH_TTY`, and tmux context; WSL, Wayland and X11 detection
remains in the existing local helper. The SSH helper captures the UTF-8 selection and runs
`tmux set-buffer`, letting the tmux server emit OSC 52. It does not write escape sequences
to the pane PTY. Local sessions delegate to `scripts/tmux-clipboard-copy`.

| キー | 動作 |
|---|---|
| `y` | 選択範囲をコピー |
| `Enter` | 選択範囲をコピー |
| `MouseDragEnd1Pane` | マウスドラッグでの選択後に自動コピー |
| `M-y` | コピー後に `tmux paste-buffer -p` で貼り付け |
| `!` | 先に `tr -d "\n"` で改行を除去してからコピー |
| `DoubleClick1Pane` | 単語選択後にコピー |
| `TripleClick1Pane` | 行選択後にコピー |

設定内に `clip.exe`・`wl-copy`・`xclip`・`xsel`・`pbcopy` の直接呼び出しは現れてはならず、
`tmux list-keys -T copy-mode-vi | grep -E 'clip\.exe|wl-copy|xclip|xsel|pbcopy'`
は出力を返さないはずです。

### リモート / SSH

**OSC 52** エスケープシーケンスによります：テキストをエンコードしてターミナルへ送り、ターミナルがローカルのクリップボードに書き込みます。

これには 2 つの条件が必要です：

```tmux
set -g allow-passthrough on    # 本仓库已设置
```

さらに OSC 52 に対応したターミナルであること（Kitty・iTerm2・WezTerm などは対応。デフォルトで無効なターミナルもあります）。

本リポジトリの `allow-passthrough on` は、まさに OSC 52 シーケンスを tmux の内側から外側のターミナルへ通すために設定されています。

## リモート / SSH：OSC 52

SSH 環境では、tmux でのコピーは tmux バッファを更新します。`set-clipboard on` により tmux はバッファの更新を OSC 52 としてエンコードして terminal client に送ります。`allow-passthrough on` はアプリケーションが発した OSC/DCS シーケンスが tmux を通過できるようにします。ネストした tmux の各層で対応する設定が必要で、最外層のターミナルも OSC 52 によるクリップボード書き込みを許可しなければなりません。OSC 52 には受信確認がないため、シーケンスを送ってもターミナルが受け付けたことを意味しません。

`set-clipboard` が見るのは tmux server option です：

```sh
tmux show-options -g allow-passthrough
tmux show-options -s set-clipboard
```

`set-clipboard` の値：

| 値 | 動作 | 本設定での推奨 |
|---|---|---|
| `external` | アプリが送った OSC 52 を受け付けて内部バッファを作る。バッファをターミナルのクリップボードには複製しない | 本構成には不適 |
| `on` | アプリが送った OSC 52 を受け付け、copy-mode バッファをターミナルのクリップボードへ送る | 推奨。メイン設定で有効化済み |
| `off` | アプリが送った OSC 52 を無視し、copy-mode バッファもターミナルへ送らない | リモートクリップボードが使えない |

メイン設定では `allow-passthrough on` と `set-clipboard on` を設定しています。`set-clipboard on` はターミナルの
`Ms` terminfo 能力と組み合わさり、tmux がバッファをコピーする際に現在の client へ OSC 52 を送れるようにします。`external`
はアプリ発の OSC 52 を受け付けて tmux 内部バッファを更新するだけで、`off` はその両方を無効化します。SSH の copy-mode では
tmux がクリップボードへの上送を処理します。`scripts/tmux-copy` は `tmux load-buffer` で選択範囲を更新し、
末尾の改行を保持します。pane の PTY へエスケープシーケンスを書き込むことはありません。SSH 以外のセッションは
`scripts/tmux-clipboard-copy` に委譲され、ローカルバックエンドを選択します：WSL は `iconv -f UTF-8 -t UTF-16LE | clip.exe`、
Wayland は `wl-copy`、X11 は `xclip`/`xsel`、macOS は `pbcopy` を使います。
外層のターミナルは OSC 52 を拒否することがあり、プロトコルには受信確認がないため、スクリプトはそれに基づいて自動的にフォールバックできません。

### 5 つの接続シナリオでの検収

各シナリオで、以下のテキストを丸ごとコピーし、ローカルのエディタに貼り付けて一字一句確認します（複数行と emoji を含む）：

```text
中文
日本語
😀
𠮷野家
第一行
第二行
```

1. Windows Terminal → WSL → tmux：OSC 52 の受け付けポリシーを検証。非対応の場合は WSL ローカルの `clip.exe` バックエンドを検証。
2. Windows Terminal → WSL → SSH → Linux → tmux：リモート pane の SSH 環境変数と tmux の OSC 52 を検証。
3. Windows Terminal → WSL → SSH → Bastion → SSH → Linux → tmux：tmux passthrough を層ごとに確認し、最後に Windows Terminal に貼り付け。
4. Linux Desktop → tmux：ローカルコピーは Wayland `wl-copy` または X11 `xclip`/`xsel` を使用。
5. macOS → tmux：ローカルコピーは `pbcopy` を使用。

Windows Terminal・WezTerm・Kitty・iTerm2 はいずれも実際のバージョンとクリップボードポリシーに応じて検収が必要です。ターミナルのポリシーによってはユーザーの確認を求められます。

| キー | 役割 |
|---|---|
| `y` | 選択範囲をコピー（ローカルのメイン設定では共有スクリプト経由でローカルバックエンドを処理） |
| copy mode で `Y` | 行末までコピー |
| `Prefix + ]` | tmux バッファを貼り付け（tmux 標準） |
| `Prefix + y` | tmux-yank プラグインが現在の pane のコマンドライン内容をコピー |

`y` は vi copy mode で有効です。本リポジトリが `setw -g mode-keys vi` を設定しているためです。

## Local clipboard helper check

Outside SSH, `tmux-copy` delegates unchanged input to `tmux-clipboard-copy`; verify the
selected bytes by pasting from the host clipboard. OSC 52 cannot be proven by a detached
tmux server because it needs an attached terminal client with `Ms` capability.

## Typical workflow

```text
1. Prefix + [              进入 copy mode
2. Space / v               开始选择（vi 模式）
3. hjkl 移动                扩展选区
4. Enter 或 y               复制并退出
5. 到其它应用 Ctrl+V         粘贴
```

第 4 手順の `y` は yank プラグインが提供するものです。`Enter` を使うと tmux バッファに入るだけで、システムクリップボードには入りません（バージョンによります）。

## 依存関係

| 依存 | 用途 | インストール |
|---|---|---|
| `xsel` / `xclip` | X11 でのコピー | `apt install xsel` |
| `wl-copy` | Wayland でのコピー | `apt install wl-clipboard` |
| `pbcopy` | macOS | システム標準 |

**これらのコマンドがないとプラグインは動作しません**。Linux デスクトップ環境なら通常入っていますが、サーバー環境では手動でインストールが必要です。

```bash
command -v xsel xclip wl-copy pbcopy
```

## トラブルシュート

**コピー後に他のアプリへ貼り付けられない**：クリップボード用コマンドが未導入です。上記のコマンドで確認します。

**SSH 内でコピーに失敗する**：ターミナルが OSC 52 に対応していないか、`allow-passthrough` が有効になっていません。

```bash
tmux show -g allow-passthrough
```

**vi モードで `y` が反応しない**：`mode-keys` が vi でないか、yank が読み込まれていません。

```bash
tmux show -gw mode-keys
```

**コピーした内容に改行が含まれる**：tmux は選択範囲の改行を保持します。1 行にしたければ先に `Y`（行末までコピー）を使うか、手動で整形します。

**Wayland で動かない**：`wl-copy` が必要です。X11 の `xclip` は純 Wayland 環境では動作しません。

## vim-tmux-navigator との関係

両者は独立しています：navigator は pane 間のカーソル移動を、yank はテキストのクリップボードへのコピーを扱います。衝突はありません。
