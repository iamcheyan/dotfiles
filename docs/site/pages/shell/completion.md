> 摘要：compinit、zsh-completions、fzf-tab 的三阶段加载，以及 PATH 整理和缓存。

# 补全系统

## 三个阶段的由来

Zsh 的补全系统要求 `compinit` 在正确时机运行：它扫描 `$fpath` 收集补全定义，生成 `~/.zcompdump`。之后加载的补全文件需要重新 `rehash` 才生效。所以：

1. **`zsh_plugins_load_pre_compinit`** — 加载 `zsh-users/zsh-completions`，把额外补全定义放进 `$fpath`。
2. **`plugins/completion/completion.zsh`** — 运行 `compinit`，设置缓存和匹配规则。
3. **`zsh_plugins_load_post_compinit`** — 加载 `Aloxaf/fzf-tab`，它会替换补全菜单的显示方式。

顺序颠倒会出现「补全候选里没有 docker 子命令」或「fzf-tab 不生效」这类问题。

## completion.zsh 做了什么

```zsh
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompcache"
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
```

| 设置 | 作用 |
|---|---|
| `use-cache on` | 把补全结果缓存到磁盘，加快重复补全 |
| `matcher-list` 第一条 | 大小写不敏感匹配 |
| 第二条 | `foo-bar` 可以只输入 `fb` 匹配 |
| 第三条 | 任意位置模糊匹配 |

缓存目录放在 `~/.cache/zsh/zcompcache`，符合 XDG 规范，不会污染 home 目录。

这个文件还做 PATH 整理：把 zinit 安装的工具目录加进 PATH，并去重、清理不存在的路径。这部分逻辑在 `clean_path` 和 `add_to_path_if_new` 两个函数里。

## fzf-tab

```zsh
zinit light Aloxaf/fzf-tab

zstyle ':completion:*:descriptions' format '[%d]'
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' menu no
zstyle ':completion:*' git-checkout:*' sort false
```

| 配置 | 效果 |
|---|---|
| `format '[%d]'` | 候选分组标题带方括号 |
| `list-colors` | 用 `LS_COLORS` 给候选上色 |
| `menu no` | 关闭 Zsh 原生菜单，交给 fzf |
| `git-checkout sort false` | 分支按仓库顺序而非字母序 |

预览配置：

```zsh
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always $realpath'
zstyle ':fzf-tab:complete:z:*'  fzf-preview 'eza -1 --color=always $realpath'
```

`cd` 和 `z` 的补全会在右侧预览目录内容。没有 eza 时回退到 `ls -1`。

## fzf-tab 内的按键

| 键 | 动作 |
|---|---|
| `Tab` | 选中并继续补全 |
| `Shift+Tab` | 反向 |
| `<` / `>` | 切换候选组（本仓库显式绑定） |
| `Ctrl+/` | 触发 fzf 的额外操作菜单 |

## 常见问题

**补全候选为空**：`compinit` 没运行。检查 `plugins/completion/completion.zsh` 是否被 source。

**新装的命令没有补全**：补全定义在 `$fpath` 里但 `zcompdump` 是旧的。删缓存重建：

```zsh
rm -f ~/.zcompdump*
exec zsh
```

**fzf-tab 生效但样式乱**：`LS_COLORS` 没设置。检查 `dircolors` 或主题是否导出了它。

**`cd` 补全很慢**：预览命令在大目录下会遍历很多文件。可以把该条 `zstyle` 注释掉，或改用 `--max-depth`。
<!-- lang:en -->
> Summary: Three-stage loading of compinit, zsh-completions, and fzf-tab, plus PATH cleanup and caching.

# Completion System

## Why there are three stages

Zsh's completion system requires `compinit` to run at the right moment: it scans `$fpath` to collect completion definitions and generates `~/.zcompdump`. Completion files loaded afterwards need a `rehash` to take effect. So:

1. **`zsh_plugins_load_pre_compinit`** — loads `zsh-users/zsh-completions` and puts extra completion definitions into `$fpath`.
2. **`plugins/completion/completion.zsh`** — runs `compinit`, sets up caching and matching rules.
3. **`zsh_plugins_load_post_compinit`** — loads `Aloxaf/fzf-tab`, which replaces how the completion menu is displayed.

Getting the order wrong causes problems like "docker subcommands missing from completion candidates" or "fzf-tab not taking effect".

## What completion.zsh does

```zsh
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompcache"
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
```

| Setting | Purpose |
|---|---|
| `use-cache on` | Caches completion results to disk, speeding up repeated completions |
| First `matcher-list` entry | Case-insensitive matching |
| Second entry | `foo-bar` can be matched by typing just `fb` |
| Third entry | Fuzzy matching at any position |

The cache directory lives at `~/.cache/zsh/zcompcache`, which follows the XDG spec and doesn't pollute the home directory.

This file also cleans up PATH: it adds directories of tools installed by zinit to PATH, then deduplicates and removes nonexistent paths. That logic lives in two functions, `clean_path` and `add_to_path_if_new`.

## fzf-tab

```zsh
zinit light Aloxaf/fzf-tab

zstyle ':completion:*:descriptions' format '[%d]'
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' menu no
zstyle ':completion:*' git-checkout:*' sort false
```

