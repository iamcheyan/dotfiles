> 摘要：HTTPie 提供 http 命令，本仓库有 install:httpie 安装器做三级回退。

# HTTPie

## 用途

HTTPie 是人性化的 HTTP 客户端。相比 `curl -X POST -H ... -d ...`，它的语法更接近自然语言：`http POST url key=value`。

本仓库通过安装器提供 `http`（HTTPie）。

## 来源与安装

| 项目 | 说明 |
|---|---|
| 来源 | `scripts/install/install_httpie.sh`，通过 `install:httpie` 函数调用 |
| 安装策略 | 包管理器 → pipx → pip 三级回退 |

```zsh
install:httpie
install:httpie --method package
install:httpie --method pipx
install:httpie --method pip
install:httpie --force
```

## 安装器行为

```bash
if command_exists http && [[ "$FORCE" -ne 1 ]]; then
  print_success "HTTPie is already installed: $(http --version)"
  exit 0
fi
```

已经装了 `http` 就跳过，除非 `--force`。

三级回退：

| 方法 | 命令 | 适用 |
|---|---|---|
| `package` | apt/dnf/pacman/brew | 有 root 权限 |
| `pipx` | `pipx install --force httpie` | 无 root，但装了 pipx |
| `pip` | `python3 -m pip install --user` | 无 root、无 pipx |

`auto` 模式按上面顺序依次尝试，任一成功即停止。

## 基本用法

```bash
http example.org                     # GET
http example.org hello=world         # POST（有数据时自动 POST）
http GET example.org                 # 显式 GET
http POST api.example.com name=alice # JSON body
```

## 语法要点

| 写法 | 含义 |
|---|---|
| `key=value` | JSON 字符串字段 |
| `key:=value` | JSON 原始值（数字、布尔、数组） |
| `key==value` | URL 查询参数 |
| `Header:value` | 请求头 |
| `Header:` | 移除请求头 |
| `field@file` | 上传文件 |
| `field=@file` | 字段值来自文件 |

例子：

```bash
# JSON body
http POST api.example.com/users name=alice age:=30

# 查询参数
http GET api.example.com/search q==term page==2

# 认证
http -a user:pass api.example.com/private
http GET api.example.com Authorization:"Bearer TOKEN"

# 表单
http --form POST example.com name=alice
```

## 常用参数

| 参数 | 作用 |
|---|---|
| `-v` / `--verbose` | 显示请求和响应头 |
| `-h` / `--headers` | 只显示响应头 |
| `-b` / `--body` | 只显示响应体 |
| `-d` / `--download` | 下载 |
| `-o` / `--output` | 输出到文件 |
| `-f` / `--form` | 表单编码 |
| `--json` | 强制 JSON |
| `--follow` | 跟随重定向 |
| `--timeout` | 超时 |
| `--verify=no` | 跳过 TLS 校验 |
| `--session` | 会话文件 |
| `--offline` | 只打印请求不发送 |
| `--print=HBhb` | 精确控制打印哪些部分 |

`--print` 的字母含义：`H` 请求头、`B` 请求体、`h` 响应头、`b` 响应体。

## 会话

```bash
http --session=work POST example.com/login user=me pass=secret
http --session=work GET example.com/profile
```

会话保存在 `~/.config/httpie/sessions/`，包含 cookie 和 headers。**可能含 token，不要提交。**

## 本地服务简写

```bash
http :3000              # http://localhost:3000
http :/api/users        # http://localhost/api/users
```

冒号开头自动补 `localhost`，省去写完整地址。

## 排错

**`http: command not found`**：安装器失败，或 pip 的 user bin 不在 PATH。`python3 -m site --user-base` 查看路径。

**JSON 被解析成字符串**：用了 `key=value` 而不是 `key:=value`。前者总是字符串。

**中文乱码**：服务端编码不是 UTF-8。加 `Accept-Charset:utf-8`。

**TLS 错误**：企业代理或自签证书。`--verify=no` 仅用于调试。

**`--session` 后认证丢失**：会话文件权限或路径问题。`ls -l ~/.config/httpie/sessions/`。

**pip 安装后仍找不到**：`~/.local/bin` 不在 PATH。在 `local/` 里补上。

<!-- lang:en -->

> Summary: HTTPie provides the http command; this repo ships an install:httpie installer with three-level fallback.

