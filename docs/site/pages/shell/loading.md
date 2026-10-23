> 摘要：从 zshrc 第一行到 fzf 函数可用，逐段说明加载了什么、为什么在那个位置。

# 启动与加载顺序

## 第一段：TERM 保护

```zsh
if [[ -n "$TERM" ]] && ! infocmp -- "$TERM" >/dev/null 2>&1; then
    export TERM=xterm-256color
fi
```

卸载 Kitty 后 `TERM` 可能残留 `xterm-kitty`，但系统里已经没有对应 terminfo，`tput` 和 TUI 程序会报 unknown terminal。这段先做可用性探测再降级。

注意：这里**不会**因为 SSH 就无条件降级。`kitten ssh` 会把 terminfo 传到远端，保留 `xterm-kitty` 才能让 TUI 用真彩色。

## 第二段：历史与 shell 选项

```zsh
export HISTSIZE=100000
export SAVEHIST=100000
export HISTFILE=~/.zsh_history

setopt SHARE_HISTORY
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_REDUCE_BLANKS
setopt HIST_VERIFY
setopt INC_APPEND_HISTORY
setopt AUTO_CD
```

| 选项 | 效果 |
|---|---|
| `SHARE_HISTORY` | 多个终端共享同一份历史，立即互相可见 |
| `HIST_IGNORE_ALL_DUPS` | 重复命令只保留一条 |
| `HIST_REDUCE_BLANKS` | 去掉多余空格 |
| `HIST_VERIFY` | 历史扩展（`!!`）先显示再执行 |
| `INC_APPEND_HISTORY` | 每条命令立即写盘，不等到退出 |
| `AUTO_CD` | 直接输入目录名即切换 |

## 第三段：推导仓库路径

```zsh
dotfiles_root="${${(%):-%x}:A:h}"
```

`%x` 是当前被 source 的文件路径，`:A` 解析为绝对路径，`:h` 取目录。这样仓库可以在任何位置，不写死 `~/dotfiles`。后面还有一个 fallback：如果推导出的目录没有 `plugins/`，就退回到 `$DOTFILES` 或 `~/dotfiles`。

## 第四段：按顺序加载

```text
plugins/zinit/zinit.zsh          Zinit 本体 + zz 函数
plugins/zsh-plugins.zsh          只定义三个加载函数，不执行
plugins/prompt/prompt.zsh        Starship（仅交互终端）
plugins/tools/tools.zsh          CLI 工具 + direnv/atuin 初始化
zsh_plugins_load_pre_compinit    zsh-completions
plugins/completion/completion.zsh
zsh_plugins_load_post_compinit   fzf-tab + 其 zstyle
scripts/setup/setup_fnm.sh       fnm 包装器
zsh_plugins_load_main            vi-mode、autosuggestions、forgit、语法高亮
plugins/fzf/fzf.zsh              f / ffd
atuin / zoxide 的 shell hook
vi 别名、EDITOR/VISUAL
aliases.conf + ~/.config/aliases.conf
local/*.zsh
```

关键点：

- `zsh-plugins.zsh` 在这一步**只定义函数**，真正执行在后面的三个阶段。
- `prompt.zsh` 包在 `[[ -t 1 ]]` 里，非交互场景不加载 Starship。
- `local/` 最后加载，所以私人配置能覆盖前面所有设置。

## 第五段：交互增强

```zsh
if command -v atuin > /dev/null; then
  _evalcache atuin init zsh
fi
if command -v zoxide > /dev/null; then
  _evalcache zoxide init zsh
  alias zi='z -i'
fi
```

`_evalcache` 来自 `mroth/evalcache` 插件，把 `init` 的输出缓存成文件，避免每次启动都执行子进程。这是启动速度的主要优化点之一。

## 第六段：编辑器与别名

```zsh
vi() { ... }   # 优先 nvim，其次 vim，最后 vi
export EDITOR=nvim
export VISUAL=nvim
```

`vi` 被定义成函数而非 alias，这样 ranger 等工具通过 `$EDITOR` 调用时也会拿到 nvim。

## 第七段：私人覆盖

```zsh
[[ -f ~/.config/aliases.conf ]] && source ~/.config/aliases.conf
[[ -f "$dotfiles_root/aliases.conf" ]] && source "$dotfiles_root/aliases.conf"

for dotfiles_local_file in "$dotfiles_root"/local/*(N.D.); do
    [[ "${dotfiles_local_file:t}" == "README.md" ]] && continue
    source "$dotfiles_local_file"
done
```

`(N.D.)` 是 zsh 通配限定符：`N` 表示无匹配时不报错，`D` 表示包含以点开头的文件。

## 排查加载问题

```zsh
zsh -d -n ~/dotfiles/zshrc          # 语法检查
zsh -x -i -c 'true' 2>&1 | head -50 # 追踪加载过程
```

`zsh -x` 会打印每一行执行内容，能看出卡在哪个文件。
<!-- lang:en -->
> Summary: From the first line of zshrc to the fzf functions being available, a section-by-section explanation of what gets loaded and why it sits there.

