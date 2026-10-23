> 摘要：procs 是 ps 的现代替代，支持关键字逻辑组合、可配置列和树状视图。

# procs

## 用途

`procs` 替代 `ps aux | grep xxx`：输出彩色、支持多关键字与布尔组合、可配置显示列、支持树状视图、可正则匹配。

## 来源与安装

| 项目 | 说明 |
|---|---|
| 来源 | Zinit，从 GitHub Release 下载 |

```zsh
zi_cmd dalance/procs procs
```

## 基本用法

```bash
procs                    # 列出所有进程
procs nvim               # 关键字搜索
procs nvim lua           # 多个关键字
procs --tree             # 树状视图
```

## 关键字逻辑

| 参数 | 逻辑 |
|---|---|
| 默认 | AND（所有关键字都要匹配） |
| `-a` / `--and` | 显式 AND |
| `-o` / `--or` | 任一匹配 |
| `-d` / `--nand` | 不全匹配 |
| `-r` / `--nor` | 全不匹配 |

例子：

```bash
procs -o nvim vim          # 名字含 nvim 或 vim
procs -r chrome firefox    # 既不是 chrome 也不是 firefox
procs --tree nvim          # 只看 nvim 的进程树
```

## 匹配模式

| 参数 | 模式 |
|---|---|
| `--text` | 纯文本（默认） |
| `--regex` | 正则表达式（单模式） |
| `--smart` | 自动判断是否用正则语法 |

## 列配置

```bash
procs -l                   # 列出所有可用列类型
```

默认列可以在配置文件里定义。配置位置：`~/.config/procs/config.toml`。

```toml
[[columns]]
kind = "Pid"
style = "BrightYellow"

[[columns]]
kind = "User"
style = "BrightGreen"

[[columns]]
kind = "Cpu"
style = "BrightCyan"

[[columns]]
kind = "Command"
style = "BrightWhite"
```

这是 procs 相对 `ps` 的最大优势：显示哪些列、什么颜色、什么顺序，全部可配。

## 常用参数

| 参数 | 作用 |
|---|---|
| `--tree` | 树状显示父子关系 |
| `-w` / `--watch` | 持续刷新 |
| `-i` / `--insert` | 在默认列前插入列 |
| `-c` / `--color` | 颜色模式 |
| `-l` / `--list` | 列出可用列类型 |

## 实用例子

```bash
procs --tree                        # 进程树
procs --watch                       # 类似 top 的持续刷新
procs -w node                       # 只看 node 进程并刷新
procs --regex '^python'             # 正则匹配
procs -r chrome firefox -w          # 排除两个浏览器并刷新
```

## 与 ps 的对照

| 需求 | ps | procs |
|---|---|---|
| 全部进程 | `ps aux` | `procs` |
| 按名搜索 | `ps aux \| grep x` | `procs x` |
| 排除 | `ps aux \| grep -v x` | `procs -r x` |
| 树状 | `ps auxf` | `procs --tree` |
| 自定义列 | `ps -o ...` | 配置文件 |
| 持续刷新 | `watch ps` | `procs -w` |

## 排错

**`procs: command not found`**：Zinit 未下载。`zinit list | grep procs` 确认。

**颜色丢失**：输出到管道时默认关色。加 `--color always`。

**列太多导致折行**：修改配置文件只保留需要的列，或加宽终端。

**搜索不到进程**：默认 AND 逻辑要求所有关键字都匹配。改用 `-o`。

**`--watch` 下按键无响应**：某些终端下需要先 `Ctrl+C` 退出。这是 procs 的实现限制。

<!-- lang:en -->

> Summary: procs is a modern replacement for ps with boolean keyword combinations, configurable columns and a tree view.

# procs

## Purpose

`procs` replaces `ps aux | grep xxx`: colored output, multiple keywords with boolean combinations, configurable display columns, a tree view, and regex matching.

## Source and install

| Item | Notes |
|---|---|
| Source | Zinit, downloaded from GitHub Release |

```zsh
zi_cmd dalance/procs procs
```

## Basic usage

```bash
procs                    # 列出所有进程
procs nvim               # 关键字搜索
procs nvim lua           # 多个关键字
procs --tree             # 树状视图
```

## Keyword logic

| Flag | Logic |
|---|---|
| default | AND (all keywords must match) |
| `-a` / `--and` | explicit AND |
| `-o` / `--or` | any match |
| `-d` / `--nand` | not all matching |
| `-r` / `--nor` | none matching |

Examples:

```bash
procs -o nvim vim          # 名字含 nvim 或 vim
procs -r chrome firefox    # 既不是 chrome 也不是 firefox
procs --tree nvim          # 只看 nvim 的进程树
```

## Match modes

| Flag | Mode |
|---|---|
| `--text` | plain text (default) |
| `--regex` | regular expression (single pattern) |
| `--smart` | automatically decides whether to use regex syntax |

## Column configuration

```bash
procs -l                   # 列出所有可用列类型
```

The default columns can be defined in the config file. Config location: `~/.config/procs/config.toml`.

```toml
[[columns]]
kind = "Pid"
style = "BrightYellow"

[[columns]]
kind = "User"
style = "BrightGreen"

[[columns]]
kind = "Cpu"
style = "BrightCyan"

[[columns]]
kind = "Command"
style = "BrightWhite"
```

This is procs' biggest advantage over `ps`: which columns to show, in what color, in what order — all configurable.

