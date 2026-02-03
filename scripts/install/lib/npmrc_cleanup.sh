#!/bin/bash
# Detect and remove npm settings that conflict with nvm-managed globals.

# shellcheck shell=bash

cleanup_npmrc_conflicts() {
    local npmrc="$HOME/.npmrc"

    if [ ! -f "$npmrc" ]; then
        return 0
    fi

    if ! grep -Eq '^\s*(prefix|globalconfig)\s*=' "$npmrc"; then
        return 0
    fi

    # Ensure color variables have defaults in case the caller did not define them.
    local yellow="${YELLOW:-\033[0;33m}"
    local nc="${NC:-\033[0m}"

    local backup="${npmrc}.codex.bak.$(date +%s)"
    cp "$npmrc" "$backup"

    local tmp_file
    tmp_file="$(mktemp)"
    grep -Ev '^\s*(prefix|globalconfig)\s*=' "$npmrc" >"$tmp_file"
    mv "$tmp_file" "$npmrc"

    echo -e "${yellow}Detected custom npm prefix/globalconfig entries in ~/.npmrc.${nc}"
    echo -e "${yellow}Backed up the original file to ${backup} and removed the conflicting lines so Codex can install correctly.${nc}"
    echo -e "${yellow}If you prefer to manage these settings yourself, restore the backup and adjust PATH manually before rerunning install:codex.${nc}"
}