| Setting | Effect |
|---|---|
| `format '[%d]'` | Candidate group titles get square brackets |
| `list-colors` | Colors candidates using `LS_COLORS` |
| `menu no` | Disables Zsh's native menu, handing over to fzf |
| `git-checkout sort false` | Branches ordered by repository order rather than alphabetically |

Preview settings:

```zsh
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always $realpath'
zstyle ':fzf-tab:complete:z:*'  fzf-preview 'eza -1 --color=always $realpath'
```

Completions for `cd` and `z` preview the directory contents on the right. Falls back to `ls -1` when eza is absent.

## Keys inside fzf-tab

| Key | Action |
|---|---|
| `Tab` | Select and keep completing |
| `Shift+Tab` | Reverse |
| `<` / `>` | Switch candidate groups (explicitly bound in this repo) |
| `Ctrl+/` | Trigger fzf's extra actions menu |

## Common problems

**Completion candidates are empty**: `compinit` didn't run. Check whether `plugins/completion/completion.zsh` is being sourced.

**A newly installed command has no completion**: the completion definition is in `$fpath` but `zcompdump` is stale. Delete the cache and rebuild:

```zsh
rm -f ~/.zcompdump*
exec zsh
```

**fzf-tab works but styling is broken**: `LS_COLORS` is not set. Check whether `dircolors` or the theme exports it.

**`cd` completion is slow**: the preview command traverses many files in large directories. You can comment out that `zstyle` line, or switch to `--max-depth`.
<!-- lang:ja -->
> 要約：compinit、zsh-completions、fzf-tab の三段階ロードと、PATH の整理とキャッシュについて。

# 補完システム

## 三段階になった理由

Zsh の補完システムでは `compinit` を正しいタイミングで実行する必要があります。`compinit` は `$fpath` を走査して補完定義を収集し、`~/.zcompdump` を生成します。その後にロードされた補完ファイルは、`rehash` をやり直さないと有効になりません。そこで：

1. **`zsh_plugins_load_pre_compinit`** — `zsh-users/zsh-completions` をロードし、追加の補完定義を `$fpath` に入れます。
2. **`plugins/completion/completion.zsh`** — `compinit` を実行し、キャッシュとマッチングルールを設定します。
3. **`zsh_plugins_load_post_compinit`** — `Aloxaf/fzf-tab` をロードします。これは補完メニューの表示方法を置き換えます。

順序を間違えると「補完候補に docker のサブコマンドが出ない」「fzf-tab が効かない」といった問題が起こります。

## completion.zsh の中身

```zsh
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompcache"
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
```

| 設定 | 役割 |
|---|---|
| `use-cache on` | 補完結果をディスクにキャッシュし、繰り返しの補完を高速化 |
| `matcher-list` の 1 つ目 | 大文字小文字を区別しないマッチング |
| 2 つ目 | `foo-bar` を `fb` だけの入力でマッチ可能 |
| 3 つ目 | 任意位置のファジーマッチング |

キャッシュディレクトリは `~/.cache/zsh/zcompcache` に置かれ、XDG 規範に従うため home ディレクトリを汚しません。

このファイルは PATH の整理も行います。zinit でインストールしたツールのディレクトリを PATH に追加し、重複排除と存在しないパスの削除をします。このロジックは `clean_path` と `add_to_path_if_new` の 2 つの関数にあります。

## fzf-tab

```zsh
zinit light Aloxaf/fzf-tab

zstyle ':completion:*:descriptions' format '[%d]'
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' menu no
zstyle ':completion:*' git-checkout:*' sort false
```

| 設定 | 効果 |
|---|---|
| `format '[%d]'` | 候補グループの見出しに角括弧を付ける |
| `list-colors` | `LS_COLORS` で候補に色を付ける |
| `menu no` | Zsh 標準のメニューを無効化し、fzf に任せる |
| `git-checkout sort false` | ブランチをアルファベット順ではなくリポジトリ順に並べる |

プレビュー設定：

```zsh
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always $realpath'
zstyle ':fzf-tab:complete:z:*'  fzf-preview 'eza -1 --color=always $realpath'
```

`cd` と `z` の補完では、右側にディレクトリの内容がプレビューされます。eza がない場合は `ls -1` にフォールバックします。

## fzf-tab 内のキー操作

| キー | 動作 |
|---|---|
| `Tab` | 選択して補完を続ける |
| `Shift+Tab` | 逆方向 |
| `<` / `>` | 候補グループの切り替え（本リポジトリで明示的にバインド） |
| `Ctrl+/` | fzf の追加アクションメニューを起動 |

## よくある問題

**補完候補が空**：`compinit` が実行されていません。`plugins/completion/completion.zsh` が source されているか確認してください。

**新しく入れたコマンドに補完がない**：補完定義は `$fpath` にあるのに `zcompdump` が古い状態です。キャッシュを削除して再構築します：

```zsh
rm -f ~/.zcompdump*
exec zsh
```

**fzf-tab は効くが見た目が崩れる**：`LS_COLORS` が設定されていません。`dircolors` やテーマがエクスポートしているか確認してください。

**`cd` の補完が遅い**：プレビューコマンドが大きなディレクトリで多くのファイルを走査します。該当の `zstyle` をコメントアウトするか、`--max-depth` を使うように変更できます。