## Common flags

| Flag | Effect |
|---|---|
| `--tree` | show the parent/child relationship as a tree |
| `-w` / `--watch` | continuous refresh |
| `-i` / `--insert` | insert columns before the default ones |
| `-c` / `--color` | color mode |
| `-l` / `--list` | list available column types |

## Useful examples

```bash
procs --tree                        # 进程树
procs --watch                       # 类似 top 的持续刷新
procs -w node                       # 只看 node 进程并刷新
procs --regex '^python'             # 正则匹配
procs -r chrome firefox -w          # 排除两个浏览器并刷新
```

## Comparison with ps

| Need | ps | procs |
|---|---|---|
| All processes | `ps aux` | `procs` |
| Search by name | `ps aux \| grep x` | `procs x` |
| Exclude | `ps aux \| grep -v x` | `procs -r x` |
| Tree | `ps auxf` | `procs --tree` |
| Custom columns | `ps -o ...` | config file |
| Continuous refresh | `watch ps` | `procs -w` |

## Troubleshooting

**`procs: command not found`** — Zinit hasn't downloaded it. Confirm with `zinit list | grep procs`.

**Colors missing** — colors are off by default when output goes to a pipe. Add `--color always`.

**Too many columns wrapping lines** — edit the config file to keep only the columns you need, or widen the terminal.

**Can't find a process** — the default AND logic requires every keyword to match. Switch to `-o`.

**Keys unresponsive under `--watch`** — on some terminals you have to exit with `Ctrl+C` first. This is a limitation of procs' implementation.

<!-- lang:ja -->

> 要約：procs は ps のモダンな代替で、キーワードの論理組み合わせ、列のカスタマイズ、ツリービューに対応しています。

# procs

## 用途

`procs` は `ps aux | grep xxx` を置き換えるものです。出力はカラー、複数キーワードと論理組み合わせに対応し、表示列を設定でき、ツリービューと正規表現マッチも使えます。

## ソースとインストール

| 項目 | 説明 |
|---|---|
| ソース | Zinit、GitHub Release からダウンロード |

```zsh
zi_cmd dalance/procs procs
```

## 基本的な使い方

```bash
procs                    # 列出所有进程
procs nvim               # 关键字搜索
procs nvim lua           # 多个关键字
procs --tree             # 树状视图
```

## キーワードの論理

| オプション | 論理 |
|---|---|
| デフォルト | AND（すべてのキーワードが一致する必要がある） |
| `-a` / `--and` | 明示的な AND |
| `-o` / `--or` | いずれかが一致 |
| `-d` / `--nand` | すべては一致しない |
| `-r` / `--nor` | まったく一致しない |

例：

```bash
procs -o nvim vim          # 名字含 nvim 或 vim
procs -r chrome firefox    # 既不是 chrome 也不是 firefox
procs --tree nvim          # 只看 nvim 的进程树
```

## マッチモード

| オプション | モード |
|---|---|
| `--text` | プレーンテキスト（デフォルト） |
| `--regex` | 正規表現（単一パターン） |
| `--smart` | 正規表現構文を使うか自動判定 |

## 列の設定

```bash
procs -l                   # 列出所有可用列类型
```

デフォルトの列は設定ファイルで定義できます。設定場所：`~/.config/procs/config.toml`。

```toml
[[columns]]
kind = "Pid"
style = "BrightYellow"

[[columns]]
kind = "User"
style = "BrightGreen"

[[columns]]
kind = "Cpu"
style = "BrightCyan"

[[columns]]
kind = "Command"
style = "BrightWhite"
```

これは `ps` に対する procs の最大の強みです。どの列を、どの色で、どの順で表示するか、すべて設定できます。

## よく使うオプション

| オプション | 効果 |
|---|---|
| `--tree` | 親子関係をツリー表示 |
| `-w` / `--watch` | 継続リフレッシュ |
| `-i` / `--insert` | デフォルト列の前に列を挿入 |
| `-c` / `--color` | カラーモード |
| `-l` / `--list` | 利用可能な列タイプの一覧 |

## 実用例

```bash
procs --tree                        # 进程树
procs --watch                       # 类似 top 的持续刷新
procs -w node                       # 只看 node 进程并刷新
procs --regex '^python'             # 正则匹配
procs -r chrome firefox -w          # 排除两个浏览器并刷新
```

## ps との対照

| 需求 | ps | procs |
|---|---|---|
| 全プロセス | `ps aux` | `procs` |
| 名前で検索 | `ps aux \| grep x` | `procs x` |
| 除外 | `ps aux \| grep -v x` | `procs -r x` |
| ツリー | `ps auxf` | `procs --tree` |
| 列のカスタマイズ | `ps -o ...` | 設定ファイル |
| 継続リフレッシュ | `watch ps` | `procs -w` |

## トラブルシュート

**`procs: command not found`**：Zinit が未ダウンロードです。`zinit list | grep procs` で確認します。

**色が消える**：パイプへの出力時はデフォルトで色がオフになります。`--color always` を付けてください。

**列が多すぎて折り返す**：設定ファイルで必要な列だけにするか、ターミナルを広げます。

**プロセスが見つからない**：デフォルトの AND 論理ではすべてのキーワードが一致する必要があります。`-o` に切り替えます。

**`--watch` 中にキーが反応しない**：一部のターミナルでは先に `Ctrl+C` で終了する必要があります。これは procs の実装上の制限です。
