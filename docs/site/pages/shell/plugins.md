> 摘要：zsh-autosuggestions、autopair、forgit、syntax-highlighting 的加载与用法。

# 交互插件

所有插件集中声明在 `plugins/zsh-plugins.zsh` 的 `zsh_plugins_load_main` 里，加载顺序有意固定。

## zsh-autosuggestions

```zsh
zinit light zsh-users/zsh-autosuggestions
ZSH_AUTOSUGGEST_STRATEGY=(history completion)
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=8'
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=100
ZSH_AUTOSUGGEST_USE_ASYNC=1
```

| 设置 | 效果 |
|---|---|
| `STRATEGY=(history completion)` | 先查历史，再查补全 |
| `HIGHLIGHT_STYLE='fg=8'` | 建议文字用灰色，不干扰视线 |
| `BUFFER_MAX_SIZE=100` | 超过 100 字符不再建议 |
| `USE_ASYNC=1` | 异步计算，避免卡顿 |

接受建议按 `→`（默认绑定），部分终端配置里是 `End`。

**为什么限制长度**：长命令的建议计算成本高，而且实际场景里很少需要。粘贴大段文本时这个限制能避免明显延迟。

## zsh-autopair

```zsh
zinit light hlissner/zsh-autopair
```

输入 `(` 自动补 `)`，输入 `"` 自动补 `"`，在已有配对前按退格会一起删除。它只作用于命令行，不影响普通文本编辑。

## forgit

```zsh
zinit light wfxr/forgit
```

forgit 把 Git 的常见操作接到 fzf 选择器上。它要求 fzf 0.60.0 或更新。

| 命令 | 作用 |
|---|---|
| `ga` | 选择文件加入暂存区 |
| `gd` | 浏览文件 diff |
| `glo` | 浏览提交历史 |
| `gcb` | 切换分支 |
| `gsw` | 选择并切换分支 |
| `gss` | 浏览 stash |
| `gsp` | 选择文件创建 stash |
| `gcp` | 选择提交 cherry-pick |
| `grb` | 交互式 rebase |
| `gwt` | 浏览 worktree |
| `gi` | 生成 `.gitignore` 条目 |
| `gbd` | 删除分支 |
| `gclean` | 清理未跟踪文件 |
| `grh` | 从暂存区移除 |
| `grs` | 恢复文件 |

**这些命令直接执行 Git 操作**。`gbd`、`gclean`、`grh`、`grs`、rebase、cherry-pick 都会改变仓库状态，确认选择后再回车。

自定义 fzf 行为：

```zsh
export FORGIT_LOG_FZF_OPTS='--height 80% --border'
export FORGIT_ADD_GIT_OPTS='--others --cached --modified'
```

与已有别名冲突时，可以设置 `FORGIT_NO_ALIASES=1` 禁用短别名，只用 `forgit::` 前缀的函数。

## zsh-syntax-highlighting

```zsh
zinit light zsh-users/zsh-syntax-highlighting
```

必须**最后**加载。它通过 `zle` hook 给命令行着色：存在的命令绿色、不存在的红色、字符串、变量、路径各有颜色。

如果它加载后颜色失效，通常是有插件在它之后又设置了 hook。检查 `zsh-plugins.zsh` 里它是否确实在最后一行。

## 可选工具的 shell 集成

`zsh_plugins_load_shell_tools` 处理两个「装了才启用」的工具：

```zsh
if command -v navi >/dev/null 2>&1; then
  eval "$(navi widget zsh)"
fi
if command -v pet >/dev/null 2>&1; then
  function pet-select() {
    BUFFER="$(pet search --query "$LBUFFER")"
    CURSOR=$#BUFFER
    zle redisplay
  }
  zle -N pet-select
  bindkey '^X^R' pet-select
fi
```

| 工具 | 集成效果 |
|---|---|
| navi | 注册 widget，可在命令行呼出 cheatsheet |
| Pet | `Ctrl+X` 再 `Ctrl+R` 把片段填进命令行 |

两个工具都缺失时，这段代码什么也不做，shell 照常启动。

## 加一个新插件

1. 在 `zsh_plugins_load_main`（或对应阶段）里加 `zinit light owner/repo`。
2. 把该插件的环境变量、`zstyle`、hook 紧挨着写在下面。
3. 检查顺序约束：补全类在 compinit 前后，语法高亮最后。
4. 验证：

```bash
zsh -d -n ./plugins/zsh-plugins.zsh
TERM=xterm-256color zsh -lic 'source ./zshrc >/dev/null 2>&1; true'
```
<!-- lang:en -->
> Summary: Loading and usage of zsh-autosuggestions, autopair, forgit, and syntax-highlighting.

