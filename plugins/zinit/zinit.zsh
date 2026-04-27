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
  local base dir
  local -a list_cmd
  base="${1:-$HOME}"

  if [[ "$base" == "." ]]; then
    base="$PWD"
  elif [[ "$base" == "~" ]]; then
    base="$HOME"
  elif [[ "$base" == ~/* ]]; then
    base="${HOME}/${base#~/}"
  fi

  if [[ ! -d "$base" ]]; then
    echo "zz: not a directory: $base" >&2
    return 1
  fi

  if command -v fd >/dev/null 2>&1; then
    list_cmd=(fd . "$base" --type d --hidden --follow --exclude .git)
  elif command -v fdfind >/dev/null 2>&1; then
    list_cmd=(fdfind . "$base" --type d --hidden --follow --exclude .git)
  else
    list_cmd=(find "$base" -type d)
  fi

  dir=$(
    {
      if [[ "$base" == "$HOME" ]]; then
        zoxide query -l 2>/dev/null
      fi
      printf '%s\n' "$base"
      "${list_cmd[@]}" 2>/dev/null
    } | awk 'NF && !seen[$0]++' | fzf \
      --height 50% \
      --reverse \
      --prompt="dirs> " \
      --preview-window=hidden
  )
  [[ -n "$dir" ]] && cd "$dir"
}
