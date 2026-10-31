> 摘要：LazySQL 是可用 Vim 键位操作的终端数据库管理器，支持多连接、表格浏览和 SQL 编辑。

# LazySQL

## 用途与用法

LazySQL 是跨平台的数据库 TUI，支持保存多个连接、浏览表和记录，并在内置 SQL 编辑器中执行查询。数据库连接可从界面添加，也可放入 TOML 配置。

```bash
lazysql
lazysql "postgres://user@localhost:5432/app"
```

常用操作：`Ctrl+E` 打开 SQL 编辑器，`Ctrl+R` 执行查询，`?` 查看当前界面的快捷键。需要只读访问时使用 `--read-only`，并优先使用数据库侧的只读账户。

## 本仓库安装方式

`init.sh` 会调用官方 release 安装器，按 Linux/macOS 架构下载到 `~/.local/bin/lazysql`：

```bash
bash scripts/install/install_lazysql.sh
```

Windows 用户请按[上游安装说明](https://github.com/jorgerojas26/lazysql#installation)安装。

配置文件位于 `${XDG_CONFIG_HOME:-~/.config}/lazysql/config.toml`。官方预编译版本默认发送最少量匿名汇总使用计数；可用 `--no-telemetry` 关闭。源码构建不会发送该数据，细节见[上游说明](https://github.com/jorgerojas26/lazysql)。

## 参考

- [LazySQL 上游仓库](https://github.com/jorgerojas26/lazysql)

<!-- lang:en -->

> Summary: LazySQL is a terminal database manager with Vim keybindings, multiple connections, table browsing, and a SQL editor.

# LazySQL

## What it does

LazySQL is a cross-platform database TUI for managing saved connections, browsing tables and records, and running queries in its built-in SQL editor. Add connections in the UI or define them in TOML.

```bash
lazysql
lazysql "postgres://user@localhost:5432/app"
```

Useful keys: `Ctrl+E` opens the SQL editor, `Ctrl+R` runs a query, and `?` shows the current screen's shortcuts. For read-only work, use `--read-only` and prefer a read-only database account.

## Install in this repository

`init.sh` runs the official release installer, which selects the Linux/macOS asset for the current architecture and installs `~/.local/bin/lazysql`:

```bash
bash scripts/install/install_lazysql.sh
```

For Windows, follow the [upstream installation guide](https://github.com/jorgerojas26/lazysql#installation).

The configuration file is `${XDG_CONFIG_HOME:-~/.config}/lazysql/config.toml`. Official prebuilt releases send minimal anonymous aggregate usage counts by default; `--no-telemetry` opts out. Source builds do not send this data. See the [upstream project](https://github.com/jorgerojas26/lazysql) for details.

## Reference

- [LazySQL upstream repository](https://github.com/jorgerojas26/lazysql)

<!-- lang:ja -->

> 要約：LazySQL は Vim キーバインド、複数接続、テーブル表示、SQL エディターを備えたターミナル DB 管理ツールです。

# LazySQL

## 概要と使い方

LazySQL は複数の接続を保存し、テーブルやレコードを閲覧して、内蔵 SQL エディターでクエリを実行できるクロスプラットフォームの TUI です。接続は画面から追加するか、TOML に記述できます。

```bash
lazysql
lazysql "postgres://user@localhost:5432/app"
```

`Ctrl+E` で SQL エディター、`Ctrl+R` でクエリを実行し、`?` で画面ごとのキー一覧を表示します。読み取り専用では `--read-only` を使い、DB 側でも読み取り専用アカウントを使ってください。

## このリポジトリでのインストール

`init.sh` は公式 release インストーラーを呼び出し、Linux/macOS のアーキテクチャに合うバイナリを `~/.local/bin/lazysql` に配置します。

```bash
bash scripts/install/install_lazysql.sh
```

Windows は[上流のインストール手順](https://github.com/jorgerojas26/lazysql#installation)を参照してください。

設定ファイルは `${XDG_CONFIG_HOME:-~/.config}/lazysql/config.toml` です。公式の事前ビルド版は既定で最小限の匿名集計利用数を送信します。`--no-telemetry` で停止できます。ソースビルドでは送信されません。詳細は[上流プロジェクト](https://github.com/jorgerojas26/lazysql)を確認してください。

## 参考

- [LazySQL 上流リポジトリ](https://github.com/jorgerojas26/lazysql)
