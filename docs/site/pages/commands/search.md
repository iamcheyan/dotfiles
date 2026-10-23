> 摘要：find、fd、locate、which 等查找命令，以及本机 fzf 交互式筛选的工作方式。

# 查找

## find

`find` 按条件遍历文件系统，是最古老也最全能的查找命令：

```bash
find . -name '*.log'                # 按文件名（通配符要引号）
find . -iname '*.log'               # 忽略大小写
find . -type f -name '*.tmp'        # 只找文件（-type d 只找目录）
find . -mtime -7                    # 最近 7 天修改过的
find . -size +100M                  # 大于 100M
find . -empty                       # 空文件/空目录
find . -user tetsuya                # 按所有者
find . -name '*.py' -exec grep -l 'TODO' {} +   # 对结果执行命令
find . -name '*.bak' -delete        # 找到即删（先 -print 干跑一遍！）
```

`-exec ... {} +` 比 `-exec ... \;` 高效（批量传参）；删除类操作先把 `-delete` 换成 `-print` 确认清单。

`find` 的坑：默认递归所有子目录包括隐藏目录，在 `~` 全盘跑会扫进 `.git`、`node_modules`。限定深度和排除：

```bash
find ~/development -maxdepth 2 -name '*.md' -not -path '*/node_modules/*'
```

## fd

本机用 **fd** 替代 `find`，更快、语法更简单、默认尊重 `.gitignore`：

```bash
fd pattern                 # 递归搜文件名含 pattern 的
fd -e py                   # 只搜 .py 文件
fd -t f pattern            # 只文件；-t d 只目录；-t l 符号链接
fd -H pattern              # 含隐藏文件
fd -I pattern              # 连 .gitignore 忽略的也搜
fd -d 2 pattern            # 最多下钻 2 层
fd -x rg '{}' pattern      # 对结果执行命令（{} 是占位符）
fd -e js -x wc -l          # 统计所有 JS 行数
```

本站 shell 配置里有两个搜索函数就是 `fd` 驱动的，见 [f 与 ffd 函数](../shell/fzf-functions.html)：

```bash
f pattern      # fd 枚举 + fzf 选择 + 用编辑器打开
ffd pattern    # fd 枚举 + fzf 选择 + cd 到所在目录
```

## locate

按全盘文件名索引秒级搜索（依赖 `mlocate`/`plocate` 每日更新的数据库）：

```bash
locate filename
locate -i filename       # 忽略大小写
locate -e filename       # 只输出确实现存的文件（-e 排除已删除的）
sudo updatedb            # 手动更新索引
```

Debian 默认可能没装 `plocate`：`sudo apt install plocate`。索引不含今天新建的文件，找新文件用 `fd`。

## which / whereis / type

```bash
which node            # 命令的可执行文件路径（按 PATH 搜）
whereis node          # 二进制、源码、man 页位置
type ls               # Zsh 内建：报告命令类型（别名/函数/内建/文件）
type -a ls            # 列出所有匹配（别名优先于真身）
command -v ls         # POSIX 写法，脚本里用这个判断存在性
```

`type` 在 Zsh 里特别有用，一眼看出 `l` 是别名、`f` 是函数还是外部命令——排查"我敲的命令到底是什么"的第一个命令。

## fzf 交互式筛选

**fzf** 不是查找器，是通用筛选器：任何列表（文件、历史、进程、Git 分支）都能变成交互式搜索。本机的核心入口：

| 快捷键 | 作用 |
|---|---|
| `Ctrl+T` | 筛选当前目录文件，路径插入命令行 |
| `Alt+C` | 筛选目录，跳过去 |
| `Ctrl+R` | 搜索历史命令（本机是 Atuin 接管） |
| `f 关键词` | 搜文件并用编辑器打开 |
| `ffd 关键词` | 搜目录并跳转 |

管道用法：

```bash
ls | fzf                       # 任意列表都能筛
git branch | fzf | xargs git checkout   # 筛选分支并切换
rg -l TODO | fzf | xargs nvim # 搜含 TODO 的文件，选一个打开
```

