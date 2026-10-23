> 摘要：direnv 按目录加载环境变量，进入项目自动生效，离开自动清理。

# direnv

## 用途

`direnv` 让环境变量跟着目录走。项目根目录放一个 `.envrc`，`cd` 进去时自动加载，离开时自动卸载。解决「不同项目需要不同 API key、不同 Python 虚拟环境、不同数据库地址」的问题。

## 来源与安装

| 项目 | 说明 |
|---|---|
| 来源 | Zinit，从 GitHub Release 下载单个二进制 |
| 加载位置 | `plugins/tools/tools.zsh` |
| 可执行名 | `direnv` |

```zsh
zinit ice as"command" from"gh-r" sbin"direnv"
zinit light direnv/direnv
```

## shell 集成

```zsh
if command -v direnv >/dev/null 2>&1; then
  eval "$(direnv hook zsh)"
fi
```

hook 注册了 `chpwd`，每次切换目录时检查当前路径及所有父目录里有没有已授权的 `.envrc`。

## 基本用法

```bash
cd ~/project
echo 'export DATABASE_URL=postgres://localhost/dev' > .envrc
direnv allow                 # 首次必须显式授权
```

之后每次进入该目录，`DATABASE_URL` 自动设置；离开后自动 unset。

## 子命令

| 命令 | 作用 |
|---|---|
| `direnv allow [path]` | 授权加载 |
| `direnv deny [path]` | 撤销授权 |
| `direnv edit [path]` | 编辑并自动授权 |
| `direnv reload` | 重新加载当前目录 |
| `direnv status` | 显示当前加载状态 |
| `direnv exec DIR CMD` | 在指定目录的环境里执行命令 |
| `direnv export SHELL` | 输出环境差异（调试用） |
| `direnv prune` | 清理过期的授权记录 |
| `direnv stdlib` | 显示可用的标准库函数 |

## 为什么必须 allow

`.envrc` 是**可执行的 shell 脚本**，能运行任意命令。如果自动加载，克隆一个恶意仓库就可能被执行代码。所以 direnv 要求你对每个文件内容做一次显式授权，并把文件哈希记在 `~/.local/share/direnv/allow/` 里。

`.envrc` 被修改后哈希失效，需要重新 `direnv allow`。这是安全设计，不是 bug。

## .envrc 里能写什么

`.envrc` 是 bash 语法，direnv 提供了标准库函数：

```bash
# 加载 .env 文件
dotenv

# 加载 .env 并允许缺失
dotenv_if_exists

# 使用 Python 虚拟环境
layout python3
layout python ~/.venv/myproject

# 使用 Node 版本
use node 20

# 使用 nix shell
use nix

# 添加 PATH
PATH_add bin

# 设置变量
export API_URL=https://api.example.com
```

`layout python3` 会自动创建/激活 `.direnv/python-3.x.x` 下的虚拟环境，并把 `VIRTUAL_ENV`、`PATH` 都设好。

## 实用模式

### 每个项目独立的 Python 环境

```bash
cd ~/projects/foo
echo 'layout python3' > .envrc
direnv allow
```

### 加载本地密钥（不提交）

```bash
# .envrc
dotenv_if_exists .env.local
```

`.env.local` 加进 `.gitignore`，`.envrc` 提交进仓库。这样别人克隆后只要建自己的 `.env.local`。

### 配合 fnm 固定 Node 版本

```bash
# .envrc
use node
```

它读 `.nvmrc` 或 `.node-version`。

## 与其它工具的关系

| 工具 | 分工 |
|---|---|
| fnm | 只管 Node 版本切换 |
| direnv | 管任意环境变量，也可以调用 fnm |
| Zsh 的 `export` | 全局生效，不随目录变化 |

两者可以叠加：direnv 在项目目录里设 `PATH`，fnm 的 `--use-on-cd` 也监听 `cd`。如果两者都改 Node 版本，行为取决于执行顺序，通常让 direnv 负责更可控。

## 排错

**进入目录没反应**：`.envrc` 没 allow。`direnv status` 会明确说「not allowed」。

**改了 .envrc 不生效**：哈希变了，重新 `direnv allow`。

**变量没清理**：离开目录后应该自动 unset。如果没清理，说明 hook 没注册，检查 `direnv hook zsh` 是否执行。

**`direnv: error .envrc is blocked`**：安全拦截，按提示 `direnv allow`。

**加载很慢**：`.envrc` 里有耗时命令（比如 `nix develop`）。考虑把结果缓存，或改用更轻的方案。

**和 tmux 会话冲突**：tmux 新建 pane 时继承的是创建时的环境，不会重新触发 direnv。在 pane 里手动 `direnv reload`。

<!-- lang:en -->
> Summary: direnv loads environment variables per directory — entering a project applies them automatically, leaving cleans them up.

# direnv

## Purpose

