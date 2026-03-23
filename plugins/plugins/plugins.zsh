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

# history-substring-search
zinit light zsh-users/zsh-history-substring-search
# 兼容 zsh-vi-mode
function zvm_after_init() {
  # 优先使用 atuin 的上键搜索（如果存在）
  if [[ -n "$widgets[atuin-up-search-viins]" ]]; then
    zvm_bindkey viins '^[[A' atuin-up-search-viins
    zvm_bindkey viins '^[[B' atuin-up-search-viins # atuin 通常自动处理上下
  else
    # 回退到传统的 history-substring-search
    zvm_bindkey viins '^[[A' history-substring-search-up
    zvm_bindkey viins '^[[B' history-substring-search-down
  fi
}


