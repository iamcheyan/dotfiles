> 摘要：glow 在终端里渲染 Markdown，支持目录浏览和分页。

# glow

## 用途

`glow` 读取 Markdown 文件，在终端里渲染成带标题、列表、代码块、链接的格式化输出。它还能把整个目录的 Markdown 当成文档库浏览。

## 来源与安装

| 项目 | 说明 |
|---|---|
| 来源 | Zinit，从 GitHub Release 下载 |
| 可执行名 | `glow` |

```zsh
zi_cmd charmbracelet/glow glow
```

## 基本用法

```bash
glow README.md                 # 渲染单个文件
glow .                         # 浏览当前目录的 Markdown（TUI）
glow /path/to/docs             # 浏览指定目录
cat file.md | glow             # 从标准输入
glow -                        # 同上
```

不带参数且不在 TTY 时，`glow` 会从标准输入读取。

## 常用参数

| 参数 | 作用 |
|---|---|
| `-p` / `--pager` | 用 pager 分页显示 |
| `-s` / `--style` | 样式名或 JSON 路径，默认 `auto` |
| `-w` / `--width` | 换行宽度，0 表示不换行 |
| `-l` / `--line-numbers` | 显示行号（TUI 模式） |
| `-a` / `--all` | 显示隐藏文件（TUI 模式） |
| `-n` / `--preserve-new-lines` | 保留原始换行 |
| `--config` | 指定配置文件 |

## 样式

```bash
glow -s dark README.md
glow -s light README.md
glow -s notty README.md        # 无颜色，适合管道
glow -s /path/to/custom.json README.md
```

`auto` 会根据终端背景自动选 dark 或 light。输出到管道时自动用 `notty`。

自定义样式：`glow config` 打开配置文件，或用 `-s` 指向 JSON。

## 目录浏览模式

```bash
glow .
```

进入一个 TUI：左侧文件列表，右侧渲染内容。适合浏览一个有多个 Markdown 的项目文档。

| 键 | 作用 |
|---|---|
| `↑` / `↓` 或 `j` / `k` | 移动 |
| `Enter` | 打开 |
| `Esc` / `q` | 返回/退出 |
| `/` | 搜索 |
| `?` | 帮助 |

## 实用场景

### 读项目文档

```bash
glow ~/dotfiles/docs
```

比逐个 `cat` 舒服得多。

### 管道渲染

```bash
curl -s https://raw.githubusercontent.com/.../README.md | glow -
```

### 在脚本里输出说明

```bash
glow -s notty <<'EOF'
# 部署完成

- 服务已重启
- 日志在 `/var/log/app.log`
EOF
```

`-s notty` 去掉颜色和边框，适合写进日志。

### 配合 fzf

```bash
fd -e md | fzf --preview 'glow -w 80 {}'
```

用 fzf 选 Markdown，右侧预览渲染结果。

## 与 bat 的分工

| | bat | glow |
|---|---|---|
| 输入 | 任意文本 | Markdown |
| 输出 | 语法高亮源码 | 渲染后的文档 |
| 用途 | 读代码 | 读文档 |

读 `.md` 想看渲染效果用 glow，想看源码用 bat。

## 排错

**`glow: command not found`**：Zinit 未下载。

**渲染乱码**：终端字体缺 CJK 或特殊符号。装 Noto Serif CJK。

**表格渲染错位**：glow 对宽表格支持有限。加 `-w` 调宽度，或改用浏览器。

**颜色丢失**：输出到管道时自动用 `notty`。想保留颜色加 `-s dark`。

**`glow .` 无反应**：需要交互式终端。在管道或脚本里不要用 TUI 模式。

**图片不显示**：glow 不渲染图片，只输出 Markdown 的图片链接文本。

<!-- lang:en -->

> Summary: glow renders Markdown in the terminal, with directory browsing and paging support.

# glow

## Purpose

`glow` reads Markdown files and renders them in the terminal as formatted output with headings, lists, code blocks, and links. It can also treat all the Markdown in a directory as a browsable documentation library.

## Source and Installation

| Item | Description |
|---|---|
| Source | Zinit, downloaded from GitHub Release |
| Executable name | `glow` |

```zsh
zi_cmd charmbracelet/glow glow
```

## Basic usage

```bash
glow README.md                 # 渲染单个文件
glow .                         # 浏览当前目录的 Markdown（TUI）
glow /path/to/docs             # 浏览指定目录
cat file.md | glow             # 从标准输入
glow -                        # 同上
```

With no arguments and not on a TTY, `glow` reads from standard input.

## Common options

| Option | Purpose |
|---|---|
| `-p` / `--pager` | Page the output through a pager |
| `-s` / `--style` | Style name or JSON path, default `auto` |
| `-w` / `--width` | Wrap width; 0 means no wrapping |
| `-l` / `--line-numbers` | Show line numbers (TUI mode) |
| `-a` / `--all` | Show hidden files (TUI mode) |
| `-n` / `--preserve-new-lines` | Preserve original newlines |
| `--config` | Specify a config file |

## Styles

```bash
glow -s dark README.md
glow -s light README.md
glow -s notty README.md        # 无颜色，适合管道
glow -s /path/to/custom.json README.md
```

`auto` picks dark or light automatically based on the terminal background. When output goes to a pipe, `notty` is used automatically.

Custom styles: `glow config` opens the config file, or point `-s` at a JSON file.

## Directory browsing mode

```bash
glow .
```

This opens a TUI: file list on the left, rendered content on the right. It suits browsing project documentation that spans multiple Markdown files.

| Key | Action |
|---|---|
| `↑` / `↓` or `j` / `k` | Move |
| `Enter` | Open |
| `Esc` / `q` | Back/quit |
| `/` | Search |
| `?` | Help |