fzf 界面里：输入即筛选，`↑/↓`（或 `Ctrl+J/K`）移动，`Enter` 选中，`Tab` 多选，`Esc` 取消。

## 组合技：本机常见查找场景

```bash
# 找最大的 10 个文件
fd -t f -I . ~ -x du -h | sort -rh | head -10

# 找最近改过的配置文件
fd -t f -e conf -e toml -e yaml --changed-within 3d ~/.config

# 哪个进程在监听某个端口（本机查服务冲突）
ss -ltnp | rg 8645

# 清理超过 30 天没人动过的下载目录文件（先 dry-run）
fd -t f --changed-before 30d ~/Downloads -x echo
```

## 排错

**`find` 结果太多太慢**：加 `-maxdepth`，或改用 `fd`（默认跳过 `.git`/`node_modules`）。

**`fd` 搜不到某文件**：被 `.gitignore` 忽略，加 `-I`。

**`fzf` 预览窗口是空的**：预览命令依赖的 `bat`/`eza` 没装，检查 `command -v bat eza`。

**`which` 和实际运行的不一致**：`which` 只搜 PATH，`type -a` 才能看到别名和函数覆盖。脚本里请用 `command -v`。

<!-- lang:en -->

> Summary: Search commands such as find, fd, locate, and which, plus how the machine's fzf interactive filtering works.

# Searching

## find

`find` walks the filesystem by conditions; it's the oldest and most versatile search command:

```bash
find . -name '*.log'                # 按文件名（通配符要引号）
find . -iname '*.log'               # 忽略大小写
find . -type f -name '*.tmp'        # 只找文件（-type d 只找目录）
find . -mtime -7                    # 最近 7 天修改过的
find . -size +100M                  # 大于 100M
find . -empty                       # 空文件/空目录
find . -user tetsuya                # 按所有者
find . -name '*.py' -exec grep -l 'TODO' {} +   # 对结果执行命令
find . -name '*.bak' -delete        # 找到即删（先 -print 干跑一遍！）
```

`-exec ... {} +` is more efficient than `-exec ... \;` (batched arguments); for deletion operations, replace `-delete` with `-print` first to confirm the list.

The pitfall of `find`: it recurses into all subdirectories including hidden ones, so running it across `~` will scan `.git` and `node_modules`. Limit depth and exclude paths:

```bash
find ~/development -maxdepth 2 -name '*.md' -not -path '*/node_modules/*'
```

## fd

This machine uses **fd** instead of `find` — faster, simpler syntax, and it respects `.gitignore` by default:

```bash
fd pattern                 # 递归搜文件名含 pattern 的
fd -e py                   # 只搜 .py 文件
fd -t f pattern            # 只文件；-t d 只目录；-t l 符号链接
fd -H pattern              # 含隐藏文件
fd -I pattern              # 连 .gitignore 忽略的也搜
fd -d 2 pattern            # 最多下钻 2 层
fd -x rg '{}' pattern      # 对结果执行命令（{} 是占位符）
fd -e js -x wc -l          # 统计所有 JS 行数
```

Two search functions in this site's shell config are driven by `fd`; see [The f and ffd functions](../shell/fzf-functions.html):

```bash
f pattern      # fd 枚举 + fzf 选择 + 用编辑器打开
ffd pattern    # fd 枚举 + fzf 选择 + cd 到所在目录
```

## locate

Second-level searches over a whole-disk filename index (backed by a database updated daily by `mlocate`/`plocate`):

```bash
locate filename
locate -i filename       # 忽略大小写
locate -e filename       # 只输出确实现存的文件（-e 排除已删除的）
sudo updatedb            # 手动更新索引
```

Debian may not have `plocate` installed by default: `sudo apt install plocate`. The index doesn't include files created today, so use `fd` for new files.

## which / whereis / type

