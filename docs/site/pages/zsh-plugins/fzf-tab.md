> 摘要：fzf-tab 用 fzf 替换 Zsh 的补全菜单，支持模糊搜索、分组切换和目录预览。

# fzf-tab

## 用途

Zsh 原生补全是一个方向键选择的菜单。fzf-tab 把它换成 fzf 界面：可模糊搜索、可预览、可用 `<` `>` 切换候选组。

它不产生补全候选——候选来自 `zsh-completions` 和 Zsh 内建补全。它只接管**显示和选择**。

## 加载方式

```zsh
zsh_plugins_load_post_compinit() {
  zinit light Aloxaf/fzf-tab

  zstyle ':completion:*:git-checkout:*' sort false
  zstyle ':completion:*:descriptions' format '[%d]'
  zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
  zstyle ':completion:*' menu no

  if command -v eza >/dev/null 2>&1; then
    zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always $realpath'
    zstyle ':fzf-tab:complete:z:*'  fzf-preview 'eza -1 --color=always $realpath'
  else
    zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls -1 --color=always $realpath'
    zstyle ':fzf-tab:complete:z:*'  fzf-preview 'ls -1 --color=always $realpath'
  fi

  zstyle ':fzf-tab:*' switch-group '<' '>'
}
```

## 本仓库的 zstyle 逐条解释

### `menu no`

```zsh
zstyle ':completion:*' menu no
```

关闭 Zsh 原生补全菜单。不关的话，fzf-tab 和原生菜单会同时出现，视觉上互相干扰。

### `format '[%d]'`

```zsh
zstyle ':completion:*:descriptions' format '[%d]'
```

补全候选会按类型分组（命令、别名、函数、文件、目录）。`%d` 是分组描述，加方括号后显示成 `[command]`、`[alias]` 这样。

### `list-colors`

```zsh
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
```

用 `LS_COLORS` 给候选上色。`(s.:.)` 是 zsh 的切分语法，把 `LS_COLORS` 按冒号切成数组。

没有 `LS_COLORS` 时这条不生效，候选是纯色。

### `git-checkout sort false`

```zsh
zstyle ':completion:*:git-checkout:*' sort false
```

Git 分支补全不按字母排序，保持 `git branch` 的输出顺序（通常是最近提交优先）。找常用分支更快。

### 预览

```zsh
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always $realpath'
zstyle ':fzf-tab:complete:z:*'  fzf-preview 'eza -1 --color=always $realpath'
```

补全 `cd` 和 `z` 的参数时，右侧显示目标目录的内容。

`$realpath` 是 fzf-tab 提供的变量，指向当前候选的完整路径。`--color=always` 必须加，因为输出到管道时默认关色。

没有 eza 时退回 `ls -1`。

### 分组切换

```zsh
zstyle ':fzf-tab:*' switch-group '<' '>'
```

用 `<` 和 `>` 在候选组之间切换。默认是 `Tab`/`Shift+Tab`，但 `Tab` 在 fzf 里已经被多选占用。

## 界面内按键

| 键 | 作用 |
|---|---|
| `Tab` | 选中并继续补全下一段 |
| `Shift+Tab` | 反向 |
| `<` / `>` | 切换候选组 |
| `Ctrl+/` | 打开 fzf 的额外操作菜单 |
| `Enter` | 确认 |
| `Esc` | 取消 |

## 效果示例

```text
$ docker <Tab>
┌─ [docker] ────────────────────────┐
│ container                         │
│ image                             │
│ network                           │
│ compose                           │
└───────────────────────────────────┘
```

输入 `cont` 会模糊过滤到 `container`。

## 与 fzf 全局选项的关系

fzf-tab 使用 fzf，但**不读** `FZF_DEFAULT_OPTS`。它的外观由 `zstyle ':fzf-tab:*'` 控制。

想改 fzf-tab 的高度/布局：

```zsh
zstyle ':fzf-tab:*' fzf-flags --height=60% --layout=reverse
```

## 与 fzf 补全脚本的区别

