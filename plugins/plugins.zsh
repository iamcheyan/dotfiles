# 启用 AUTO_CD：输入目录路径时自动 cd
setopt AUTO_CD

# vim 模式（必须在 autosuggestions 之前加载，因为会影响键绑定）
zinit light jeffreytse/zsh-vi-mode

# autosuggestions
zinit light zsh-users/zsh-autosuggestions

# syntax highlighting（必须最后）
zinit light zsh-users/zsh-syntax-highlighting

# sudo 插件（替代 OMZ sudo）
zinit snippet OMZP::sudo

# git 插件（只拿 git，不引 OMZ）
zinit snippet OMZP::git


