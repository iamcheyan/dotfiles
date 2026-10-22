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