容易混淆的两件事：

| | fzf-tab | fzf 的 key-bindings |
|---|---|---|
| 触发 | `Tab` 补全 | `Ctrl+T` / `Ctrl+R` / `Alt+C` |
| 作用 | 筛选补全候选 | 选文件、选历史、切目录 |
| 来源 | Zinit 插件 | 上游 snippet |

两者都依赖 fzf 二进制，但功能不重叠。

## 排错

**Tab 还是原生菜单**：fzf-tab 没加载，或 `menu no` 没设。`zinit list | grep fzf-tab` 确认。

**候选是空的**：`compinit` 没运行，或者 `zsh-completions` 没在 compinit 前加载。

**预览区空白**：`eza` / `ls` 不可用，或 `$realpath` 为空。用 `cd` 到有内容的目录测试。

**候选没有颜色**：`LS_COLORS` 为空。检查 `dircolors` 是否执行。

**`<` `>` 不起作用**：被别的 zstyle 覆盖。`zstyle -L ':fzf-tab:*'` 查看当前设置。

**在大目录里补全很慢**：预览命令遍历了整个目录。可以给 `eza` 加 `--level=1` 限制深度，或去掉该条 `zstyle`。

<!-- lang:en -->

> Summary: fzf-tab replaces Zsh's completion menu with fzf, supporting fuzzy search, group switching, and directory preview.

# fzf-tab

## Purpose

Zsh's native completion is a menu you navigate with the arrow keys. fzf-tab replaces it with an fzf interface: you can fuzzy-search, preview, and switch candidate groups with `<` `>`.

It does not produce completion candidates — candidates come from `zsh-completions` and Zsh's built-in completions. It only takes over **display and selection**.

## Loading

```zsh
zsh_plugins_load_post_compinit() {
  zinit light Aloxaf/fzf-tab

  zstyle ':completion:*:git-checkout:*' sort false
  zstyle ':completion:*:descriptions' format '[%d]'
  zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
  zstyle ':completion:*' menu no

  if command -v eza >/dev/null 2>&1; then
    zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always $realpath'
    zstyle ':fzf-tab:complete:z:*'  fzf-preview 'eza -1 --color=always $realpath'
  else
    zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls -1 --color=always $realpath'
    zstyle ':fzf-tab:complete:z:*'  fzf-preview 'ls -1 --color=always $realpath'
  fi

  zstyle ':fzf-tab:*' switch-group '<' '>'
}
```

## This repo's zstyle, line by line

### `menu no`

```zsh
zstyle ':completion:*' menu no
```

Turns off Zsh's native completion menu. Without this, fzf-tab and the native menu appear together and interfere with each other visually.

### `format '[%d]'`

```zsh
zstyle ':completion:*:descriptions' format '[%d]'
```

Completion candidates are grouped by type (commands, aliases, functions, files, directories). `%d` is the group description; with brackets added it displays as `[command]`, `[alias]`, and so on.

### `list-colors`

```zsh
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
```

Colors the candidates using `LS_COLORS`. `(s.:.)` is zsh's splitting syntax; it splits `LS_COLORS` into an array by colons.

Without `LS_COLORS` this line has no effect and candidates are a single color.

### `git-checkout sort false`

```zsh
zstyle ':completion:*:git-checkout:*' sort false
```

Git branch completion is not sorted alphabetically, keeping the output order of `git branch` (usually most recent commit first). This makes finding frequently used branches faster.

### Preview

```zsh
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always $realpath'
zstyle ':fzf-tab:complete:z:*'  fzf-preview 'eza -1 --color=always $realpath'
```

When completing arguments for `cd` and `z`, the right side shows the contents of the target directory.

`$realpath` is a variable provided by fzf-tab pointing to the full path of the current candidate. `--color=always` must be included because color is off by default when output goes to a pipe.

Without eza it falls back to `ls -1`.

### Group switching

```zsh
zstyle ':fzf-tab:*' switch-group '<' '>'
```

