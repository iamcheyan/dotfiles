> 摘要：Pet 管理命令片段，用 Ctrl+X Ctrl+R 把选中片段填进命令行。

# Pet

## 用途

Pet 是一个命令片段库：把常用命令存起来，用的时候搜索、选中、填入命令行。它和 shell 别名不同——别名是固定的，片段可以带占位符。

## 来源与安装

| 项目 | 说明 |
|---|---|
| 来源 | Zinit，从 GitHub Release 下载 |
| shell 集成 | `plugins/zsh-plugins.zsh` |
| 片段文件 | 默认 `~/.config/pet/snippet.toml` |

```zsh
zi_cmd knqyf263/pet pet
```

## shell 集成

```zsh
if command -v pet >/dev/null 2>&1; then
    function pet-select() {
      BUFFER="$(pet search --query "$LBUFFER")"
      CURSOR=$#BUFFER
      zle redisplay
    }
    zle -N pet-select
    bindkey '^X^R' pet-select
fi
```

`BUFFER` 是 Zsh 的行编辑缓冲区，`LBUFFER` 是光标左侧部分。这个函数：

1. 用当前已输入的内容作为初始查询
2. 调 `pet search`，选中后返回命令文本
3. 把结果写回 `BUFFER`
4. 光标移到末尾

所以你可以先打 `docker`，按 `Ctrl+X` `Ctrl+R`，它就从含 `docker` 的片段里筛。

## 基本用法

```bash
pet new                # 新建片段
pet search             # 搜索
pet search --query git # 带初始查询
pet list               # 列出全部
pet edit               # 编辑片段文件
pet exec               # 选中并直接执行
pet clip               # 选中并复制到剪贴板
pet configure          # 打开配置文件
pet sync               # 同步（需配置）
```

## 新建片段

```bash
pet new
```

交互式提问：

```text
Command> git log --oneline -20
Description> 最近 20 条提交
Tag> git
```

保存后可以用 `pet search` 搜到。

## 片段文件格式

`~/.config/pet/snippet.toml`：

```toml
[[snippets]]
  command = "git log --oneline -20"
  description = "最近 20 条提交"
  output = ""

[[snippets]]
  command = "kubectl get pods -n {{namespace}}"
  description = "列出指定 namespace 的 pod"
  output = ""

[[snippets]]
  command = "ssh {{host}}"
  description = "连接服务器"
  tag = ["ssh", "remote"]
```

`{{placeholder}}` 是占位符，选中后 Pet 会提示你填写。

## 快捷键

| 键 | 作用 |
|---|---|
| `Ctrl+X` 然后 `Ctrl+R` | 在命令行里搜索片段 |
| `Ctrl+X` 然后 `Ctrl+S` | 直接执行选中片段（部分版本） |

本仓库只绑定了 `Ctrl+X` `Ctrl+R`，不占用 Atuin 的上箭头。

## 与其他工具的对比

| | Pet | navi | 别名 |
|---|---|---|---|
| 存储 | TOML 文件 | .cheat 文件 | shell 配置 |
| 占位符 | `{{name}}` | `<name>` | 无 |
| 交互 | fzf | 自己的界面 | 无 |
| 同步 | 支持 Gist/GitLab | repo 机制 | 靠 dotfiles |
| 适合 | 短命令 | 带参数的命令 | 固定命令 |

Pet 比别名灵活（有占位符），比 navi 轻量（不需要 cheatsheet 语法）。

## 同步

```bash
pet sync
```

需要在 `~/.config/pet/config.toml` 里配置 Gist 或 GitLab Snippets：

```toml
[General]
  snippetfile = "~/.config/pet/snippet.toml"

[Gist]
  file_name = "pet-snippet.toml"
  access_token = "..."

[GitLab]
  file_name = "pet-snippet.toml"
  access_token = "..."
```

**access_token 不要提交到公开仓库。** 本仓库不提供这个配置文件。

## 排错

**`Ctrl+X Ctrl+R` 没反应**：`zsh_plugins_load_shell_tools` 没执行，或 pet 没装。`type pet-select` 确认函数存在。

**片段文件损坏**：`pet list` 会报 TOML 解析错误。用 `pet edit` 修复或从备份恢复。

**占位符不提示**：`pet search` 才有填参流程，`pet exec` 会跳过。确认用的是 search。

**中文描述乱码**：文件编码问题。确认是 UTF-8。

**同步冲突**：多机同时改会冲突。`pet sync` 前先 `pet edit` 检查本地版本。

<!-- lang:en -->

> Summary: Pet manages command snippets; Ctrl+X Ctrl+R fills the selected snippet into the command line.

