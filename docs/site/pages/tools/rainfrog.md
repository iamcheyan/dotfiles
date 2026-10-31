> 摘要：Rainfrog 是带 Vim 风格操作的终端数据库客户端，支持查询编辑、历史、收藏和表格浏览。

# Rainfrog

## 用途与用法

Rainfrog 是轻量级终端数据库工具，支持 PostgreSQL、MySQL、SQLite 等数据库，并提供查询编辑器、历史记录和收藏。

```bash
rainfrog
rainfrog --url "postgres://user@localhost:5432/app"
```

也可使用 `DATABASE_URL` 环境变量。运行 `rainfrog --help` 查看连接参数；配置命令为 `rainfrog edit`。

**安全提示：**上游项目仍在积极开发并提示可能发生破坏性变更，也不建议以可写权限连接生产数据库。请使用只读账户，并在执行修改查询前仔细确认。

## 本仓库安装方式

```bash
bash scripts/install/install_rainfrog.sh
```

安装器在 macOS 使用 Homebrew，在 Arch Linux 使用 pacman；其他受支持的 Linux x86_64/arm64 平台下载官方 release 并校验 SHA-256。NixOS 由系统配置管理，初始化脚本会跳过安装。

更多连接、配置和支持数据库的信息见[上游 README](https://github.com/achristmascarl/rainfrog#readme)。

## 参考

- [Rainfrog 上游仓库](https://github.com/achristmascarl/rainfrog)
- [上游安装与用法](https://github.com/achristmascarl/rainfrog#installation)

<!-- lang:en -->

> Summary: Rainfrog is a terminal database client with Vim-style navigation, query editing, history, favorites, and table browsing.

# Rainfrog

## What it does

Rainfrog is a lightweight terminal database tool with a query editor, query history, favorites, and table browsing. It supports PostgreSQL, MySQL, SQLite, and other databases.

```bash
rainfrog
rainfrog --url "postgres://user@localhost:5432/app"
```

You can also set `DATABASE_URL`. Run `rainfrog --help` for connection options and `rainfrog edit` to edit its configuration.

**Safety:** the upstream project is under active development and warns that breaking changes may occur. It also advises against using a writable connection to a production database. Use a read-only account and review any write query before running it.

## Install in this repository

```bash
bash scripts/install/install_rainfrog.sh
```

The installer uses Homebrew on macOS and pacman on Arch Linux. On other supported Linux x86_64/arm64 systems it downloads the official release and verifies its SHA-256 checksum. NixOS manages this tool through its system configuration, so the bootstrap skips it there.

See the [upstream README](https://github.com/achristmascarl/rainfrog#readme) for connection, configuration, and database support details.

## Reference

- [Rainfrog upstream repository](https://github.com/achristmascarl/rainfrog)
- [Upstream installation and usage](https://github.com/achristmascarl/rainfrog#installation)

<!-- lang:ja -->

> 要約：Rainfrog は Vim 風の操作、クエリエディター、履歴、ブックマーク、テーブル表示を備えたターミナル DB クライアントです。

# Rainfrog

## 概要と使い方

Rainfrog はクエリエディター、履歴、ブックマーク、テーブル表示を備えた軽量 DB ツールです。PostgreSQL、MySQL、SQLite などに対応します。

```bash
rainfrog
rainfrog --url "postgres://user@localhost:5432/app"
```

`DATABASE_URL` 環境変数も使えます。接続オプションは `rainfrog --help`、設定編集は `rainfrog edit` で確認してください。

**安全性：**上流プロジェクトは開発中で、互換性を壊す変更の可能性を案内しています。また、本番 DB に書き込み可能な接続を使わないよう推奨しています。読み取り専用アカウントを使い、書き込みクエリを実行する前に内容を確認してください。

## このリポジトリでのインストール

```bash
bash scripts/install/install_rainfrog.sh
```

macOS では Homebrew、Arch Linux では pacman を使用します。その他の対応 Linux x86_64/arm64 では公式 release を取得して SHA-256 を検証します。NixOS ではシステム設定で管理するため、bootstrap はインストールをスキップします。

接続、設定、対応 DB の詳細は[上流 README](https://github.com/achristmascarl/rainfrog#readme)を参照してください。

## 参考

- [Rainfrog 上流リポジトリ](https://github.com/achristmascarl/rainfrog)
- [上流のインストールと使い方](https://github.com/achristmascarl/rainfrog#installation)
