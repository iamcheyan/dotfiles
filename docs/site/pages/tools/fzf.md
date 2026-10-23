> 摘要：fzf 是本仓库交互层的底座，f、ffd、forgit、fzf-tab、tmux-fzf 都建立在它之上。

# fzf

## 用途

`fzf` 是通用的模糊筛选器：从标准输入读一组行，让你用键盘快速缩小范围，输出选中的行。它本身不知道「文件」「分支」「命令」是什么——所有语义都由调用方赋予。

本仓库里五个地方用到它：

| 使用方 | 用途 |
|---|---|
| `f` / `ffd` | 文件与目录选择 |
| forgit | Git 分支、提交、stash 选择 |
| fzf-tab | Tab 补全候选筛选 |
| tmux-fzf | session/window/pane 选择 |
| vssh | SSH 主机选择 |

## 来源与安装

| 项目 | 说明 |
|---|---|
| 二进制 | init.sh 检查/安装；也可由系统包提供 |
| 补全与按键 | `plugins/tools/tools.zsh` 里用 Zinit snippet 加载上游脚本 |
| 版本要求 | forgit 需要 0.60.0+ |

```zsh
# 补全
zinit ice as"completion"
zinit snippet https://github.com/junegunn/fzf/raw/master/shell/completion.zsh
# 按键绑定
zinit ice as"completion"
zinit snippet https://github.com/junegunn/fzf/raw/master/shell/key-bindings.zsh
```

`fzf.zsh` 里还有一层兜底：如果系统 `/usr/share/fzf/shell/key-bindings.zsh` 存在，也会 source 它。

## 基本用法

```bash
ls | fzf                    # 从管道选择
fzf < file.txt              # 从文件读
vim "$(fzf)"                # 选中后传给另一个命令
fzf --multi                 # 允许多选（Tab 标记）
fzf --preview 'cat {}'      # 右侧预览
```

`{}` 是当前选中项的占位符，在 `--preview`、`--bind` 里可用。

## 核心参数

### 搜索

| 参数 | 作用 |
|---|---|
| `-e` / `--exact` | 精确匹配而非模糊 |
| `-i` / `--ignore-case` | 忽略大小写 |
| `+i` | 区分大小写 |
| `--smart-case` | 全小写忽略、含大写区分（默认） |
| `-n` / `--nth` | 只在指定字段内搜索 |
| `--with-nth` | 只显示指定字段 |
| `--accept-nth` | 接受时只输出指定字段 |
| `-d` / `--delimiter` | 字段分隔符 |
| `+s` / `--no-sort` | 不按匹配度排序，保持输入顺序 |

### 布局

| 参数 | 作用 |
|---|---|
| `--height` | 占用多少高度，如 `90%` 或 `40` |
| `--layout=reverse` | 提示行在顶部，列表向下（更符合直觉） |
| `--border` | 画边框 |
| `--preview` | 预览命令 |
| `--preview-window` | 预览位置与大小，如 `right:40%` |
| `--header` | 顶部说明文字 |
| `--info` | 信息行样式 |

### 输入输出

| 参数 | 作用 |
|---|---|
| `--read0` | 输入用 NUL 分隔 |
| `--print0` | 输出用 NUL 分隔 |
| `--ansi` | 解析输入里的 ANSI 颜色 |
| `--print-query` | 输出里带上用户输入的查询 |
| `--expect=alt-enter` | 捕获特定按键，输出到第二行 |
| `--multi` | 多选 |

`--print-query` 和 `--expect` 的组合是本仓库 `f` 函数的核心，见 [f 与 ffd 函数](../shell/fzf-functions.html)。

## 本仓库的默认选项

```zsh
export FZF_DEFAULT_COMMAND='fd --hidden --follow --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

export FZF_DEFAULT_OPTS="--height 90% --layout=reverse --border --wrap \
  --preview '([[ -d {} ]] && ls -F --color=always {}) || ([[ -f {} ]] && bat --style=numbers --color=always --line-range :300 {})' \
  --preview-window=right:40%"
```

拆开看：

- `--height 90%` — 占九成终端高度，保留一点上下文。
- `--layout=reverse` — 输入框在上，结果向下展开。
- `--border` — 画边框，视觉上区分于底层终端。
- `--wrap` — 长行折行，不横向滚动。
- `--preview` — 目录列内容，文件用 bat 高亮前 300 行。
- `--preview-window=right:40%` — 预览在右，占 40% 宽度。

没有 bat 时 `fzf.zsh` 会换成一个只有目录预览的版本。

## 官方按键绑定

| 键 | 作用 |
|---|---|
| `Ctrl+T` | 在当前命令行插入选中文件路径 |
| `Alt+C` | 选择目录并 `cd` |
| `Ctrl+R` | 搜索命令历史 |

`Ctrl+R` 可能被 Atuin 抢走，取决于加载顺序。

