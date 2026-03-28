# 启用 AUTO_CD：输入目录路径时自动 cd
setopt AUTO_CD

# autosuggestions
zinit light zsh-users/zsh-autosuggestions

# 语法高亮（性能更好且更智能的 fast-syntax-highlighting）
# 注意：必须放在插件列表的最后加载，以确保高亮所有命令
zinit light zdharma-continuum/fast-syntax-highlighting

# zsh-autopair: 自动补全括号、引号等 (IDE 般体验)
zinit light hlissner/zsh-autopair

# forgit: 用 fzf 玩转 Git (交互式 add, log, diff)
zinit ice lucid wait="0"
zinit load wfxr/forgit

# sudo 插件（替代 OMZ sudo）
zinit snippet OMZP::sudo

# git 插件（只拿 git，不引 OMZ）
zinit snippet OMZP::git

# zshcp 插件：Zsh 剪贴板管理 (必须在 copypath/copyfile 之前加载)
zinit light 1mykull/zshcp

# copypath 插件：复制文件或目录路径到剪贴板
zinit snippet OMZP::copypath

# copyfile 插件：复制文件内容到剪贴板
zinit snippet OMZP::copyfile

# you-should-use 插件：提醒使用已存在的别名
zinit light MichaelAquilina/zsh-you-should-use

# extract 插件：自动解压各种压缩文件
zinit light le0me55i/zsh-extract

# git-open 插件：在浏览器中打开 Git 仓库页面
zinit light paulirish/git-open

# colored-man-pages: 彩色帮助手册
zinit snippet OMZP::colored-man-pages

# zsh-bd: 快速回到上级目录 (bd 目录名)
zinit light Tarrasch/zsh-bd

# zsh-navigation-tools: 交互式导航工具集 (n-list, n-panelize 等)
zinit light zdharma-continuum/zsh-navigation-tools




