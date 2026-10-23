> 摘要：tabiew（命令 `tw`）是一个查看/查询表格数据的 TUI，用 SQL 直接查本地 CSV/TSV/parquet 文件，不需要先把数据装进数据库。

# tabiew

## 用途

`tabiew` 是一个轻量级 TUI 应用，用来查看和查询表格数据文件。它的卖点是「用 SQL 查本地文件」：打开一个 CSV/TSV/parquet 后直接按 `:` 输入 SQL 查询，结果就在表格视图里，全程不需要建库、导库。

支持的输入格式（来自 `tw --help`）：dsv、csv、tsv、parquet、jsonl、json、arrow、fwf、sqlite、excel、logfmt、avro、html、markdown。

本仓库的分工：

- 打开文件看一眼、跑几条 SQL → tabiew
- 交互式浏览、编辑、筛选 → [VisiData](visidata.html)
- 批处理/脚本化 → [qsv](qsv.html)

## 来源与安装

| 项目 | 说明 |
|---|---|
| 仓库 | `shshemi/tabiew`（Rust） |
| 安装器 | `scripts/install/install_tabiew.sh`（转发到上游 install.sh） |
| 命令 | `tw`（不是 `tabiew`） |
| 版本 | 0.15.1（`tw --version` 实测） |

```bash
# 本仓库的安装方式
bash scripts/install/install_tabiew.sh

# 上游安装脚本会把预编译二进制装进 PATH；备选方案是
# 从 GitHub Releases 下载 .deb 手动安装
```

## 基本用法

```bash
tw data.csv                    # 打开单个文件
tw a.csv b.csv                 # 同时打开多个文件（t 切换）
tw data.parquet                # parquet 直接开
tw -f jsonl events.json        # 按扩展名猜不出时显式指定格式
tw --infer-schema fast big.csv # 换 schema 推断策略
tw --max-rows 1000 huge.tsv    # 只读前 1000 行
```

打开后按 `:` 进入命令面板，可以执行 `q`（SQL 查询）、`s`（Select）、`Filter`、`Order`、`Export`、`Schema` 等命令。

## 常用键位

来自上游 README 的 Useful Keybindings：

| 键 | 作用 |
|---|---|
| `h j k l` 或方向键 | 移动 |
| `b` / `w` | 上一列 / 下一列 |
| `Ctrl+u` / `Ctrl+d` | 上下翻半页 |
| `Ctrl+b` / `Ctrl+f` | 上下翻整页 |
| `g` / `G`（或 `Home`/`End`） | 首行 / 末行 |
| `e` | 切换自动列宽 |
| `t` | Tab 切换器（多文件间切换） |
| `f` | sheet 内切换默认/JSON 显示格式 |
| `c` | 复制当前行到剪贴板 |
| `Ctrl+r` | 重置数据框 |
| `:` | 命令面板（输入 `q` 跑 SQL） |
| `/` | 模糊搜索 |
| `q` | 关闭当前 sheet |
| `Q` | 退出整个应用 |

## 本仓库的配置

- `install_tabiew.sh` 不碰任何配置文件，只是跑上游 install.sh；tabiew 的配置在 `~/.config/tabiew/config.toml`（本仓库未管理）。
- `init.sh` 在工具段检查 `tw` 命令，缺失时自动调用安装器。
- SQL 方言随文件格式而定：CSV 等文件经内置引擎查询，`.sqlite`/`.db` 文件则直接打开数据库（必要时用 `--sqlite-key` 指定键）。

## 排错

**装完没有 `tabiew` 命令**：命令名是 `tw`。`command -v tw` 确认。

**打开文件提示格式错误**：扩展名不足以判断格式时用 `-f` 显式指定，如 `tw -f csv noext`。

**parquet/avro 打不开**：安装的构建需包含相应特性；确认版本 `tw --version`，必要时用上游最新安装脚本重装。

**大文件打开慢**：schema 推断在扫描文件。加 `--infer-schema fast` 或 `--max-rows` 限制读取量。

**SQL 查询报语法错误**：tabiew 的 SQL 由所用引擎决定，函数支持与标准 SQLite/duckdb 语法不完全一致；先用 `Schema` 命令确认列名和类型。

**解析到一半报错退出**：文件里有脏行。加 `--ignore-errors` 跳过解析错误，或 `--truncate-ragged-lines` 处理列数不齐的行。