`direnv` makes environment variables follow the directory. Put a `.envrc` in the project root and it is loaded automatically when you `cd` in, unloaded automatically when you leave. It solves the problem of "different projects needing different API keys, different Python virtual environments, different database addresses".

## Source and installation

| Item | Description |
|---|---|
| Source | Zinit, downloads a single binary from GitHub Release |
| Load location | `plugins/tools/tools.zsh` |
| Executable name | `direnv` |

```zsh
zinit ice as"command" from"gh-r" sbin"direnv"
zinit light direnv/direnv
```

## Shell integration

```zsh
if command -v direnv >/dev/null 2>&1; then
  eval "$(direnv hook zsh)"
fi
```

The hook registers `chpwd`, and on every directory change checks the current path and all parent directories for an authorized `.envrc`.

## Basic usage

```bash
cd ~/project
echo 'export DATABASE_URL=postgres://localhost/dev' > .envrc
direnv allow                 # 首次必须显式授权
```

From then on, every time you enter that directory `DATABASE_URL` is set automatically; after leaving it is unset automatically.

## Subcommands

| Command | Action |
|---|---|
| `direnv allow [path]` | Authorize loading |
| `direnv deny [path]` | Revoke authorization |
| `direnv edit [path]` | Edit and authorize automatically |
| `direnv reload` | Reload the current directory |
| `direnv status` | Show the current load state |
| `direnv exec DIR CMD` | Run a command with the environment of a given directory |
| `direnv export SHELL` | Print the environment diff (for debugging) |
| `direnv prune` | Clean up stale authorization records |
| `direnv stdlib` | Show the available stdlib functions |

## Why allow is mandatory

`.envrc` is an **executable shell script** that can run arbitrary commands. If it loaded automatically, cloning a malicious repo could execute code. That is why direnv requires an explicit authorization of each file's contents, recording the file hash in `~/.local/share/direnv/allow/`.

After `.envrc` is modified, the hash becomes invalid and `direnv allow` is needed again. This is a security design, not a bug.

## What can go in .envrc

`.envrc` uses bash syntax, and direnv provides stdlib functions:

```bash
# 加载 .env 文件
dotenv

# 加载 .env 并允许缺失
dotenv_if_exists

# 使用 Python 虚拟环境
layout python3
layout python ~/.venv/myproject

# 使用 Node 版本
use node 20

# 使用 nix shell
use nix

# 添加 PATH
PATH_add bin

# 设置变量
export API_URL=https://api.example.com
```

`layout python3` automatically creates/activates a virtual environment under `.direnv/python-3.x.x` and sets both `VIRTUAL_ENV` and `PATH`.

## Practical patterns

### A separate Python environment per project

```bash
cd ~/projects/foo
echo 'layout python3' > .envrc
direnv allow
```

### Loading local secrets (not committed)

```bash
# .envrc
dotenv_if_exists .env.local
```

Add `.env.local` to `.gitignore` and commit `.envrc` to the repo. That way others only need to create their own `.env.local` after cloning.

### Pinning the Node version with fnm

```bash
# .envrc
use node
```

It reads `.nvmrc` or `.node-version`.

## Relationship with other tools

| Tool | Role |
|---|---|
| fnm | Only switches Node versions |
| direnv | Manages arbitrary environment variables, and can also call fnm |
| Zsh `export` | Global effect, does not change with the directory |

The two can be combined: direnv sets `PATH` in the project directory while fnm's `--use-on-cd` also listens for `cd`. If both change the Node version, the behavior depends on execution order — usually letting direnv take charge is more predictable.

## Troubleshooting

**Nothing happens when entering a directory**: `.envrc` has not been allowed. `direnv status` will explicitly say "not allowed".

**Editing .envrc has no effect**: the hash changed; run `direnv allow` again.

**Variables not cleaned up**: after leaving a directory they should be unset automatically. If not, the hook is not registered — check whether `direnv hook zsh` ran.

**`direnv: error .envrc is blocked`**: a security block; follow the prompt and run `direnv allow`.

**Slow loading**: `.envrc` contains slow commands (like `nix develop`). Consider caching the result or switching to something lighter.

**Conflicts with tmux sessions**: a new tmux pane inherits the environment from the time it was created and does not re-trigger direnv. Run `direnv reload` manually in the pane.

<!-- lang:ja -->
> 要約：direnv はディレクトリごとに環境変数を読み込みます。プロジェクトに入ると自動で適用され、出ると自動でクリーンアップされます。

# direnv

## 用途

`direnv` は環境変数をディレクトリに追従させます。プロジェクトのルートに `.envrc` を置くと、`cd` で入ったときに自動で読み込まれ、出るときに自動でアンロードされます。「プロジェクトごとに異なる API キー、異なる Python 仮想環境、異なるデータベースアドレスが必要」という問題を解決します。

## ソースとインストール

