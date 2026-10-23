> 摘要：ripgrep 按内容搜索，是 Neovim 的 grepprg，也是本仓库唯一的内容检索工具。

# ripgrep

## 用途

`ripgrep`（命令名 `rg`）在目录树里按**内容**搜索，速度远超 `grep -r`。它默认遵守 `.gitignore`、跳过二进制文件、并行搜索、自动检测编码。

本仓库在三个地方用到它：

1. 手动搜索内容。
2. Neovim 的 `grepprg`（`config/nvim` 里设为 `rg --vimgrep`）。
3. `packtar.sh` 里检测 `tar --help` 是否支持某个参数（用 `rg -q` 代替 grep）。

## 来源与安装

| 项目 | 说明 |
|---|---|
| 来源 | Zinit，从 GitHub Release 下载 |
| 加载位置 | `plugins/tools/tools.zsh` |
| 特殊处理 | Release 包内二进制在子目录，需要扁平化 |

```zsh
zinit ice as"command" from"gh-r" mv"ripgrep-*/rg -> rg" pick"rg" sbin"rg"
zinit light BurntSushi/ripgrep
```

## 基本用法

```bash
rg pattern                  # 当前目录递归搜索
rg pattern path/            # 指定目录
rg -i pattern               # 忽略大小写
rg -w pattern               # 全词匹配
rg -F pattern               # 字面匹配，不当正则
rg -l pattern               # 只列文件名
rg -c pattern               # 只计数
rg --files                  # 列出会被搜索的文件（不搜内容）
```

## 常用参数

| 参数 | 作用 |
|---|---|
| `-i` / `--ignore-case` | 忽略大小写 |
| `-S` / `--smart-case` | 全小写时忽略大小写，含大写时区分 |
| `-w` / `--word-regexp` | 全词匹配 |
| `-F` / `--fixed-strings` | 按字面串匹配 |
| `-l` / `--files-with-matches` | 只输出文件名 |
| `-c` / `--count` | 每个文件的匹配数 |
| `-n` / `--line-number` | 显示行号（默认开启） |
| `-A/-B/-C N` | 匹配行后/前/前后 N 行 |
| `-t` / `--type` | 按文件类型过滤，如 `-t py` |
| `-g` / `--glob` | 按 glob 包含/排除 |
| `-U` / `--multiline` | 允许多行匹配 |
| `-P` / `--pcre2` | 用 PCRE2 正则（支持后行断言等） |
| `--hidden` | 搜索隐藏文件 |
| `--no-ignore` | 忽略 `.gitignore` |
| `--vimgrep` | 输出 `file:line:col:match` 格式 |
| `--json` | 结构化输出，配合 jq |

## 实用例子

```bash
rg -t lua 'vim\.keymap'              # 只在 lua 文件里搜
rg -g '*.md' -g '!CHANGELOG*' TODO   # 排除特定文件
rg -C 3 'function M\.'               # 带三行上下文
rg -l 'FIXME' | xargs wc -l          # 列出含 FIXME 的文件并统计行数
rg --files -g '*.cob'                # 只列 cobol 文件
rg -U 'BEGIN.*?END' -P               # 多行 + PCRE2
rg --json 'error' | jq '.data.path.text'  # 结构化处理
```

## 本仓库里的用法

### Neovim grepprg

Neovim 配置里：

```vim
if executable("rg")
  let &grepprg = "rg --vimgrep"
  set grepformat=%f:%l:%c:%m
endif
```

这让 `:grep` 用 rg，结果带列号，可以直接跳转。Neovim 里的 Telescope/Snacks picker 也优先用 rg 做 live grep。

### packtar 里的探测

```bash
if command -v rg >/dev/null 2>&1; then
    TAR_HELP_MATCHER=(rg -q --)
else
    TAR_HELP_MATCHER=(grep -q --)
fi
```

用 `rg -q` 检查 `tar --help` 输出里有没有某参数。有 rg 就用 rg，没有就退回 grep——这是本仓库「优先现代工具、保留 fallback」模式的典型写法。