<!-- lang:en -->

> Summary: tabiew (command `tw`) is a TUI for viewing and querying tabular data; it runs SQL directly against local CSV/TSV/parquet files without loading anything into a database.

# tabiew

## Purpose

`tabiew` is a lightweight TUI application for viewing and querying tabular data files. Its selling point is "SQL over local files": open a CSV/TSV/parquet, press `:`, type a SQL query, and the result appears in the table view — no database to create or import into.

Supported input formats (from `tw --help`): dsv, csv, tsv, parquet, jsonl, json, arrow, fwf, sqlite, excel, logfmt, avro, html and markdown.

Division of labor in this repository:

- Open a file for a look and run a few queries → tabiew
- Interactive browsing, editing, filtering → [VisiData](visidata.html)
- Batch/scripted processing → [qsv](qsv.html)

## Source and install

| Item | Notes |
|---|---|
| Repository | `shshemi/tabiew` (Rust) |
| Installer | `scripts/install/install_tabiew.sh` (delegates to the upstream install.sh) |
| Command | `tw` (not `tabiew`) |
| Version | 0.15.1 (verified via `tw --version`) |

```bash
# How this repository installs it
bash scripts/install/install_tabiew.sh

# The upstream script installs a prebuilt binary onto PATH; the
# documented alternative is a manual .deb from GitHub Releases
```

## Basic usage

```bash
tw data.csv                    # open a single file
tw a.csv b.csv                 # several files at once (t to switch)
tw data.parquet                # parquet opens directly
tw -f jsonl events.json        # force the format when the extension misleads
tw --infer-schema fast big.csv # pick another schema-inference mode
tw --max-rows 1000 huge.tsv    # read only the first 1000 rows
```

Once open, press `:` for the command palette, which runs commands such as `q` (SQL query), `s` (Select), `Filter`, `Order`, `Export` and `Schema`.

## Common keys

From the upstream README's Useful Keybindings:

| Key | Effect |
|---|---|
| `h j k l` or arrows | move |
| `b` / `w` | previous / next column |
| `Ctrl+u` / `Ctrl+d` | half page up/down |
| `Ctrl+b` / `Ctrl+f` | full page up/down |
| `g` / `G` (or `Home`/`End`) | first / last row |
| `e` | toggle auto-fit widths |
| `t` | tab switcher (between open files) |
| `f` | in-sheet toggle between default and JSON rendering |
| `c` | copy the current row to the clipboard |
| `Ctrl+r` | reset the data frame |
| `:` | command palette (`q` runs SQL) |
| `/` | fuzzy search |
| `q` | close the current sheet |
| `Q` | quit the application |

## In this repository

- `install_tabiew.sh` touches no configuration; it only runs the upstream install.sh. tabiew's own config lives at `~/.config/tabiew/config.toml` (not managed by this repo).
- `init.sh` checks for the `tw` command in its tools section and calls the installer when missing.
- The SQL dialect follows the file type: CSV and friends go through the built-in engine, while `.sqlite`/`.db` files open as databases directly (supply `--sqlite-key` if a key is required).

## Troubleshooting

**No `tabiew` command after install**: the command is `tw`. Confirm with `command -v tw`.

**Format error when opening a file**: when the extension is not enough, pass `-f` explicitly, e.g. `tw -f csv noext`.

**parquet/avro will not open**: the build must include those features. Check `tw --version` and reinstall with the latest upstream install script if needed.

**Large file opens slowly**: schema inference scans the file. Add `--infer-schema fast` or cap the read with `--max-rows`.

**SQL query syntax error**: tabiew's SQL depends on the underlying engine, and function support is not identical to stock SQLite/duckdb syntax; run the `Schema` command first to check column names and types.

**Aborts mid-parse**: the file contains dirty lines. Add `--ignore-errors` to skip parse errors, or `--truncate-ragged-lines` for rows with mismatched column counts.

<!-- lang:ja -->

> 要約：tabiew（コマンドは `tw`）は表データを表示・クエリする TUI です。ローカルの CSV/TSV/parquet に直接 SQL を投げられ、データをデータベースに入れる必要はありません。

# tabiew

## 役割

