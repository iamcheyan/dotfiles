> 摘要：harlequin 是终端 SQL IDE，TUI 里编辑、运行、分栏查看查询结果；本仓库用 pipx 安装，附带面向 agent 的 `hsql` 命令。

# harlequin

## 用途

[harlequin](https://harlequin.sh) 是一个跑在终端里的 SQL IDE：左侧目录树（数据库对象、文件、S3 桶），中间 SQL 编辑器，下方结果查看器，全部在一个 TUI 里完成。它通过「适配器」插件连接不同数据库，本机安装了 `duckdb` 和 `sqlite` 两个适配器。

同一个 pipx 包还提供 `hsql`：不进 TUI，直接执行 SQL 并退出，输出表格/JSON/CSV 等格式。TUI 适合人来交互探索，`hsql` 适合脚本和 agent 调用。

在本仓库的角色：

| 场景 | 用哪个 |
|---|---|
| 交互式探索本地 sqlite/duckdb 文件 | `harlequin` |
| 脚本、agent 执行 SQL 拿结果 | `hsql` |
| 两个命令共用查询历史与配置文件 | 自动 |

## 来源与安装

| 项目 | 说明 |
|---|---|
| 仓库 | [tconbeer/harlequin](https://github.com/tconbeer/harlequin)（Python） |
| 安装器 | `scripts/install/install_pipx_tool.sh`（通用 pipx 安装器） |
| 二进制 | `~/.local/bin/harlequin`、`~/.local/bin/hsql` |
| 适配器 | duckdb 2.16.2、sqlite 2.16.2（`harlequin --version` 可见） |

```bash
bash scripts/install/install_pipx_tool.sh harlequin harlequin
harlequin --version    # harlequin, version 2.16.2，并列出已装适配器
```

## 基本用法

```bash
# 打开 IDE，连接本地数据库文件
harlequin data.duckdb
harlequin app.sqlite

# 显式指定适配器（默认 duckdb）
harlequin -a sqlite app.sqlite

# 只读打开，拒绝任何写操作
harlequin -r data.duckdb

# 命令行配置向导 / 键位配置应用
harlequin --config
harlequin --keys

# 通过 SSH 隧道连接远端库
harlequin --ssh-host myhost --ssh-forward 5432:db.internal:5432
```

`hsql` 的用法：

```bash
hsql data.duckdb -c "SELECT count(*) FROM users"
hsql app.sqlite --adapter sqlite -f query.sql --format json
cat rows.csv | hsql -c "SELECT * FROM 'rows.csv'"   # duckdb 读 CSV
hsql data.duckdb -c "SELECT 1" -o out/               # 结果写到目录/文件
hsql data.duckdb -c "SELECT 1" --timeout 5           # 5 秒后取消并以退出码 4 结束
```

## 常用命令或键位

### harlequin IDE 选项（来自 `harlequin --help`）

| 选项 | 作用 |
|---|---|
| `CONN_STR...` | 一个或多个连接字符串/本地数据库文件路径 |
| `-a` / `--adapter NAME` | 数据库适配器插件名，默认 `duckdb` |
| `-r` / `--read-only` | 只读连接；适配器做不到就拒绝启动 |
| `-P` / `--profile NAME` | 从配置文件加载指定 profile |
| `-f` / `--show-files DIR` | 在数据目录树里显示某个本地目录 |
| `--show-s3 BUCKET` | 在数据目录树里显示 S3 对象，`all` 显示全部 |
| `-t` / `--theme NAME` | 主题（textual-dark、gruvbox、dracula 等） |
| `--keymap-name NAME` | 加载键位方案，可重复叠加 |
| `--limit N` | 默认行数限制；不设则取全部行 |
| `-o` / `--output PATH` | 数据导出器的默认目标 |
| `--no-write-history` | 本次会话不写入查询历史 |
| `--config` / `--keys` | 运行配置向导 / 键位配置应用 |

### hsql 选项（来自 `hsql --help`）

| 选项 | 作用 |
|---|---|
| `-c` / `--command SQL` | 要执行的 SQL，可重复 |
| `-f` / `--file PATH` | 从文件执行 SQL，`-` 表示 stdin，可重复 |
| `-o` / `--output PATH` | 结果写入文件或目录而不是 stdout |
| `--format NAME` | 输出格式，默认 `table` |
| `--csv` / `--json` / `--jsonl` / `--markdown` | 对应格式的简写 |
| `-x` / `--vertical` | 竖排输出（同 psql） |
| `-t` / `--tuples-only` | 只输出行，不带表头页脚 |
| `-A` / `--no-align` | 不对齐输出 |
| `--timeout SECONDS` | 超时取消并退出码 4 |
| `-a` / `--adapter NAME` | 适配器，默认 `duckdb` |
| `-r` / `--read-only` | 只读连接 |

## 本仓库的配置

- 安装走通用 pipx 安装器，不单独维护配置文件；harlequin 自己的配置按上游约定从当前目录和 `~` 下的 `.harlequin.toml` 合并读取，需要时再创建。
- harlequin 和 hsql 共享同一份查询历史与 profile 配置，`--no-write-history` 可跳过记录。
- 配置文件路径可用环境变量 `HARLEQUIN_CONFIG_PATH` 或 `--config-path` 覆盖。
- 本仓库文档索引（build.py）里登记了 harlequin：终端 SQL IDE，附带 hsql agent 客户端。

## 排错

**`harlequin -a mysql` 之类的适配器报错**：适配器是独立插件，本机只装了 duckdb 和 sqlite（`harlequin --version` 可确认）。要别的数据库需按上游文档 pipx 注入对应插件。

**查询很慢、结果卡住**：默认不限制行数。用 `--limit` 设默认限制，或用 `hsql --timeout` 加超时。

**连不上远端数据库**：SSH 隧道参数写错。`--ssh-forward` 的格式与 `ssh -L` 一致（`LOCAL:HOST:REMOTE`）；ssh 配置里已有 LocalForward 时不要再传。

**hsql 输出乱成一团**：选错格式。机器消费用 `--json`/`--jsonl`，人看用默认 `table` 或 `-x` 竖排。

**pipx 升级后 hsql 消失**：hsql 是 harlequin 包的入口点之一，单独重装 harlequin 即可恢复。

<!-- lang:en -->

> Summary: harlequin is a terminal SQL IDE — edit, run, and view query results in panes inside a TUI. Installed in this repo via pipx, and it ships the agent-friendly `hsql` command.

# harlequin

## Purpose

[harlequin](https://harlequin.sh) is a SQL IDE that runs in the terminal: a data catalog sidebar (database objects, files, S3 buckets), a SQL editor in the middle, and a results viewer below, all inside one TUI. It connects to different databases through adapter plug-ins; this machine has the `duckdb` and `sqlite` adapters installed.

The same pipx package also provides `hsql`: no TUI, just execute SQL and exit, printing table/JSON/CSV output. The TUI is for interactive exploration; `hsql` is for scripts and agents.

Role in this repository:

| Scenario | Which one |
|---|---|
| Interactive exploration of local sqlite/duckdb files | `harlequin` |
| Scripts and agents running SQL for results | `hsql` |
| Both commands share query history and config files | automatic |

## Source and install

| Item | Notes |
|---|---|
| Repository | [tconbeer/harlequin](https://github.com/tconbeer/harlequin) (Python) |
| Installer | `scripts/install/install_pipx_tool.sh` (generic pipx installer) |
| Binaries | `~/.local/bin/harlequin`, `~/.local/bin/hsql` |
| Adapters | duckdb 2.16.2, sqlite 2.16.2 (visible via `harlequin --version`) |

```bash
bash scripts/install/install_pipx_tool.sh harlequin harlequin
harlequin --version    # harlequin, version 2.16.2, plus installed adapters
```

## Basic usage

```bash
# open the IDE on a local database file
harlequin data.duckdb
harlequin app.sqlite

# pick the adapter explicitly (default is duckdb)
harlequin -a sqlite app.sqlite

# read-only, refuse any writes
harlequin -r data.duckdb

# the config wizard / the key-binding config app
harlequin --config
harlequin --keys

# reach a remote database through an SSH tunnel
harlequin --ssh-host myhost --ssh-forward 5432:db.internal:5432
```

`hsql` usage:

```bash
hsql data.duckdb -c "SELECT count(*) FROM users"
hsql app.sqlite --adapter sqlite -f query.sql --format json
cat rows.csv | hsql -c "SELECT * FROM 'rows.csv'"   # duckdb reads CSV
hsql data.duckdb -c "SELECT 1" -o out/               # write results to a dir/file
hsql data.duckdb -c "SELECT 1" --timeout 5           # cancel after 5s, exit code 4
```

## Common options and keys

### harlequin IDE options (from `harlequin --help`)

| Option | Effect |
|---|---|
| `CONN_STR...` | one or more connection strings / local db file paths |
| `-a` / `--adapter NAME` | database adapter plug-in name, default `duckdb` |
| `-r` / `--read-only` | connect read-only; refuse to start if the adapter cannot |
| `-P` / `--profile NAME` | load the given profile from the config file |
| `-f` / `--show-files DIR` | show a local directory in the data catalog tree |
| `--show-s3 BUCKET` | show S3 objects in the catalog, `all` for every bucket |
| `-t` / `--theme NAME` | theme (textual-dark, gruvbox, dracula, ...) |
| `--keymap-name NAME` | load a keymap; repeatable, later ones win |
| `--limit N` | default row limit; unset means fetch all rows |
| `-o` / `--output PATH` | default target for the data exporter |
| `--no-write-history` | do not record this session in the query history |
| `--config` / `--keys` | run the config wizard / the keymap config app |

### hsql options (from `hsql --help`)

| Option | Effect |
|---|---|
| `-c` / `--command SQL` | SQL to execute; repeatable |
| `-f` / `--file PATH` | execute SQL from a file, `-` for stdin; repeatable |
| `-o` / `--output PATH` | write results to a file or directory instead of stdout |
| `--format NAME` | output format, default `table` |
| `--csv` / `--json` / `--jsonl` / `--markdown` | shorthands for the matching format |
| `-x` / `--vertical` | vertical output (as in psql) |
| `-t` / `--tuples-only` | rows only: no header, no footer |
| `-A` / `--no-align` | unaligned output |
| `--timeout SECONDS` | cancel after the timeout and exit 4 |
| `-a` / `--adapter NAME` | adapter, default `duckdb` |
| `-r` / `--read-only` | connect read-only |

## Configuration in this repository

- Installation goes through the generic pipx installer; no repo-side config is maintained. Harlequin's own config is, per upstream convention, merged from `.harlequin.toml` files in the current directory and `~`; create one when needed.
- harlequin and hsql share the same query history and profile config; `--no-write-history` skips recording.
- The config path can be overridden with the `HARLEQUIN_CONFIG_PATH` env var or `--config-path`.
- Harlequin is registered in this repo's docs index (build.py): terminal SQL IDE with the hsql agent client.

## Troubleshooting

**`harlequin -a mysql` and similar adapter errors**: adapters are separate plug-ins; only duckdb and sqlite are installed here (check `harlequin --version`). Other databases require pipx-injecting the matching adapter per upstream docs.

**Slow queries / stuck results**: there is no row limit by default. Set a default with `--limit`, or use `hsql --timeout`.

**Cannot reach a remote database**: SSH tunnel flags are wrong. `--ssh-forward` follows `ssh -L` syntax (`LOCAL:HOST:REMOTE`); if your ssh config already has the LocalForward, don't pass it again.

**hsql output is a mess**: wrong format. Use `--json`/`--jsonl` for machines, the default `table` or `-x` vertical for humans.

**hsql disappeared after a pipx upgrade**: hsql is one of the harlequin package's entry points; reinstalling harlequin restores it.

<!-- lang:ja -->

> 要約：harlequin はターミナル上の SQL IDE です。TUI の中で SQL を編集・実行し、結果をペインで確認できます。このリポジトリでは pipx でインストールし、エージェント向けの `hsql` コマンドも同梱しています。

# harlequin

## 役割

[harlequin](https://harlequin.sh) はターミナルで動く SQL IDE です。左にデータカタログ（データベースオブジェクト、ファイル、S3 バケット）、中央に SQL エディタ、下に結果ビューアが並び、すべて 1 つの TUI に収まっています。データベースへの接続は「アダプタ」プラグインで行い、このマシンには `duckdb` と `sqlite` のアダプタが入っています。

同じ pipx パッケージは `hsql` も提供します。TUI に入らず SQL を実行して終了し、表・JSON・CSV などの形式で出力します。TUI は人間の対話的な探索に、`hsql` はスクリプトやエージェント向けです。

このリポジトリでの役割：

| 場面 | 使うもの |
|---|---|
| ローカルの sqlite/duckdb ファイルを対話的に探索 | `harlequin` |
| スクリプトやエージェントが SQL を実行して結果を得る | `hsql` |
| 両コマンドはクエリ履歴と設定ファイルを共有 | 自動 |

## 入手とインストール

| 項目 | 説明 |
|---|---|
| リポジトリ | [tconbeer/harlequin](https://github.com/tconbeer/harlequin)（Python） |
| インストーラ | `scripts/install/install_pipx_tool.sh`（汎用 pipx インストーラ） |
| バイナリ | `~/.local/bin/harlequin`、`~/.local/bin/hsql` |
| アダプタ | duckdb 2.16.2、sqlite 2.16.2（`harlequin --version` で確認可） |

```bash
bash scripts/install/install_pipx_tool.sh harlequin harlequin
harlequin --version    # harlequin, version 2.16.2 と、インストール済みアダプタ一覧
```

## 基本的な使い方

```bash
# ローカルの DB ファイルで IDE を開く
harlequin data.duckdb
harlequin app.sqlite

# アダプタを明示（既定は duckdb）
harlequin -a sqlite app.sqlite

# 読み取り専用で開き、書き込みは一切拒否
harlequin -r data.duckdb

# 設定ウィザード／キーバインド設定アプリ
harlequin --config
harlequin --keys

# SSH トンネル経由でリモート DB に接続
harlequin --ssh-host myhost --ssh-forward 5432:db.internal:5432
```

`hsql` の使い方：

```bash
hsql data.duckdb -c "SELECT count(*) FROM users"
hsql app.sqlite --adapter sqlite -f query.sql --format json
cat rows.csv | hsql -c "SELECT * FROM 'rows.csv'"   # duckdb は CSV を読める
hsql data.duckdb -c "SELECT 1" -o out/               # 結果をディレクトリ／ファイルへ
hsql data.duckdb -c "SELECT 1" --timeout 5           # 5 秒でキャンセル、終了コード 4
```

## よく使うオプションとキー

### harlequin IDE のオプション（`harlequin --help` より）

| オプション | 効果 |
|---|---|
| `CONN_STR...` | 接続文字列／ローカル DB ファイルパスを 1 つ以上 |
| `-a` / `--adapter NAME` | アダプタプラグイン名。既定 `duckdb` |
| `-r` / `--read-only` | 読み取り専用で接続。できなければ起動しない |
| `-P` / `--profile NAME` | 設定ファイルから指定プロファイルを読み込む |
| `-f` / `--show-files DIR` | ローカルディレクトリをデータカタログに表示 |
| `--show-s3 BUCKET` | S3 オブジェクトをカタログに表示。`all` で全バケット |
| `-t` / `--theme NAME` | テーマ（textual-dark、gruvbox、dracula など） |
| `--keymap-name NAME` | キーマップを読み込み。繰り返し指定可、後のものが優先 |
| `--limit N` | 既定の行数制限。未指定なら全行取得 |
| `-o` / `--output PATH` | データエクスポータの既定出力先 |
| `--no-write-history` | このセッションをクエリ履歴に記録しない |
| `--config` / `--keys` | 設定ウィザード／キーマップ設定アプリを起動 |

### hsql のオプション（`hsql --help` より）

| オプション | 効果 |
|---|---|
| `-c` / `--command SQL` | 実行する SQL。繰り返し指定可 |
| `-f` / `--file PATH` | ファイルから SQL を実行。`-` は stdin。繰り返し可 |
| `-o` / `--output PATH` | stdout の代わりにファイル／ディレクトリへ出力 |
| `--format NAME` | 出力形式。既定 `table` |
| `--csv` / `--json` / `--jsonl` / `--markdown` | 各形式の shorthand |
| `-x` / `--vertical` | 縦並び出力（psql と同様） |
| `-t` / `--tuples-only` | 行のみ。ヘッダ・フッタなし |
| `-A` / `--no-align` | 整形なし出力 |
| `--timeout SECONDS` | 指定秒でキャンセルし終了コード 4 |
| `-a` / `--adapter NAME` | アダプタ。既定 `duckdb` |
| `-r` / `--read-only` | 読み取り専用で接続 |

## このリポジトリでの設定

- インストールは汎用 pipx インストーラ経由で、リポジトリ側の設定ファイルは持たない。harlequin 本体の設定は上流の流儀に従い、カレントディレクトリと `~` の `.harlequin.toml` をマージして読みます。必要になったら作成します。
- harlequin と hsql は同じクエリ履歴とプロファイル設定を共有します。記録したくなければ `--no-write-history`。
- 設定ファイルの場所は環境変数 `HARLEQUIN_CONFIG_PATH` か `--config-path` で上書きできます。
- harlequin はこのリポジトリのドキュメント索引（build.py）にも登録済み：hsql エージェントクライアント付きのターミナル SQL IDE。

## トラブルシュート

**`harlequin -a mysql` などでアダプタエラー**：アダプタは別プラグインです。このマシンには duckdb と sqlite しか入っていません（`harlequin --version` で確認）。他の DB は上流ドキュメントに従い pipx で該当アダプタを注入します。

**クエリが遅い・結果で固まる**：既定では行数制限がありません。`--limit` で既定値を設定するか、`hsql --timeout` を使います。

**リモート DB に繋がらない**：SSH トンネルの指定ミスです。`--ssh-forward` は `ssh -L` と同じ書式（`LOCAL:HOST:REMOTE`）。ssh 設定に LocalForward が既にあるなら二重に渡さないでください。

**hsql の出力が崩れる**：形式選択の誤りです。機械消費には `--json`／`--jsonl`、人間用には既定の `table` か `-x` 縦並びを。

**pipx でアップグレードしたら hsql が消えた**：hsql は harlequin パッケージのエントリポイントの 1 つです。harlequin を再インストールすれば戻ります。
