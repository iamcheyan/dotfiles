> 摘要：toolong（命令 `tl`）是 Textualize 出的日志查看器，在终端里看、tail、合并、搜索日志文件和 JSONL，自动高亮时间戳，几 GB 的文件秒开。本仓库用它读 Hermes 日志和 agent session 日志。

# toolong

## 用途

`toolong` 是 Textualize（Textual 框架的作者）开发的终端应用，用来查看、tail、合并和搜索日志文件（含 JSONL）。上游列出的特性：

- 日志文件的实时 tail
- 对常见 web 服务器日志格式做语法高亮
- 打开多个 GB 的文件和打开小文件一样快
- JSONL 支持：每行 JSON 自动 pretty print
- 自动打开 .bz / .bz2 压缩文件
- 按自动检测的时间戳合并多个日志文件

本仓库的定位：读 `~/.hermes/` 下的日志、journalctl 导出、agent session 日志（通常是 JSONL）——这类文件用 less/grep 看很费劲，toolong 帮你把时间戳高亮、行内 JSON 展开。

## 来源与安装

| 项目 | 说明 |
|---|---|
| 仓库 | `Textualize/toolong`（Python，基于 Textual） |
| 安装器 | `scripts/install/install_pipx_tool.sh`（通用 pipx 安装器） |
| 命令 | `tl` |
| 版本 | 1.5.0（`tl --version` 实测） |

```bash
# 本仓库的安装方式
bash scripts/install/install_pipx_tool.sh toolong tl

# 等价于手动：
pipx install toolong
```

## 基本用法

实际选项以 `tl --help` 为准，全部选项如下：

```text
Usage: tl [OPTIONS] FILE1 FILE2

  View / tail / search log files.

Options:
  --version                Show the version and exit.
  -m, --merge              Merge files.
  -o, --output-merge PATH  Path to save merged file (requires -m).
  --help                   Show this message and exit.
```

```bash
tl app.log                 # 打开单个日志，UI 内可实时 tail
tl access.log error.log    # 多文件（在 UI 内切换）
tl -m a.log b.log          # 按时间戳合并多个日志
tl -m a.log b.log -o merged.log   # 合并结果另存
```

打开后在 UI 里可以搜索（`Ctrl+F`）、用过滤器缩窄行、跟随 tail。具体按键按 `?` 或 UI 内的快捷键面板查看。

## 常用操作

| 操作 | 说明 |
|---|---|
| 打开文件 | `tl <file>`，GB 级文件即时打开，不必等加载 |
| 实时 tail | 打开后自动跟随新增内容 |
| 搜索 | UI 内按 `Ctrl+F` 输入关键词 |
| JSONL 查看 | 每行 JSON 自动 pretty print，字段可高亮 |
| 压缩文件 | `.bz`/`.bz2` 自动解压打开 |
| 合并 | `tl -m a.log b.log`，按自动检测的时间戳归并 |

## 本仓库的配置

- `install_pipx_tool.sh` 把 toolong 装进独立 pipx venv，命令 `tl` 链接到 `~/.local/bin`。
- `init.sh` 在工具段检查 `tl` 命令，缺失时自动调用安装器。
- 没有需要管理的配置文件；toolong 开箱即用。

## 排错

**`tl` 命令不存在**：命令名是 `tl` 而不是 `toolong`。`command -v tl` 确认；没有就重跑 `install_pipx_tool.sh toolong tl --force`。

**打开文件黑屏/卡住**：极老的终端可能不满足 Textual 的渲染要求。换个现代终端（本仓库默认终端即可）。

**JSONL 每行都显示为纯文本**：行内不是合法 JSON 或扩展名/内容不匹配。确认文件确实是 JSON Lines 格式。

**合并后的时间顺序不对**：toolong 靠自动检测时间戳合并，某文件的时间戳格式无法识别时归并会乱。先用单文件打开确认该文件的时间戳能被高亮识别。

**想退出**：`Ctrl+Q` 退出应用。

