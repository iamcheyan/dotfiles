# 启用 AUTO_CD：输入目录路径时自动 cd
setopt AUTO_CD

# vim 模式（建议较早加载）
zinit light jeffreytse/zsh-vi-mode

# Atuin 键绑定兼容逻辑 (在 zsh-vi-mode 初始化后重新绑定)
function zvm_after_init() {
  if command -v atuin > /dev/null; then
    # 绑定上方向键触发 Atuin 历史记录搜索
    bindkey '^[[A' atuin-up-search
    bindkey '^[OA' atuin-up-search
    # 在 Vi 插入模式下也启用
    zvm_bindkey viins '^[[A' atuin-up-search
    zvm_bindkey viins '^[OA' atuin-up-search
  fi
}

# syntax highlighting（应在 autosuggestions 之前加载，但尽量靠后）
zinit light zsh-users/zsh-syntax-highlighting

# autosuggestions（应在 syntax highlighting 之后加载以获得最佳效果）
zinit light zsh-users/zsh-autosuggestions

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

# 必须在所有补全相关的插件加载后调用，以确保补全生效
zinit cdreplay -q