# Startup and Load Order

## Section 1: TERM protection

```zsh
if [[ -n "$TERM" ]] && ! infocmp -- "$TERM" >/dev/null 2>&1; then
    export TERM=xterm-256color
fi
```

After Kitty is uninstalled, `TERM` may still be `xterm-kitty`, but the matching terminfo no longer exists on the system, and `tput` and TUI programs will report unknown terminal. This section probes availability first, then downgrades.

Note: this does **not** unconditionally downgrade just because of SSH. `kitten ssh` transfers the terminfo to the remote host, so keeping `xterm-kitty` is what lets TUI programs use true color.

## Section 2: history and shell options

```zsh
export HISTSIZE=100000
export SAVEHIST=100000
export HISTFILE=~/.zsh_history

setopt SHARE_HISTORY
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_REDUCE_BLANKS
setopt HIST_VERIFY
setopt INC_APPEND_HISTORY
setopt AUTO_CD
```

| Option | Effect |
|---|---|
| `SHARE_HISTORY` | Multiple terminals share one history and see each other's entries immediately |
| `HIST_IGNORE_ALL_DUPS` | Only one copy of a duplicated command is kept |
| `HIST_REDUCE_BLANKS` | Strips redundant whitespace |
| `HIST_VERIFY` | History expansion (`!!`) is shown before it executes |
| `INC_APPEND_HISTORY` | Each command is written to disk immediately, not on exit |
| `AUTO_CD` | Typing a directory name directly changes into it |

## Section 3: deriving the repo path

```zsh
dotfiles_root="${${(%):-%x}:A:h}"
```

`%x` is the path of the file currently being sourced, `:A` resolves it to an absolute path, and `:h` takes the directory. This way the repo can live anywhere instead of hard-coding `~/dotfiles`. There is also a fallback further down: if the derived directory has no `plugins/`, it falls back to `$DOTFILES` or `~/dotfiles`.

## Section 4: loading in order

```text
plugins/zinit/zinit.zsh          Zinit 本体 + zz 函数
plugins/zsh-plugins.zsh          只定义三个加载函数，不执行
plugins/prompt/prompt.zsh        Starship（仅交互终端）
plugins/tools/tools.zsh          CLI 工具 + direnv/atuin 初始化
zsh_plugins_load_pre_compinit    zsh-completions
plugins/completion/completion.zsh
zsh_plugins_load_post_compinit   fzf-tab + 其 zstyle
scripts/setup/setup_fnm.sh       fnm 包装器
zsh_plugins_load_main            vi-mode、autosuggestions、forgit、语法高亮
plugins/fzf/fzf.zsh              f / ffd
atuin / zoxide 的 shell hook
vi 别名、EDITOR/VISUAL
aliases.conf + ~/.config/aliases.conf
local/*.zsh
```

Key points:

- At this step `zsh-plugins.zsh` **only defines functions**; actual execution happens in the three later stages.
- `prompt.zsh` is wrapped in `[[ -t 1 ]]`, so Starship isn't loaded in non-interactive contexts.
- `local/` loads last, so private configuration can override everything above it.

## Section 5: interactive enhancements

```zsh
if command -v atuin > /dev/null; then
  _evalcache atuin init zsh
fi
if command -v zoxide > /dev/null; then
  _evalcache zoxide init zsh
  alias zi='z -i'
fi
```

`_evalcache` comes from the `mroth/evalcache` plugin; it caches the output of `init` into a file, avoiding a subprocess on every startup. This is one of the main startup-speed optimizations.

## Section 6: editor and aliases

```zsh
vi() { ... }   # 优先 nvim，其次 vim，最后 vi
export EDITOR=nvim
export VISUAL=nvim
```

`vi` is defined as a function rather than an alias, so tools like ranger that invoke `$EDITOR` also get nvim.

## Section 7: private overrides

```zsh
[[ -f ~/.config/aliases.conf ]] && source ~/.config/aliases.conf
[[ -f "$dotfiles_root/aliases.conf" ]] && source "$dotfiles_root/aliases.conf"

for dotfiles_local_file in "$dotfiles_root"/local/*(N.D.); do
    [[ "${dotfiles_local_file:t}" == "README.md" ]] && continue
    source "$dotfiles_local_file"
done
```

`(N.D.)` are zsh glob qualifiers: `N` means no error when there are no matches, `D` means include dot-files.

## Debugging load problems

```zsh
zsh -d -n ~/dotfiles/zshrc          # 语法检查
zsh -x -i -c 'true' 2>&1 | head -50 # 追踪加载过程
```

`zsh -x` prints every executed line, so you can see which file it stalls on.
<!-- lang:ja -->
> 要約：zshrc の最初の行から fzf 関数が使えるようになるまで、何がロードされ、なぜその位置にあるのかを順に説明します。

# 起動とロード順序

## 第 1 段：TERM 保護

