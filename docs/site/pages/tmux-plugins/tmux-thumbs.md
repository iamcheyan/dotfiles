> 摘要：tmux-thumbs 为当前分屏上的文件路径、Git Hash、URL、IP 等生成双字母提示标签，敲击字母即可无鼠标复制。

# tmux-thumbs

## 用途

`tmux-thumbs`（Rust 实现的 `tmux-fingers` 替代品）在当前 pane 屏幕上自动识别文件路径、Git commit hash、URL、IP 地址、数字、UUID 等模式，并在旁边显示双字母标签（类似 Vimium / Kitty Hints）。

无需移动鼠标或进入 copy-mode：按下触发键后直接敲对应的字母即可复制。

## 本仓库配置

```tmux
set -g @plugin 'fcsonline/tmux-thumbs'
set -g @thumbs-key T
set -g @thumbs-osc52 1
```

| 选项 | 值 | 说明 |
|---|---|---|
| `@thumbs-key` | `T` | 触发快捷键设为 `Prefix + T`（大写），避免覆盖 tmux 默认的 `Prefix + Space`（切换布局） |
| `@thumbs-osc52` | `1` | 选中后同时输出 OSC 52 剪贴板序列，SSH 远端会话也能直接写入本地剪贴板 |

## 快捷键与操作

| 键 | 作用 |
|---|---|
| `Prefix + T` | 启动 tmux-thumbs 标签标注界面 |
| `<小写字母标签>` | 复制对应文本到 tmux 缓冲区与系统剪贴板 |
| `<大写字母标签>` | 复制对应文本并自动粘贴到当前命令行 |
| `Space` | 多选模式（可连续选多个标签，回车合并复制） |
| `Esc` / `q` | 取消退出 |

## 首次安装二进制

TPM 克隆仓库后，首次按 `Prefix + T` 时若未检测到编译好的二进制，会提示选择 `Compile`（用 `cargo` 编译）或 `Download`（直接下载预编译二进制）。也可以在命令行一键下载预编译版：

```bash
cd ~/.config/tmux/plugins/tmux-thumbs && mkdir -p target/release
url=$(curl -s "https://api.github.com/repos/fcsonline/tmux-thumbs/releases/latest" | grep -o 'https://.*linux-musl.tar.gz' | head -1)
curl -sL "$url" | tar -zxf - -C target/release thumbs tmux-thumbs
chmod +x target/release/thumbs target/release/tmux-thumbs
```

<!-- lang:en -->

> Summary: tmux-thumbs overlays two-letter hint labels on file paths, Git hashes, URLs, and IPs in the current pane for mouseless copying.

# tmux-thumbs

## Purpose

`tmux-thumbs` (a fast Rust reimplementation of `tmux-fingers`) scans the visible pane for file paths, Git commit hashes, URLs, IP addresses, numbers, and UUIDs, displaying two-letter hint labels next to each match (similar to Vimium or Kitty Hints).

You can copy or insert matches without touching the mouse or entering copy-mode.

## Configuration in this repository

```tmux
set -g @plugin 'fcsonline/tmux-thumbs'
set -g @thumbs-key T
set -g @thumbs-osc52 1
```

| Option | Value | Description |
|---|---|---|
| `@thumbs-key` | `T` | Binds trigger to `Prefix + T` (uppercase) so `Prefix + Space` (`next-layout`) is preserved |
| `@thumbs-osc52` | `1` | Emits OSC 52 sequences on selection so remote SSH sessions update the local clipboard |

## Keys and actions

| Key | Effect |
|---|---|
| `Prefix + T` | Open the tmux-thumbs hint overlay |
| `<lowercase hint>` | Copy the matched text to the tmux buffer and clipboard |
| `<uppercase hint>` | Copy the matched text and paste it directly into the active pane |
| `Space` | Multi-select mode (select multiple hints, press Enter to confirm) |
| `Esc` / `q` | Cancel and exit |

<!-- lang:ja -->

> 要約：tmux-thumbs は現在の pane 上のファイルパス、Git ハッシュ、URL、IP などに 2 文字のヒントラベルを表示し、マウスなしで素早くコピーできます。

# tmux-thumbs

## 用途

`tmux-thumbs`（Rust 製の高速な `tmux-fingers` 代替）は、現在の pane 画面からファイルパス、Git コミットハッシュ、URL、IP アドレス、数値、UUID などを自動検出し、横にアルファベットのヒントラベルを表示します（Vimium や Kitty Hints と同様の操作感です）。

## 本リポジトリの設定

```tmux
set -g @plugin 'fcsonline/tmux-thumbs'
set -g @thumbs-key T
set -g @thumbs-osc52 1
```

| オプション | 値 | 説明 |
|---|---|---|
| `@thumbs-key` | `T` | `Prefix + Space`（レイアウト切替）を潰さないよう `Prefix + T`（大文字）に割り当てます |
| `@thumbs-osc52` | `1` | 選択時に OSC 52 シーケンスも出力し、SSH 経由でもローカルクリップボードへコピーします |

## キー操作

| キー | 役割 |
|---|---|
| `Prefix + T` | ヒントラベル画面を起動 |
| `<小文字ヒント>` | 対象テキストをコピー |
| `<大文字ヒント>` | 対象テキストをコピーして現在のコマンドラインへ貼り付け |
| `Space` | 複数選択モード |
| `Esc` / `q` | キャンセル |
