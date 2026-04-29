# starship: 跨平台现代化提示符
# 根据操作系统和架构选择正确的二进制包
local _starship_bpick
if [[ "$OSTYPE" == "darwin"* ]]; then
    if [[ "$(uname -m)" == "arm64" ]]; then
        _starship_bpick="*aarch64-apple-darwin.tar.gz"
    else
        _starship_bpick="*x86_64-apple-darwin.tar.gz"
    fi
else
    if [[ "$(uname -m)" == "aarch64" ]] || [[ "$(uname -m)" == "arm64" ]]; then
        _starship_bpick="*aarch64-unknown-linux-musl.tar.gz"
    else
        _starship_bpick="*x86_64-unknown-linux-musl.tar.gz"
    fi
fi

zinit ice as"command" from"gh-r" bpick"${_starship_bpick}" pick"starship" sbin"starship"
zinit light starship/starship

# 初始化 starship
if command -v starship >/dev/null 2>&1; then
  eval "$(starship init zsh)"
fi