# Interactive Plugins

All plugins are declared in one place, inside `zsh_plugins_load_main` in `plugins/zsh-plugins.zsh`, and the load order is deliberately fixed.

## zsh-autosuggestions

```zsh
zinit light zsh-users/zsh-autosuggestions
ZSH_AUTOSUGGEST_STRATEGY=(history completion)
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=8'
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=100
ZSH_AUTOSUGGEST_USE_ASYNC=1
```

| Setting | Effect |
|---|---|
| `STRATEGY=(history completion)` | Check history first, then completions |
| `HIGHLIGHT_STYLE='fg=8'` | Suggestion text in gray, so it doesn't distract |
| `BUFFER_MAX_SIZE=100` | No suggestions past 100 characters |
| `USE_ASYNC=1` | Async computation to avoid stalling |

Accept a suggestion with `→` (the default binding); in some terminal configurations it's `End`.

**Why limit the length**: suggestion computation is expensive for long commands and rarely needed in practice. When pasting large chunks of text, this limit avoids noticeable delay.

## zsh-autopair

```zsh
zinit light hlissner/zsh-autopair
```

Typing `(` auto-inserts `)`, typing `"` auto-inserts `"`, and backspacing before an existing pair deletes both. It only affects the command line, not ordinary text editing.

## forgit

```zsh
zinit light wfxr/forgit
```

forgit wires Git's common operations to fzf pickers. It requires fzf 0.60.0 or newer.

| Command | Purpose |
|---|---|
| `ga` | Pick files to stage |
| `gd` | Browse file diffs |
| `glo` | Browse commit history |
| `gcb` | Switch branches |
| `gsw` | Pick and switch a branch |
| `gss` | Browse stashes |
| `gsp` | Pick files to stash |
| `gcp` | Pick a commit to cherry-pick |
| `grb` | Interactive rebase |
| `gwt` | Browse worktrees |
| `gi` | Generate `.gitignore` entries |
| `gbd` | Delete branches |
| `gclean` | Clean untracked files |
| `grh` | Remove from the index |
| `grs` | Restore files |

**These commands execute Git operations directly**. `gbd`, `gclean`, `grh`, `grs`, rebase, and cherry-pick all change the repository state — confirm your selection before pressing Enter.

Customizing fzf behavior:

```zsh
export FORGIT_LOG_FZF_OPTS='--height 80% --border'
export FORGIT_ADD_GIT_OPTS='--others --cached --modified'
```

If it conflicts with existing aliases, set `FORGIT_NO_ALIASES=1` to disable the short aliases and use only the `forgit::`-prefixed functions.

## zsh-syntax-highlighting

```zsh
zinit light zsh-users/zsh-syntax-highlighting
```

It must load **last**. It colors the command line through a `zle` hook: existing commands green, nonexistent ones red, with separate colors for strings, variables, and paths.

If colors stop working after it loads, some plugin usually set its own hook afterwards. Check that it really is the last line in `zsh-plugins.zsh`.

## Shell integration for optional tools

`zsh_plugins_load_shell_tools` handles two "enable only if installed" tools:

```zsh
if command -v navi >/dev/null 2>&1; then
  eval "$(navi widget zsh)"
fi
if command -v pet >/dev/null 2>&1; then
  function pet-select() {
    BUFFER="$(pet search --query "$LBUFFER")"
    CURSOR=$#BUFFER
    zle redisplay
  }
  zle -N pet-select
  bindkey '^X^R' pet-select
fi
```

| Tool | Integration effect |
|---|---|
| navi | Registers a widget to summon a cheatsheet from the command line |
| Pet | `Ctrl+X` then `Ctrl+R` fills a snippet into the command line |

When both tools are missing, this code does nothing and the shell starts as usual.

## Adding a new plugin

1. Add `zinit light owner/repo` inside `zsh_plugins_load_main` (or the matching stage).
2. Write the plugin's environment variables, `zstyle`s, and hooks right below it.
3. Check order constraints: completion-related plugins around compinit, syntax highlighting last.
4. Verify:

```bash
zsh -d -n ./plugins/zsh-plugins.zsh
TERM=xterm-256color zsh -lic 'source ./zshrc >/dev/null 2>&1; true'
```
<!-- lang:ja -->
> 要約：zsh-autosuggestions、autopair、forgit、syntax-highlighting のロードと使い方。

# インタラクティブプラグイン

すべてのプラグインは `plugins/zsh-plugins.zsh` の `zsh_plugins_load_main` に一括して宣言され、ロード順序は意図的に固定されています。

## zsh-autosuggestions