```zsh
if [[ -n "$TERM" ]] && ! infocmp -- "$TERM" >/dev/null 2>&1; then
    export TERM=xterm-256color
fi
```

Kitty をアンインストールした後も `TERM` に `xterm-kitty` が残ることがありますが、システムには対応する terminfo がもうなく、`tput` や TUI プログラムが unknown terminal を出します。この段では先に可用性を確認してからダウングレードします。

注意：ここでは SSH だからといって無条件にダウングレードはしません。`kitten ssh` は terminfo をリモートに転送するため、`xterm-kitty` を保持してこそ TUI がトゥルーカラーを使えます。

## 第 2 段：履歴と shell オプション

```zsh
export HISTSIZE=100000
export SAVEHIST=100000
export HISTFILE=~/.zsh_history

setopt SHARE_HISTORY
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_REDUCE_BLANKS
setopt HIST_VERIFY
setopt INC_APPEND_HISTORY
setopt AUTO_CD
```

| オプション | 効果 |
|---|---|
| `SHARE_HISTORY` | 複数ターミナルが同じ履歴を共有し、すぐに互いに見える |
| `HIST_IGNORE_ALL_DUPS` | 重複コマンドは 1 件だけ残す |
| `HIST_REDUCE_BLANKS` | 余分な空白を除去 |
| `HIST_VERIFY` | 履歴展開（`!!`）は実行前に表示 |
| `INC_APPEND_HISTORY` | 各コマンドを終了時ではなく即座にディスクに書き込む |
| `AUTO_CD` | ディレクトリ名の直接入力で移動 |

## 第 3 段：リポジトリパスの導出

```zsh
dotfiles_root="${${(%):-%x}:A:h}"
```

`%x` は現在 source 中のファイルパス、`:A` は絶対パスに解決、`:h` はディレクトリ部分を取ります。これによりリポジトリはどこに置いてもよく、`~/dotfiles` をハードコードしません。この後にもフォールバックがあります。導出されたディレクトリに `plugins/` がなければ、`$DOTFILES` や `~/dotfiles` に退避します。

## 第 4 段：順番にロード

```text
plugins/zinit/zinit.zsh          Zinit 本体 + zz 函数
plugins/zsh-plugins.zsh          只定义三个加载函数，不执行
plugins/prompt/prompt.zsh        Starship（仅交互终端）
plugins/tools/tools.zsh          CLI 工具 + direnv/atuin 初始化
zsh_plugins_load_pre_compinit    zsh-completions
plugins/completion/completion.zsh
zsh_plugins_load_post_compinit   fzf-tab + 其 zstyle
scripts/setup/setup_fnm.sh       fnm 包装器
zsh_plugins_load_main            vi-mode、autosuggestions、forgit、语法高亮
plugins/fzf/fzf.zsh              f / ffd
atuin / zoxide 的 shell hook
vi 别名、EDITOR/VISUAL
aliases.conf + ~/.config/aliases.conf
local/*.zsh
```

ポイント：

- この時点で `zsh-plugins.zsh` は**関数を定義するだけ**で、実際の実行は後の 3 段階で行われます。
- `prompt.zsh` は `[[ -t 1 ]]` で包まれており、非対話の場面では Starship をロードしません。
- `local/` が最後にロードされるため、プライベート設定が前のすべての設定を上書きできます。

## 第 5 段：インタラクティブ強化

```zsh
if command -v atuin > /dev/null; then
  _evalcache atuin init zsh
fi
if command -v zoxide > /dev/null; then
  _evalcache zoxide init zsh
  alias zi='z -i'
fi
```

`_evalcache` は `mroth/evalcache` プラグイン由来で、`init` の出力をファイルにキャッシュし、起動のたびにサブプロセスを実行するのを避けます。起動速度の主要な最適化ポイントの一つです。

## 第 6 段：エディタとエイリアス

```zsh
vi() { ... }   # 优先 nvim，其次 vim，最后 vi
export EDITOR=nvim
export VISUAL=nvim
```

`vi` はエイリアスではなく関数として定義されます。これにより ranger などのツールが `$EDITOR` 経由で呼び出しても nvim が使われます。

## 第 7 段：プライベート上書き

```zsh
[[ -f ~/.config/aliases.conf ]] && source ~/.config/aliases.conf
[[ -f "$dotfiles_root/aliases.conf" ]] && source "$dotfiles_root/aliases.conf"

for dotfiles_local_file in "$dotfiles_root"/local/*(N.D.); do
    [[ "${dotfiles_local_file:t}" == "README.md" ]] && continue
    source "$dotfiles_local_file"
done
```

`(N.D.)` は zsh のグロブ修飾子です。`N` はマッチがなくてもエラーにしない、`D` はドットで始まるファイルも含めることを意味します。

## ロード問題の調査

```zsh
zsh -d -n ~/dotfiles/zshrc          # 语法检查
zsh -x -i -c 'true' 2>&1 | head -50 # 追踪加载过程
```

`zsh -x` は実行内容を 1 行ずつ表示するため、どのファイルで止まっているか分かります。
