if ! command -v broot >/dev/null 2>&1; then
  return 0
fi

typeset -g BROOT_LAUNCHER="${XDG_CONFIG_HOME:-$HOME/.config}/broot/launcher/br"
typeset -g BROOT_INIT_SCRIPT="$HOME/dotfiles/config/broot/init.sh"
typeset -g BROOT_INIT_FLAG="${XDG_STATE_HOME:-$HOME/.local/state}/broot/init.done"

if [[ (! -f "$BROOT_LAUNCHER" || ! -f "$BROOT_INIT_FLAG") && -f "$BROOT_INIT_SCRIPT" ]]; then
  mkdir -p "${BROOT_INIT_FLAG%/*}"
  bash "$BROOT_INIT_SCRIPT" >/dev/null 2>&1 || true
fi

[[ -f "$BROOT_LAUNCHER" ]] && source "$BROOT_LAUNCHER"

if typeset -f br >/dev/null 2>&1; then
  functions[_broot_launcher]="$functions[br]"

  br() {
    emulate -L zsh

    if [[ $# -eq 0 ]]; then
      _broot_launcher
      return
    fi

    if [[ "$1" == -* ]]; then
      _broot_launcher "$@"
      return
    fi

    if [[ -e "$1" || "$1" == "." || "$1" == ".." || "$1" == "~" || "$1" == ~/* ]]; then
      _broot_launcher "$@"
      return
    fi

    local cmd_file cmd code query
    query="$*"
    cmd_file="$(mktemp)"

    if broot --outcmd "$cmd_file" --cmd "${query};:panel_right" "${PWD}"; then
      cmd="$(<"$cmd_file")"
      command rm -f "$cmd_file"
      eval "$cmd"
    else
      code=$?
      command rm -f "$cmd_file"
      return "$code"
    fi
  }
fi