```bash
which node            # 命令的可执行文件路径（按 PATH 搜）
whereis node          # 二进制、源码、man 页位置
type ls               # Zsh 内建：报告命令类型（别名/函数/内建/文件）
type -a ls            # 列出所有匹配（别名优先于真身）
command -v ls         # POSIX 写法，脚本里用这个判断存在性
```

`type` is especially useful in Zsh: at a glance you see whether `l` is an alias, `f` a function, or an external command — the first command for diagnosing "what exactly am I running".

## fzf interactive filtering

**fzf** isn't a searcher; it's a universal filter: any list (files, history, processes, Git branches) becomes an interactive search. This machine's core entry points:

| 快捷键 | 作用 |
|---|---|
| `Ctrl+T` | 筛选当前目录文件，路径插入命令行 |
| `Alt+C` | 筛选目录，跳过去 |
| `Ctrl+R` | 搜索历史命令（本机是 Atuin 接管） |
| `f 关键词` | 搜文件并用编辑器打开 |
| `ffd 关键词` | 搜目录并跳转 |

Piping usage:

```bash
ls | fzf                       # 任意列表都能筛
git branch | fzf | xargs git checkout   # 筛选分支并切换
rg -l TODO | fzf | xargs nvim # 搜含 TODO 的文件，选一个打开
```

Inside the fzf UI: typing filters, `↑/↓` (or `Ctrl+J/K`) moves, `Enter` selects, `Tab` multi-selects, `Esc` cancels.

## Combos: common search scenarios on this machine

```bash
# 找最大的 10 个文件
fd -t f -I . ~ -x du -h | sort -rh | head -10

# 找最近改过的配置文件
fd -t f -e conf -e toml -e yaml --changed-within 3d ~/.config

# 哪个进程在监听某个端口（本机查服务冲突）
ss -ltnp | rg 8645

# 清理超过 30 天没人动过的下载目录文件（先 dry-run）
fd -t f --changed-before 30d ~/Downloads -x echo
```

## Troubleshooting

**`find` returns too many results, too slowly**: add `-maxdepth`, or switch to `fd` (skips `.git`/`node_modules` by default).

**`fd` can't find a file**: it's ignored by `.gitignore`; add `-I`.

**The `fzf` preview window is empty**: the preview command depends on `bat`/`eza`, which aren't installed; check with `command -v bat eza`.

**`which` disagrees with what actually runs**: `which` only searches PATH; `type -a` shows alias and function overrides. In scripts, use `command -v`.

<!-- lang:ja -->

> 要約：find、fd、locate、which などの検索コマンドと、本機の fzf 対話型フィルタリングの仕組み。

# 検索

## find

`find` は条件に従ってファイルシステムを巡回する、最も古く最も万能な検索コマンドです：

```bash
find . -name '*.log'                # 按文件名（通配符要引号）
find . -iname '*.log'               # 忽略大小写
find . -type f -name '*.tmp'        # 只找文件（-type d 只找目录）
find . -mtime -7                    # 最近 7 天修改过的
find . -size +100M                  # 大于 100M
find . -empty                       # 空文件/空目录
find . -user tetsuya                # 按所有者
find . -name '*.py' -exec grep -l 'TODO' {} +   # 对结果执行命令
find . -name '*.bak' -delete        # 找到即删（先 -print 干跑一遍！）
```

`-exec ... {} +` は `-exec ... \;` より効率的です（引数をまとめて渡す）。削除系の操作では、リストを確認するためにまず `-delete` を `-print` に置き換えます。

`find` の落とし穴：デフォルトで隠しディレクトリも含むすべてのサブディレクトリを再帰するので、`~` 全体で実行すると `.git` や `node_modules` まで掃いてしまいます。深さを限定し、除外を指定します：

```bash
find ~/development -maxdepth 2 -name '*.md' -not -path '*/node_modules/*'
```

## fd

本機では `find` の代わりに **fd** を使います。より速く、構文がシンプルで、デフォルトで `.gitignore` を尊重します：

