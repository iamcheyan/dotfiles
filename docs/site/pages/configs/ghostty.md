> 摘要：Ghostty 配置字体、配色、选中复制和窗口行为，但当前不在 dotlink 映射里。

# Ghostty 配置

## 文件位置

| 项目 | 路径 |
|---|---|
| 仓库源文件 | `config/ghostty/config` |
| 部署目标 | `~/.config/ghostty/config` |
| 是否自动链接 | **否** |

这是本章最重要的提醒：文件在仓库里，但 `dotlink/dotlinkrc` 没有它。安装完 dotfiles 后 Ghostty 不会自动用上这个配置。

## 手动部署

```bash
mkdir -p ~/.config/ghostty
ln -sf ~/dotfiles/config/ghostty/config ~/.config/ghostty/config
```

macOS 上 Ghostty 的配置路径可能不同，按官方文档确认。

## 字体

```text
font-family = MesloLGS Nerd Font Mono
font-size = 11
```

Meslo 由 `scripts/install/install_font.sh` 安装。字体名必须完全匹配，`fc-list | grep -i meslo` 查看实际名称。

## 配色

```text
background = #0000aa
foreground = #ffff55
cursor-color = #ffffff
selection-background = #1e1ec8
selection-foreground = #ffffff
```

与 Neovim 内置 Blue 的 Nostalgia 配色一致：深蓝底、黄字、白色光标，选区用亮蓝底。

### 16 色板

```text
palette = 0=#000080
palette = 1=#aa0000
palette = 2=#00aa00
palette = 3=#aaaa00
palette = 4=#0000aa
palette = 5=#aa00aa
palette = 6=#00aaaa
palette = 7=#a3be8c
palette = 8=#5f7f5f
palette = 9=#ff5555
palette = 10=#00ff00
palette = 11=#ffff55
palette = 12=#5555ff
palette = 13=#ff55ff
palette = 14=#55ffff
palette = 15=#ffffff
```

| 索引 | 用途 | 颜色 |
|---|---|---|
| 0 | 深蓝 | `#000080` |
| 1 | 红 | `#aa0000` |
| 2 | 绿 | `#00aa00` |
| 3 | 黄 | `#aaaa00` |
| 4 | 蓝 | `#0000aa` |
| 5 | 品红 | `#aa00aa` |
| 6 | 青 | `#00aaaa` |
| 7 | 浅绿 | `#a3be8c` |
| 8 | 暗绿 | `#5f7f5f` |
| 9–15 | 亮色版本 | 红、绿、黄、蓝、品红、青、白的亮色变体 |

8 是柔和绿，用作原本的亮黑／灰色槽；9–15 是红、绿、黄、蓝、品红、青、白的亮色版本。

## 剪贴板

```text
copy-on-select = clipboard
```

选中文本立即写入系统剪贴板，不需要 `Ctrl+Shift+C`。

代价：不小心选中就会覆盖剪贴板内容。习惯 `Ctrl+C` 复制别的内容时要注意。

## 窗口

```text
window-padding-x = 5
window-padding-y = 5
window-decoration = auto
window-theme = dark
window-border-color = #55ffff
quit-after-last-window-closed = false
```

| 设置 | 作用 |
|---|---|
| `window-padding-x/y = 5` | 内容四周留白 5px |
| `window-decoration = auto` | 由系统决定是否显示标题栏 |
| `window-theme = dark` | 强制暗色窗口装饰 |
| `quit-after-last-window-closed = false` | 关闭最后窗口时不退出应用（macOS 习惯） |

## 按键

```text
keybind = f11=toggle_fullscreen
```

F11 切换全屏。其它按键用 Ghostty 默认值。

## 与 tmux 的配合

Ghostty 提供终端能力和颜色，tmux 在其内部管理 pane。真彩色需要：

1. Ghostty 支持真彩色（默认支持）
2. tmux 配置 `terminal-features ,*:RGB`
3. 应用声明 `termguicolors`