# HTTPie

## Purpose

HTTPie is a human-friendly HTTP client. Compared with `curl -X POST -H ... -d ...`, its syntax is closer to natural language: `http POST url key=value`.

This repo provides `http` (HTTPie) through an installer.

## Source and Installation

| Item | Description |
|---|---|
| Source | `scripts/install/install_httpie.sh`, invoked via the `install:httpie` function |
| Install strategy | Package manager → pipx → pip, a three-level fallback |

```zsh
install:httpie
install:httpie --method package
install:httpie --method pipx
install:httpie --method pip
install:httpie --force
```

## Installer behavior

```bash
if command_exists http && [[ "$FORCE" -ne 1 ]]; then
  print_success "HTTPie is already installed: $(http --version)"
  exit 0
fi
```

If `http` is already installed, it skips — unless `--force` is given.

The three-level fallback:

| Method | Command | Applies when |
|---|---|---|
| `package` | apt/dnf/pacman/brew | You have root privileges |
| `pipx` | `pipx install --force httpie` | No root, but pipx is installed |
| `pip` | `python3 -m pip install --user` | No root and no pipx |

In `auto` mode the methods are tried in the order above, stopping at the first success.

## Basic usage

```bash
http example.org                     # GET
http example.org hello=world         # POST（有数据时自动 POST）
http GET example.org                 # 显式 GET
http POST api.example.com name=alice # JSON body
```

## Syntax essentials

| Notation | Meaning |
|---|---|
| `key=value` | JSON string field |
| `key:=value` | Raw JSON value (number, boolean, array) |
| `key==value` | URL query parameter |
| `Header:value` | Request header |
| `Header:` | Remove a request header |
| `field@file` | Upload a file |
| `field=@file` | Field value taken from a file |

Examples:

```bash
# JSON body
http POST api.example.com/users name=alice age:=30

# 查询参数
http GET api.example.com/search q==term page==2

# 认证
http -a user:pass api.example.com/private
http GET api.example.com Authorization:"Bearer TOKEN"

# 表单
http --form POST example.com name=alice
```

## Common options

| Option | Purpose |
|---|---|
| `-v` / `--verbose` | Show request and response headers |
| `-h` / `--headers` | Show only response headers |
| `-b` / `--body` | Show only the response body |
| `-d` / `--download` | Download |
| `-o` / `--output` | Write output to a file |
| `-f` / `--form` | Form encoding |
| `--json` | Force JSON |
| `--follow` | Follow redirects |
| `--timeout` | Timeout |
| `--verify=no` | Skip TLS verification |
| `--session` | Session file |
| `--offline` | Print the request without sending it |
| `--print=HBhb` | Precisely control which parts are printed |

The letters of `--print` mean: `H` request headers, `B` request body, `h` response headers, `b` response body.

## Sessions

```bash
http --session=work POST example.com/login user=me pass=secret
http --session=work GET example.com/profile
```

Sessions are stored in `~/.config/httpie/sessions/`, containing cookies and headers. **They may contain tokens; do not commit them.**

## Local service shorthand

```bash
http :3000              # http://localhost:3000
http :/api/users        # http://localhost/api/users
```

A leading colon auto-fills `localhost`, saving you from writing the full address.

## Troubleshooting

**`http: command not found`**: the installer failed, or pip's user bin is not in PATH. Check the path with `python3 -m site --user-base`.

**JSON parsed as a string**: you used `key=value` instead of `key:=value`. The former is always a string.

**Garbled Chinese**: the server's encoding is not UTF-8. Add `Accept-Charset:utf-8`.

**TLS errors**: a corporate proxy or self-signed certificate. `--verify=no` is for debugging only.

**Authentication lost after `--session`**: a session file permissions or path issue. Run `ls -l ~/.config/httpie/sessions/`.

**Still not found after a pip install**: `~/.local/bin` is not in PATH. Add it in `local/`.

<!-- lang:ja -->

> 要約：HTTPie は http コマンドを提供し、本リポジトリには 3 段階フォールバック付きの install:httpie インストーラーがあります。

# HTTPie

## 用途

HTTPie は人間に優しい HTTP クライアントです。`curl -X POST -H ... -d ...` に比べ、構文は自然言語に近いものになっています：`http POST url key=value`。

本リポジトリはインストーラーを通じて `http`（HTTPie）を提供します。

