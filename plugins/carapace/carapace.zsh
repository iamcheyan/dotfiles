# carapace-bin completion integration.
#
# carapace must load after compinit and after zsh-vi-mode has installed its
# widgets. The generated script registers the `_carapace` completer for every
# supported command and works together with fzf-tab.

if command -v carapace >/dev/null 2>&1; then
  source <(carapace _carapace 2>/dev/null)
fi
