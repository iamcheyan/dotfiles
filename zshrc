# 如果 TERM 对应的 terminfo 条目缺失（例如卸载 kitty 后残留 xterm-kitty），
# 退回到通用值，避免 tput / 终端程序启动时报 "unknown terminal"
if [[ -n "$TERM" ]] && ! infocmp -- "$TERM" >/dev/null 2>&1; then
    export TERM=xterm-256color
fi

export HISTSIZE=10000
export SAVEHIST=10000

setopt SHARE_HISTORY
setopt HIST_IGNORE_ALL_DUPS
setopt AUTO_CD              # 启用 AUTO_CD：输入目录路径时自动 cd

# SSH 会话中降级 TERM，避免远程服务器不认识 xterm-kitty
# 同时设置 kitty tab 颜色为红色，直观区分远程会话
if [[ -n "$SSH_CONNECTION" || -n "$SSH_CLIENT" || -n "$SSH_TTY" ]]; then
    export TERM=xterm-256color
    # SSH 会话：kitty tab 设为红色背景
    if [[ -n "$KITTY_WINDOW_ID" ]]; then
        (kitty @ --to unix:/tmp/mykitty set-tab-color active_bg=rgb(8b0000) inactive_bg=rgb(3a0000) >/dev/null 2>&1 &) >/dev/null 2>&1
    fi
else
    # 本地会话：恢复默认 tab 颜色
    if [[ -n "$KITTY_WINDOW_ID" ]]; then
        (kitty @ --to unix:/tmp/mykitty set-tab-color active_bg=default inactive_bg=default >/dev/null 2>&1 &) >/dev/null 2>&1
    fi
fi

export PATH="$HOME/.fzf/bin:$PATH"



# NVM 惰性加载（仅在需要时加载）
load_nvm() {
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
}
unalias gm 2>/dev/null
for cmd in nvm node npm npx yarn pnpm gemini gm; do
    eval "${cmd}() { unset -f nvm node npm npx yarn pnpm gemini gm; load_nvm; ${cmd} \"\$@\"; }"
done

# zinit: 插件管理器，负责下载、缓存和加载后面的 zsh 插件/命令
source ~/dotfiles/plugins/zinit/zinit.zsh

# powerlevel10k: 提示符主题，显示目录、Git 状态和环境信息
if [[ -t 1 ]]; then
  source ~/dotfiles/plugins/prompt/prompt.zsh
fi

# 核心工具集合：通过 zinit 安装命令行工具，并初始化 pyenv/direnv/atuin 等 shell 集成
source ~/dotfiles/plugins/tools/tools.zsh



# 补全系统：初始化 compinit、额外补全定义和 fzf-tab 补全界面
source ~/dotfiles/plugins/completion/completion.zsh

# evalcache: 缓存 init 脚本输出，减少 atuin/zoxide/direnv 这类 hook 的重复开销
zinit light mroth/evalcache

# 自动补全
zinit light zsh-users/zsh-autosuggestions

# zsh-autopair: 自动补全括号、引号等
zinit light hlissner/zsh-autopair

# zsh-navigation-tools: 交互式导航工具集，需要同步注册到 fpath/autoload
# 否则 ncd / nkill / nhistory 在新 shell 里可能在异步加载完成前不可用
zinit light zdharma-continuum/zsh-navigation-tools
typeset -g ZNT_PLUGIN_DIR="${HOME}/.zinit/plugins/zdharma-continuum---zsh-navigation-tools"
if [[ -d "$ZNT_PLUGIN_DIR" ]]; then
  fpath+=("$ZNT_PLUGIN_DIR")
  source "$ZNT_PLUGIN_DIR/zsh-navigation-tools.plugin.zsh"
fi

# zsh-vi-mode: 为命令行编辑提供 Vim 模式和模式切换
# 必须在 autosuggestions 之前加载，避免按键绑定冲突
zinit ice lucid
zinit light jeffreytse/zsh-vi-mode

# zsh-history-substring-search: 根据当前已输入前缀，用上下键搜索历史
# 这里作为 atuin 上下键搜索不可用时的回退方案
zinit ice lucid
zinit light zsh-users/zsh-history-substring-search

# 配置 zsh-vi-mode
export ZVM_LINE_INIT_MODE=$ZVM_MODE_INSERT  # 每次新行开始默认进入插入模式
function zvm_after_init() {
  if [[ -n "$widgets[atuin-up-search-viins]" ]]; then
    zvm_bindkey viins '^[[A' atuin-up-search
    zvm_bindkey viins '^[OA' atuin-up-search
  else
    zvm_bindkey viins '^[[A' history-substring-search-up
    zvm_bindkey viins '^[[B' history-substring-search-down
  fi
}