本仓库的 tmux 配置已处理第 2 步。

## 为什么不在 dotlink 里

可能的原因：

- Ghostty 相对较新，配置路径在不同平台不一致
- 用户可能用别的终端（Kitty、Alacritty、WezTerm）
- 强制部署会覆盖用户已有的 Ghostty 配置

所以它作为「可选的参考配置」存在，需要的人手动链接。

## 验证

```bash
ls -l ~/.config/ghostty/config
ghostty +show-config | head -20
```

`ghostty +show-config` 会打印实际生效的配置，包括默认值和覆盖值。

## 排错

**配置不生效**：确认软链接建立了。`ls -l ~/.config/ghostty/config`。

**图标是方框**：Meslo 字体没装，或 `font-family` 名字不对。

**颜色不对**：`ghostty +show-config` 看实际值，可能有更高优先级的配置文件。

**选中复制太敏感**：把 `copy-on-select` 改成 `false` 或 `clipboard` 之外的值。

**F11 无反应**：窗口管理器可能拦截了 F11。换一个键。

**在 tmux 里颜色退化**：检查 tmux 的 `default-terminal` 和 `terminal-features`。

<!-- lang:en -->

> Summary: The Ghostty configuration sets fonts, colors, copy-on-select, and window behavior, but it is currently not in the dotlink mapping.

# Ghostty Configuration

## File Locations

| Item | Path |
|---|---|
| Repository source file | `config/ghostty/config` |
| Deployment target | `~/.config/ghostty/config` |
| Auto-linked | **No** |

This is the most important reminder in this chapter: the file is in the repository, but `dotlink/dotlinkrc` does not include it. After installing the dotfiles, Ghostty will not pick up this configuration automatically.

## Manual Deployment

```bash
mkdir -p ~/.config/ghostty
ln -sf ~/dotfiles/config/ghostty/config ~/.config/ghostty/config
```

On macOS the Ghostty configuration path may differ; confirm it against the official documentation.

## Font

```text
font-family = MesloLGS Nerd Font Mono
font-size = 11
```

Meslo is installed by `scripts/install/install_font.sh`. The font name must match exactly; run `fc-list | grep -i meslo` to see the actual name.

## Colors

```text
background = #0000aa
foreground = #ffff55
cursor-color = #ffffff
selection-background = #1e1ec8
selection-foreground = #ffffff
```

Consistent with the Nostalgia colors of Neovim's built-in Blue: dark blue background, yellow text, white cursor, and a bright blue selection background.

### The 16-Color Palette

```text
palette = 0=#000080
palette = 1=#aa0000
palette = 2=#00aa00
palette = 3=#aaaa00
palette = 4=#0000aa
palette = 5=#aa00aa
palette = 6=#00aaaa
palette = 7=#a3be8c
palette = 8=#5f7f5f
palette = 9=#ff5555
palette = 10=#00ff00
palette = 11=#ffff55
palette = 12=#5555ff
palette = 13=#ff55ff
palette = 14=#55ffff
palette = 15=#ffffff
```

| Index | Purpose | Color |
|---|---|---|
| 0 | Dark blue | `#000080` |
| 1 | Red | `#aa0000` |
| 2 | Green | `#00aa00` |
| 3 | Yellow | `#aaaa00` |
| 4 | Blue | `#0000aa` |
| 5 | Magenta | `#aa00aa` |
| 6 | Cyan | `#00aaaa` |
| 7 | Light green | `#a3be8c` |
| 8 | Muted green | `#5f7f5f` |
| 9–15 | Bright variants | Bright variants of red, green, yellow, blue, magenta, cyan, and white |

8 is muted green in place of the usual bright black/gray slot; 9–15 are the bright red, green, yellow, blue, magenta, cyan, and white colors.

## Clipboard

```text
copy-on-select = clipboard
```

Selected text is written to the system clipboard immediately, with no need for `Ctrl+Shift+C`.

