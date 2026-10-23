> 摘要：fd 按文件名查找，是 fzf 和 ffd 的默认枚举器，也是 f 的兜底方案。

# fd

## 用途

`fd` 是 `find` 的现代替代：语法更短、默认并行、默认忽略 `.gitignore` 和隐藏文件、输出彩色。本仓库用它做两件事：fzf 的默认文件枚举，以及 `ffd` 的搜索后端。

## 来源与安装

| 项目 | 说明 |
|---|---|
| 来源 | Zinit，从 GitHub Release 下载 |
| 加载位置 | `plugins/tools/tools.zsh` |
| 特殊处理 | Release 包里的二进制在子目录中，需要 `mv` 和 `sbin` |

```zsh
zinit ice as"command" from"gh-r" mv"fd-*/fd -> fd" pick"fd" sbin"fd"
zinit light sharkdp/fd
```

`mv"fd-*/fd -> fd"` 把压缩包内 `fd-v10.2.0-x86_64-unknown-linux-gnu/fd` 这类路径扁平化成 `fd`。`sbin"fd"` 把二进制放进 Zinit 的 bin 目录，让它进入 PATH。

Debian 系统包里的可执行名是 `fdfind`（因为 `fd` 名字冲突），本仓库的 `fzf.zsh` 有兼容处理：如果找不到 `fd` 但找得到 `fdfind`，会建一个 `~/.local/bin/fd` 软链接。

## 基本用法

```bash
fd                          # 列出当前目录所有文件（递归）
fd pattern                  # 按文件名匹配
fd pattern /some/path       # 在指定目录搜索
fd -e py                    # 按扩展名
fd -t f                     # 只要文件
fd -t d                     # 只要目录
fd -x rm                    # 对每个结果执行命令
fd -X rm                    # 所有结果一次性传给命令
```

`pattern` 默认是**正则表达式**（不是 glob）。想用 glob 加 `--glob`。

## 常用参数

| 参数 | 作用 |
|---|---|
| `-H` / `--hidden` | 包含隐藏文件 |
| `-I` / `--no-ignore` | 忽略 `.gitignore` 等规则 |
| `--no-ignore-vcs` | 只忽略 VCS 规则 |
| `-e` / `--extension` | 按扩展名筛选，可重复 |
| `-t` / `--type` | `f` 文件、`d` 目录、`l` 软链接、`x` 可执行 |
| `-d` / `--max-depth` | 最大递归深度 |
| `-x` / `--exec` | 对每个结果执行命令（并行） |
| `-X` / `--exec-batch` | 所有结果一次传给命令 |
| `-g` / `--glob` | 用 glob 而不是正则 |
| `-F` / `--fixed-strings` | 按字面字符串匹配 |
| `-0` / `--print0` | NUL 分隔，配合 `xargs -0` |
| `-c` / `--color` | `auto`/`always`/`never` |
| `--follow` | 跟随软链接 |
| `--exclude` | 排除匹配项 |

## 实用例子

```bash
fd -e lua                          # 所有 .lua 文件
fd -e lua -e md                    # .lua 或 .md
fd -t d -d 1                       # 只看当前目录的直接子目录
fd -H -I '\.env'                   # 含隐藏文件和被忽略文件
fd -x wc -l                        # 统计每个文件行数
fd -e png -X rm                    # 删除所有 png
fd --changed-within 1d             # 最近一天修改过
fd --size +10M                     # 大于 10MB
```

## 本仓库里的用法

### fzf 默认命令

```zsh
export FZF_DEFAULT_COMMAND='fd --hidden --follow --exclude .git'
```

| 选项 | 原因 |
|---|---|
| `--hidden` | 想搜到 `.env`、`.github` 这类文件 |
| `--follow` | 跟随软链接，仓库里有 `chezmoi` 这样的软链接 |
| `--exclude .git` | 不枚举 Git 内部对象，数量巨大且无用 |

### f 的兜底

`f` 函数本身用 `ls` 枚举，但 `FZF_DEFAULT_COMMAND` 会影响 fzf 的 `Ctrl+T` 行为。

### ffd 的后端

