> 摘要：qsv 是 Rust 写的 CSV 数据整备工具箱，100+ 个子命令覆盖统计、校验、清洗、连接、排序到 LLM 描述，本仓库用它做批处理/脚本化的表格处理，与交互式的 VisiData、SQL 的 tabiew 互补。

# qsv

## 用途

`qsv` 是一个「blazing-fast」的 CSV/TSV/parquet 数据整备（data-wrangling）工具箱，单二进制、多线程。它的形态类似 xsv/csvkit 的现代续作：`qsv <command> <args>` 一条命令吃进 CSV、吐出 CSV 或报告，适合放进管道和脚本。

`qsv --list` 列出的子命令有 100+ 个。本仓库主要把它当「批处理那一环」：

- 大文件统计、去重、排序、连接 → 写脚本跑 qsv
- 边看边改 → [VisiData](visidata.html)
- 本地文件跑 SQL → [tabiew](tabiew.html)

## 来源与安装

| 项目 | 说明 |
|---|---|
| 仓库 | `dathere/qsv`（Rust） |
| 安装器 | `scripts/install/install_qsv.sh` |
| 二进制 | 预编译版（prebuilt-pgo），安装到 `~/.local/bin` |
| 硬件要求 | 预编译版需要 AVX2（x86-64-v3）；没有则需源码编译 |
| 版本 | 26.0.0（`qsv --version` 实测） |

```bash
# 本仓库的安装方式
bash scripts/install/install_qsv.sh

# 脚本从 GitHub Releases 下载预编译 zip 解压到 ~/.local/bin；
# CPU 缺 AVX2 时脚本会拒绝安装并提示改用：
cargo install qsv --locked --features apply,fetch,foreach,prompt,self_update,to,Polars
```

## 基本用法

```bash
qsv --list                      # 列出全部子命令
qsv <command> --help            # 查看某个子命令的帮助
qsv stats data.csv              # 每列的汇总统计
qsv stats data.csv --output stats.csv
qsv -u                          # 从 GitHub 更新 qsv
```

常用选项（`qsv --help`）：`--envlist` 列出相关环境变量，`--capabilities` 以 JSON 输出版本与特性，`-U`（updatenow）跳过确认直接更新。

## 常用命令

以下描述均摘自 `qsv <cmd> --help`：

| 命令 | 作用 |
|---|---|
| `stats` | 计算每列的汇总统计并推断数据类型（针对格式良好的 UTF-8 CSV 高速优化） |
| `schema` | 从 CSV 生成 JSON Schema（Draft 2020-12）或 Polars Schema |
| `validate` | 两种模式：拿 JSON Schema 校验 CSV，或校验 RFC4180 合规性 |
| `dedup` | 行去重（需整表进内存；已排序文件可用 `--sorted` 免排序） |
| `join` | 按指定列连接两组 CSV，默认 inner join |
| `sort` | 按字典/自然/数值/逆序/唯一/随机排序（整表进内存） |
| `select` | 高效选择/重排/复制/反转/删除列，支持索引、列名与范围 |
| `extsort` | 多线程外部排序，可处理装不进内存的超大文件 |
| `luau` | 用 Luau 脚本为每行创建计算列、过滤行或做聚合——qsv 的 DSL |
| `describegpt` | 把统计摘要喂给 OpenAI 兼容的 LLM，生成数据字典/描述/标签 |

组合示例：

```bash
# 先看每列的类型与统计，再生成 schema 供 validate 用
qsv stats data.csv
qsv schema data.csv --output schema.json
qsv validate data.csv --schema schema.json

# 去掉重复行后按第三列数值排序
qsv dedup data.csv | qsv sort --select 3 --numeric

# 两文件按 id 列内连接
qsv join id a.csv id b.csv

# luau：给每行加一列 computed = a + b
qsv luau map data.csv computed 'a + b'
```

## 本仓库的配置