## 交互快捷键

在 fzf 界面内：

| 键 | 作用 |
|---|---|
| `Tab` / `Shift+Tab` | 多选标记 / 反向 |
| `Ctrl+J` / `Ctrl+K` | 下移 / 上移 |
| `Ctrl+N` / `Ctrl+P` | 同上 |
| `Enter` | 确认 |
| `Esc` / `Ctrl+C` | 取消 |
| `?` | 显示帮助 |
| `Ctrl+/` | 切换预览窗口 |
| `Alt+数字` | 多选时用数字键快速选中 |

## 在脚本里用

```bash
# 选中后删除
rm "$(ls | fzf)"

# 多选后批量处理
ls *.log | fzf --multi | xargs rm

# 带预览
git branch | fzf --preview 'git log --oneline -10 {}'

# 只输出第二列
printf 'a\t1\nb\t2\n' | fzf --delimiter='\t' --accept-nth=2
```

## 排错

**fzf 列表为空**：`FZF_DEFAULT_COMMAND` 指向的命令不存在。检查 `command -v fd`。

**预览空白**：预览命令里的工具缺失（bat、ls）。`command -v bat` 确认。

**预览有乱码**：终端不支持该字符，或字体缺字形。

**`Ctrl+T` 没反应**：key-bindings 没加载。检查 `plugins/tools/tools.zsh` 里那两个 snippet 是否成功。

**`Ctrl+R` 行为和预期不同**：Atuin 或 fzf 接管了。用 `bindkey '^R'` 确认当前绑定。

**forgit 报版本太低**：`fzf --version` 检查，需要 0.60.0+。系统包太旧时用官方安装脚本升级。

<!-- lang:en -->

> 摘要：fzf is the foundation of this repository's interactive layer; f, ffd, forgit, fzf-tab and tmux-fzf all sit on top of it.

# fzf

## Purpose

`fzf` is a general-purpose fuzzy filter: it reads a list of lines from stdin, lets you narrow them down with the keyboard, and prints the selected line(s). It knows nothing about "files", "branches" or "commands" — every meaning is supplied by the caller.

Five places use it in this repository:

| Consumer | Use |
|---|---|
| `f` / `ffd` | file and directory selection |
| forgit | Git branch, commit and stash selection |
| fzf-tab | filtering Tab-completion candidates |
| tmux-fzf | session/window/pane selection |
| vssh | SSH host selection |

## Source and install

| Item | Notes |
|---|---|
| Binary | checked/installed by init.sh; may also come from the system package |
| Completion & keys | upstream scripts loaded as Zinit snippets in `plugins/tools/tools.zsh` |
| Version floor | forgit needs 0.60.0+ |

```zsh
# completion
zinit ice as"completion"
zinit snippet https://github.com/junegunn/fzf/raw/master/shell/completion.zsh
# key bindings
zinit ice as"completion"
zinit snippet https://github.com/junegunn/fzf/raw/master/shell/key-bindings.zsh
```

`fzf.zsh` adds a fallback: if the system `/usr/share/fzf/shell/key-bindings.zsh` exists, it is sourced too.

## Basic usage

```bash
ls | fzf                    # select from a pipe
fzf < file.txt              # read from a file
vim "$(fzf)"                # hand the pick to another command
fzf --multi                 # allow multi-select (Tab marks)
fzf --preview 'cat {}'      # side preview
```

`{}` is the placeholder for the current selection, usable in `--preview` and `--bind`.

## Core flags

### Search

| Flag | Effect |
|---|---|
| `-e` / `--exact` | exact match instead of fuzzy |
| `-i` / `--ignore-case` | case-insensitive |
| `+i` | case-sensitive |
| `--smart-case` | ignore case when all-lower, respect when mixed (default) |
| `-n` / `--nth` | search only the given fields |
| `--with-nth` | display only the given fields |
| `--accept-nth` | output only the given fields on accept |
| `-d` / `--delimiter` | field delimiter |
| `+s` / `--no-sort` | keep input order instead of match score |

### Layout

| Flag | Effect |
|---|---|
| `--height` | how much height to use, e.g. `90%` or `40` |
| `--layout=reverse` | prompt at top, list grows down (more intuitive) |
| `--border` | draw a border |
| `--preview` | preview command |
| `--preview-window` | preview position and size, e.g. `right:40%` |
| `--header` | header text |
| `--info` | info-line style |

### Input/output

| Flag | Effect |
|---|---|
| `--read0` | NUL-separated input |
| `--print0` | NUL-separated output |
| `--ansi` | parse ANSI colours in the input |
| `--print-query` | include the user's query in the output |
| `--expect=alt-enter` | capture a key, emit it on a second line |
| `--multi` | multi-select |

`--print-query` plus `--expect` is the core of this repository's `f` function; see [the f and ffd functions](../shell/fzf-functions.html).

