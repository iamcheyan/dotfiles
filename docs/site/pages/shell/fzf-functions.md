> 摘要：f 与 ffd 两个文件搜索函数的完整行为、按键、回退逻辑和实现细节。

# f 与 ffd 函数

两个函数都在 `plugins/fzf/fzf.zsh`，共用一套 fzf 选项和剪贴板逻辑。

## f：当前目录选择器 / 管道选择器

```zsh
f                                   # 列当前目录
find . -iname '*keyword*' | f       # 选择 find 结果
grep -rn 'keyword' . | f            # 选择 grep 结果（带行号）
```

### 行为

**无管道**（`f` 单独使用）：

1. 用 `ls` 生成候选列表。
2. 弹出 fzf，右侧预览：目录用 `ls -F --color=always`，文件用 `bat --style=numbers --line-range :300`。
3. 根据选择执行动作：

| 选择 | 动作 |
|---|---|
| 文件 | `nvim <file>` |
| 目录 | `ra <dir>`（Ranger） |
| 按 `Alt+Enter` | 强制交给 Ranger，文件用 `ra --selectfile` |

**有管道**（`... | f`）：沿用同一套 fzf 界面（左侧列表、右侧预览），但从管道读取候选行：

| 选择 | 动作 |
|---|---|
| 文件路径 | `nvim <file>` |
| `path:line:text`（`grep -n`） | `nvim +<line> <file>` |
| `path:line:col:text`（`rg`） | `nvim +<line> <file>` |
| 目录 | `cd <dir>`（在当前 shell 里真正切换目录） |
| 不是路径的普通文本 | 原样打印回终端 |

预览会先把 `path:line:col:text` 剥成真实路径再渲染；路径含空格、相对路径、绝对路径都按同样规则处理。

### 按键

| 键 | 动作 |
|---|---|
| `Enter` | 无管道：文件进 nvim、目录进 ranger；有管道：文件进 nvim、目录 `cd` |
| `Alt+Enter` | 强制用 Ranger 打开 |
| `Alt+C` | 复制当前选中路径到剪贴板 |
| `Tab` / `Shift+Tab` | 下移 / 上移 |
| `Alt+J` / `Alt+K` | 同上（大小写两套） |
| `Alt+U` / `Alt+D` | 半页上 / 下 |
| `Alt+G` | 跳到顶部 |

fzf 顶部的 header 会实时显示这些提示。

### 实现细节

函数用 `--print-query` 和 `--expect=alt-enter`，fzf 的返回值是三段：

```text
第 1 行：query
第 2 行：按下的特殊键
第 3 行：选中的条目
```

代码里分别读 `sed -n '1p'`、`'2p'`、`'3p'`，再按「有没有特殊键」「是文件还是目录」分支处理。管道模式额外用 `_fzf_line_path` 从 `path:line:text` 里还原路径，用 `_fzf_line_number` 取行号；还原失败的条目按普通文本处理。

复制路径用的 `_fzf_copy_path_cmd` 会把剪贴板命令序列化成字符串传给 fzf 的 `execute-silent`，因为 fzf 的 bind 动作在子 shell 里执行，不能直接调用父 shell 的函数。

## ffd：按文件名搜索

```zsh
ffd                       # 在 $HOME 下搜索
ffd bundle.mjs            # 在 $HOME 下搜索 bundle.mjs
ffd . main.py             # 在当前目录搜索
ffd /some/path '*.lua'    # 在指定目录搜索
ffd ~/work config         # 在 ~/work 搜索
```

### 参数解析

第一个参数可以是：

| 形式 | 含义 |
|---|---|
| 省略 | 起始目录 `$HOME`，无搜索模式 |
| `.` | 起始目录为当前目录 |
| `~` | 起始目录为 `$HOME` |
| `~/xxx` | 起始目录为 `~/xxx` |
| 已存在的目录路径 | 用该目录 |
| 其它 | 视为搜索模式 |

后续参数全部合并成一个模式字符串（`"$*"`）。

### 搜索后端

按优先级：

1. `fd`（如果可用且 `fd --version` 成功）
2. `fdfind`（Debian 的包名）
3. `plocate`（如果有索引数据库）
4. 最后回退到 `find`

### 选中后的动作

与 `f` 相同：文件进 Neovim，目录进 Ranger。

### noglob

```zsh
alias ffd='noglob ffd'
```

没有这行，`ffd '*.lua'` 会先被 Zsh 展开成当前目录的文件列表，函数收到的就不是模式了。`noglob` 让 Zsh 跳过通配符展开，把原始字符串交给 fd。

## 共用的 fzf 默认值

