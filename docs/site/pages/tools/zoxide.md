> 摘要：zoxide 按访问频率记录目录，用 z 跳转、zi 交互选择、za/zr 维护数据库。

# zoxide

## 用途

`zoxide` 记录你访问过的目录及其频率，用短关键字跳转。输入 `z proj` 就能跳到最常访问的、路径里含 `proj` 的目录，不需要写完整路径。

本仓库用它替代 `cd` 的长路径输入，并把它和 fzf 结合成 `zi`。

## 来源与安装

| 项目 | 说明 |
|---|---|
| 来源 | Zinit，从 GitHub Release 下载 |
| 加载位置 | `plugins/tools/tools.zsh` |
| 数据文件 | 默认在系统数据目录（Linux: `~/.local/share/zoxide/db.zo`） |

```zsh
zi_cmd ajeetdsouza/zoxide zoxide
```

## 初始化与别名

```zsh
if command -v zoxide > /dev/null; then
  _evalcache zoxide init zsh
  alias zi='z -i'      # 交互式选择
  alias za='z -a'      # 添加目录
  alias zr='z -r'      # 移除目录
fi
```

`_evalcache` 把 `zoxide init zsh` 的输出缓存，避免每次启动都执行。它注入的是 `z` 和 `zi` 两个 shell 函数，不是别名——因为需要在当前 shell 里真正 `cd`。

## 基本用法

```bash
z project           # 跳到最匹配 project 的目录
z proj doc          # 多个关键字，全部匹配
z ~/work            # 给绝对路径时直接 cd（退化为普通 cd）
z -                 # 回到上一个目录（类似 cd -）
zi                  # 交互式选择
```

匹配规则：关键字可以出现在路径的任意位置，按「访问频率 × 时间衰减」排序。刚访问过的目录权重更高。

## 子命令

| 命令 | 作用 |
|---|---|
| `zoxide add <path>` | 手动增加路径权重 |
| `zoxide remove <path>` | 从数据库移除 |
| `zoxide query <keyword>` | 查询匹配路径，不跳转 |
| `zoxide query -l` | 列出全部记录的路径 |
| `zoxide query -s` | 显示每个路径的分数 |
| `zoxide edit` | 打开数据库编辑器 |
| `zoxide import` | 从 autojump / z / fasd 导入 |
| `zoxide init <shell>` | 生成 shell 集成代码 |

## 本仓库的别名

| 别名 | 展开 | 用途 |
|---|---|---|
| `zi` | `z -i` | 交互式：用 fzf 从匹配项里选 |
| `za` | `z -a` | 添加当前目录到数据库 |
| `zr` | `z -r` | 移除指定目录 |

`zi` 是最常用的：当 `z` 的关键字匹配到多个目录时，`zi` 会弹出 fzf 让你选。它复用 `FZF_DEFAULT_OPTS`，所以也有预览窗口。

## 环境变量

| 变量 | 作用 |
|---|---|
| `_ZO_DATA_DIR` | 数据文件目录 |
| `_ZO_ECHO` | 设为 1 时跳转前打印目标路径 |
| `_ZO_EXCLUDE_DIRS` | 排除的目录 glob 列表 |
| `_ZO_FZF_OPTS` | 传给 `zi` 的 fzf 参数 |
| `_ZO_MAXAGE` | 条目总权重上限，超过后淘汰旧条目 |
| `_ZO_RESOLVE_SYMLINKS` | 存储时解析软链接 |

常用配置示例（放在 `local/`）：

```zsh
export _ZO_EXCLUDE_DIRS="$HOME:/tmp:/var/tmp"
export _ZO_FZF_OPTS="--height 60% --reverse --border"
```

## 与 fzf 的关系

`zoxide init zsh` 注入的 `zi` 函数内部调用 fzf。所以：

- 没有 fzf 时 `zi` 不可用，但 `z` 仍工作。
- `zi` 的预览由 zoxide 自己的默认值决定，可用 `_ZO_FZF_OPTS` 覆盖。
- 本仓库的 `alias zi='z -i'` 是把 `z` 的交互开关暴露出来，等价于内置的 `zi`。

## 与 fzf-tab 的联动

`plugins/zsh-plugins.zsh` 里配置了：

```zsh
zstyle ':fzf-tab:complete:z:*' fzf-preview 'eza -1 --color=always $realpath'
```

所以用 Tab 补全 `z` 的参数时，也会显示目标目录的内容预览。

## 排错

**`z` 命令不存在**：zoxide 没初始化。检查 `zshrc` 里那行 `_evalcache zoxide init zsh`。

**`z` 跳不到想要的目录**：数据库里还没有它。先进去一次（`cd`），zoxide 会自动记录；或 `za` 手动添加。

**跳到了错误目录**：用 `zi` 手动选，或用 `zoxide query -s` 看分数，用 `zr` 移除错误项。

**数据库太大**：`_ZO_MAXAGE` 控制上限，默认会自动淘汰。也可以 `zoxide edit` 手动清理。

**多个终端共享数据库**：这是设计行为。zoxide 用文件锁保证并发安全。