# 其他增强插件集合：autosuggestions、语法高亮、autopair 等
# 这里直接 source 本地文件，避免 zinit 对本地 snippet 的缓存副本滞后
# 具体插件是否异步加载，仍由 plugins.zsh 内部的各个 zinit ice 控制
source ~/dotfiles/plugins/plugins/plugins.zsh

# fzf 相关函数和默认选项：ff/rf/zd/zc/y 等交互工具
# 这里必须同步加载，否则 ff/rf 在新 shell 中可能不存在
source ~/dotfiles/plugins/fzf/fzf.zsh

# atuin: 增强版 shell 历史，支持更强的搜索和历史同步
# 这里初始化 shell hook，并用 evalcache 缓存其输出
if command -v atuin > /dev/null; then
  _evalcache atuin init zsh
fi

# zoxide: 智能目录跳转，替代传统 cd 记忆能力较弱的问题
# 这里初始化 shell hook，并用 evalcache 缓存其输出
if command -v zoxide > /dev/null; then
  _evalcache zoxide init zsh
fi

# direnv: 进入目录时自动加载/卸载环境变量
# 这里初始化 shell hook，并用 evalcache 缓存其输出
# if command -v direnv >/dev/null 2>&1; then
#   _evalcache direnv hook zsh
# fi

# superfile: 文件管理器的 shell 集成；存在本地配置时才加载
# [[ -f ~/dotfiles/plugins/spf/superfile.zsh ]] && source ~/dotfiles/plugins/spf/superfile.zsh

# local.zsh: 机器本地专用配置，不同机器可以放不同逻辑
[[ -f ~/dotfiles/plugins/local/local.zsh ]] && source ~/dotfiles/plugins/local/local.zsh
[[ -f ~/dotfiles/plugins/wdiff/wdiff.zsh ]] && source ~/dotfiles/plugins/wdiff/wdiff.zsh
[[ -f ~/dotfiles/plugins/termscp/termscp.zsh ]] && source ~/dotfiles/plugins/termscp/termscp.zsh

# vi 别名：优先使用 nvim，其次 vim，最后 vi
unalias vi 2>/dev/null
vi() {
    if command -v nvim &> /dev/null; then
        nvim "$@"
    elif command -v vim &> /dev/null; then
        vim "$@"
    else
        command vi "$@"
    fi
}

# 设置编辑器环境变量（yazi 等工具会使用）
# 优先使用 nvim，其次 vim，最后 vi
if command -v nvim &> /dev/null; then
    export EDITOR=nvim
    export VISUAL=nvim
elif command -v vim &> /dev/null; then
    export EDITOR=vim
    export VISUAL=vim
else
    export EDITOR=vi
    export VISUAL=vi
fi

# 启动 shell 前自动同步 chezmoi 管理的 aliases，避免修改源文件后目标文件滞后
if command -v chezmoi >/dev/null 2>&1 && [[ -d "$HOME/chezmoi" ]]; then
    chezmoi apply "$HOME/.config/aliases" >/dev/null 2>&1
fi

# 加载别名配置 (如果目录存在且包含 .conf 文件则加载)
source ~/dotfiles/aliases.conf
[[ -d ~/.config/aliases ]] &&
  for f in ~/.config/aliases/*.conf(N); do
    [[ -r $f ]] && source $f
  done

[[ -r ~/.aws/aliases.conf ]] && source ~/.aws/aliases.conf

# Prompt customization is handled in plugins/prompt/prompt.zsh, which loads ~/.p10k.zsh.

# SSH 会话时在窗口标题前加 [SSH] 标记
function _update_window_title() {
    local prefix=""
    if [[ -n "$SSH_CONNECTION" || -n "$SSH_CLIENT" || -n "$SSH_TTY" ]]; then
        prefix="[SSH] "
    fi
    print -Pn "\e]2;${prefix}%n@%m: %~\a"
}
precmd_functions+=(_update_window_title)

# GO
export GOENV_ROOT="$HOME/.goenv"
export PATH="$GOENV_ROOT/shims:$GOENV_ROOT/bin:$PATH"

if command -v goenv >/dev/null 2>&1; then
  eval "$(goenv init -)"
fi

# bun completions
[ -s "/Users/tetsuya/.bun/_bun" ] && source "/Users/tetsuya/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# Android SDK
export ANDROID_HOME=$HOME/Android/Sdk
export ANDROID_SDK_ROOT=$HOME/Android/Sdk
export PATH=$PATH:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:$ANDROID_HOME/build-tools/33.0.2