```zsh
export FZF_DEFAULT_COMMAND='fd --hidden --follow --exclude .git'
export FZF_DEFAULT_OPTS="--height 90% --layout=reverse --border --wrap \
  --preview '([[ -d {} ]] && ls -F --color=always {}) || ([[ -f {} ]] && bat --style=numbers --color=always --line-range :300 {})' \
  --preview-window=right:40%"
```

| 选项 | 作用 |
|---|---|
| `--hidden --follow` | 包含隐藏文件，跟随软链接 |
| `--exclude .git` | 不枚举 `.git` 目录 |
| `--height 90%` | 占用 90% 终端高度 |
| `--layout=reverse` | 提示行在顶部，符合直觉 |
| `--preview-window=right:40%` | 预览占右侧 40% |
| `--line-range :300` | bat 只渲染前 300 行，避免大文件卡顿 |

没有 bat 时 `FZF_DEFAULT_OPTS` 会退化成只有目录预览的版本。

## 排错

**`f` 没定义**：`plugins/fzf/fzf.zsh` 没被 source。检查 `zshrc` 里那行是否在。

**预览空白**：`bat` 或 `ls` 不可用。`command -v bat ls` 确认。

**`ffd` 报「not a directory」**：第一个参数被当成目录但不存在。检查是否多打了空格。

**`ffd '*.lua'` 结果不对**：`noglob` 别名没生效。用 `type ffd` 确认它是别名而不是函数。
<!-- lang:en -->
> Summary: The complete behavior, key bindings, fallback logic, and implementation details of the two file-search functions `f` and `ffd`.

# The f and ffd Functions

Both functions live in `plugins/fzf/fzf.zsh` and share one set of fzf options and clipboard logic.

## f: current-directory picker / pipe picker

```zsh
f                                   # 列当前目录
find . -iname '*keyword*' | f       # 选择 find 结果
grep -rn 'keyword' . | f            # 选择 grep 结果（带行号）
```

### Behavior

**No pipe** (`f` on its own):

1. Builds the candidate list with `ls`.
2. Opens fzf with a preview on the right: directories use `ls -F --color=always`, files use `bat --style=numbers --line-range :300`.
3. Executes an action based on the selection:

| Selection | Action |
|---|---|
| File | `nvim <file>` |
| Directory | `ra <dir>` (Ranger) |
| Press `Alt+Enter` | Force hand-off to Ranger; files use `ra --selectfile` |

**With a pipe** (`... | f`): reuses the same fzf interface (list on the left, preview on the right), but reads candidate lines from the pipe:

| Selection | Action |
|---|---|
| File path | `nvim <file>` |
| `path:line:text` (`grep -n`) | `nvim +<line> <file>` |
| `path:line:col:text` (`rg`) | `nvim +<line> <file>` |
| Directory | `cd <dir>` (actually changes directory in the current shell) |
| Plain text that isn't a path | Printed back to the terminal as-is |

The preview strips `path:line:col:text` down to the real path before rendering; paths with spaces, relative paths, and absolute paths are all handled by the same rules.

### Key bindings

| Key | Action |
|---|---|
| `Enter` | No pipe: files go to nvim, directories to ranger; with pipe: files to nvim, directories `cd` |
| `Alt+Enter` | Force open with Ranger |
| `Alt+C` | Copy the currently selected path to the clipboard |
| `Tab` / `Shift+Tab` | Move down / up |
| `Alt+J` / `Alt+K` | Same as above (both case variants) |
| `Alt+U` / `Alt+D` | Half page up / down |
| `Alt+G` | Jump to top |

The header at the top of fzf shows these hints in real time.

### Implementation details

The function uses `--print-query` and `--expect=alt-enter`; fzf returns three segments:

```text
第 1 行：query
第 2 行：按下的特殊键
第 3 行：选中的条目
```

The code reads them with `sed -n '1p'`, `'2p'`, and `'3p'`, then branches on "was there a special key" and "is it a file or directory". Pipe mode additionally uses `_fzf_line_path` to recover the path from `path:line:text` and `_fzf_line_number` to get the line number; entries that fail to parse are treated as plain text.

`_fzf_copy_path_cmd`, used for copying paths, serializes the clipboard command into a string passed to fzf's `execute-silent`, because fzf's bind actions run in a subshell and cannot call parent-shell functions directly.

## ffd: search by file name

```zsh
ffd                       # 在 $HOME 下搜索
ffd bundle.mjs            # 在 $HOME 下搜索 bundle.mjs
ffd . main.py             # 在当前目录搜索
ffd /some/path '*.lua'    # 在指定目录搜索
ffd ~/work config         # 在 ~/work 搜索
```

