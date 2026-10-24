# 通用 helper（你以后只加工具，不改结构）
zi_cmd() {
  zinit ice as"command" from"gh-r" pick"$2"
  zinit light "$1"
}

unalias install:httpie 2>/dev/null || true
install:httpie() {
  bash "$HOME/dotfiles/scripts/install/install_httpie.sh" "$@"
}

# 系统监控
zi_cmd aristocratos/btop btop
zi_cmd ClementTsang/bottom btm
zi_cmd muesli/duf duf
# ncdu: 使用系统包管理器安装: sudo apt install ncdu
# glances: 使用 pip 安装: pip install glances
# htop: 使用系统包管理器安装: sudo apt install htop

# Git / 开发
zi_cmd jesseduffield/lazygit lazygit
# Navi and Pet CLI binaries.
zi_cmd denisidoro/navi navi
zi_cmd knqyf263/pet pet
zi_cmd cli/cli gh
if [[ "$OSTYPE" == "darwin"* ]]; then
  local gitui_asset="gitui-mac.tar.gz"
  [[ "$(uname -m)" == "x86_64" ]] && gitui_asset="gitui-mac-x86.tar.gz"
  zinit ice as"command" from"gh-r" bpick"$gitui_asset" pick"gitui"
else
  local gitui_arch="x86_64"
  case "$(uname -m)" in
    aarch64|arm64) gitui_arch="aarch64" ;;
    armv7l) gitui_arch="armv7" ;;
    armv6l|arm) gitui_arch="arm" ;;
  esac
  zinit ice as"command" from"gh-r" bpick"gitui-linux-${gitui_arch}.tar.gz" pick"gitui"
fi
zinit light gitui-org/gitui

# 文本处理
zi_cmd jqlang/jq jq
zi_cmd chmln/sd sd
zi_cmd charmbracelet/glow glow
# dog: 没有 arm64 版本，使用系统包管理器安装: sudo apt install dog
# zi_cmd ogham/dog dog
# httpie: 使用 pip 安装: pip install httpie

# 文件工具
# bat is installed by init.sh on supported platforms; do not download a second copy here.
if [[ "$OSTYPE" == "darwin"* ]]; then
  zinit ice as"command" from"gh-r" bpick"broot_*.zip" mv"broot_*/aarch64-apple-darwin/broot -> broot" pick"broot"
else
  case "$(uname -m)" in
    aarch64|arm64)
      zinit ice as"command" from"gh-r" bpick"broot_*.zip" mv"broot_*/aarch64-unknown-linux-gnu/broot -> broot" pick"broot"
      ;;
    armv7l|armv7)
      zinit ice as"command" from"gh-r" bpick"broot_*.zip" mv"broot_*/armv7-unknown-linux-gnueabihf/broot -> broot" pick"broot"
      ;;
    *)
      zinit ice as"command" from"gh-r" bpick"broot_*.zip" mv"broot_*/x86_64-unknown-linux-gnu-glibc2.28/broot -> broot" pick"broot"
      ;;
  esac
fi
zinit light Canop/broot
# fd 需要特殊处理，因为文件在子目录中
zinit ice as"command" from"gh-r" mv"fd-*/fd -> fd" pick"fd" sbin"fd"
zinit light sharkdp/fd
# ripgrep 需要特殊处理，因为文件在子目录中
zinit ice as"command" from"gh-r" mv"ripgrep-*/rg -> rg" pick"rg" sbin"rg"
zinit light BurntSushi/ripgrep
zi_cmd ajeetdsouza/zoxide zoxide

# fzf（使用系统安装的 fzf，这里只加载补全和键绑定）
# zinit ice from"gh-r" as"command" bpick"*linux_arm64.tar.gz"
# zinit light junegunn/fzf
zinit ice as"completion"
zinit snippet https://github.com/junegunn/fzf/raw/master/shell/completion.zsh
zinit ice as"completion"
zinit snippet https://github.com/junegunn/fzf/raw/master/shell/key-bindings.zsh

# 其他核心工具
# zi_cmd eza-community/eza eza
zi_cmd dalance/procs procs
zi_cmd zellij-org/zellij zellij

# carapace-bin：为大量 CLI 命令提供统一的参数补全。
# Release 资产按 OS/架构命名，需显式 bpick，避免选到 deb/rpm/apk。
case "$OSTYPE" in
  darwin*)
    local carapace_asset="darwin_amd64"
    [[ "$(uname -m)" == "arm64" ]] && carapace_asset="darwin_arm64"
    ;;
  linux*)
    case "$(uname -m)" in
      aarch64|arm64) carapace_asset="linux_arm64" ;;
      i386|i686) carapace_asset="linux_386" ;;
      armv7l|armv6l|arm) carapace_asset="" ;;
      *) carapace_asset="linux_amd64" ;;
    esac
    ;;
  *) carapace_asset="" ;;
esac
if [[ -n "$carapace_asset" ]]; then
  zinit ice as"command" from"gh-r" bpick"carapace-bin_*_${carapace_asset}.tar.gz" pick"carapace"
  zinit light carapace-sh/carapace-bin
fi

# direnv (GitHub release is a single binary)
zinit ice as"command" from"gh-r" sbin"direnv"
zinit light direnv/direnv

# tig: 使用系统包管理器安装: sudo apt install tig 或从源码编译
# superfile: 使用官方安装脚本: bash -c "$(curl -sLo- https://superfile.netlify.app/install.sh)"
# 或者使用 x-cmd: x install superfile
# mdcat: 使用 cargo 安装: cargo install mdcat
# aws: 使用官方安装脚本: curl "https://awscli.amazonaws.com/awscli-exe-linux-aarch64.zip" -o "awscliv2.zip"

# atuin 由系统包管理器安装；仅在系统没有 atuin 时使用 zinit 兜底
if ! command -v atuin >/dev/null 2>&1; then
  if [[ "$OSTYPE" == "darwin"* ]]; then
    zinit ice as"command" from"gh-r" bpick"*apple-darwin*.tar.gz" mv"atuin-*/atuin -> atuin" pick"atuin"
  else
    # Linux (x86_64 or aarch64)
    local atuin_arch="x86_64"
    [[ "$(uname -m)" == "aarch64" || "$(uname -m)" == "arm64" ]] && atuin_arch="aarch64"
    zinit ice as"command" from"gh-r" bpick"atuin-${atuin_arch}-unknown-linux-gnu.tar.gz" mv"atuin-*/atuin -> atuin" pick"atuin"
  fi
  zinit light atuinsh/atuin
fi
