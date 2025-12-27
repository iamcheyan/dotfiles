# 通用 helper（你以后只加工具，不改结构）
zi_cmd() {
  zinit ice as"command" from"gh-r" pick"$2"
  zinit light "$1"
}

# 系统监控
zi_cmd aristocratos/btop btop
zi_cmd ClementTsang/bottom btm
zi_cmd muesli/duf duf

# Git / 开发
zi_cmd jesseduffield/lazygit lazygit
zi_cmd dandavison/delta delta
zi_cmd cli/cli gh

# 文本处理
zi_cmd jqlang/jq jq
zi_cmd mikefarah/yq yq
zi_cmd chmln/sd sd
zi_cmd theryangeary/choose choose
# tealdeer: GitHub releases 不可用，使用系统包管理器安装: sudo apt install tealdeer
# zi_cmd dbrgn/tealdeer tldr

# 网络工具
zi_cmd ducaale/xh xh
# dog: 没有 arm64 版本，使用系统包管理器安装: sudo apt install dog
# zi_cmd ogham/dog dog

# 文件工具
zi_cmd sharkdp/bat bat
zi_cmd BurntSushi/ripgrep rg
zi_cmd ajeetdsouza/zoxide zoxide
zi_cmd sxyazi/yazi yazi

# fzf（需要特殊处理：二进制 + 补全 + 键绑定）
zinit ice from"gh-r" as"command" bpick"*linux_arm64.tar.gz"
zinit light junegunn/fzf
zinit ice as"completion"
zinit snippet https://github.com/junegunn/fzf/raw/master/shell/completion.zsh
zinit ice as"completion"
zinit snippet https://github.com/junegunn/fzf/raw/master/shell/key-bindings.zsh

# 其他核心工具
zi_cmd eza-community/eza eza
zi_cmd bootandy/dust dust
zi_cmd dalance/procs procs
zi_cmd zellij-org/zellij zellij

# atuin（单独处理，必须）
zinit ice \
  as"command" \
  from"gh-r" \
  bpick"*.tar.gz" \
  mv"atuin-*-unknown-linux-gnu/atuin -> atuin" \
  atclone"./atuin init zsh > init.zsh" \
  atpull"%atclone" \
  src"init.zsh"

zinit light atuinsh/atuin