### Argument parsing

The first argument can be:

| Form | Meaning |
|---|---|
| Omitted | Start directory `$HOME`, no search pattern |
| `.` | Start directory is the current directory |
| `~` | Start directory is `$HOME` |
| `~/xxx` | Start directory is `~/xxx` |
| An existing directory path | Use that directory |
| Anything else | Treated as the search pattern |

All remaining arguments are joined into a single pattern string (`"$*"`).

### Search backends

In priority order:

1. `fd` (if available and `fd --version` succeeds)
2. `fdfind` (the Debian package name)
3. `plocate` (if an index database exists)
4. Finally falls back to `find`

### Actions after selection

Same as `f`: files go to Neovim, directories to Ranger.

### noglob

```zsh
alias ffd='noglob ffd'
```

Without this line, `ffd '*.lua'` would first be expanded by Zsh into the current directory's file list, and the function would not receive a pattern. `noglob` makes Zsh skip glob expansion and hand the raw string to fd.

## Shared fzf defaults

```zsh
export FZF_DEFAULT_COMMAND='fd --hidden --follow --exclude .git'
export FZF_DEFAULT_OPTS="--height 90% --layout=reverse --border --wrap \
  --preview '([[ -d {} ]] && ls -F --color=always {}) || ([[ -f {} ]] && bat --style=numbers --color=always --line-range :300 {})' \
  --preview-window=right:40%"
```

| Option | Purpose |
|---|---|
| `--hidden --follow` | Include hidden files, follow symlinks |
| `--exclude .git` | Don't enumerate `.git` directories |
| `--height 90%` | Occupy 90% of terminal height |
| `--layout=reverse` | Prompt line at the top, which feels natural |
| `--preview-window=right:40%` | Preview takes 40% of the right side |
| `--line-range :300` | bat renders only the first 300 lines to avoid stalling on large files |

Without bat, `FZF_DEFAULT_OPTS` degrades to a version with only directory previews.

## Troubleshooting

**`f` is not defined**: `plugins/fzf/fzf.zsh` isn't being sourced. Check that the line in `zshrc` is present.

**Preview is blank**: `bat` or `ls` is unavailable. Confirm with `command -v bat ls`.

**`ffd` reports "not a directory"**: the first argument was treated as a directory but doesn't exist. Check for an extra space.

**`ffd '*.lua'` gives wrong results**: the `noglob` alias isn't taking effect. Use `type ffd` to confirm it is an alias, not a function.
<!-- lang:ja -->
> 要約：f と ffd の 2 つのファイル検索関数の完全な挙動、キー操作、フォールバックロジック、実装の詳細。

# f と ffd 関数

両関数は `plugins/fzf/fzf.zsh` にあり、共通の fzf オプションとクリップボードロジックを共用しています。

## f：カレントディレクトリセレクタ / パイプセレクタ

```zsh
f                                   # 列当前目录
find . -iname '*keyword*' | f       # 选择 find 结果
grep -rn 'keyword' . | f            # 选择 grep 结果（带行号）
```

### 挙動

**パイプなし**（`f` 単体）：

1. `ls` で候補リストを生成します。
2. fzf を開き、右側にプレビューを表示します。ディレクトリは `ls -F --color=always`、ファイルは `bat --style=numbers --line-range :300`。
3. 選択に応じてアクションを実行します：

| 選択 | アクション |
|---|---|
| ファイル | `nvim <file>` |
| ディレクトリ | `ra <dir>`（Ranger） |
| `Alt+Enter` 押下 | 強制的に Ranger に渡す。ファイルは `ra --selectfile` |

**パイプあり**（`... | f`）：同じ fzf インターフェース（左にリスト、右にプレビュー）をそのまま使い、候補行をパイプから読み込みます：

| 選択 | アクション |
|---|---|
| ファイルパス | `nvim <file>` |
| `path:line:text`（`grep -n`） | `nvim +<line> <file>` |
| `path:line:col:text`（`rg`） | `nvim +<line> <file>` |
| ディレクトリ | `cd <dir>`（現在のシェルで実際にディレクトリを移動） |
| パスでない普通のテキスト | そのままターミナルに表示 |

プレビューは `path:line:col:text` を実際のパスに剥してから描画します。空白を含むパス、相対パス、絶対パスも同じルールで処理されます。

### キー操作