```zsh
zinit light zsh-users/zsh-autosuggestions
ZSH_AUTOSUGGEST_STRATEGY=(history completion)
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=8'
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=100
ZSH_AUTOSUGGEST_USE_ASYNC=1
```

| 設定 | 効果 |
|---|---|
| `STRATEGY=(history completion)` | まず履歴を調べ、次に補完 |
| `HIGHLIGHT_STYLE='fg=8'` | 候補表示は灰色で視線の妨げにしない |
| `BUFFER_MAX_SIZE=100` | 100 文字を超えると候補を出さない |
| `USE_ASYNC=1` | 非同期計算で固まりを防ぐ |

候補の確定は `→`（デフォルトのバインド）。ターミナル設定によっては `End` の場合もあります。

**なぜ長さを制限するのか**：長いコマンドの候補計算はコストが高く、実際の使用ではめったに必要になりません。大きなテキストを貼り付ける際に、この制限が顕著な遅延を防ぎます。

## zsh-autopair

```zsh
zinit light hlissner/zsh-autopair
```

`(` を入力すると自動で `)` を補い、`"` を入力すると自動で `"` を補い、既存のペアの前でバックスペースを押すと両方削除します。コマンドラインのみに作用し、普通のテキスト編集には影響しません。

## forgit

```zsh
zinit light wfxr/forgit
```

forgit は Git のよくある操作を fzf セレクタに接続します。fzf 0.60.0 以上が必要です。

| コマンド | 役割 |
|---|---|
| `ga` | ファイルを選んでステージングへ |
| `gd` | ファイルの diff を閲覧 |
| `glo` | コミット履歴を閲覧 |
| `gcb` | ブランチを切り替え |
| `gsw` | ブランチを選んで切り替え |
| `gss` | stash を閲覧 |
| `gsp` | ファイルを選んで stash 作成 |
| `gcp` | コミットを選んで cherry-pick |
| `grb` | 対話式 rebase |
| `gwt` | worktree を閲覧 |
| `gi` | `.gitignore` エントリを生成 |
| `gbd` | ブランチを削除 |
| `gclean` | 未追跡ファイルの掃除 |
| `grh` | ステージングから取り消し |
| `grs` | ファイルを復元 |

**これらのコマンドは Git 操作を直接実行します**。`gbd`、`gclean`、`grh`、`grs`、rebase、cherry-pick はすべてリポジトリの状態を変更するので、Enter の前に選択を確認してください。

fzf の挙動のカスタマイズ：

```zsh
export FORGIT_LOG_FZF_OPTS='--height 80% --border'
export FORGIT_ADD_GIT_OPTS='--others --cached --modified'
```

既存のエイリアスと衝突する場合は、`FORGIT_NO_ALIASES=1` を設定して短いエイリアスを無効化し、`forgit::` 接頭辞の関数だけを使えます。

## zsh-syntax-highlighting

```zsh
zinit light zsh-users/zsh-syntax-highlighting
```

**最後**にロードする必要があります。`zle` hook 経由でコマンドラインに色を付けます。存在するコマンドは緑、存在しないものは赤、文字列・変数・パスにはそれぞれ色が付きます。

ロード後に色が効かなくなった場合、通常は別のプラグインがその後 hook を設定したことが原因です。`zsh-plugins.zsh` で本当に最終行になっているか確認してください。

## 任意ツールの shell 統合

`zsh_plugins_load_shell_tools` は「入っていれば有効化」する 2 つのツールを処理します：

```zsh
if command -v navi >/dev/null 2>&1; then
  eval "$(navi widget zsh)"
fi
if command -v pet >/dev/null 2>&1; then
  function pet-select() {
    BUFFER="$(pet search --query "$LBUFFER")"
    CURSOR=$#BUFFER
    zle redisplay
  }
  zle -N pet-select
  bindkey '^X^R' pet-select
fi
```

| ツール | 統合効果 |
|---|---|
| navi | widget を登録し、コマンドラインから cheatsheet を呼び出せる |
| Pet | `Ctrl+X`、`Ctrl+R` でスニペットをコマンドラインに入力 |

両ツールとも無い場合、このコードは何もせず、shell は通常どおり起動します。

## 新しいプラグインの追加

1. `zsh_plugins_load_main`（または対応する段階）に `zinit light owner/repo` を追加します。
2. そのプラグインの環境変数、`zstyle`、hook を直下に書きます。
3. 順序制約を確認します。補完系は compinit の前後、シンタックスハイライトは最後。
4. 検証：

```bash
zsh -d -n ./plugins/zsh-plugins.zsh
TERM=xterm-256color zsh -lic 'source ./zshrc >/dev/null 2>&1; true'
```
