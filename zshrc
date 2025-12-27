# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
# Set instant prompt to quiet to suppress warnings during zinit tool installation
typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Instant prompt (p10k)
[[ -r ~/.cache/p10k-instant-prompt.zsh ]] && source ~/.cache/p10k-instant-prompt.zsh

source ~/.dotfiles/config/zsh/plugins/zinit.zsh
source ~/.dotfiles/config/zsh/plugins/prompt.zsh
source ~/.dotfiles/config/zsh/plugins/plugins.zsh
source ~/.dotfiles/config/zsh/plugins/tools.zsh
source ~/.dotfiles/config/zsh/plugins/completion.zsh

# fzf 配置（需要在 tools.zsh 之后加载，因为 fzf 二进制需要先安装）
[[ -f ~/.dotfiles/config/zsh/plugins/fzf.zsh ]] && source ~/.dotfiles/config/zsh/plugins/fzf.zsh

# superfile 配置（自动安装功能）
[[ -f ~/.dotfiles/config/zsh/plugins/superfile.zsh ]] && source ~/.dotfiles/config/zsh/plugins/superfile.zsh

[[ -f ~/.dotfiles/config/zsh/plugins/local.zsh ]] && source ~/.dotfiles/config/zsh/plugins/local.zsh

# 加载别名配置
[[ -f ~/.dotfiles/aliases.conf ]] && source ~/.dotfiles/aliases.conf

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
