#!/bin/bash
# Push dotfiles repository.

set -euo pipefail

DOTFILES_DIR="$HOME/dotfiles"
TIMESTAMP="$(date '+%Y%m%d_%H%M%S')"

ensure_git_repo() {
    local repo_dir="$1"
    if ! git -C "$repo_dir" rev-parse --git-dir > /dev/null 2>&1; then
        echo "Error: not a Git repository: $repo_dir" >&2
        exit 1
    fi
}

has_changes() {
    local repo_dir="$1"
    shift
    if [ "$#" -gt 0 ]; then
        [ -n "$(git -C "$repo_dir" status --porcelain --untracked-files=all -- "$@")" ]
    else
        [ -n "$(git -C "$repo_dir" status --porcelain --untracked-files=all)" ]
    fi
}

stage_changes() {
    local repo_dir="$1"
    local scope="${2:-.}"

    # Stage tracked-file updates and deletions first.
    git -C "$repo_dir" add -u -- "$scope"

    # Then stage only untracked, non-ignored files.
    while IFS= read -r -d '' path; do
        git -C "$repo_dir" add -- "$path"
    done < <(git -C "$repo_dir" ls-files --others --exclude-standard -z -- "$scope")
}

push_repo() {
    local repo_dir="$1"
    local repo_name="$2"
    local branch

    ensure_git_repo "$repo_dir"

    if ! has_changes "$repo_dir"; then
        echo "[$repo_name] No changes to commit"
        return 0
    fi

    echo "[$repo_name] Staging changes..."
    stage_changes "$repo_dir"

    echo "[$repo_name] Committing..."
    git -C "$repo_dir" commit -m "$TIMESTAMP"

    branch="$(git -C "$repo_dir" branch --show-current 2>/dev/null || true)"
    if [ -z "$branch" ]; then
        branch="main"
    fi

    echo "[$repo_name] Pushing..."
    if ! git -C "$repo_dir" push -u origin "$branch"; then
        echo "Error: push failed: $repo_name" >&2
        exit 1
    fi
}

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Push dotfiles"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Commit message: $TIMESTAMP"
echo ""

push_repo "$DOTFILES_DIR" "dotfiles"
echo ""
echo "Done"
