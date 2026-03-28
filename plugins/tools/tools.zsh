# 通用 helper（你以后只加工具，不改结构）
zi_cmd() {
  zinit ice as"command" from"gh-r" pick"$2"
  zinit light "$1"
}

# pyenv + pyenv-virtualenv
export PYENV_ROOT="$HOME/.pyenv"
if [ -d "$PYENV_ROOT" ]; then
  export PATH="$PYENV_ROOT/bin:$PATH"
  if command -v pyenv >/dev/null 2>&1; then
    eval "$(pyenv init -)"
    if [[ -x "$PYENV_ROOT/plugins/pyenv-virtualenv/bin/pyenv-virtualenv-init" ]]; then
      eval "$($PYENV_ROOT/plugins/pyenv-virtualenv/bin/pyenv-virtualenv-init -)"
    fi
  fi
fi

# 系统监控
zi_cmd aristocratos/btop btop
zi_cmd ClementTsang/bottom btm
zi_cmd muesli/duf duf
# ncdu: 使用系统包管理器安装: sudo apt install ncdu
# glances: 使用 pip 安装: pip install glances
# htop: 使用系统包管理器安装: sudo apt install htop

# Git / 开发
zi_cmd jesseduffield/lazygit lazygit
zi_cmd dandavison/delta delta
zi_cmd cli/cli gh
# gitui: 使用 cargo 安装: cargo install gitui 或从源码编译

# 文本处理
zi_cmd jqlang/jq jq
zi_cmd mikefarah/yq yq
zi_cmd chmln/sd sd
zi_cmd theryangeary/choose choose
zi_cmd charmbracelet/glow glow
# tealdeer: 高性能 tldr 客户端
if [[ "$OSTYPE" == "darwin"* ]]; then
  # macOS (arm64 or x86_64)
  local tldr_arch="aarch64"
  [[ "$(uname -m)" == "x86_64" ]] && tldr_arch="x86_64"
  zinit ice as"command" from"gh-r" bpick"tealdeer-macos-${tldr_arch}" mv"tealdeer* -> tldr" pick"tldr"
else
  # Linux (x86_64 or aarch64)
  local tldr_arch="x86_64"
  [[ "$(uname -m)" == "aarch64" ]] && tldr_arch="aarch64"
  zinit ice as"command" from"gh-r" bpick"tealdeer-linux-${tldr_arch}-musl" mv"tealdeer* -> tldr" pick"tldr"
fi
zinit light tealdeer-rs/tealdeer

# 网络工具
zi_cmd ducaale/xh xh
if [[ "$OSTYPE" == "darwin"* ]]; then
  # macOS (arm64 or x86_64)
  local gping_arch="arm64"
  [[ "$(uname -m)" == "x86_64" ]] && gping_arch="x86_64"
  zinit ice as"command" from"gh-r" bpick"gping-macOS-${gping_arch}.tar.gz" pick"gping"
else
  # Linux (x86_64 or aarch64)
  local gping_arch="x86_64"
  [[ "$(uname -m)" == "aarch64" ]] && gping_arch="arm64"
  zinit ice as"command" from"gh-r" bpick"gping-Linux-musl-${gping_arch}.tar.gz" pick"gping"
fi
zinit light orf/gping
# dog: 没有 arm64 版本，使用系统包管理器安装: sudo apt install dog
# zi_cmd ogham/dog dog
# httpie: 使用 pip 安装: pip install httpie

# 文件工具
zi_cmd sharkdp/bat bat
# fd 需要特殊处理，因为文件在子目录中
zinit ice as"command" from"gh-r" mv"fd-*/fd -> fd" pick"fd" sbin"fd"
zinit light sharkdp/fd
# ripgrep 需要特殊处理，因为文件在子目录中
zinit ice as"command" from"gh-r" mv"ripgrep-*/rg -> rg" pick"rg" sbin"rg"
zinit light BurntSushi/ripgrep
zi_cmd ajeetdsouza/zoxide zoxide
# yazi 使用 musl 版本（静态链接，不依赖系统 GLIBC）
if [[ "$OSTYPE" == "darwin"* ]]; then
  zinit ice as"command" from"gh-r" bpick"*apple-darwin.zip" mv"yazi-*/yazi -> yazi"
else
  zinit ice as"command" from"gh-r" bpick"*linux-musl.zip" mv"yazi-*/yazi -> yazi"
fi
zinit light sxyazi/yazi
# 初始化 yazi（仅首次）
yazi_init_flag="${XDG_STATE_HOME:-$HOME/.local/state}/yazi/init.done"
if [ ! -f "$yazi_init_flag" ] && [ -f ~/.dotfiles/config/yazi/init.sh ]; then
  mkdir -p "${yazi_init_flag%/*}" && bash ~/.dotfiles/config/yazi/init.sh && touch "$yazi_init_flag"
fi

# fzf（使用系统安装的 fzf，这里只加载补全和键绑定）
# zinit ice from"gh-r" as"command" bpick"*linux_arm64.tar.gz"
# zinit light junegunn/fzf
zinit ice as"completion"
zinit snippet https://github.com/junegunn/fzf/raw/master/shell/completion.zsh
zinit ice as"completion"
zinit snippet https://github.com/junegunn/fzf/raw/master/shell/key-bindings.zsh

# 其他核心工具
zi_cmd eza-community/eza eza
zi_cmd bootandy/dust dust
zi_cmd dalance/procs procs
zi_cmd zellij-org/zellij zellij

# direnv (GitHub release is a single binary)
zinit ice as"command" from"gh-r" sbin"direnv"
zinit light direnv/direnv
# tig: 使用系统包管理器安装: sudo apt install tig 或从源码编译
# superfile: 使用官方安装脚本: bash -c "$(curl -sLo- https://superfile.netlify.app/install.sh)"
# 或者使用 x-cmd: x install superfile
# mdcat: 使用 cargo 安装: cargo install mdcat
# aws: 使用官方安装脚本: curl "https://awscli.amazonaws.com/awscli-exe-linux-aarch64.zip" -o "awscliv2.zip"

# atuin 只下载二进制，不再自动初始化（初始化在 plugins.zsh 中进行）
if [[ "$OSTYPE" == "darwin"* ]]; then
  zinit ice as"command" from"gh-r" bpick"*apple-darwin*" mv"atuin-*/atuin -> atuin" pick"atuin"
else
  zinit ice as"command" from"gh-r" bpick"*unknown-linux-gnu*" mv"atuin-*/atuin -> atuin" pick"atuin"
fi
zinit light atuinsh/atuin

# direnv (hook 已移至 zshrc)
