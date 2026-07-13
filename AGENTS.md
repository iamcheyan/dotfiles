# Chezmoi Dotfiles

## Important Rules

- **NEVER edit files in `~/.config/` directly** — those are chezmoi-managed output files
- **Always edit the chezmoi source** in this repo (e.g., `dot_config/aliases/zellij.conf`)
- After editing, run `chezmoi apply` to sync changes
