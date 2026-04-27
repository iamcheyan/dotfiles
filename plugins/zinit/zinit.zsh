if [[ ! -f ~/.zinit/bin/zinit.zsh ]]; then
  mkdir -p ~/.zinit
  git clone https://github.com/zdharma-continuum/zinit.git ~/.zinit/bin
fi

source ~/.zinit/bin/zinit.zsh

# # zz 函数：交互式 zoxide 目录查询并切换
# function zz() {
#   local dir
#   dir=$(zoxide query -i)
#   if [[ -n "$dir" ]]; then
#     cd "$dir"
#   fi
# }

zz() {
  local dir
  dir=$( (zoxide query -l; find ~ -type d 2>/dev/null | head -2000) | sort -u | fzf \
    --height 50% \
    --reverse \
    --prompt="dirs> ")
  [ -n "$dir" ] && cd "$dir"
}