| 項目 | 説明 |
|---|---|
| ソース | Zinit、GitHub Release から単一バイナリをダウンロード |
| 読み込み場所 | `plugins/tools/tools.zsh` |
| 実行ファイル名 | `direnv` |

```zsh
zinit ice as"command" from"gh-r" sbin"direnv"
zinit light direnv/direnv
```

## シェル統合

```zsh
if command -v direnv >/dev/null 2>&1; then
  eval "$(direnv hook zsh)"
fi
```

フックは `chpwd` を登録し、ディレクトリを移動するたびに現在のパスとすべての親ディレクトリに許可済みの `.envrc` がないか確認します。

## 基本的な使い方

```bash
cd ~/project
echo 'export DATABASE_URL=postgres://localhost/dev' > .envrc
direnv allow                 # 首次必须显式授权
```

以後、そのディレクトリに入るたびに `DATABASE_URL` が自動的に設定され、出た後に自動的に unset されます。

## サブコマンド

| コマンド | 動作 |
|---|---|
| `direnv allow [path]` | 読み込みを許可 |
| `direnv deny [path]` | 許可を取り消す |
| `direnv edit [path]` | 編集して自動的に許可 |
| `direnv reload` | 現在のディレクトリを再読み込み |
| `direnv status` | 現在の読み込み状態を表示 |
| `direnv exec DIR CMD` | 指定ディレクトリの環境でコマンドを実行 |
| `direnv export SHELL` | 環境の差分を出力（デバッグ用） |
| `direnv prune` | 期限切れの許可記録を整理 |
| `direnv stdlib` | 利用可能な標準ライブラリ関数を表示 |

## allow が必須な理由

`.envrc` は**実行可能なシェルスクリプト**であり、任意のコマンドを実行できます。自動で読み込まれると、悪意あるリポジトリをクローンしただけでコードが実行される可能性があります。そのため direnv は、ファイルの内容ごとに明示的な許可を求め、ファイルのハッシュを `~/.local/share/direnv/allow/` に記録します。

`.envrc` が変更されるとハッシュが無効になり、再度 `direnv allow` が必要です。これはセキュリティ設計であり、バグではありません。

## .envrc に書けること

`.envrc` は bash 構文で、direnv が標準ライブラリ関数を提供します：

```bash
# 加载 .env 文件
dotenv

# 加载 .env 并允许缺失
dotenv_if_exists

# 使用 Python 虚拟环境
layout python3
layout python ~/.venv/myproject

# 使用 Node 版本
use node 20

# 使用 nix shell
use nix

# 添加 PATH
PATH_add bin

# 设置变量
export API_URL=https://api.example.com
```

`layout python3` は `.direnv/python-3.x.x` の下に仮想環境を自動作成/アクティベートし、`VIRTUAL_ENV` と `PATH` の両方を設定します。

## 実用的なパターン

### プロジェクトごとの独立した Python 環境

```bash
cd ~/projects/foo
echo 'layout python3' > .envrc
direnv allow
```

### ローカルのシークレットを読み込む（コミットしない）

```bash
# .envrc
dotenv_if_exists .env.local
```

`.env.local` を `.gitignore` に追加し、`.envrc` をリポジトリにコミットします。これにより他の人がクローンした後は、自分の `.env.local` を作るだけで済みます。

### fnm で Node バージョンを固定

```bash
# .envrc
use node
```

`.nvmrc` か `.node-version` を読みます。

## 他のツールとの関係

| ツール | 役割 |
|---|---|
| fnm | Node バージョン切り替えのみ担当 |
| direnv | 任意の環境変数を管理。fnm の呼び出しも可能 |
| Zsh の `export` | グローバルに有効で、ディレクトリに追従しない |

両者は併用できます。direnv がプロジェクトディレクトリで `PATH` を設定し、fnm の `--use-on-cd` も `cd` を監視します。両方が Node バージョンを変更する場合、挙動は実行順序に依存するため、通常は direnv に任せる方が制御しやすくなります。

## トラブルシューティング

**ディレクトリに入っても反応がない**：`.envrc` が allow されていません。`direnv status` が「not allowed」と明示的に表示します。

**.envrc を変更しても効かない**：ハッシュが変わったので、再度 `direnv allow` してください。

**変数がクリーンアップされない**：ディレクトリを出たら自動で unset されるはずです。されない場合はフックが登録されていないので、`direnv hook zsh` が実行されているか確認してください。

**`direnv: error .envrc is blocked`**：セキュリティによるブロックです。表示に従い `direnv allow` してください。

**読み込みが遅い**：`.envrc` に時間のかかるコマンド（例：`nix develop`）があります。結果をキャッシュするか、より軽い方法に切り替えてください。

**tmux セッションとの競合**：tmux が新しい pane を作るとき、継承するのは作成時点の環境であり、direnv は再トリガされません。pane 内で手動で `direnv reload` してください。