## 与 grep 的差异

| 行为 | grep | ripgrep |
|---|---|---|
| 默认递归 | 否 | 是 |
| 遵守 .gitignore | 否 | 是 |
| 跳过二进制 | 需 `-I` | 默认 |
| 隐藏文件 | 默认搜 | 默认跳过 |
| 并行 | 否 | 是 |
| 正则引擎 | BRE/ERE | Rust regex（近似 PCRE） |

**最容易踩的差异**：`rg` 默认不搜隐藏文件和被 gitignore 的文件。想全搜要显式 `--hidden --no-ignore`。

## 排错

**搜不到 `.env` 或 `node_modules` 里的内容**：默认被忽略。用 `rg --hidden --no-ignore`。

**正则写法不兼容**：Rust regex 不支持后行断言（lookbehind）。需要时加 `-P` 用 PCRE2。

**`rg: command not found`**：Zinit 未下载。`zinit list | grep ripgrep` 确认。

**输出太多**：先 `-l` 只列文件，再针对单个文件搜索。

<!-- lang:en -->
> Summary: ripgrep searches file contents, serves as Neovim's grepprg, and is the only content search tool in this repository.

# ripgrep

## Purpose

`ripgrep` (command name `rg`) searches **file contents** throughout directory trees, far faster than `grep -r`. By default, it follows `.gitignore`, skips binary files, searches in parallel, and detects encodings automatically.

This repository uses it in three places:

1. Searching content manually.
2. Neovim's `grepprg` (set to `rg --vimgrep` in `config/nvim`).
3. Checking in `packtar.sh` whether `tar --help` supports an option (using `rg -q` instead of grep).

## Source and installation

| Item | Description |
|---|---|
| Source | Zinit, downloaded from GitHub Release |
| Load location | `plugins/tools/tools.zsh` |
| Special handling | The binary in the Release package is in a subdirectory, so it must be flattened |

## Basic usage

```bash
rg pattern                  # 当前目录递归搜索
rg pattern path/            # 指定目录
rg -i pattern               # 忽略大小写
rg -w pattern               # 全词匹配
rg -F pattern               # 字面匹配，不当正则
rg -l pattern               # 只列文件名
rg -c pattern               # 只计数
rg --files                  # 列出会被搜索的文件（不搜内容）
```

## Common options

| Option | Effect |
|---|---|
| `-i` / `--ignore-case` | Ignore case |
| `-S` / `--smart-case` | Ignore case when all letters are lowercase; match case when uppercase letters are present |
| `-w` / `--word-regexp` | Match whole words |
| `-F` / `--fixed-strings` | Match literal strings |
| `-l` / `--files-with-matches` | Output filenames only |
| `-c` / `--count` | Number of matches in each file |
| `-n` / `--line-number` | Show line numbers (enabled by default) |
| `-A/-B/-C N` | N lines after/before/around each match |
| `-t` / `--type` | Filter by file type, such as `-t py` |
| `-g` / `--glob` | Include/exclude by glob |
| `-U` / `--multiline` | Allow matches across multiple lines |
| `-P` / `--pcre2` | Use PCRE2 regex (supports lookbehind and more) |
| `--hidden` | Search hidden files |
| `--no-ignore` | Ignore `.gitignore` |
| `--vimgrep` | Output in `file:line:col:match` format |
| `--json` | Structured output, for use with jq |

## Practical examples

```bash
rg -t lua 'vim\\.keymap'              # 只在 lua 文件里搜
rg -g '*.md' -g '!CHANGELOG*' TODO   # 排除特定文件
rg -C 3 'function M\\.'               # 带三行上下文
rg -l 'FIXME' | xargs wc -l          # 列出含 FIXME 的文件并统计行数
rg --files -g '*.cob'                # 只列 cobol 文件
rg -U 'BEGIN.*?END' -P               # 多行 + PCRE2
rg --json 'error' | jq '.data.path.text'  # 结构化处理
```

## Usage in this repository

