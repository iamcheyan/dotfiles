> 摘要：nano 与 Herdr 两个较小配置的边界与部署方式。

# nano 与 Herdr

三个配置文件体量小，或只部分部署，放在一起说明。

## nano

### 位置

| 项目 | 路径 |
|---|---|
| 仓库源文件 | `config/nano/nanorc` |
| 部署目标 | `~/.nanorc` |
| 是否自动链接 | 是 |

### 用途

Nano 的语法高亮和默认选项。适合在没有 Vim 的环境里应急编辑。

### 注意

`~/.nanorc` 会被 Nano 读取，如果文件里有语法错误，Nano 会报错但通常仍能启动。

本仓库的 `nanorc` 内容较短，主要是语法高亮包含和少量默认项。

Nano 标题栏用蓝底黄字，状态栏用青色，选区和行号沿用 Neovim Blue 的蓝／青色强调。

### 验证

```bash
nano --version
nano /tmp/test.txt
```

### 排错

**Nano 启动报语法错误**：`nanorc` 里有不兼容当前 Nano 版本的指令。注释掉对应行。

**没有语法高亮**：`include` 路径不对，或 Nano 编译时没启用语法支持。

## Herdr

### 位置

| 项目 | 路径 |
|---|---|
| 仓库源文件 | `config/herdr/config.toml` |
| 部署目标 | `~/.config/herdr/config.toml` |
| 是否自动链接 | 是 |

### 用途

Herdr 是一个本地 AI 编程助手，`init.sh` 会通过官方脚本安装：

```bash
curl -fsSL https://herdr.dev/install.sh | sh
```

配置是 TOML 格式，本仓库提供一个基础主题配置。

Herdr 面板背景、青色强调色和绿色提示色与 Neovim Blue / Nostalgia 配色一致。

### 边界

Herdr 的 API key、provider 配置属于私有内容，**不在这里**。公开配置只包含界面和通用选项。

### 验证

```bash
herdr --version
ls -l ~/.config/herdr/config.toml
```

### 排错

**配置不生效**：确认 Herdr 读的是这个路径。

**认证失败**：key 不在公开配置里，需要自己在私有配置或环境变量里提供。

<!-- lang:en -->

> Summary: The boundaries and deployment of two smaller configurations, nano and Herdr.

# nano and Herdr

These configuration files are small, or only partially deployed, so they are described together.

## nano

### Location

| Item | Path |
|---|---|
| Repository source file | `config/nano/nanorc` |
| Deployment target | `~/.nanorc` |
| Auto-linked | Yes |

### Purpose

Syntax highlighting and default options for Nano. Useful for quick edits in environments without Vim.

### Notes

Nano reads `~/.nanorc`; if the file contains a syntax error, Nano reports it but usually still starts.

The `nanorc` in this repository is short, consisting mainly of syntax highlighting includes and a few default options.

The Nano title bar uses yellow on blue, the status bar cyan, and the selection and line numbers follow Neovim Blue's blue/cyan accents.

### Verification

```bash
nano --version
nano /tmp/test.txt
```

### Troubleshooting

**Nano reports a syntax error on startup**: the `nanorc` contains a directive incompatible with the current Nano version. Comment out the offending line.

**No syntax highlighting**: the `include` path is wrong, or Nano was built without syntax support.

## Herdr

### Location

| Item | Path |
|---|---|
| Repository source file | `config/herdr/config.toml` |
| Deployment target | `~/.config/herdr/config.toml` |
| Auto-linked | Yes |

### Purpose

Herdr is a local AI coding assistant; `init.sh` installs it via the official script:

```bash
curl -fsSL https://herdr.dev/install.sh | sh
```

The configuration is in TOML format, and this repository provides a basic theme configuration.

Herdr's panel background, cyan accent, and green hint colors match the Neovim Blue / Nostalgia color scheme.

### Boundaries

Herdr's API keys and provider configuration are private and are **not here**. The public configuration only contains interface and general options.

### Verification

```bash
herdr --version
ls -l ~/.config/herdr/config.toml
```

### Troubleshooting

**Configuration not taking effect**: confirm Herdr reads this path.

**Authentication fails**: the key is not in the public configuration; provide it yourself in a private configuration or environment variables.

<!-- lang:ja -->

> 要約：nano と Herdr という小規模な 2 つの設定の境界とデプロイ方法。

# nano と Herdr

これらの設定ファイルは容量が小さいか、一部だけデプロイされるため、まとめて説明します。

## nano

### 場所

| 項目 | パス |
|---|---|
| リポジトリのソースファイル | `config/nano/nanorc` |
| デプロイ先 | `~/.nanorc` |
| 自動リンクの対象 | はい |

### 用途

Nano のシンタックスハイライトとデフォルトオプションです。Vim のない環境での応急編集に適しています。

### 注意

`~/.nanorc` は Nano に読み込まれます。ファイルに文法エラーがあると、Nano はエラーを報告しますが、通常は起動自体はできます。

本リポジトリの `nanorc` は短く、主にシンタックスハイライトの include と少数のデフォルト項目からなります。

Nano のタイトルバーは青地に黄色、ステータスバーはシアンを使い、選択範囲と行番号は Neovim Blue の青／シアンのアクセントに合わせています。

### 検証

```bash
nano --version
nano /tmp/test.txt
```

### トラブルシューティング

**Nano 起動時に文法エラーが出る**：`nanorc` に現在の Nano バージョンと互換性のないディレクティブがあります。該当行をコメントアウトしてください。

**シンタックスハイライトが出ない**：`include` のパスが間違っているか、Nano がシンタックスサポート無しでビルドされています。

## Herdr

### 場所

| 項目 | パス |
|---|---|
| リポジトリのソースファイル | `config/herdr/config.toml` |
| デプロイ先 | `~/.config/herdr/config.toml` |
| 自動リンクの対象 | はい |

### 用途

Herdr はローカルの AI コーディングアシスタントで、`init.sh` が公式スクリプトでインストールします：

```bash
curl -fsSL https://herdr.dev/install.sh | sh
```

設定は TOML 形式で、本リポジトリは基本的なテーマ設定を提供しています。

Herdr のパネル背景・シアンのアクセント・緑のヒント色は、Neovim Blue / Nostalgia の配色と一致しています。

### 境界

Herdr の API キーやプロバイダ設定はプライベートな内容であり、**ここにはありません**。公開設定にはインターフェースと一般オプションのみが含まれます。

### 検証

```bash
herdr --version
ls -l ~/.config/herdr/config.toml
```

### トラブルシューティング

**設定が効かない**：Herdr がこのパスを読んでいるか確認します。

**認証に失敗する**：キーは公開設定に含まれていないため、プライベート設定か環境変数で自分で用意する必要があります。