<!-- lang:en -->
> Summary: zoxide records directories by visit frequency. Use z to jump, zi for interactive selection, and za/zr to manage the database.

# zoxide

## Purpose

`zoxide` records the directories you visit and how often you visit them, then lets you jump using short keywords. Enter `z proj` to jump to the most frequently visited directory whose path contains `proj`; you do not need to type the full path.

This repository uses it instead of typing long paths for `cd`, and combines it with fzf as `zi`.

## Source and installation

| Item | Description |
|---|---|
| Source | Zinit, downloaded from GitHub Release |
| Load location | `plugins/tools/tools.zsh` |
| Data file | System data directory by default (Linux: `~/.local/share/zoxide/db.zo`) |

## Initialization and aliases

`_evalcache` caches the output of `zoxide init zsh` to avoid executing it at every startup. It injects two shell functions, `z` and `zi`, rather than aliases, because they need to run `cd` in the current shell.

## Basic usage

Matching rules: keywords can appear anywhere in the path, and results are sorted by “visit frequency × time decay.” Recently visited directories receive a higher score.

## Subcommands

| Command | Effect |
|---|---|
| `zoxide add <path>` | Manually increase a path's score |
| `zoxide remove <path>` | Remove a path from the database |
| `zoxide query <keyword>` | Find matching paths without jumping |
| `zoxide query -l` | List all recorded paths |
| `zoxide query -s` | Show the score for each path |
| `zoxide edit` | Open the database editor |
| `zoxide import` | Import from autojump / z / fasd |
| `zoxide init <shell>` | Generate shell integration code |

## Aliases in this repository

| Alias | Expands to | Purpose |
|---|---|---|
| `zi` | `z -i` | Interactive: choose a match with fzf |
| `za` | `z -a` | Add the current directory to the database |
| `zr` | `z -r` | Remove a specified directory |

`zi` is used most often: when `z` matches multiple directories, `zi` opens fzf so you can choose one. It reuses `FZF_DEFAULT_OPTS`, so it also has a preview window.

## Environment variables

| Variable | Effect |
|---|---|
| `_ZO_DATA_DIR` | Data file directory |
| `_ZO_ECHO` | When set to 1, print the destination path before jumping |
| `_ZO_EXCLUDE_DIRS` | List of directory globs to exclude |
| `_ZO_FZF_OPTS` | fzf options passed to `zi` |
| `_ZO_MAXAGE` | Total entry score limit; old entries are removed after it is exceeded |
| `_ZO_RESOLVE_SYMLINKS` | Resolve symlinks when storing paths |

Common configuration examples (put these in `local/`):

## Relationship with fzf

The `zi` function injected by `zoxide init zsh` calls fzf internally. Therefore:

- Without fzf, `zi` is unavailable, but `z` still works.
- The preview in `zi` is determined by zoxide's defaults and can be overridden with `_ZO_FZF_OPTS`.
- This repository's `alias zi='z -i'` exposes the interactive option for `z`; it is equivalent to the built-in `zi`.

## Integration with fzf-tab

When you use Tab completion for `z` arguments, the contents of the destination directory are also previewed.

## Troubleshooting

**The `z` command is missing**: zoxide has not been initialized. Check the `_evalcache zoxide init zsh` line in `zshrc`.

**`z` cannot reach the directory you want**: It is not in the database yet. Visit it once with `cd` so zoxide records it, or add it manually with `za`.

**It jumps to the wrong directory**: Choose manually with `zi`, inspect scores with `zoxide query -s`, or remove the wrong entry with `zr`.

**The database is too large**: `_ZO_MAXAGE` controls the limit, and old entries are removed automatically by default. You can also clean it manually with `zoxide edit`.

**Multiple terminals share the database**: This is intentional. zoxide uses file locking to ensure concurrent access is safe.

```zsh
zi_cmd ajeetdsouza/zoxide zoxide
```

```zsh
if command -v zoxide > /dev/null; then
  _evalcache zoxide init zsh
  alias zi='z -i'      # 交互式选择
  alias za='z -a'      # 添加目录
  alias zr='z -r'      # 移除目录
fi
```

```bash
z project           # 跳到最匹配 project 的目录
z proj doc          # 多个关键字，全部匹配
z ~/work            # 给绝对路径时直接 cd（退化为普通 cd）
z -                 # 回到上一个目录（类似 cd -）
zi                  # 交互式选择
```

```zsh
export _ZO_EXCLUDE_DIRS="$HOME:/tmp:/var/tmp"
export _ZO_FZF_OPTS="--height 60% --reverse --border"
```

```zsh
zstyle ':fzf-tab:complete:z:*' fzf-preview 'eza -1 --color=always $realpath'
```

<!-- lang:ja -->
> 要約：zoxide は訪問頻度に応じてディレクトリを記録します。z で移動し、zi で対話的に選択し、za/zr でデータベースを管理します。

# zoxide

## 用途

`zoxide` は訪問したディレクトリとその頻度を記録し、短いキーワードで移動できるようにします。`z proj` と入力すると、パスに `proj` を含むディレクトリのうち、最もよく訪問した場所へ移動します。パス全体を入力する必要はありません。