### Neovim grepprg

In the Neovim configuration:

```vim
if executable("rg")
  let &grepprg = "rg --vimgrep"
  set grepformat=%f:%l:%c:%m
endif
```

This makes `:grep` use rg and include column numbers, so you can jump directly to a match. Telescope/Snacks pickers in Neovim also prefer rg for live grep.

### Detection in packtar

```bash
if command -v rg >/dev/null 2>&1; then
    TAR_HELP_MATCHER=(rg -q --)
else
    TAR_HELP_MATCHER=(grep -q --)
fi
```

Use `rg -q` to check whether the `tar --help` output contains an option. If rg is available, use it; otherwise fall back to grep—a typical example of this repository's “prefer modern tools, retain a fallback” pattern.

## Differences from grep

| Behavior | grep | ripgrep |
|---|---|---|
| Recursive by default | No | Yes |
| Follows .gitignore | No | Yes |
| Skips binary files | Requires `-I` | By default |
| Hidden files | Searches by default | Skips by default |
| Parallel | No | Yes |
| Regex engine | BRE/ERE | Rust regex (roughly similar to PCRE) |

**The easiest difference to overlook**: `rg` does not search hidden files or files ignored by gitignore by default. To search everything, explicitly pass `--hidden --no-ignore`.

## Troubleshooting

**Can't find content in `.env` or `node_modules`**: These are ignored by default. Use `rg --hidden --no-ignore`.

**Regex syntax is incompatible**: Rust regex does not support lookbehind. Add `-P` to use PCRE2 when needed.

**`rg: command not found`**: Zinit has not downloaded it. Check with `zinit list | grep ripgrep`.

**Too much output**: First use `-l` to list only files, then search a specific file.

```zsh
zinit ice as"command" from"gh-r" mv"ripgrep-*/rg -> rg" pick"rg" sbin"rg"
zinit light BurntSushi/ripgrep
```

```bash
rg -t lua 'vim\.keymap'              # 只在 lua 文件里搜
rg -g '*.md' -g '!CHANGELOG*' TODO   # 排除特定文件
rg -C 3 'function M\.'               # 带三行上下文
rg -l 'FIXME' | xargs wc -l          # 列出含 FIXME 的文件并统计行数
rg --files -g '*.cob'                # 只列 cobol 文件
rg -U 'BEGIN.*?END' -P               # 多行 + PCRE2
rg --json 'error' | jq '.data.path.text'  # 结构化处理
```

<!-- lang:ja -->
> 要約：ripgrep は内容検索ツールです。Neovim の grepprg として使われ、このリポジトリ唯一の内容検索ツールです。

# ripgrep

## 用途

`ripgrep`（コマンド名 `rg`）はディレクトリツリー全体から**ファイルの内容**を検索します。`grep -r` より大幅に高速です。既定で `.gitignore` に従い、バイナリファイルを除外し、並列検索を行い、エンコーディングを自動検出します。

このリポジトリでは次の3か所で使います。

1. 手動で内容を検索します。
2. Neovim の `grepprg` として使います（`config/nvim` で `rg --vimgrep` に設定しています）。
3. `packtar.sh` で `tar --help` が特定のオプションに対応するか確認します（grep の代わりに `rg -q` を使います）。

## 入手元とインストール

| 項目 | 説明 |
|---|---|
| 入手元 | Zinit が GitHub Release からダウンロードします |
| 読み込み場所 | `plugins/tools/tools.zsh` |
| 特別な処理 | Release パッケージ内のバイナリがサブディレクトリにあるため、平坦化します |

## 基本的な使い方

## よく使うオプション

