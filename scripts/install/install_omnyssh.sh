#!/bin/bash
set -e

CONFIG_DIR="$HOME/.config/omnyssh"
DOTFILES_OMNY="$HOME/dotfiles/config/omnyssh"

echo "Installing OmnySSH..."

if ! command -v omny &>/dev/null; then
    echo "Installing from source (cargo)..."
    cargo install omnyssh
fi

mkdir -p "$CONFIG_DIR"

if [ -d "$DOTFILES_OMNY" ]; then
    echo "Linking config files..."
    ln -sf "$DOTFILES_OMNY/config.toml" "$CONFIG_DIR/config.toml"
    ln -sf "$DOTFILES_OMNY/hosts.toml" "$CONFIG_DIR/hosts.toml"
    ln -sf "$DOTFILES_OMNY/snippets.toml" "$CONFIG_DIR/snippets.toml"
fi

echo "OmnySSH installed!"
