#!/usr/bin/env bash
# Install TPM and all plugins declared by the dotfiles tmux configuration.
#
# Safe to run repeatedly. It never overwrites an existing TPM checkout or
# plugin directory, skips cleanly when tmux/git/configuration are unavailable,
# and exits 0 so a bootstrap step cannot fail the whole dotfiles initialization.

set -u

info() {
    printf '%s\n' "$*"
}

warning() {
    printf 'warning: %s\n' "$*" >&2
}

config_path="${XDG_CONFIG_HOME:-$HOME/.config}/tmux/tmux.conf"
if [ ! -f "$config_path" ]; then
    config_path="$HOME/.tmux.conf"
fi
if [ ! -f "$config_path" ]; then
    warning "tmux configuration not found; skipping TPM and plugin setup."
    exit 0
fi

if ! command -v tmux >/dev/null 2>&1; then
    info "tmux is not installed; skipping TPM and plugin setup."
    exit 0
fi
if ! command -v git >/dev/null 2>&1; then
    info "git is not installed; skipping TPM and plugin setup."
    exit 0
fi

plugin_dir="${TMUX_PLUGIN_MANAGER_PATH:-${XDG_CONFIG_HOME:-$HOME/.config}/tmux/plugins}"
plugin_dir="${plugin_dir%/}"
tpm_dir="$plugin_dir/tpm"

if [ ! -d "$tpm_dir" ]; then
    mkdir -p "$plugin_dir" || {
        warning "could not create $plugin_dir."
        exit 0
    }
    if ! GIT_TERMINAL_PROMPT=0 git clone --depth 1 \
        https://github.com/tmux-plugins/tpm "$tpm_dir"; then
        warning "could not clone TPM; tmux plugins were not installed."
        exit 0
    fi
elif [ ! -d "$tpm_dir/.git" ] && [ ! -x "$tpm_dir/bin/install_plugins" ]; then
    warning "$tpm_dir exists but is not a TPM checkout; refusing to overwrite it."
    exit 0
fi

if [ ! -x "$tpm_dir/bin/install_plugins" ] || [ ! -x "$tpm_dir/bin/update_plugins" ]; then
    warning "TPM is present but its installer scripts are missing; skipping."
    exit 0
fi

if ! tmux start-server 2>/dev/null; then
    warning "could not start the tmux server; skipping TPM and plugin setup."
    exit 0
fi

temporary_session=""
trap '[ -z "$temporary_session" ] || tmux kill-session -t "$temporary_session" 2>/dev/null || true' EXIT
if ! tmux has-session 2>/dev/null; then
    temporary_session="dotfiles-tpm-install-$$"
    if ! tmux new-session -d -s "$temporary_session" -c "$HOME" /bin/sh 2>/dev/null; then
        temporary_session=""
        warning "could not create a temporary tmux session; skipping TPM setup."
        exit 0
    fi
fi

# TPM resolves its plugin directory from the tmux server environment, not from
# the shell that invokes it. Set it before installing so fresh machines with no
# prior tmux session still use the dotfiles XDG plugin path.
tmux set-environment -g TMUX_PLUGIN_MANAGER_PATH "$plugin_dir/" || { warning "could not configure the tmux plugin path."; exit 0; }
export TMUX_PLUGIN_MANAGER_PATH="$plugin_dir/"


status=0
if ! "$tpm_dir/bin/install_plugins"; then
    warning "TPM plugin installation reported an error."
    status=1
fi
if ! "$tpm_dir/bin/update_plugins" all; then
    warning "TPM plugin update reported an error."
    status=1
fi

# On a server created for this run, source the config so its TPM entry and
# bindings are active and a later acceptance check does not see returned 127.
if [ -n "$temporary_session" ]; then
    if ! tmux source-file "$config_path" 2>/dev/null; then
        warning "could not source $config_path after plugin installation."
        status=1
    fi
    tmux kill-session -t "$temporary_session" 2>/dev/null || true
fi

if [ "$status" -eq 0 ]; then
    info "TPM and tmux plugins are installed."
else
    warning "TPM setup completed with warnings; inspect the output above."
fi
exit 0