- `install_qsv.sh` 只下载 GitHub Releases 的预编译二进制放进 `~/.local/bin`，不生成配置文件。qsv 的行为调优主要靠环境变量（`qsv --envlist` 查看）。
- `init.sh` 在工具段检查 `qsv` 命令，缺失时自动调用安装器。
- 预编译版是针对 AVX2 编译的，在不支持的 CPU 上会直接 SIGILL——安装脚本已经替你挡住这种情况。

## 排错

**运行即 Illegal instruction（SIGILL）**：CPU 不支持 AVX2 却装了预编译版。按安装器提示用 `cargo install qsv --locked --features ...` 源码编译。

**`qsv: command not found`**：`~/.local/bin` 不在 PATH。确认后重跑 `install_qsv.sh --force`。

**stats 报 undefined behavior / 结果怪**：`stats` 假设 CSV 格式良好且 UTF-8 编码以换取速度。先用 `qsv validate` 检查输入。

**dedup/sort 内存吃满**：这两个命令要把全表读进内存。大文件换 `extsort`（排序）或先分片处理。

**luau 脚本报错**：Luau 与标准 Lua 不完全一致（沙箱化的子集+扩展）。查 `qsv luau --help` 和上游文档确认可用 API。

**describegpt 连不上**：需要 OpenAI API 兼容端点与 key，通过环境变量配置；`qsv --envlist` 找到相关变量名。

<!-- lang:en -->

> Summary: qsv is a Rust CSV data-wrangling toolkit with 100+ subcommands spanning stats, validation, cleaning, joins, sorting and LLM descriptions; in this repository it handles batch/scripted tabular processing, complementing interactive VisiData and SQL-flavored tabiew.

# qsv

## Purpose

`qsv` is a "blazing-fast" CSV/TSV/parquet data-wrangling toolkit: a single multithreaded binary. Think of it as the modern successor to xsv/csvkit — `qsv <command> <args>` takes a CSV in and emits a CSV or a report, which makes it a natural fit for pipes and scripts.

`qsv --list` shows 100+ subcommands. In this repository it plays the "batch" role:

- Stats, dedup, sort or join on large files → script it with qsv
- Look and change as you go → [VisiData](visidata.html)
- SQL over local files → [tabiew](tabiew.html)

## Source and install

| Item | Notes |
|---|---|
| Repository | `dathere/qsv` (Rust) |
| Installer | `scripts/install/install_qsv.sh` |
| Binary | prebuilt (prebuilt-pgo), installed into `~/.local/bin` |
| Hardware | the prebuilt needs AVX2 (x86-64-v3); without it, build from source |
| Version | 26.0.0 (verified via `qsv --version`) |

```bash
# How this repository installs it
bash scripts/install/install_qsv.sh

# The script downloads a prebuilt zip from GitHub Releases into ~/.local/bin;
# on a CPU without AVX2 it refuses and suggests instead:
cargo install qsv --locked --features apply,fetch,foreach,prompt,self_update,to,Polars
```

## Basic usage

```bash
qsv --list                      # list every subcommand
qsv <command> --help            # help for one command
qsv stats data.csv              # summary statistics per column
qsv stats data.csv --output stats.csv
qsv -u                          # update qsv from GitHub
```

Useful top-level options (`qsv --help`): `--envlist` lists relevant environment variables, `--capabilities` prints version and features as JSON, `-U` (updatenow) updates without confirming.

## Common commands

Descriptions below are quoted from `qsv <cmd> --help`:

| Command | Effect |
|---|---|
| `stats` | computes summary statistics and infers types per column (heavily optimized for well-formed UTF-8 CSVs) |
| `schema` | generates a JSON Schema (Draft 2020-12) or Polars Schema from CSV data |
| `validate` | two modes: validate a CSV against a JSON Schema, or check RFC4180 compliance |
| `dedup` | deduplicate rows (loads the whole file; `--sorted` skips sorting pre-sorted input) |
| `join` | joins two CSVs on given columns; the default is an inner join |
| `sort` | lexicographical/natural/numerical/reverse/unique/random sort (loads the whole file) |
| `select` | efficiently select/reorder/duplicate/reverse/drop columns by index, name or range |
| `extsort` | multithreaded external sort for arbitrarily large files |
| `luau` | creates computed columns, filters rows or aggregates via a Luau script — qsv's DSL |
| `describegpt` | feeds summary stats to an OpenAI-compatible LLM to produce a data dictionary/description/tags |

