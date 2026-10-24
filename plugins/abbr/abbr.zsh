# zsh-abbr interactive bindings.
#
# The plugin is loaded with ABBR_DEFAULT_BINDINGS=0 so zsh-vi-mode cannot
# replace its widgets. Bind the Emacs map here; the viins map is bound again in
# zvm_after_init after zsh-vi-mode finishes resetting its keymaps.

if (( $+widgets[abbr-expand-and-insert] )); then
  bindkey -M emacs ' ' abbr-expand-and-insert
  bindkey -M emacs '^ ' magic-space
  bindkey -M emacs '^M' abbr-expand-and-accept
  bindkey -M viins ' ' abbr-expand-and-insert 2>/dev/null
  bindkey -M viins '^ ' magic-space 2>/dev/null
  bindkey -M viins '^M' abbr-expand-and-accept 2>/dev/null
fi