## Defaults in this repository

```zsh
export FZF_DEFAULT_COMMAND='fd --hidden --follow --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

export FZF_DEFAULT_OPTS="--height 90% --layout=reverse --border --wrap \
  --preview '([[ -d {} ]] && ls -F --color=always {}) || ([[ -f {} ]] && bat --style=numbers --color=always --line-range :300 {})' \
  --preview-window=right:40%"
```

Piece by piece:

- `--height 90%` — take nine tenths of the terminal, keeping a little context.
- `--layout=reverse` — input on top, results growing downward.
- `--border` — a border visually separates fzf from the terminal behind it.
- `--wrap` — wrap long lines instead of scrolling sideways.
- `--preview` — directories get a listing; files get bat highlighting for the first 300 lines.
- `--preview-window=right:40%` — preview on the right, 40% of the width.

Without bat, `fzf.zsh` falls back to a directory-preview-only variant.

## Official key bindings

| Key | Effect |
|---|---|
| `Ctrl+T` | insert the selected file path into the current command line |
| `Alt+C` | pick a directory and `cd` into it |
| `Ctrl+R` | search command history |

`Ctrl+R` may be taken over by Atuin depending on load order.

## Keys inside fzf

| Key | Effect |
|---|---|
| `Tab` / `Shift+Tab` | mark / unmark in multi-select |
| `Ctrl+J` / `Ctrl+K` | down / up |
| `Ctrl+N` / `Ctrl+P` | same |
| `Enter` | accept |
| `Esc` / `Ctrl+C` | cancel |
| `?` | help |
| `Ctrl+/` | toggle the preview window |
| `Alt+digit` | quick-select in multi-select |

## In scripts

```bash
# delete after picking
rm "$(ls | fzf)"

# batch-process a multi-select
ls *.log | fzf --multi | xargs rm

# with preview
git branch | fzf --preview 'git log --oneline -10 {}'

# output only the second column
printf 'a\t1\nb\t2\n' | fzf --delimiter='\t' --accept-nth=2
```

## Troubleshooting

**Empty fzf list**: the command in `FZF_DEFAULT_COMMAND` does not exist. Check `command -v fd`.

**Blank preview**: a tool used by the preview command is missing (bat, ls). Confirm with `command -v bat`.

**Garbled preview**: the terminal cannot render that character, or the font lacks the glyph.

**`Ctrl+T` dead**: key-bindings never loaded. Check the two snippets in `plugins/tools/tools.zsh`.

**`Ctrl+R` behaves unexpectedly**: Atuin or fzf took over. `bindkey '^R'` shows the current owner.

**forgit complains about version**: check `fzf --version`; 0.60.0+ required. When the system package is too old, upgrade via the official install script.

<!-- lang:ja -->

> 摘要：fzf はこのリポジトリの対話レイヤーの土台。f、ffd、forgit、fzf-tab、tmux-fzf がすべてその上に載っています。

# fzf

## 役割

`fzf` は汎用のファジーフィルタです。標準入力から行のリストを受け取り、キーボードで絞り込み、選択した行を出力します。「ファイル」「ブランチ」「コマンド」といった意味は fzf 自体は知らず、すべて呼び出し側が与えます。

このリポジトリでは 5 か所で使っています：

| 使用元 | 用途 |
|---|---|
| `f` / `ffd` | ファイルとディレクトリ選択 |
| forgit | Git のブランチ・コミット・stash 選択 |
| fzf-tab | Tab 補完候補の絞り込み |
| tmux-fzf | session/window/pane 選択 |
| vssh | SSH ホスト選択 |

## 入手とインストール

| 項目 | 説明 |
|---|---|
| バイナリ | init.sh が確認／インストール。システムパッケージ由来でも可 |
| 補完とキー | `plugins/tools/tools.zsh` で上游スクリプトを Zinit snippet として読み込み |
| バージョン下限 | forgit は 0.60.0+ 必要 |

```zsh
# 補完
zinit ice as"completion"
zinit snippet https://github.com/junegunn/fzf/raw/master/shell/completion.zsh
# キーバインド
zinit ice as"completion"
zinit snippet https://github.com/junegunn/fzf/raw/master/shell/key-bindings.zsh
```

`fzf.zsh` にはさらにフォールバックがあり、システムの `/usr/share/fzf/shell/key-bindings.zsh` が存在すれば source します。

## 基本的な使い方

```bash
ls | fzf                    # パイプから選択
fzf < file.txt              # ファイルから読み込み
vim "$(fzf)"                # 選択結果を別コマンドへ
fzf --multi                 # 複数選択（Tab でマーク）
fzf --preview 'cat {}'      # 右側にプレビュー
```

`{}` は現在の選択項目のプレースホルダで、`--preview` と `--bind` で使えます。

## 主要フラグ