このリポジトリでは長いパスを `cd` に入力する代わりに使い、fzf と組み合わせて `zi` を提供しています。

## 入手元とインストール

| 項目 | 説明 |
|---|---|
| 入手元 | Zinit が GitHub Release からダウンロードします |
| 読み込み場所 | `plugins/tools/tools.zsh` |
| データファイル | 既定ではシステムのデータディレクトリ（Linux: `~/.local/share/zoxide/db.zo`） |

## 初期化とエイリアス

`_evalcache` は `zoxide init zsh` の出力をキャッシュし、起動のたびに実行するのを避けます。現在のシェル内で `cd` する必要があるため、エイリアスではなく `z` と `zi` の2つのシェル関数を注入します。

## 基本的な使い方

照合キーワードはパス内のどこにあってもよく、「訪問頻度 × 時間による減衰」で並べ替えます。最近訪問したディレクトリほど高い重みになります。

## サブコマンド

| コマンド | 効果 |
|---|---|
| `zoxide add <path>` | パスの重みを手動で増やします |
| `zoxide remove <path>` | データベースからパスを削除します |
| `zoxide query <keyword>` | 移動せずに一致するパスを検索します |
| `zoxide query -l` | 記録されたパスをすべて表示します |
| `zoxide query -s` | 各パスのスコアを表示します |
| `zoxide edit` | データベース編集用のエディターを開きます |
| `zoxide import` | autojump / z / fasd から取り込みます |
| `zoxide init <shell>` | シェル統合コードを生成します |

## このリポジトリのエイリアス

| エイリアス | 展開形 | 用途 |
|---|---|---|
| `zi` | `z -i` | fzf で候補を選ぶ対話モードです |
| `za` | `z -a` | 現在のディレクトリをデータベースに追加します |
| `zr` | `z -r` | 指定したディレクトリを削除します |

最もよく使うのは `zi` です。`z` で複数のディレクトリが見つかると、fzf が開いて選べます。`FZF_DEFAULT_OPTS` を再利用するため、プレビューウィンドウも表示されます。

## 環境変数

| 変数 | 効果 |
|---|---|
| `_ZO_DATA_DIR` | データファイルのディレクトリ |
| `_ZO_ECHO` | 1 にすると、移動前に移動先のパスを表示します |
| `_ZO_EXCLUDE_DIRS` | 除外するディレクトリ glob の一覧 |
| `_ZO_FZF_OPTS` | `zi` に渡す fzf オプション |
| `_ZO_MAXAGE` | エントリ全体の重みの上限です。超えると古いエントリが削除されます |
| `_ZO_RESOLVE_SYMLINKS` | 保存時にシンボリックリンクを解決します |

よく使う設定例は `local/` に置きます。

## fzf との関係

`zoxide init zsh` が注入する `zi` 関数は内部で fzf を呼び出します。そのため、次のようになります。

- fzf がない場合、`zi` は使えませんが `z` は動作します。
- `zi` のプレビューは zoxide の既定値で決まり、`_ZO_FZF_OPTS` で上書きできます。
- このリポジトリの `alias zi='z -i'` は `z` の対話オプションを使えるようにします。組み込みの `zi` と同等です。

## fzf-tab との連携

`z` の引数を Tab 補完すると、移動先ディレクトリの内容もプレビューします。

## トラブルシューティング

**`z` コマンドがありません**：zoxide が初期化されていません。`zshrc` の `_evalcache zoxide init zsh` の行を確認します。

**`z` で目的のディレクトリへ移動できません**：まだデータベースにありません。一度 `cd` で移動すると自動的に記録されます。または `za` で手動追加します。

**誤ったディレクトリへ移動します**：`zi` で手動選択するか、`zoxide query -s` でスコアを確認し、間違った項目を `zr` で削除します。

**データベースが大きすぎます**：`_ZO_MAXAGE` で上限を設定でき、既定では古い項目が自動削除されます。`zoxide edit` で手動整理することもできます。

**複数の端末でデータベースを共有します**：これは意図した動作です。zoxide はファイルロックを使い、並行アクセスの安全性を保ちます。

```zsh
zi_cmd ajeetdsouza/zoxide zoxide
```

```zsh
if command -v zoxide > /dev/null; then
  _evalcache zoxide init zsh
  alias zi='z -i'      # 交互式选择
  alias za='z -a'      # 添加目录
  alias zr='z -r'      # 移除目录
fi
```

```bash
z project           # 跳到最匹配 project 的目录
z proj doc          # 多个关键字，全部匹配
z ~/work            # 给绝对路径时直接 cd（退化为普通 cd）
z -                 # 回到上一个目录（类似 cd -）
zi                  # 交互式选择
```

```zsh
export _ZO_EXCLUDE_DIRS="$HOME:/tmp:/var/tmp"
export _ZO_FZF_OPTS="--height 60% --reverse --border"
```

```zsh
zstyle ':fzf-tab:complete:z:*' fzf-preview 'eza -1 --color=always $realpath'
```