`tabiew` は表データファイルを表示・クエリする軽量 TUI アプリです。売りは「ローカルファイルへの SQL」：CSV/TSV/parquet を開いて `:` を押し、SQL を入力すると結果がテーブルビューに表示されます。データベースの作成もインポートも不要です。

対応フォーマット（`tw --help` より）：dsv、csv、tsv、parquet、jsonl、json、arrow、fwf、sqlite、excel、logfmt、avro、html、markdown。

このリポジトリでの分担：

- ファイルを開いて眺め、SQL を数本試す → tabiew
- 対話的な閲覧・編集・フィルタ → [VisiData](visidata.html)
- バッチ・スクリプト処理 → [qsv](qsv.html)

## 入手とインストール

| 項目 | 説明 |
|---|---|
| リポジトリ | `shshemi/tabiew`（Rust） |
| インストーラ | `scripts/install/install_tabiew.sh`（上游の install.sh に委譲） |
| コマンド | `tw`（`tabiew` ではない） |
| バージョン | 0.15.1（`tw --version` で確認済み） |

```bash
# このリポジトリのインストール方法
bash scripts/install/install_tabiew.sh

# 上游スクリプトがプリビルドバイナリを PATH に導入します。
# 代替手段は GitHub Releases から .deb を手動インストール
```

## 基本的な使い方

```bash
tw data.csv                    # 1 ファイルを開く
tw a.csv b.csv                 # 複数ファイルを同時に開く（t で切替）
tw data.parquet                # parquet も直接開ける
tw -f jsonl events.json        # 拡張子で判別できない場合は -f で指定
tw --infer-schema fast big.csv # スキーマ推論のモードを変更
tw --max-rows 1000 huge.tsv    # 先頭 1000 行だけ読む
```

開いたら `:` でコマンドパレットを出し、`q`（SQL クエリ）、`s`（Select）、`Filter`、`Order`、`Export`、`Schema` などを実行できます。

## 主なキー

上游 README の Useful Keybindings より：

| キー | 効果 |
|---|---|
| `h j k l` または矢印 | 移動 |
| `b` / `w` | 前の列／次の列 |
| `Ctrl+u` / `Ctrl+d` | 半ページ上下 |
| `Ctrl+b` / `Ctrl+f` | 1 ページ上下 |
| `g` / `G`（または `Home`/`End`） | 先頭行／最終行 |
| `e` | 自動列幅のトグル |
| `t` | タブ切替器（開いたファイル間） |
| `f` | シート内で既定／JSON 表示を切替 |
| `c` | 現在行をクリップボードへコピー |
| `Ctrl+r` | データフレームをリセット |
| `:` | コマンドパレット（`q` で SQL） |
| `/` | ファジー検索 |
| `q` | 現在のシートを閉じる |
| `Q` | アプリケーションを終了 |

## このリポジトリでの扱い

- `install_tabiew.sh` は設定ファイルに触れず、上游の install.sh を実行するだけです。tabiew 自身の設定は `~/.config/tabiew/config.toml` にあります（本リポジトリでは未管理）。
- `init.sh` はツール導入部で `tw` コマンドを確認し、無ければインストーラを呼びます。
- SQL の方言はファイル形式に依存します：CSV などは内蔵エンジンでクエリし、`.sqlite`/`.db` はそのままデータベースとして開きます（必要なら `--sqlite-key` でキーを指定）。

## トラブルシュート

**インストール後に `tabiew` コマンドが無い**：コマンド名は `tw` です。`command -v tw` で確認。

**ファイルを開くとフォーマットエラー**：拡張子だけでは判別できないときは `-f` で明示します（例：`tw -f csv noext`）。

**parquet/avro が開かない**：そのビルドに当該機能が含まれていない可能性。`tw --version` で確認し、必要なら上游の最新インストールスクリプトで再導入。

**大きなファイルのオープンが遅い**：スキーマ推論がファイルを走査しています。`--infer-schema fast` を付けるか、`--max-rows` で読み込み量を制限。

**SQL が構文エラーになる**：tabiew の SQL は使っているエンジン次第で、関数の対応が標準の SQLite/duckdb と完全一致するとは限りません。先に `Schema` コマンドで列名と型を確認。

**解析の途中でエラー終了**：ファイルに壊れた行があります。`--ignore-errors` で解析エラーをスキップするか、列数の不揃いな行には `--truncate-ragged-lines`。