## ソースとインストール

| 項目 | 説明 |
|---|---|
| ソース | `scripts/install/install_httpie.sh`。`install:httpie` 関数から呼び出し |
| インストール戦略 | パッケージマネージャー → pipx → pip の 3 段階フォールバック |

```zsh
install:httpie
install:httpie --method package
install:httpie --method pipx
install:httpie --method pip
install:httpie --force
```

## インストーラーの動作

```bash
if command_exists http && [[ "$FORCE" -ne 1 ]]; then
  print_success "HTTPie is already installed: $(http --version)"
  exit 0
fi
```

`http` が既にインストールされていればスキップします。`--force` が付いた場合を除きます。

3 段階フォールバック：

| 方法 | コマンド | 使える状況 |
|---|---|---|
| `package` | apt/dnf/pacman/brew | root 権限がある |
| `pipx` | `pipx install --force httpie` | root はないが pipx が入っている |
| `pip` | `python3 -m pip install --user` | root も pipx もない |

`auto` モードでは上の順序で順に試し、どれかが成功した時点で止まります。

## 基本的な使い方

```bash
http example.org                     # GET
http example.org hello=world         # POST（有数据时自动 POST）
http GET example.org                 # 显式 GET
http POST api.example.com name=alice # JSON body
```

## 構文のポイント

| 書き方 | 意味 |
|---|---|
| `key=value` | JSON の文字列フィールド |
| `key:=value` | JSON の生の値（数値、真偽値、配列） |
| `key==value` | URL クエリパラメータ |
| `Header:value` | リクエストヘッダー |
| `Header:` | リクエストヘッダーを除去 |
| `field@file` | ファイルをアップロード |
| `field=@file` | フィールド値をファイルから取得 |

例：

```bash
# JSON body
http POST api.example.com/users name=alice age:=30

# 查询参数
http GET api.example.com/search q==term page==2

# 认证
http -a user:pass api.example.com/private
http GET api.example.com Authorization:"Bearer TOKEN"

# 表单
http --form POST example.com name=alice
```

## よく使うオプション

| オプション | 役割 |
|---|---|
| `-v` / `--verbose` | リクエストとレスポンスのヘッダーを表示 |
| `-h` / `--headers` | レスポンスヘッダーだけ表示 |
| `-b` / `--body` | レスポンスボディだけ表示 |
| `-d` / `--download` | ダウンロード |
| `-o` / `--output` | ファイルに出力 |
| `-f` / `--form` | フォームエンコーディング |
| `--json` | JSON を強制 |
| `--follow` | リダイレクトを追う |
| `--timeout` | タイムアウト |
| `--verify=no` | TLS 検証をスキップ |
| `--session` | セッションファイル |
| `--offline` | 送信せずリクエストだけ表示 |
| `--print=HBhb` | 表示する部分を正確に制御 |

`--print` の文字の意味：`H` はリクエストヘッダー、`B` はリクエストボディ、`h` はレスポンスヘッダー、`b` はレスポンスボディです。

## セッション

```bash
http --session=work POST example.com/login user=me pass=secret
http --session=work GET example.com/profile
```

セッションは `~/.config/httpie/sessions/` に保存され、cookie と headers を含みます。**トークンを含む可能性があるため、コミットしないでください。**

## ローカルサービスの略記

```bash
http :3000              # http://localhost:3000
http :/api/users        # http://localhost/api/users
```

先頭のコロンで `localhost` が自動補完され、完全なアドレスを書かずに済みます。

## トラブルシューティング

**`http: command not found`**：インストーラーが失敗したか、pip の user bin が PATH にありません。`python3 -m site --user-base` でパスを確認します。

**JSON が文字列として解釈される**：`key:=value` ではなく `key=value` を使っています。前者は常に文字列になります。

**中国語の文字化け**：サーバー側のエンコーディングが UTF-8 ではありません。`Accept-Charset:utf-8` を付けます。

**TLS エラー**：企業プロキシか自己署名証明書です。`--verify=no` はデバッグ専用です。

**`--session` の後に認証が消える**：セッションファイルのパーミッションかパスの問題です。`ls -l ~/.config/httpie/sessions/` を実行します。

**pip でインストールしたのに見つからない**：`~/.local/bin` が PATH にありません。`local/` に追加します。
