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
  # 如果已经在 zellij 里：提示用户如何 detach
  if [[ -n "$ZELLIJ" ]]; then
    echo "You are in a zellij session. Please use 'Ctrl+o' and then 'd' to detach."
    return
  fi

  # session 名：优先用参数，其次用当前目录名
  local session_name
  if [[ -n "$1" ]]; then
    session_name="$1"
  else
    session_name="$(basename "$PWD")"
  fi

  # 如果 session 已存在就 attach，否则新建
  if zellij list-sessions 2>/dev/null | grep -q "^${session_name}\b"; then
    zellij attach "$session_name"
  else
    zellij -s "$session_name"
  fi
}
