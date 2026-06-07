#!/usr/bin/env bash
set -euo pipefail

repo_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
cd "$repo_dir"

echo "[dotfiles] pulling $repo_dir"
git pull --ff-only

if [[ -f .gitmodules ]]; then
  echo "[dotfiles] updating configured submodules"
  git config --file .gitmodules --get-regexp '^submodule\..*\.path$' |
    while read -r _ path; do
      echo "[submodule] $path"
      git submodule sync -- "$path"
      git submodule update --init --recursive -- "$path"
    done
fi

echo "[dotfiles] done"