<!-- lang:en -->

> Summary: toolong (command `tl`) is a log viewer from Textualize: view, tail, merge and search log files plus JSONL in the terminal, with automatic timestamp highlighting and instant opening of multi-GB files. In this repository it is used to read Hermes logs and agent session logs.

# toolong

## Purpose

`toolong` is a terminal application by Textualize (the authors of the Textual framework) for viewing, tailing, merging and searching log files (JSONL included). The upstream feature list:

- Live tailing of log files
- Syntax highlighting for common web server log formats
- As fast to open a multi-gigabyte file as a tiny one
- JSONL support: each line of JSON is pretty printed
- Automatic opening of .bz / .bz2 compressed files
- Merging log files by auto-detected timestamps

Its slot in this repository: reading logs under `~/.hermes/`, journalctl dumps and agent session logs (usually JSONL) — files that are painful with less/grep, and where toolong's timestamp highlighting and in-line JSON expansion help.

## Source and install

| Item | Notes |
|---|---|
| Repository | `Textualize/toolong` (Python, built on Textual) |
| Installer | `scripts/install/install_pipx_tool.sh` (generic pipx installer) |
| Command | `tl` |
| Version | 1.5.0 (verified via `tl --version`) |

```bash
# How this repository installs it
bash scripts/install/install_pipx_tool.sh toolong tl

# Equivalent to:
pipx install toolong
```

## Basic usage

The real option set, straight from `tl --help`:

```text
Usage: tl [OPTIONS] FILE1 FILE2

  View / tail / search log files.

Options:
  --version                Show the version and exit.
  -m, --merge              Merge files.
  -o, --output-merge PATH  Path to save merged file (requires -m).
  --help                   Show this message and exit.
```

```bash
tl app.log                 # open a single log; the UI tails it live
tl access.log error.log    # several files (switch inside the UI)
tl -m a.log b.log          # merge logs by timestamp
tl -m a.log b.log -o merged.log   # save the merge result
```

Once open, the UI offers search (`Ctrl+F`), row filters to narrow the view and tail following. Check the in-UI key panel (press `?`) for the exact keys.

## Common operations

| Operation | Notes |
|---|---|
| Open a file | `tl <file>`; GB-sized files open instantly, no loading wait |
| Live tail | new content is followed automatically once open |
| Search | press `Ctrl+F` in the UI and type a keyword |
| JSONL view | each JSON line is pretty printed with highlighted fields |
| Compressed files | `.bz`/`.bz2` decompress and open automatically |
| Merge | `tl -m a.log b.log`, merged by auto-detected timestamps |

## In this repository

- `install_pipx_tool.sh` installs toolong into a dedicated pipx venv, with the `tl` command linked into `~/.local/bin`.
- `init.sh` checks for the `tl` command in its tools section and calls the installer when missing.
- There is no configuration to manage; toolong works out of the box.

## Troubleshooting

**No `tl` command**: the command is `tl`, not `toolong`. Confirm with `command -v tl`; if absent, rerun `install_pipx_tool.sh toolong tl --force`.

**Black screen or hang on open**: very old terminals may not meet Textual's rendering requirements. Use a modern terminal (the repository default is fine).

**JSONL lines show as plain text**: the lines are not valid JSON, or the content does not match the format. Confirm the file really is JSON Lines.

**Merged output is out of order**: toolong merges by auto-detected timestamps; a file whose timestamp format cannot be recognized will merge badly. Open that file alone first and check its timestamps get highlighted.

**How to quit**: `Ctrl+Q` exits the application.

<!-- lang:ja -->

> 要約：toolong（コマンドは `tl`）は Textualize 製のログビューアです。ターミナルでログファイルや JSONL を表示・tail・マージ・検索し、タイムスタンプを自動ハイライト、数 GB のファイルも即開けます。このリポジトリでは Hermes のログや agent セッションログの閲覧に使います。

# toolong

## 役割

