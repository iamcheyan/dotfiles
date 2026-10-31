> 摘要：sqlmux 把 tmux 式窗格与 Vim 风格 SQL 编辑器带进终端数据库客户端。

# sqlmux

## 用途与用法

sqlmux 是面向 PostgreSQL、MySQL、SQLite、Redis 等服务的终端数据库客户端，支持多会话、窗口和分屏、表格浏览与 SQL 编辑。

```bash
sqlmux
sqlmux ./app.db
sqlmux "postgres://user@localhost:5432/app"
```

`SPC`（空格）是默认 leader 键，例如 `SPC %` 分屏、`SPC c` 新建窗口；`C-p` 打开命令面板。查看 `?` 或运行 `sqlmux keys` 获取完整键位。

sqlmux 可以编辑数据库记录。写入前会显示变更预览并在事务中保存，但这些保护不是权限边界；生产数据库应使用只读账号，并仔细检查连接目标。

## 本仓库安装方式

`init.sh` 会下载 Linux/macOS amd64/arm64 的官方 release，并校验发布的 SHA-256：

```bash
bash scripts/install/install_sqlmux.sh
```

该安装器需要 `curl`、`tar`、`python3` 和 `sha256sum`。更多安装选项与配置见[上游文档](https://github.com/kackerx/sqlmux)。

## 参考

- [sqlmux 上游仓库](https://github.com/kackerx/sqlmux)
- [键位与配置](https://github.com/kackerx/sqlmux#keys-and-configuration)

<!-- lang:en -->

> Summary: sqlmux brings tmux-style panes and a Vim-like SQL editor to terminal database work.

# sqlmux

## What it does

sqlmux is a terminal database client for PostgreSQL, MySQL, SQLite, Redis, and other backends. It supports sessions, windows and splits, table browsing, and SQL editing.

```bash
sqlmux
sqlmux ./app.db
sqlmux "postgres://user@localhost:5432/app"
```

`SPC` (Space) is the default leader key: `SPC %` splits a pane and `SPC c` opens a window. `C-p` opens the command palette. Use `?` or `sqlmux keys` for the complete key list.

sqlmux can edit database records. It previews changes before saving them in a transaction, but these safeguards are not an access-control boundary. Use a read-only account for production databases and check the connection target carefully.

## Install in this repository

`init.sh` downloads the official Linux/macOS amd64/arm64 release and verifies its published SHA-256 digest:

```bash
bash scripts/install/install_sqlmux.sh
```

The installer requires `curl`, `tar`, `python3`, and `sha256sum`. See the [upstream documentation](https://github.com/kackerx/sqlmux) for other install methods and configuration.

## Reference

- [sqlmux upstream repository](https://github.com/kackerx/sqlmux)
- [Keybindings and configuration](https://github.com/kackerx/sqlmux#keys-and-configuration)

<!-- lang:ja -->

> 要約：sqlmux は tmux 風のペインと Vim 風 SQL エディターを備えたターミナル DB クライアントです。

# sqlmux

## 概要と使い方

sqlmux は PostgreSQL、MySQL、SQLite、Redis などに対応するターミナル DB クライアントです。セッション、ウィンドウ、分割ペイン、テーブル表示、SQL 編集を利用できます。

```bash
sqlmux
sqlmux ./app.db
sqlmux "postgres://user@localhost:5432/app"
```

既定の leader キーは `SPC`（Space）です。`SPC %` で分割し、`SPC c` でウィンドウを開きます。`C-p` はコマンドパレットです。全キー一覧は `?` または `sqlmux keys` で確認できます。

レコードを編集できます。保存前に変更内容をプレビューし、トランザクションで保存しますが、この保護はアクセス権限の代わりにはなりません。本番 DB には読み取り専用アカウントを使い、接続先をよく確認してください。

## このリポジトリでのインストール

`init.sh` は Linux/macOS の amd64/arm64 向け公式 release をダウンロードし、公開 SHA-256 を検証します。

```bash
bash scripts/install/install_sqlmux.sh
```

インストーラーには `curl`、`tar`、`python3`、`sha256sum` が必要です。ほかのインストール方法と設定は[上流ドキュメント](https://github.com/kackerx/sqlmux)を参照してください。

## 参考

- [sqlmux 上流リポジトリ](https://github.com/kackerx/sqlmux)
- [キー操作と設定](https://github.com/kackerx/sqlmux#keys-and-configuration)