```bash
fd pattern                 # 递归搜文件名含 pattern 的
fd -e py                   # 只搜 .py 文件
fd -t f pattern            # 只文件；-t d 只目录；-t l 符号链接
fd -H pattern              # 含隐藏文件
fd -I pattern              # 连 .gitignore 忽略的也搜
fd -d 2 pattern            # 最多下钻 2 层
fd -x rg '{}' pattern      # 对结果执行命令（{} 是占位符）
fd -e js -x wc -l          # 统计所有 JS 行数
```

本サイトのシェル設定には `fd` で駆動する検索関数が 2 つあります。[f と ffd 関数](../shell/fzf-functions.html)を参照：

```bash
f pattern      # fd 枚举 + fzf 选择 + 用编辑器打开
ffd pattern    # fd 枚举 + fzf 选择 + cd 到所在目录
```

## locate

全ディスクのファイル名インデックスを使った秒単位の検索です（`mlocate`/`plocate` が毎日更新するデータベースに依存します）：

```bash
locate filename
locate -i filename       # 忽略大小写
locate -e filename       # 只输出确实现存的文件（-e 排除已删除的）
sudo updatedb            # 手动更新索引
```

Debian ではデフォルトで `plocate` が入っていないことがあります：`sudo apt install plocate`。インデックスには今日作ったファイルは含まれないので、新しいファイルは `fd` で探します。

## which / whereis / type

```bash
which node            # 命令的可执行ファイルパス（PATH に従って検索）
whereis node          # バイナリ、ソース、man ページの場所
type ls               # Zsh 内建：报告命令类型（别名/函数/内建/文件）
type -a ls            # 列出所有匹配（别名优先于真身）
command -v ls         # POSIX 写法，脚本里用这个判断存在性
```

Zsh では `type` が特に有用で、`l` がエイリアスか、`f` が関数か外部コマンドか一目で分かります — 「自分が叩いたコマンドは結局何なのか」を調べる最初のコマンドです。

## fzf 対話型フィルタリング

**fzf** は検索ツールではなく万能フィルタです：どんなリスト（ファイル、履歴、プロセス、Git ブランチ）も対話型検索に変えられます。本機の主な入口：

| 快捷键 | 作用 |
|---|---|
| `Ctrl+T` | 筛选当前目录文件，路径插入命令行 |
| `Alt+C` | 筛选目录，跳过去 |
| `Ctrl+R` | 搜索历史命令（本机是 Atuin 接管） |
| `f 关键词` | 搜文件并用编辑器打开 |
| `ffd 关键词` | 搜目录并跳转 |

パイプでの使い方：

```bash
ls | fzf                       # 任意列表都能筛
git branch | fzf | xargs git checkout   # 筛选分支并切换
rg -l TODO | fzf | xargs nvim # 搜含 TODO 的文件，选一个打开
```

fzf の画面では：入力するだけで絞り込み、`↑/↓`（または `Ctrl+J/K`）で移動、`Enter` で選択、`Tab` で複数選択、`Esc` でキャンセルです。

## 組み合わせ技：本機のよくある検索シーン

```bash
# 找最大的 10 个文件
fd -t f -I . ~ -x du -h | sort -rh | head -10

# 找最近改过的配置文件
fd -t f -e conf -e toml -e yaml --changed-within 3d ~/.config

# 哪个进程在监听某个端口（本机查服务冲突）
ss -ltnp | rg 8645

# 清理超过 30 天没人动过的下载目录文件（先 dry-run）
fd -t f --changed-before 30d ~/Downloads -x echo
```

## トラブルシューティング

**`find` の結果が多すぎて遅い**：`-maxdepth` を付けるか、`fd` に切り替えます（デフォルトで `.git`/`node_modules` をスキップ）。

**`fd` でファイルが見つからない**：`.gitignore` に無視されています。`-I` を付けます。

**`fzf` のプレビューウィンドウが空**：プレビューコマンドが依存する `bat`/`eza` が未インストールです。`command -v bat eza` で確認します。

**`which` と実際に動くものが一致しない**：`which` は PATH しか見ず、エイリアスや関数の上書きは `type -a` でしか見えません。スクリプトでは `command -v` を使ってください。