`toolong` は Textual フレームワークの作者 Textualize が開発するターミナルアプリで、ログファイル（JSONL 含む）の表示・tail・マージ・検索を行います。上游が挙げる特徴：

- ログファイルのライブ tail
- 一般的な Web サーバーログ形式のシンタックスハイライト
- 数 GB のファイルも小さなファイルと同じ速さで開ける
- JSONL 対応：各行の JSON を自動で pretty print
- .bz / .bz2 圧縮ファイルを自動で開く
- 自動検出したタイムスタンプで複数ログをマージ

このリポジトリでの位置づけ：`~/.hermes/` 配下のログ、journalctl のダンプ、agent セッションログ（たいてい JSONL）の閲覧です。less/grep では辛いこの手のファイルを、タイムスタンプのハイライトと行内 JSON の展開で快適に読めます。

## 入手とインストール

| 項目 | 説明 |
|---|---|
| リポジトリ | `Textualize/toolong`（Python，Textual ベース） |
| インストーラ | `scripts/install/install_pipx_tool.sh`（汎用 pipx インストーラ） |
| コマンド | `tl` |
| バージョン | 1.5.0（`tl --version` で確認済み） |

```bash
# このリポジトリのインストール方法
bash scripts/install/install_pipx_tool.sh toolong tl

# 手動では以下と同等：
pipx install toolong
```

## 基本的な使い方

実際のオプションは `tl --help` のとおりで、全容は次のとおりです：

```text
Usage: tl [OPTIONS] FILE1 FILE2

  View / tail / search log files.

Options:
  --version                Show the version and exit.
  -m, --merge              Merge files.
  -o, --output-merge PATH  Path to save merged file (requires -m).
  --help                   Show this message and exit.
```

```bash
tl app.log                 # 1 つのログを開く。UI 内でライブ tail
tl access.log error.log    # 複数ファイル（UI 内で切替）
tl -m a.log b.log          # タイムスタンプでマージ
tl -m a.log b.log -o merged.log   # マージ結果を保存
```

開いた後の UI では検索（`Ctrl+F`）、行フィルタでの絞り込み、tail の追従ができます。正確なキーは UI 内のキーパネル（`?`）で確認してください。

## よく使う操作

| 操作 | 説明 |
|---|---|
| ファイルを開く | `tl <file>`。GB 級のファイルも即座に開き、読み込み待ちなし |
| ライブ tail | 開いた後は追加分を自動追従 |
| 検索 | UI 内で `Ctrl+F` を押してキーワード入力 |
| JSONL 表示 | 各 JSON 行を自動 pretty print、フィールドをハイライト |
| 圧縮ファイル | `.bz`/`.bz2` は自動展開して開く |
| マージ | `tl -m a.log b.log`。自動検出したタイムスタンプでマージ |

## このリポジトリでの扱い

- `install_pipx_tool.sh` が toolong を独立した pipx venv に導入し、`tl` コマンドを `~/.local/bin` にリンクします。
- `init.sh` はツール導入部で `tl` コマンドを確認し、無ければインストーラを呼びます。
- 管理すべき設定ファイルはありません。toolong はそのまま動きます。

## トラブルシュート

**`tl` コマンドが無い**：コマンド名は `toolong` ではなく `tl` です。`command -v tl` で確認し、無ければ `install_pipx_tool.sh toolong tl --force` を再実行。

**ファイルを開くと黒画面／固まる**：非常に古いターミナルは Textual の描画要件を満たさないことがあります。モダンなターミナル（本リポジトリの既定端末で可）を使ってください。

**JSONL の各行がただのテキストで表示される**：行が正当な JSON でないか、内容と形式が一致していません。ファイルが本当に JSON Lines 形式か確認してください。

**マージ結果の時系列がおかしい**：toolong は自動検出したタイムスタンプでマージするため、あるファイルの書式を認識できないと順序が崩れます。まずそのファイルを単体で開き、タイムスタンプがハイライトされるか確認してください。

**終了方法**：`Ctrl+Q` でアプリケーションを終了します。