## Practical scenarios

### Reading project docs

```bash
glow ~/dotfiles/docs
```

Much more comfortable than `cat`-ing files one by one.

### Piping render

```bash
curl -s https://raw.githubusercontent.com/.../README.md | glow -
```

### Printing instructions from scripts

```bash
glow -s notty <<'EOF'
# 部署完成

- 服务已重启
- 日志在 `/var/log/app.log`
EOF
```

`-s notty` drops colors and borders, which suits writing into logs.

### With fzf

```bash
fd -e md | fzf --preview 'glow -w 80 {}'
```

Pick Markdown with fzf and preview the rendered result on the right.

## Division of labor with bat

| | bat | glow |
|---|---|---|
| Input | Any text | Markdown |
| Output | Syntax-highlighted source | Rendered document |
| Use | Reading code | Reading docs |

For `.md` files, use glow to see the rendered look and bat to see the source.

## Troubleshooting

**`glow: command not found`**: Zinit has not downloaded it.

**Garbled rendering**: the terminal font lacks CJK or special symbols. Install Noto Serif CJK.

**Tables render misaligned**: glow's support for wide tables is limited. Adjust the width with `-w`, or switch to a browser.

**Colors lost**: when output goes to a pipe, `notty` is used automatically. Add `-s dark` to keep colors.

**`glow .` does nothing**: it needs an interactive terminal. Do not use TUI mode in pipes or scripts.

**Images do not show**: glow does not render images; it only outputs the Markdown image link text.

<!-- lang:ja -->

> 要約：glow はターミナルで Markdown をレンダリングし、ディレクトリ閲覧とページングに対応しています。

# glow

## 用途

`glow` は Markdown ファイルを読み込み、見出し、リスト、コードブロック、リンク付きの整形された出力としてターミナルにレンダリングします。ディレクトリ全体の Markdown をドキュメントライブラリとして閲覧することもできます。

## ソースとインストール

| 項目 | 説明 |
|---|---|
| ソース | Zinit。GitHub Release からダウンロード |
| 実行ファイル名 | `glow` |

```zsh
zi_cmd charmbracelet/glow glow
```

## 基本的な使い方

```bash
glow README.md                 # 渲染单个文件
glow .                         # 浏览当前目录的 Markdown（TUI）
glow /path/to/docs             # 浏览指定目录
cat file.md | glow             # 从标准输入
glow -                        # 同上
```

引数なしで TTY に接続していない場合、`glow` は標準入力から読み込みます。

## よく使うオプション

| オプション | 役割 |
|---|---|
| `-p` / `--pager` | pager でページング表示 |
| `-s` / `--style` | スタイル名または JSON のパス。デフォルトは `auto` |
| `-w` / `--width` | 折り返し幅。0 は折り返しなし |
| `-l` / `--line-numbers` | 行番号を表示（TUI モード） |
| `-a` / `--all` | 隠しファイルを表示（TUI モード） |
| `-n` / `--preserve-new-lines` | 元の改行を保持 |
| `--config` | 設定ファイルを指定 |

## スタイル

```bash
glow -s dark README.md
glow -s light README.md
glow -s notty README.md        # 无颜色，适合管道
glow -s /path/to/custom.json README.md
```

`auto` はターミナルの背景に応じて dark か light を自動選択します。パイプへの出力では自動的に `notty` が使われます。

カスタムスタイル：`glow config` で設定ファイルを開くか、`-s` で JSON を指します。

## ディレクトリ閲覧モード

```bash
glow .
```

TUI が起動します。左にファイル一覧、右にレンダリングされた内容が表示されます。Markdown が複数あるプロジェクトドキュメントの閲覧に向いています。

| キー | 動作 |
|---|---|
| `↑` / `↓` または `j` / `k` | 移動 |
| `Enter` | 開く |
| `Esc` / `q` | 戻る/終了 |
| `/` | 検索 |
| `?` | ヘルプ |

## 実用的な場面

### プロジェクトドキュメントを読む

```bash
glow ~/dotfiles/docs
```

一つずつ `cat` するよりずっと快適です。

### パイプでレンダリング

```bash
curl -s https://raw.githubusercontent.com/.../README.md | glow -
```

### スクリプト内で説明を出力

```bash
glow -s notty <<'EOF'
# 部署完成

- 服务已重启
- 日志在 `/var/log/app.log`
EOF
```

`-s notty` は色と枠線を取り除き、ログに書き込むのに向いています。

### fzf との連携

```bash
fd -e md | fzf --preview 'glow -w 80 {}'
```

fzf で Markdown を選び、右側にレンダリング結果をプレビューします。

## bat との使い分け

| | bat | glow |
|---|---|---|
| 入力 | 任意のテキスト | Markdown |
| 出力 | シンタックスハイライトされたソース | レンダリングされたドキュメント |
| 用途 | コードを読む | ドキュメントを読む |

`.md` をレンダリング表示したいときは glow、ソースを見たいときは bat を使います。

## トラブルシューティング

**`glow: command not found`**：Zinit がダウンロードしていません。

**レンダリングが文字化けする**：ターミナルフォントに CJK や特殊記号がありません。Noto Serif CJK をインストールします。

**表のレンダリングがずれる**：glow の幅広の表への対応は限定的です。`-w` で幅を調整するか、ブラウザに切り替えます。

**色が消える**：パイプへの出力では自動的に `notty` が使われます。色を残したい場合は `-s dark` を付けます。

**`glow .` が反応しない**：インタラクティブなターミナルが必要です。パイプやスクリプト内では TUI モードを使わないでください。

**画像が表示されない**：glow は画像をレンダリングせず、Markdown の画像リンクのテキストだけを出力します。