The cost: an accidental selection overwrites the clipboard contents. Be careful if you are used to copying other things with `Ctrl+C`.

## Window

```text
window-padding-x = 5
window-padding-y = 5
window-decoration = auto
window-theme = dark
window-border-color = #55ffff
quit-after-last-window-closed = false
```

| Setting | Effect |
|---|---|
| `window-padding-x/y = 5` | 5px of padding around the content |
| `window-decoration = auto` | Lets the system decide whether to show the title bar |
| `window-theme = dark` | Forces dark window decorations |
| `quit-after-last-window-closed = false` | Keeps the app running when the last window closes (macOS convention) |

## Keybindings

```text
keybind = f11=toggle_fullscreen
```

F11 toggles fullscreen. Other keys use Ghostty's defaults.

## Working with tmux

Ghostty provides the terminal capabilities and colors, while tmux manages panes inside it. True color requires:

1. Ghostty supports true color (supported by default)
2. tmux sets `terminal-features ,*:RGB`
3. The application declares `termguicolors`

This repository's tmux configuration already handles step 2.

## Why It Is Not in dotlink

Possible reasons:

- Ghostty is relatively new, and its configuration path varies across platforms
- The user may use another terminal (Kitty, Alacritty, WezTerm)
- Forcing deployment would overwrite the user's existing Ghostty configuration

So it exists as an "optional reference configuration" that those who need it link manually.

## Verification

```bash
ls -l ~/.config/ghostty/config
ghostty +show-config | head -20
```

`ghostty +show-config` prints the configuration actually in effect, including defaults and overrides.

## Troubleshooting

**Configuration not taking effect**: confirm the symlink exists. `ls -l ~/.config/ghostty/config`.

**Icons render as boxes**: Meslo is not installed, or the `font-family` name is wrong.

**Wrong colors**: check the actual values with `ghostty +show-config`; another configuration file with higher priority may exist.

**Copy-on-select too aggressive**: change `copy-on-select` to `false` or something other than `clipboard`.

**F11 does nothing**: the window manager may be intercepting F11. Use a different key.

**Colors degrade inside tmux**: check tmux's `default-terminal` and `terminal-features`.

<!-- lang:ja -->

> 要約：Ghostty の設定はフォント・配色・選択コピー・ウィンドウの挙動を定めますが、現在は dotlink のマッピングに含まれていません。

# Ghostty の設定

## ファイルの場所

| 項目 | パス |
|---|---|
| リポジトリのソースファイル | `config/ghostty/config` |
| デプロイ先 | `~/.config/ghostty/config` |
| 自動リンクの対象 | **いいえ** |

これがこの章で最も重要な注意点です。ファイルはリポジトリ内にありますが、`dotlink/dotlinkrc` には含まれていません。dotfiles をインストールしただけでは、Ghostty はこの設定を自動的に使いません。

## 手動デプロイ

```bash
mkdir -p ~/.config/ghostty
ln -sf ~/dotfiles/config/ghostty/config ~/.config/ghostty/config
```

macOS では Ghostty の設定パスが異なる場合があります。公式ドキュメントで確認してください。

## フォント

```text
font-family = MesloLGS Nerd Font Mono
font-size = 11
```

Meslo は `scripts/install/install_font.sh` でインストールされます。フォント名は完全に一致する必要があり、`fc-list | grep -i meslo` で実際の名前を確認できます。

## 配色

```text
background = #0000aa
foreground = #ffff55
cursor-color = #ffffff
selection-background = #1e1ec8
selection-foreground = #ffffff
```

Neovim 内蔵 Blue の Nostalgia 配色と一致しています：濃い青の背景、黄色の文字、白いカーソル、選択範囲は明るい青の背景です。

### 16 色パレット