Uses `<` and `>` to switch between candidate groups. The default is `Tab`/`Shift+Tab`, but `Tab` is already taken by multi-select inside fzf.

## Keys inside the UI

| Key | Action |
|---|---|
| `Tab` | Select and continue completing the next segment |
| `Shift+Tab` | Reverse direction |
| `<` / `>` | Switch candidate groups |
| `Ctrl+/` | Open fzf's extra-actions menu |
| `Enter` | Confirm |
| `Esc` | Cancel |

## Example of the effect

```text
$ docker <Tab>
┌─ [docker] ────────────────────────┐
│ container                         │
│ image                             │
│ network                           │
│ compose                           │
└───────────────────────────────────┘
```

Typing `cont` fuzzy-filters down to `container`.

## Relationship with fzf's global options

fzf-tab uses fzf but does **not** read `FZF_DEFAULT_OPTS`. Its appearance is controlled by `zstyle ':fzf-tab:*'`.

To change fzf-tab's height/layout:

```zsh
zstyle ':fzf-tab:*' fzf-flags --height=60% --layout=reverse
```

## Difference from the fzf completion scripts

Two things that are easy to confuse:

| | fzf-tab | fzf key-bindings |
|---|---|---|
| Trigger | `Tab` completion | `Ctrl+T` / `Ctrl+R` / `Alt+C` |
| Effect | Filters completion candidates | Pick files, pick history, switch directories |
| Source | Zinit plugin | Upstream snippet |

Both depend on the fzf binary, but their functions do not overlap.

## Troubleshooting

**Tab still shows the native menu**: fzf-tab is not loaded, or `menu no` is not set. Confirm with `zinit list | grep fzf-tab`.

**Candidates are empty**: `compinit` did not run, or `zsh-completions` was not loaded before compinit.

**Preview area is blank**: `eza` / `ls` is unavailable, or `$realpath` is empty. Test by `cd`-ing into a directory with content.

**Candidates have no color**: `LS_COLORS` is empty. Check whether `dircolors` runs.

**`<` `>` do not work**: overridden by another zstyle. Use `zstyle -L ':fzf-tab:*'` to check the current settings.

**Completion is slow in large directories**: the preview command traverses the entire directory. You can add `--level=1` to `eza` to limit depth, or remove that `zstyle`.

<!-- lang:ja -->

> 要約：fzf-tab は Zsh の補完メニューを fzf に置き換え、あいまい検索・グループ切り替え・ディレクトリプレビューに対応します。

# fzf-tab

## 用途

Zsh のネイティブ補完は方向キーで選ぶメニューです。fzf-tab はそれを fzf のインターフェースに置き換えます：あいまい検索ができ、プレビューが表示でき、`<` `>` で候補グループを切り替えられます。

補完候補を生成するのは `zsh-completions` と Zsh 内蔵の補完であり、fzf-tab 自体は候補を作りません。表示と選択だけを引き受けます。

## 読み込み方法

```zsh
zsh_plugins_load_post_compinit() {
  zinit light Aloxaf/fzf-tab

  zstyle ':completion:*:git-checkout:*' sort false
  zstyle ':completion:*:descriptions' format '[%d]'
  zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
  zstyle ':completion:*' menu no

  if command -v eza >/dev/null 2>&1; then
    zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always $realpath'
    zstyle ':fzf-tab:complete:z:*'  fzf-preview 'eza -1 --color=always $realpath'
  else
    zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls -1 --color=always $realpath'
    zstyle ':fzf-tab:complete:z:*'  fzf-preview 'ls -1 --color=always $realpath'
  fi

  zstyle ':fzf-tab:*' switch-group '<' '>'
}
```

## 本リポジトリの zstyle の逐条解説

### `menu no`

```zsh
zstyle ':completion:*' menu no
```

Zsh のネイティブ補完メニューを無効化します。無効化しないと fzf-tab とネイティブのメニューが同時に現れ、視覚的に干渉し合います。

### `format '[%d]'`

