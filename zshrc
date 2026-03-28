# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
# Set instant prompt to quiet to suppress warnings during zinit tool installation

export PATH="$HOME/.fzf/bin:$PATH"

# NVM 惰性加载（仅在需要时加载）
load_nvm() {
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
}
nvm() {
    load_nvm && nvm "$@"
}

typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

source ~/.dotfiles/plugins/zinit/zinit.zsh
source ~/.dotfiles/plugins/prompt/prompt.zsh

# 核心工具同步加载
source ~/.dotfiles/plugins/tools/tools.zsh

# 补全系统同步加载（确保按 Tab 即刻可用）
source ~/.dotfiles/plugins/completion/completion.zsh

# 同步加载 evalcache，供后面的 init 使用
zinit light mroth/evalcache

# 同步加载 zsh-vi-mode (确保光标状态立即生效)
# 必须在 autosuggestions 之前加载
zinit ice lucid
zinit light jeffreytse/zsh-vi-mode

# 同步加载历史记录子串搜索（回退方案）
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

# 其他增强插件异步加载（wait 0 表示在 prompt 出现后立即在后台加载）
zinit ice wait"0" lucid
zinit snippet ~/.dotfiles/plugins/plugins/plugins.zsh

# fzf 配置（异步加载）
zinit ice wait"0" lucid
zinit snippet ~/.dotfiles/plugins/fzf/fzf.zsh

# Atuin 历史搜索初始化 (使用 evalcache 缓存以加速启动)
if command -v atuin > /dev/null; then
  _evalcache atuin init zsh
fi

# zoxide 初始化 (使用 evalcache)
if command -v zoxide > /dev/null; then
  _evalcache zoxide init zsh
fi

# direnv hook (使用 evalcache)
if command -v direnv >/dev/null 2>&1; then
  _evalcache direnv hook zsh
fi

# superfile 配置
[[ -f ~/.dotfiles/plugins/spf/superfile.zsh ]] && source ~/.dotfiles/plugins/spf/superfile.zsh

[[ -f ~/.dotfiles/plugins/local/local.zsh ]] && source ~/.dotfiles/plugins/local/local.zsh

# vi 别名：优先使用 nvim，其次 vim，最后 vi
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

# 加载别名配置
[[ -f ~/.dotfiles/aliases.conf ]] && source ~/.dotfiles/aliases.conf

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# opencode
export PATH=$HOME/.opencode/bin:$PATH