### 検索

| フラグ | 効果 |
|---|---|
| `-e` / `--exact` | ファジーではなく完全一致 |
| `-i` / `--ignore-case` | 大文字小文字を無視 |
| `+i` | 大文字小文字を区別 |
| `--smart-case` | 全小文字なら無視、大文字混じりなら区別（既定） |
| `-n` / `--nth` | 指定フィールドのみ検索 |
| `--with-nth` | 指定フィールドのみ表示 |
| `--accept-nth` | 確定時に指定フィールドのみ出力 |
| `-d` / `--delimiter` | フィールド区切り |
| `+s` / `--no-sort` | スコア順ではなく入力順を維持 |

### レイアウト

| フラグ | 効果 |
|---|---|
| `--height` | 占有高。`90%` や `40` など |
| `--layout=reverse` | 入力行を上に、リストを下へ（直感的） |
| `--border` | 枠を描画 |
| `--preview` | プレビューコマンド |
| `--preview-window` | プレビューの位置と大きさ。`right:40%` など |
| `--header` | 上部の説明文 |
| `--info` | 情報行のスタイル |

### 入出力

| フラグ | 効果 |
|---|---|
| `--read0` | 入力を NUL 区切りに |
| `--print0` | 出力を NUL 区切りに |
| `--ansi` | 入力内の ANSI 色を解釈 |
| `--print-query` | 出力にユーザーのクエリを含める |
| `--expect=alt-enter` | 特定キーを捕まえ、2 行目に出力 |
| `--multi` | 複数選択 |

`--print-query` と `--expect` の組み合わせがこのリポジトリの `f` 関数の核です。[f と ffd 関数](../shell/fzf-functions.html) を参照。

## このリポジトリの既定値

```zsh
export FZF_DEFAULT_COMMAND='fd --hidden --follow --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

export FZF_DEFAULT_OPTS="--height 90% --layout=reverse --border --wrap \
  --preview '([[ -d {} ]] && ls -F --color=always {}) || ([[ -f {} ]] && bat --style=numbers --color=always --line-range :300 {})' \
  --preview-window=right:40%"
```

ばらして見ると：

- `--height 90%` — ターミナルの 9 割を使い、文脈を少し残す。
- `--layout=reverse` — 入力欄が上、結果が下へ伸びる。
- `--border` — 枠で背後のターミナルと視覚的に区切る。
- `--wrap` — 長い行は横スクロールではなく折り返す。
- `--preview` — ディレクトリは内容一覧、ファイルは bat で先頭 300 行をハイライト。
- `--preview-window=right:40%` — プレビューは右側、幅 40%。

bat が無い環境では `fzf.zsh` がディレクトリプレビューのみの版に切り替えます。

## 公式キーバインド

| キー | 効果 |
|---|---|
| `Ctrl+T` | 選択したファイルパスを現在のコマンドラインに挿入 |
| `Alt+C` | ディレクトリを選んで `cd` |
| `Ctrl+R` | コマンド履歴を検索 |

`Ctrl+R` は読み込み順によって Atuin に奪われていることがあります。

## fzf 内のキー

| キー | 効果 |
|---|---|
| `Tab` / `Shift+Tab` | 複数選択のマーク／解除 |
| `Ctrl+J` / `Ctrl+K` | 下へ／上へ |
| `Ctrl+N` / `Ctrl+P` | 同上 |
| `Enter` | 確定 |
| `Esc` / `Ctrl+C` | キャンセル |
| `?` | ヘルプ表示 |
| `Ctrl+/` | プレビューウィンドウの切り替え |
| `Alt+数字` | 複数選択時に数字キーで即選択 |

## スクリプト内で使う

```bash
# 選んでから削除
rm "$(ls | fzf)"

# 複数選択を一括処理
ls *.log | fzf --multi | xargs rm

# プレビュー付き
git branch | fzf --preview 'git log --oneline -10 {}'

# 2 列目だけ出力
printf 'a\t1\nb\t2\n' | fzf --delimiter='\t' --accept-nth=2
```

## トラブルシュート

**fzf のリストが空**：`FZF_DEFAULT_COMMAND` のコマンドが存在しない。`command -v fd` を確認。

**プレビューが空白**：プレビューコマンドのツール（bat、ls）が不足。`command -v bat` で確認。

**プレビューが文字化け**：ターミナルがその文字を表示できない、またはフォントにグリフが無い。

**`Ctrl+T` が反応しない**：key-bindings が未読み込み。`plugins/tools/tools.zsh` の 2 つの snippet を確認。

**`Ctrl+R` の挙動が違う**：Atuin か fzf が握っている。`bindkey '^R'` で現在の持ち主を確認。

**forgit がバージョン不足を訴える**：`fzf --version` を確認。0.60.0+ が必要。システムパッケージが古い場合は公式インストールスクリプトで更新。