```zsh
zstyle ':completion:*:descriptions' format '[%d]'
```

補完候補は種類ごとにグループ化されます（コマンド、エイリアス、関数、ファイル、ディレクトリ）。`%d` はグループの説明で、角括弧を付けて `[command]`、`[alias]` のように表示されます。

### `list-colors`

```zsh
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
```

`LS_COLORS` を使って候補に色を付けます。`(s.:.)` は zsh の分割構文で、`LS_COLORS` をコロンで配列に分割します。

`LS_COLORS` がなければこの行は効かず、候補は単色になります。

### `git-checkout sort false`

```zsh
zstyle ':completion:*:git-checkout:*' sort false
```

Git ブランチの補完をアルファベット順に並べ替えず、`git branch` の出力順（通常は最近のコミット優先）を保ちます。よく使うブランチを探しやすくなります。

### プレビュー

```zsh
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always $realpath'
zstyle ':fzf-tab:complete:z:*'  fzf-preview 'eza -1 --color=always $realpath'
```

`cd` と `z` の引数を補完するとき、右側に移動先ディレクトリの内容を表示します。

`$realpath` は fzf-tab が提供する変数で、現在の候補の完全なパスを指します。パイプへの出力時はデフォルトで色が消えるため、`--color=always` は必須です。

eza がない場合は `ls -1` にフォールバックします。

### グループ切り替え

```zsh
zstyle ':fzf-tab:*' switch-group '<' '>'
```

`<` と `>` で候補グループを切り替えます。デフォルトは `Tab`/`Shift+Tab` ですが、`Tab` は fzf 内ですでに複数選択に使われています。

## UI 内のキー

| キー | 動作 |
|---|---|
| `Tab` | 選択し、次のセグメントの補完へ進む |
| `Shift+Tab` | 逆方向 |
| `<` / `>` | 候補グループの切り替え |
| `Ctrl+/` | fzf の追加操作メニューを開く |
| `Enter` | 確定 |
| `Esc` | キャンセル |

## 表示例

```text
$ docker <Tab>
┌─ [docker] ────────────────────────┐
│ container                         │
│ image                             │
│ network                           │
│ compose                           │
└───────────────────────────────────┘
```

`cont` と入力すると `container` にあいまいフィルタされます。

## fzf のグローバルオプションとの関係

fzf-tab は fzf を使いますが、`FZF_DEFAULT_OPTS` は**読みません**。見た目は `zstyle ':fzf-tab:*'` で制御します。

fzf-tab の高さ/レイアウトを変えたい場合：

```zsh
zstyle ':fzf-tab:*' fzf-flags --height=60% --layout=reverse
```

## fzf 補完スクリプトとの違い

混同しやすい2つのもの：

| | fzf-tab | fzf の key-bindings |
|---|---|---|
| 発動 | `Tab` 補完 | `Ctrl+T` / `Ctrl+R` / `Alt+C` |
| 役割 | 補完候補を絞り込む | ファイル選択、履歴選択、ディレクトリ移動 |
| ソース | Zinit プラグイン | 上流 snippet |

両者とも fzf バイナリに依存しますが、機能は重なりません。

## トラブルシューティング

**Tab がまだネイティブのメニュー**：fzf-tab が読み込まれていないか、`menu no` が設定されていません。`zinit list | grep fzf-tab` で確認します。

**候補が空**：`compinit` が実行されていないか、`zsh-completions` が compinit より前に読み込まれていません。

**プレビュー領域が空白**：`eza` / `ls` が使えないか、`$realpath` が空です。内容のあるディレクトリへ `cd` してテストします。

**候補に色が付かない**：`LS_COLORS` が空です。`dircolors` が実行されているか確認します。

**`<` `>` が効かない**：別の zstyle に上書きされています。`zstyle -L ':fzf-tab:*'` で現在の設定を確認します。

**大きなディレクトリで補完が遅い**：プレビューコマンドがディレクトリ全体を走査しています。`eza` に `--level=1` を付けて深さを制限するか、その `zstyle` を外します。