```text
palette = 0=#000080
palette = 1=#aa0000
palette = 2=#00aa00
palette = 3=#aaaa00
palette = 4=#0000aa
palette = 5=#aa00aa
palette = 6=#00aaaa
palette = 7=#a3be8c
palette = 8=#5f7f5f
palette = 9=#ff5555
palette = 10=#00ff00
palette = 11=#ffff55
palette = 12=#5555ff
palette = 13=#ff55ff
palette = 14=#55ffff
palette = 15=#ffffff
```

| インデックス | 用途 | 色 |
|---|---|---|
| 0 | 濃い青 | `#000080` |
| 1 | 赤 | `#aa0000` |
| 2 | 緑 | `#00aa00` |
| 3 | 黄 | `#aaaa00` |
| 4 | 青 | `#0000aa` |
| 5 | マゼンタ | `#aa00aa` |
| 6 | シアン | `#00aaaa` |
| 7 | 淡い緑 | `#a3be8c` |
| 8 | 落ち着いた緑 | `#5f7f5f` |
| 9–15 | 明色版 | 赤・緑・黄・青・マゼンタ・シアン・白の明色バリエーション |

8 は通常の明るい黒／グレーの代わりに落ち着いた緑にし、9–15 は赤・緑・黄・青・マゼンタ・シアン・白の明色にしています。

## クリップボード

```text
copy-on-select = clipboard
```

選択したテキストは即座にシステムクリップボードに書き込まれ、`Ctrl+Shift+C` は不要です。

代償として、うっかり選択しただけでクリップボードの内容が上書きされます。`Ctrl+C` で別の内容をコピーする習慣がある場合は注意してください。

## ウィンドウ

```text
window-padding-x = 5
window-padding-y = 5
window-decoration = auto
window-theme = dark
window-border-color = #55ffff
quit-after-last-window-closed = false
```

| 設定 | 効果 |
|---|---|
| `window-padding-x/y = 5` | 内容の周囲に 5px の余白を空けます |
| `window-decoration = auto` | タイトルバーの表示をシステムに任せます |
| `window-theme = dark` | ウィンドウ装飾をダークに固定します |
| `quit-after-last-window-closed = false` | 最後のウィンドウを閉じてもアプリを終了しません（macOS 流儀） |

## キー

```text
keybind = f11=toggle_fullscreen
```

F11 で全画面を切り替えます。その他のキーは Ghostty のデフォルトです。

## tmux との連携

Ghostty が端末の能力と色を提供し、tmux がその内部で pane を管理します。トゥルーカラーには次が必要です：

1. Ghostty がトゥルーカラーに対応している（デフォルトで対応）
2. tmux が `terminal-features ,*:RGB` を設定している
3. アプリケーションが `termguicolors` を宣言している

このリポジトリの tmux 設定は 2 番を既に処理しています。

## dotlink に入っていない理由

考えられる理由：

- Ghostty は比較的新しく、設定パスがプラットフォームごとに異なる
- ユーザーは別の端末（Kitty、Alacritty、WezTerm）を使っているかもしれない
- 強制的にデプロイするとユーザーの既存の Ghostty 設定を上書きしてしまう

そのため「任意の参考設定」として存在し、必要な人が手動でリンクします。

## 検証

```bash
ls -l ~/.config/ghostty/config
ghostty +show-config | head -20
```

`ghostty +show-config` はデフォルト値と上書き値を含め、実際に有効な設定を出力します。

## トラブルシューティング

**設定が効かない**：シンボリックリンクが張られているか確認します。`ls -l ~/.config/ghostty/config`。

**アイコンが四角になる**：Meslo フォントがインストールされていないか、`font-family` の名前が違います。

**色がおかしい**：`ghostty +show-config` で実際の値を確認します。優先度の高い別の設定ファイルがある可能性があります。

**選択コピーが敏感すぎる**：`copy-on-select` を `false` か `clipboard` 以外の値に変更します。

**F11 が反応しない**：ウィンドウマネージャーが F11 を横取りしている可能性があります。別のキーに変えます。

**tmux 内で色が劣化する**：tmux の `default-terminal` と `terminal-features` を確認します。