# Pet

## Purpose

Pet is a command snippet library: you store frequently used commands and, when needed, search, select and insert them into the command line. It differs from shell aliases — an alias is fixed, while a snippet can carry placeholders.

## Source and install

| Item | Notes |
|---|---|
| Source | Zinit, downloaded from GitHub Release |
| Shell integration | `plugins/zsh-plugins.zsh` |
| Snippet file | default `~/.config/pet/snippet.toml` |

```zsh
zi_cmd knqyf263/pet pet
```

## Shell integration

```zsh
if command -v pet >/dev/null 2>&1; then
    function pet-select() {
      BUFFER="$(pet search --query "$LBUFFER")"
      CURSOR=$#BUFFER
      zle redisplay
    }
    zle -N pet-select
    bindkey '^X^R' pet-select
fi
```

`BUFFER` is Zsh's line-editor buffer and `LBUFFER` is the part left of the cursor. This function:

1. uses whatever you've already typed as the initial query
2. calls `pet search`, which returns the command text of your selection
3. writes the result back into `BUFFER`
4. moves the cursor to the end

So you can type `docker` first, then press `Ctrl+X` `Ctrl+R`, and it filters snippets containing `docker`.

## Basic usage

```bash
pet new                # 新建片段
pet search             # 搜索
pet search --query git # 带初始查询
pet list               # 列出全部
pet edit               # 编辑片段文件
pet exec               # 选中并直接执行
pet clip               # 选中并复制到剪贴板
pet configure          # 打开配置文件
pet sync               # 同步（需配置）
```

## Creating a snippet

```bash
pet new
```

It asks interactively:

```text
Command> git log --oneline -20
Description> 最近 20 条提交
Tag> git
```

Once saved it can be found with `pet search`.

## Snippet file format

`~/.config/pet/snippet.toml`:

```toml
[[snippets]]
  command = "git log --oneline -20"
  description = "最近 20 条提交"
  output = ""

[[snippets]]
  command = "kubectl get pods -n {{namespace}}"
  description = "列出指定 namespace 的 pod"
  output = ""

[[snippets]]
  command = "ssh {{host}}"
  description = "连接服务器"
  tag = ["ssh", "remote"]
```

`{{placeholder}}` is a placeholder; after selection Pet prompts you to fill it in.

## Key bindings

| Key | Effect |
|---|---|
| `Ctrl+X` then `Ctrl+R` | search snippets from the command line |
| `Ctrl+X` then `Ctrl+S` | execute the selected snippet directly (some versions) |

This repository only binds `Ctrl+X` `Ctrl+R`, leaving Atuin's up-arrow untouched.

## Comparison with other tools

| | Pet | navi | aliases |
|---|---|---|---|
| Storage | TOML file | .cheat files | shell config |
| Placeholders | `{{name}}` | `<name>` | none |
| Interaction | fzf | its own UI | none |
| Sync | Gist/GitLab supported | repo mechanism | via dotfiles |
| Good for | short commands | commands with parameters | fixed commands |

Pet is more flexible than aliases (it has placeholders) and lighter than navi (no cheat sheet syntax needed).

## Sync

```bash
pet sync
```

Requires configuring Gist or GitLab Snippets in `~/.config/pet/config.toml`:

```toml
[General]
  snippetfile = "~/.config/pet/snippet.toml"

[Gist]
  file_name = "pet-snippet.toml"
  access_token = "..."

[GitLab]
  file_name = "pet-snippet.toml"
  access_token = "..."
```

**Never commit the access_token to a public repository.** This repository doesn't provide that config file.

## Troubleshooting

**`Ctrl+X Ctrl+R` does nothing** — `zsh_plugins_load_shell_tools` wasn't executed, or pet isn't installed. Confirm the function exists with `type pet-select`.

**Snippet file corrupted** — `pet list` reports a TOML parse error. Fix it with `pet edit` or restore from backup.

**No placeholder prompt** — only `pet search` runs the fill-in flow; `pet exec` skips it. Make sure you're using search.

**Garbled Chinese descriptions** — a file-encoding problem. Confirm the file is UTF-8.

**Sync conflicts** — editing on multiple machines at once conflicts. Run `pet edit` to check the local version before `pet sync`.

<!-- lang:ja -->

> 要約：Pet はコマンドスニペットを管理し、Ctrl+X Ctrl+R で選択したスニペットをコマンドラインに挿入します。

# Pet

## 用途

Pet はコマンドスニペットのライブラリです。よく使うコマンドを保存しておき、必要なときに検索・選択してコマンドラインに入力します。シェルのエイリアスとは異なります。エイリアスは固定ですが、スニペットはプレースホルダを持てます。

