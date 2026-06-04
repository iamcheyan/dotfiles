_omnyssh_config_dir() {
  printf '%s\n' "${XDG_CONFIG_HOME:-$HOME/.config}/omnyssh"
}

_omnyssh_link_config() {
  local source_dir="$HOME/dotfiles/config/omnyssh"
  local target_dir
  target_dir="$(_omnyssh_config_dir)"

  [[ -d "$source_dir" ]] || return 0

  mkdir -p "$target_dir"
  ln -sf "$source_dir/config.toml" "$target_dir/config.toml"
  ln -sf "$source_dir/hosts.toml" "$target_dir/hosts.toml"
  ln -sf "$source_dir/snippets.toml" "$target_dir/snippets.toml"
}

_omnyssh_find_binary() {
  local candidate

  for candidate in \
    "$HOME/.cargo/bin/omny" \
    "$HOME/.local/bin/omny" \
    "/opt/homebrew/bin/omny" \
    "/usr/local/bin/omny" \
    "/usr/bin/omny"
  do
    [[ -x "$candidate" ]] && {
      printf '%s\n' "$candidate"
      return 0
    }
  done

  whence -p omny 2>/dev/null
}

_omnyssh_install() {
  case "$(uname -s 2>/dev/null)" in
    Linux*|Darwin*) ;;
    *)
      print -u2 "omnyssh auto-install supports Linux and macOS only."
      return 1
      ;;
  esac

  if command -v brew >/dev/null 2>&1; then
    brew install timhartmann7/tap/omnyssh
  elif command -v curl >/dev/null 2>&1; then
    curl -fsSL https://raw.githubusercontent.com/timhartmann7/omnyssh/main/install.sh | sh
  elif command -v cargo >/dev/null 2>&1; then
    cargo install omnyssh
  else
    print -u2 "Cannot install omnyssh: install brew, curl, or cargo first."
    return 1
  fi
}

ossh() {
  local omny_bin

  _omnyssh_link_config
  omny_bin="$(_omnyssh_find_binary)"

  if [[ -z "$omny_bin" ]]; then
    print "omnyssh is not installed. Installing..."
    _omnyssh_install || return $?
    rehash
    omny_bin="$(_omnyssh_find_binary)"
  fi

  if [[ -z "$omny_bin" ]]; then
    print -u2 "omnyssh installation finished, but the omny binary was not found in PATH."
    return 1
  fi

  "$omny_bin" "$@"
}

alias omnyssh=ossh
