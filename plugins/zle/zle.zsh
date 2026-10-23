# Long-command editing for ZLE.
#
# Ctrl+X Ctrl+E opens the current command line in $VISUAL/$EDITOR (Neovim).
# Ctrl+O inserts a real newline without executing the command.
#
# zsh-vi-mode resets the vi keymaps during initialisation, so its bindings are
# registered in zvm_after_init in plugins/zsh-plugins.zsh. The bindings below
# cover the emacs map and plain zsh (when zsh-vi-mode is unavailable).

autoload -Uz edit-command-line
zle -N edit-command-line

function insert-newline() {
    LBUFFER+=$'\n'
}
zle -N insert-newline

bindkey -M emacs '^X^E' edit-command-line
bindkey -M emacs '^O' insert-newline
bindkey -M viins '^X^E' edit-command-line 2>/dev/null
bindkey -M viins '^O' insert-newline 2>/dev/null