## ソースとインストール

| 項目 | 説明 |
|---|---|
| ソース | Zinit、GitHub Release からダウンロード |
| シェル統合 | `plugins/zsh-plugins.zsh` |
| スニペットファイル | デフォルトは `~/.config/pet/snippet.toml` |

```zsh
zi_cmd knqyf263/pet pet
```

## シェル統合

```zsh
if command -v pet >/dev/null 2>&1; then
    function pet-select() {
      BUFFER="$(pet search --query "$LBUFFER")"
      CURSOR=$#BUFFER
      zle redisplay
    }
    zle -N pet-select
    bindkey '^X^R' pet-select
fi
```

`BUFFER` は Zsh の行エディタバッファ、`LBUFFER` はカーソルの左側の部分です。この関数は：

1. 既に入力済みの内容を初期クエリとして使い
2. `pet search` を呼び、選択結果のコマンドテキストを受け取り
3. 結果を `BUFFER` に書き戻し
4. カーソルを末尾へ移動します

つまり先に `docker` と打ってから `Ctrl+X` `Ctrl+R` を押すと、`docker` を含むスニペットに絞り込めます。

## 基本的な使い方

```bash
pet new                # 新建片段
pet search             # 搜索
pet search --query git # 带初始查询
pet list               # 列出全部
pet edit               # 编辑片段文件
pet exec               # 选中并直接执行
pet clip               # 选中并复制到剪贴板
pet configure          # 打开配置文件
pet sync               # 同步（需配置）
```

## スニペットの作成

```bash
pet new
```

対話形式で尋ねられます：

```text
Command> git log --oneline -20
Description> 最近 20 条提交
Tag> git
```

保存すると `pet search` で見つけられるようになります。

## スニペットファイルの形式

`~/.config/pet/snippet.toml`：

```toml
[[snippets]]
  command = "git log --oneline -20"
  description = "最近 20 条提交"
  output = ""

[[snippets]]
  command = "kubectl get pods -n {{namespace}}"
  description = "列出指定 namespace 的 pod"
  output = ""

[[snippets]]
  command = "ssh {{host}}"
  description = "连接服务器"
  tag = ["ssh", "remote"]
```

`{{placeholder}}` はプレースホルダで、選択後に Pet が記入を促します。

## キーバインド

| キー | 効果 |
|---|---|
| `Ctrl+X` の後に `Ctrl+R` | コマンドラインからスニペットを検索 |
| `Ctrl+X` の後に `Ctrl+S` | 選択したスニペットをそのまま実行（一部のバージョン） |

本リポジトリは `Ctrl+X` `Ctrl+R` だけをバインドし、Atuin の上矢印は占有しません。

## 他のツールとの比較

| | Pet | navi | エイリアス |
|---|---|---|---|
| 保存 | TOML ファイル | .cheat ファイル | シェル設定 |
| プレースホルダ | `{{name}}` | `<name>` | なし |
| インタラクション | fzf | 独自の画面 | なし |
| 同期 | Gist/GitLab 対応 | repo 仕組み | dotfiles に依存 |
| 向いているもの | 短いコマンド | パラメータ付きコマンド | 固定コマンド |

Pet はエイリアスより柔軟（プレースホルダがある）で、navi より軽量（チートシート構文が不要）です。

## 同期

```bash
pet sync
```

`~/.config/pet/config.toml` で Gist か GitLab Snippets を設定する必要があります：

```toml
[General]
  snippetfile = "~/.config/pet/snippet.toml"

[Gist]
  file_name = "pet-snippet.toml"
  access_token = "..."

[GitLab]
  file_name = "pet-snippet.toml"
  access_token = "..."
```

**access_token を公開リポジトリにコミットしないでください。** 本リポジトリはこの設定ファイルを提供していません。

## トラブルシュート

**`Ctrl+X Ctrl+R` が反応しない**：`zsh_plugins_load_shell_tools` が実行されていないか、pet が未インストールです。`type pet-select` で関数の存在を確認します。

**スニペットファイルが壊れている**：`pet list` が TOML のパースエラーを出します。`pet edit` で修復するか、バックアップから復元します。

**プレースホルダの入力を促されない**：記入フローがあるのは `pet search` で、`pet exec` はスキップします。search を使っているか確認します。

**中国語の説明が文字化けする**：ファイルエンコーディングの問題です。UTF-8 か確認します。

**同期のコンフリクト**：複数マシンで同時に編集すると衝突します。`pet sync` の前に `pet edit` でローカルのバージョンを確認します。