| オプション | 効果 |
|---|---|
| `-i` / `--ignore-case` | 大文字と小文字を区別しません |
| `-S` / `--smart-case` | すべて小文字なら区別せず、大文字を含む場合は区別します |
| `-w` / `--word-regexp` | 単語全体に一致させます |
| `-F` / `--fixed-strings` | 文字列をそのまま照合します |
| `-l` / `--files-with-matches` | ファイル名だけを出力します |
| `-c` / `--count` | 各ファイルの一致数を表示します |
| `-n` / `--line-number` | 行番号を表示します（既定で有効です） |
| `-A/-B/-C N` | 一致行の後／前／前後 N 行を表示します |
| `-t` / `--type` | `-t py` のようにファイル種別で絞り込みます |
| `-g` / `--glob` | glob で対象を含める／除外します |
| `-U` / `--multiline` | 複数行にまたがる一致を許可します |
| `-P` / `--pcre2` | PCRE2 正規表現を使います（後読みなどに対応します） |
| `--hidden` | 隠しファイルを検索します |
| `--no-ignore` | `.gitignore` を無視します |
| `--vimgrep` | `file:line:col:match` 形式で出力します |
| `--json` | jq と組み合わせられる構造化出力を行います |

## 実用例

## このリポジトリでの使い方

### Neovim grepprg

Neovim の設定では次のようにしています。

これにより `:grep` が rg を使い、列番号も出力するため、一致箇所へ直接移動できます。Neovim の Telescope/Snacks picker も live grep に rg を優先して使います。

### packtar での検出

`rg -q` で `tar --help` の出力にオプションが含まれるか確認します。rg があれば rg を使い、なければ grep に切り替えます。これは「新しいツールを優先しつつ、代替手段も残す」というこのリポジトリの典型的な書き方です。

## grep との違い

| 動作 | grep | ripgrep |
|---|---|---|
| 既定で再帰検索 | いいえ | はい |
| .gitignore に従う | いいえ | はい |
| バイナリを除外 | `-I` が必要です | 既定で除外します |
| 隠しファイル | 既定で検索します | 既定で除外します |
| 並列処理 | しません | します |
| 正規表現エンジン | BRE/ERE | Rust regex（PCRE に近い仕様です） |

**特に見落としやすい違い**：`rg` は既定で隠しファイルと gitignore 対象を検索しません。すべて検索するには `--hidden --no-ignore` を明示します。

## トラブルシューティング

**`.env` や `node_modules` 内の内容が見つかりません**：既定で無視されています。`rg --hidden --no-ignore` を使います。

**正規表現の構文が使えません**：Rust regex は後読みをサポートしません。必要な場合は `-P` を付けて PCRE2 を使います。

**`rg: command not found`**：Zinit がまだダウンロードしていません。`zinit list | grep ripgrep` で確認します。

**出力が多すぎます**：まず `-l` でファイル名だけを表示し、その後、個別のファイルを検索します。

```zsh
zinit ice as"command" from"gh-r" mv"ripgrep-*/rg -> rg" pick"rg" sbin"rg"
zinit light BurntSushi/ripgrep
```

```bash
rg pattern                  # 当前目录递归搜索
rg pattern path/            # 指定目录
rg -i pattern               # 忽略大小写
rg -w pattern               # 全词匹配
rg -F pattern               # 字面匹配，不当正则
rg -l pattern               # 只列文件名
rg -c pattern               # 只计数
rg --files                  # 列出会被搜索的文件（不搜内容）
```

```bash
rg -t lua 'vim\.keymap'              # 只在 lua 文件里搜
rg -g '*.md' -g '!CHANGELOG*' TODO   # 排除特定文件
rg -C 3 'function M\.'               # 带三行上下文
rg -l 'FIXME' | xargs wc -l          # 列出含 FIXME 的文件并统计行数
rg --files -g '*.cob'                # 只列 cobol 文件
rg -U 'BEGIN.*?END' -P               # 多行 + PCRE2
rg --json 'error' | jq '.data.path.text'  # 结构化处理
```

```vim
if executable("rg")
  let &grepprg = "rg --vimgrep"
  set grepformat=%f:%l:%c:%m
endif
```

```bash
if command -v rg >/dev/null 2>&1; then
    TAR_HELP_MATCHER=(rg -q --)
else
    TAR_HELP_MATCHER=(grep -q --)
fi
```