Recipes:

```bash
# inspect types and stats, then build a schema for validation
qsv stats data.csv
qsv schema data.csv --output schema.json
qsv validate data.csv --schema schema.json

# drop duplicates, then sort numerically by the third column
qsv dedup data.csv | qsv sort --select 3 --numeric

# inner-join two files on the id column
qsv join id a.csv id b.csv

# luau: add a computed = a + b column to every row
qsv luau map data.csv computed 'a + b'
```

## In this repository

- `install_qsv.sh` only downloads the prebuilt binary from GitHub Releases into `~/.local/bin`; it creates no config file. qsv tuning is done through environment variables (see `qsv --envlist`).
- `init.sh` checks for the `qsv` command in its tools section and calls the installer when missing.
- The prebuilt binary is compiled for AVX2 and crashes with SIGILL on CPUs lacking it — the installer screens for that case.

## Troubleshooting

**Illegal instruction (SIGILL) on launch**: the CPU lacks AVX2 but a prebuilt binary was installed. Compile from source as the installer suggests: `cargo install qsv --locked --features ...`.

**`qsv: command not found`**: `~/.local/bin` is not on PATH. Fix PATH and rerun `install_qsv.sh --force`.

**stats behaves oddly / undefined behavior**: `stats` assumes a well-formed, UTF-8 CSV in exchange for speed. Check the input with `qsv validate` first.

**dedup/sort exhaust memory**: both load the whole table. For large files use `extsort` (sorting) or split the input first.

**luau script errors**: Luau is not stock Lua — it is a sandboxed subset with extensions. Check `qsv luau --help` and the upstream docs for the available API.

**describegpt cannot connect**: it needs an OpenAI-compatible endpoint and key, configured via environment variables; `qsv --envlist` lists the names.

<!-- lang:ja -->

> 要約：qsv は Rust 製の CSV データ整形ツールキットで、100+ のサブコマンドが統計・検証・クリーニング・結合・ソートから LLM による記述生成までを網羅します。このリポジトリではバッチ／スクリプト処理を担い、対話の VisiData、SQL の tabiew と補完関係にあります。

# qsv

## 役割

`qsv` は「blazing-fast」を謳う CSV/TSV/parquet データ整形（data-wrangling）ツールキットで、単一バイナリ・マルチスレッドです。xsv/csvkit の現代的後継とも言える形で、`qsv <command> <args>` の 1 コマンドが CSV を受け取り CSV やレポートを出力するため、パイプやスクリプトに組み込みやすい構造です。

`qsv --list` には 100+ のサブコマンドが並びます。このリポジトリでは「バッチ処理」の担当です：

- 大きなファイルの統計・重複排除・ソート・結合 → qsv でスクリプト化
- 見ながら編集 → [VisiData](visidata.html)
- ローカルファイルに SQL → [tabiew](tabiew.html)

## 入手とインストール

| 項目 | 説明 |
|---|---|
| リポジトリ | `dathere/qsv`（Rust） |
| インストーラ | `scripts/install/install_qsv.sh` |
| バイナリ | プリビルド（prebuilt-pgo）、`~/.local/bin` へ導入 |
| ハードウェア要件 | プリビルドは AVX2（x86-64-v3）必須。無ければソースビルド |
| バージョン | 26.0.0（`qsv --version` で確認済み） |

```bash
# このリポジトリのインストール方法
bash scripts/install/install_qsv.sh

# スクリプトは GitHub Releases のプリビルド zip を ~/.local/bin に展開します。
# CPU が AVX2 非対応の場合は拒否され、次を提案します：
cargo install qsv --locked --features apply,fetch,foreach,prompt,self_update,to,Polars
```