```zsh
if command -v fd >/dev/null 2>&1 && fd --version >/dev/null 2>&1; then
    fd_cmd="fd"
    [[ -n "$pattern" ]] && search_cmd=(fd "$pattern" "$base") || search_cmd=(fd . "$base")
elif command -v fdfind >/dev/null 2>&1; then
    ...
fi
```

注意 `fd --version` 这个额外检查：不仅要求命令存在，还要求它能正常执行。这能捕获「软链接指向了不存在的目标」这类损坏状态。

## 和 find 的对照

| 需求 | find | fd |
|---|---|---|
| 按名查找 | `find . -name '*.lua'` | `fd -e lua` |
| 忽略 gitignore | 手动 `-not -path` | 默认忽略 |
| 含隐藏文件 | 默认包含 | `-H` |
| 执行命令 | `-exec cmd {} \;` | `-x cmd` |
| 并行 | 无 | 默认并行 |

## 排错

**`fd: command not found`**：Zinit 未下载。`zinit list | grep fd` 确认，重启 Zsh。

**找不到被忽略的文件**：默认遵守 `.gitignore`。加 `-I`。

**找不到隐藏文件**：加 `-H`。

**`fdfind` 和 `fd` 都在**：`command -v fd` 应指向 Zinit 目录。如果指向 `~/.local/bin/fd` 且是坏软链接，删掉它让 Zinit 版本生效。

<!-- lang:en -->
> Summary: fd finds files by name; it is the default enumerator for fzf and ffd, and the fallback for f.

# fd

## Purpose

`fd` is a modern replacement for `find`: shorter syntax, parallel by default, respects `.gitignore` and skips hidden files by default, colored output. This repo uses it for two things: the default file enumerator for fzf, and the search backend for `ffd`.

## Source and installation

| Item | Description |
|---|---|
| Source | Zinit, downloaded from GitHub Release |
| Load location | `plugins/tools/tools.zsh` |
| Special handling | The binary inside the release package sits in a subdirectory, requiring `mv` and `sbin` |

```zsh
zinit ice as"command" from"gh-r" mv"fd-*/fd -> fd" pick"fd" sbin"fd"
zinit light sharkdp/fd
```

`mv"fd-*/fd -> fd"` flattens paths like `fd-v10.2.0-x86_64-unknown-linux-gnu/fd` inside the archive into `fd`. `sbin"fd"` places the binary into Zinit's bin directory, putting it on the PATH.

The Debian system package names the executable `fdfind` (due to a name clash with `fd`). This repo's `fzf.zsh` handles that: if `fd` is not found but `fdfind` is, it creates a `~/.local/bin/fd` symlink.

## Basic usage

```bash
fd                          # 列出当前目录所有文件（递归）
fd pattern                  # 按文件名匹配
fd pattern /some/path       # 在指定目录搜索
fd -e py                    # 按扩展名
fd -t f                     # 只要文件
fd -t d                     # 只要目录
fd -x rm                    # 对每个结果执行命令
fd -X rm                    # 所有结果一次性传给命令
```

`pattern` is a **regular expression** by default (not a glob). Add `--glob` to use globs.

## Common options

| Option | Action |
|---|---|
| `-H` / `--hidden` | Include hidden files |
| `-I` / `--no-ignore` | Ignore `.gitignore` and similar rules |
| `--no-ignore-vcs` | Ignore only VCS rules |
| `-e` / `--extension` | Filter by extension, repeatable |
| `-t` / `--type` | `f` files, `d` directories, `l` symlinks, `x` executables |
| `-d` / `--max-depth` | Maximum recursion depth |
| `-x` / `--exec` | Run a command for each result (in parallel) |
| `-X` / `--exec-batch` | Pass all results to a command at once |
| `-g` / `--glob` | Use globs instead of regex |
| `-F` / `--fixed-strings` | Match literal strings |
| `-0` / `--print0` | NUL-separated, pair with `xargs -0` |
| `-c` / `--color` | `auto`/`always`/`never` |
| `--follow` | Follow symlinks |
| `--exclude` | Exclude matches |

## Practical examples

