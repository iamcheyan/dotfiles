# zsh-abbr ships a completion file but zinit loads the plugin after the main
# compinit pass. Register _abbr explicitly once both are available.
if (( $+functions[_abbr] )) || autoload -Uz _abbr 2>/dev/null; then
  compdef _abbr abbr 2>/dev/null
fi