## 基本的な使い方

```bash
qsv --list                      # 全サブコマンドを一覧
qsv <command> --help            # サブコマンドのヘルプ
qsv stats data.csv              # 列ごとの要約統計
qsv stats data.csv --output stats.csv
qsv -u                          # GitHub から qsv を更新
```

便利なトップレベルオプション（`qsv --help` より）：`--envlist` は関連環境変数の一覧、`--capabilities` はバージョンと機能を JSON で出力、`-U`（updatenow）は確認なしで更新します。

## 主なコマンド

以下の説明は `qsv <cmd> --help` からの抜粋です：

| コマンド | 効果 |
|---|---|
| `stats` | 列ごとの要約統計を計算し型を推論（整形式 UTF-8 CSV 向けに高速化） |
| `schema` | CSV から JSON Schema（Draft 2020-12）または Polars Schema を生成 |
| `validate` | 2 モード：JSON Schema による検証、または RFC4180 準拠チェック |
| `dedup` | 行の重複排除（全データをメモリへ。`--sorted` でソート済み入力を高速化） |
| `join` | 指定列で 2 つの CSV を結合。既定は inner join |
| `sort` | 辞書／自然／数値／逆順／一意／ランダムでソート（全データをメモリへ） |
| `select` | 列を選択・並べ替え・複製・反転・削除。索引・列名・範囲に対応 |
| `extsort` | マルチスレッドの外部ソート。メモリに載らない巨大ファイル向け |
| `luau` | Luau スクリプトで行ごとの計算列作成・フィルタ・集計を行う qsv の DSL |
| `describegpt` | 統計サマリを OpenAI 互換 LLM に渡し、データ辞書・説明・タグを生成 |

組み合わせの例：

```bash
# 各列の型と統計を見てから、validate 用の schema を作る
qsv stats data.csv
qsv schema data.csv --output schema.json
qsv validate data.csv --schema schema.json

# 重複行を除いて 3 列目で数値ソート
qsv dedup data.csv | qsv sort --select 3 --numeric

# id 列で 2 ファイルを内部結合
qsv join id a.csv id b.csv

# luau：各行に computed = a + b 列を追加
qsv luau map data.csv computed 'a + b'
```

## このリポジトリでの扱い

- `install_qsv.sh` は GitHub Releases のプリビルドバイナリを `~/.local/bin` に置くだけで、設定ファイルは作りません。qsv の調整は環境変数で行います（`qsv --envlist` で確認）。
- `init.sh` はツール導入部で `qsv` コマンドを確認し、無ければインストーラを呼びます。
- プリビルドは AVX2 向けにコンパイルされており、非対応 CPU では SIGILL で即落ちします。このケースはインストーラが事前にはじいています。

## トラブルシュート

**起動直後に Illegal instruction（SIGILL）**：AVX2 非対応 CPU にプリビルドを入れた場合。インストーラの案内どおり `cargo install qsv --locked --features ...` でソースビルドする。

**`qsv: command not found`**：`~/.local/bin` が PATH に無い。確認して `install_qsv.sh --force` を再実行。

**stats の結果がおかしい／undefined behavior**：`stats` は速度と引き換えに整形式・UTF-8 の CSV を前提としています。先に `qsv validate` で入力を確認。

**dedup/sort でメモリが足りない**：両コマンドとも全表をメモリに読み込みます。大きなファイルは `extsort`（ソート）にするか、入力を分割して処理。

**luau スクリプトがエラー**：Luau は標準 Lua とは限らない（サンドボックス化したサブセット＋拡張）。`qsv luau --help` と上游ドキュメントで使える API を確認。

**describegpt が接続できない**：OpenAI 互換エンドポイントとキーを環境変数で設定する必要があります。変数名は `qsv --envlist` で確認。