```bash
fd -e lua                          # 所有 .lua 文件
fd -e lua -e md                    # .lua 或 .md
fd -t d -d 1                       # 只看当前目录的直接子目录
fd -H -I '\.env'                   # 含隐藏文件和被忽略文件
fd -x wc -l                        # 统计每个文件行数
fd -e png -X rm                    # 删除所有 png
fd --changed-within 1d             # 最近一天修改过
fd --size +10M                     # 大于 10MB
```

## Usage in this repo

### fzf default command

```zsh
export FZF_DEFAULT_COMMAND='fd --hidden --follow --exclude .git'
```

| Option | Reason |
|---|---|
| `--hidden` | We want to find files like `.env` and `.github` |
| `--follow` | Follow symlinks; the repo contains symlinks like `chezmoi` |
| `--exclude .git` | Do not enumerate Git internals — huge in number and useless |

### The fallback for f

The `f` function itself enumerates with `ls`, but `FZF_DEFAULT_COMMAND` affects fzf's `Ctrl+T` behavior.

### The backend for ffd

```zsh
if command -v fd >/dev/null 2>&1 && fd --version >/dev/null 2>&1; then
    fd_cmd="fd"
    [[ -n "$pattern" ]] && search_cmd=(fd "$pattern" "$base") || search_cmd=(fd . "$base")
elif command -v fdfind >/dev/null 2>&1; then
    ...
fi
```

Note the extra `fd --version` check: it requires not just that the command exists, but that it actually runs. This catches broken states like "the symlink points to a nonexistent target".

## Comparison with find

| Need | find | fd |
|---|---|---|
| Find by name | `find . -name '*.lua'` | `fd -e lua` |
| Respect gitignore | Manual `-not -path` | Respected by default |
| Include hidden files | Included by default | `-H` |
| Run a command | `-exec cmd {} \;` | `-x cmd` |
| Parallelism | None | Parallel by default |

## Troubleshooting

**`fd: command not found`**: Zinit has not downloaded it. Confirm with `zinit list | grep fd`, then restart Zsh.

**Ignored files not found**: `.gitignore` rules are respected by default. Add `-I`.

**Hidden files not found**: add `-H`.

**Both `fdfind` and `fd` exist**: `command -v fd` should point into the Zinit directory. If it points at `~/.local/bin/fd` and that symlink is broken, delete it so the Zinit version takes effect.

<!-- lang:ja -->
> 要約：fd はファイル名で検索します。fzf と ffd のデフォルト列挙器であり、f のフォールバックでもあります。

# fd

## 用途

`fd` は `find` の現代的な代替です。構文が短く、デフォルトで並列処理し、デフォルトで `.gitignore` と隠しファイルを無視し、出力はカラーです。本リポジトリでは 2 つの用途で使います。fzf のデフォルトのファイル列挙と、`ffd` の検索バックエンドです。

## ソースとインストール

| 項目 | 説明 |
|---|---|
| ソース | Zinit、GitHub Release からダウンロード |
| 読み込み場所 | `plugins/tools/tools.zsh` |
| 特殊処理 | release パッケージ内のバイナリはサブディレクトリにあり、`mv` と `sbin` が必要 |

```zsh
zinit ice as"command" from"gh-r" mv"fd-*/fd -> fd" pick"fd" sbin"fd"
zinit light sharkdp/fd
```

`mv"fd-*/fd -> fd"` は、アーカイブ内の `fd-v10.2.0-x86_64-unknown-linux-gnu/fd` のようなパスを `fd` にフラット化します。`sbin"fd"` はバイナリを Zinit の bin ディレクトリに置き、PATH に乗せます。

Debian のシステムパッケージでは実行ファイル名が `fdfind` です（`fd` という名前の衝突のため）。本リポジトリの `fzf.zsh` には互換処理があり、`fd` が見つからず `fdfind` が見つかる場合は `~/.local/bin/fd` にシンボリックリンクを作成します。

## 基本的な使い方

```bash
fd                          # 列出当前目录所有文件（递归）
fd pattern                  # 按文件名匹配
fd pattern /some/path       # 在指定目录搜索
fd -e py                    # 按扩展名
fd -t f                     # 只要文件
fd -t d                     # 只要目录
fd -x rm                    # 对每个结果执行命令
fd -X rm                    # 所有结果一次性传给命令
```

