# starship: 跨平台现代化提示符
zinit ice as"command" from"gh-r" bpick"*x86_64-unknown-linux-musl.tar.gz" pick"starship" sbin"starship"
zinit light starship/starship

# 初始化 starship
if command -v starship >/dev/null 2>&1; then
  eval "$(starship init zsh)"
fi
