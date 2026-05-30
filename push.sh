#!/usr/bin/env bash
# Usage: push
# Auto commit with timestamp and push both dotfiles and chezmoi repos.

set -euo pipefail

TS=$(date '+%m/%d %H:%M')

push_repo() {
  local dir="$1"
  local name=$(basename "$dir")
  echo "── $name ──"
  cd "$dir"
  if ! git diff --quiet || ! git diff --cached --quiet; then
    git add -A
    git commit -m "$TS"
    echo "  committed"
  else
    echo "  nothing to commit"
  fi
  if ! git push 2>&1; then
    echo "  ⚠ push failed for $dir" >&2
  else
    echo "  pushed"
  fi
}

push_repo /Users/tetsuya/dotfiles
push_repo /Users/tetsuya/chezmoi