`pattern` はデフォルトで**正規表現**です（glob ではありません）。glob を使いたい場合は `--glob` を付けてください。

## よく使うオプション

| オプション | 動作 |
|---|---|
| `-H` / `--hidden` | 隠しファイルを含める |
| `-I` / `--no-ignore` | `.gitignore` などのルールを無視 |
| `--no-ignore-vcs` | VCS のルールのみ無視 |
| `-e` / `--extension` | 拡張子でフィルタ。繰り返し指定可 |
| `-t` / `--type` | `f` ファイル、`d` ディレクトリ、`l` シンボリックリンク、`x` 実行可能ファイル |
| `-d` / `--max-depth` | 最大再帰の深さ |
| `-x` / `--exec` | 結果ごとにコマンドを実行（並列） |
| `-X` / `--exec-batch` | すべての結果を一度にコマンドへ渡す |
| `-g` / `--glob` | 正規表現の代わりに glob を使う |
| `-F` / `--fixed-strings` | リテラル文字列でマッチ |
| `-0` / `--print0` | NUL 区切り。`xargs -0` と組み合わせ |
| `-c` / `--color` | `auto`/`always`/`never` |
| `--follow` | シンボリックリンクを辿る |
| `--exclude` | マッチする項目を除外 |

## 実用的な例

```bash
fd -e lua                          # 所有 .lua 文件
fd -e lua -e md                    # .lua 或 .md
fd -t d -d 1                       # 只看当前目录的直接子目录
fd -H -I '\.env'                   # 含隐藏文件和被忽略文件
fd -x wc -l                        # 统计每个文件行数
fd -e png -X rm                    # 删除所有 png
fd --changed-within 1d             # 最近一天修改过
fd --size +10M                     # 大于 10MB
```

## 本リポジトリでの使い方

### fzf のデフォルトコマンド

```zsh
export FZF_DEFAULT_COMMAND='fd --hidden --follow --exclude .git'
```

| オプション | 理由 |
|---|---|
| `--hidden` | `.env`、`.github` のようなファイルも検索したい |
| `--follow` | シンボリックリンクを辿る。リポジトリには `chezmoi` のようなリンクがある |
| `--exclude .git` | Git の内部オブジェクトを列挙しない。数が膨大で無意味 |

### f のフォールバック

`f` 関数自体は `ls` で列挙しますが、`FZF_DEFAULT_COMMAND` は fzf の `Ctrl+T` の挙動に影響します。

### ffd のバックエンド

```zsh
if command -v fd >/dev/null 2>&1 && fd --version >/dev/null 2>&1; then
    fd_cmd="fd"
    [[ -n "$pattern" ]] && search_cmd=(fd "$pattern" "$base") || search_cmd=(fd . "$base")
elif command -v fdfind >/dev/null 2>&1; then
    ...
fi
```

`fd --version` という追加チェックに注意してください。コマンドが存在するだけでなく、実際に実行できることも要求します。これにより「シンボリックリンクが存在しない先を指している」といった壊れた状態を捕捉できます。

## find との対照

| 要件 | find | fd |
|---|---|---|
| 名前で検索 | `find . -name '*.lua'` | `fd -e lua` |
| gitignore を無視 | 手動で `-not -path` | デフォルトで無視 |
| 隠しファイルを含む | デフォルトで含む | `-H` |
| コマンドを実行 | `-exec cmd {} \;` | `-x cmd` |
| 並列処理 | なし | デフォルトで並列 |

## トラブルシューティング

**`fd: command not found`**：Zinit がダウンロードしていません。`zinit list | grep fd` で確認し、Zsh を再起動してください。

**無視されているファイルが見つからない**：デフォルトで `.gitignore` に従います。`-I` を追加してください。

**隠しファイルが見つからない**：`-H` を追加してください。

**`fdfind` と `fd` の両方がある**：`command -v fd` は Zinit のディレクトリを指しているはずです。`~/.local/bin/fd` を指していて、それが壊れたシンボリックリンクなら、削除して Zinit 版を有効にしてください。