| キー | 動作 |
|---|---|
| `Enter` | パイプなし：ファイルは nvim、ディレクトリは ranger。パイプあり：ファイルは nvim、ディレクトリは `cd` |
| `Alt+Enter` | 強制的に Ranger で開く |
| `Alt+C` | 選択中のパスをクリップボードにコピー |
| `Tab` / `Shift+Tab` | 下へ / 上へ |
| `Alt+J` / `Alt+K` | 同上（大小両方のケース） |
| `Alt+U` / `Alt+D` | 半ページ上 / 下 |
| `Alt+G` | 先頭へジャンプ |

fzf 上部の header にこれらのヒントがリアルタイムで表示されます。

### 実装の詳細

関数は `--print-query` と `--expect=alt-enter` を使い、fzf の戻り値は 3 部構成です：

```text
第 1 行：query
第 2 行：按下的特殊键
第 3 行：选中的条目
```

コードはそれぞれ `sed -n '1p'`、`'2p'`、`'3p'` で読み取り、「特殊キーがあったか」「ファイルかディレクトリか」で分岐します。パイプモードでは追加で `_fzf_line_path` が `path:line:text` からパスを復元し、`_fzf_line_number` が行番号を取得します。復元に失敗したエントリは普通のテキストとして扱われます。

パスのコピーに使う `_fzf_copy_path_cmd` は、クリップボードコマンドを文字列にシリアライズして fzf の `execute-silent` に渡します。fzf の bind アクションはサブシェルで実行されるため、親シェルの関数を直接呼び出せないためです。

## ffd：ファイル名で検索

```zsh
ffd                       # 在 $HOME 下搜索
ffd bundle.mjs            # 在 $HOME 下搜索 bundle.mjs
ffd . main.py             # 在当前目录搜索
ffd /some/path '*.lua'    # 在指定目录搜索
ffd ~/work config         # 在 ~/work 搜索
```

### 引数の解析

最初の引数は次のいずれかです：

| 形式 | 意味 |
|---|---|
| 省略 | 開始ディレクトリは `$HOME`、検索パターンなし |
| `.` | 開始ディレクトリはカレントディレクトリ |
| `~` | 開始ディレクトリは `$HOME` |
| `~/xxx` | 開始ディレクトリは `~/xxx` |
| 存在するディレクトリパス | そのディレクトリを使用 |
| その他 | 検索パターンとして扱う |

残りの引数はすべて 1 つのパターン文字列に結合されます（`"$*"`）。

### 検索バックエンド

優先度順に：

1. `fd`（利用可能で `fd --version` が成功する場合）
2. `fdfind`（Debian のパッケージ名）
3. `plocate`（インデックス DB がある場合）
4. 最後に `find` にフォールバック

### 選択後のアクション

`f` と同じです。ファイルは Neovim へ、ディレクトリは Ranger へ。

### noglob

```zsh
alias ffd='noglob ffd'
```

この行がないと、`ffd '*.lua'` が先に Zsh によってカレントディレクトリのファイル一覧へ展開され、関数が受け取るのがパターンではなくなります。`noglob` は Zsh にグロブ展開をスキップさせ、生の文字列を fd に渡させます。

## 共用の fzf デフォルト値

```zsh
export FZF_DEFAULT_COMMAND='fd --hidden --follow --exclude .git'
export FZF_DEFAULT_OPTS="--height 90% --layout=reverse --border --wrap \
  --preview '([[ -d {} ]] && ls -F --color=always {}) || ([[ -f {} ]] && bat --style=numbers --color=always --line-range :300 {})' \
  --preview-window=right:40%"
```

| オプション | 役割 |
|---|---|
| `--hidden --follow` | 隠しファイルを含め、シンボリックリンクを辿る |
| `--exclude .git` | `.git` ディレクトリを列挙しない |
| `--height 90%` | ターミナル高の 90% を使用 |
| `--layout=reverse` | プロンプト行を上部に置き、直感的にする |
| `--preview-window=right:40%` | プレビューが右側 40% を占有 |
| `--line-range :300` | bat は先頭 300 行のみ描画し、大きなファイルでの固まりを防ぐ |

bat がない場合、`FZF_DEFAULT_OPTS` はディレクトリプレビューのみのバージョンに縮退します。

## トラブルシューティング

**`f` が定義されていない**：`plugins/fzf/fzf.zsh` が source されていません。`zshrc` 内の該当行があるか確認してください。

**プレビューが空白**：`bat` か `ls` が利用できません。`command -v bat ls` で確認します。

**`ffd` が「not a directory」を出す**：最初の引数がディレクトリとして扱われたのに存在しません。空白を余分に入力していないか確認してください。

**`ffd '*.lua'` の結果がおかしい**：`noglob` エイリアスが効いていません。`type ffd` で関数ではなくエイリアスであることを確認してください。
