#!/bin/bash
# Push dotfiles repository.

set -euo pipefail

DOTFILES_DIR="$HOME/dotfiles"
USER_COMMIT_MESSAGE="${*:-}"

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
    local commit_message="$3"
    local branch

    ensure_git_repo "$repo_dir"

    if ! has_changes "$repo_dir"; then
        echo "[$repo_name] No changes to commit"
        return 0
    fi

    echo "[$repo_name] Staging changes..."
    stage_changes "$repo_dir"

    echo "[$repo_name] Committing..."
    git -C "$repo_dir" commit -m "$commit_message"

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

trim_text() {
    local text="$*"
    text="${text#"${text%%[![:space:]]*}"}"
    text="${text%"${text##*[![:space:]]}"}"
    printf '%s' "$text"
}

classify_scope() {
    local path="$1"

    case "$path" in
        config/zellij/*|plugins/zellij/*)
            echo "zellij"
            ;;
        config/nvim/*|plugins/nvim/*)
            echo "nvim"
            ;;
        aliases.conf|aliases/*)
            echo "shell aliases"
            ;;
        documents/*|doc/*|*.md|*.adoc|*.txt)
            echo "docs"
            ;;
        scripts/*)
            echo "scripts"
            ;;
        tools/*)
            echo "tools"
            ;;
        config/*)
            echo "$(echo "$path" | cut -d/ -f2)"
            ;;
        plugins/*)
            echo "$(echo "$path" | cut -d/ -f2)"
            ;;
        *)
            basename "$path" | sed 's/\.[^.]*$//'
            ;;
    esac
}

detect_commit_prefix() {
    local path

    if [ "$#" -eq 0 ]; then
        echo "chore"
        return
    fi

    for path in "$@"; do
        case "$path" in
            documents/*|doc/*|*.md|*.adoc|*.txt)
                ;;
            *)
                echo "chore"
                return
                ;;
        esac
    done

    echo "docs"
}

join_scopes() {
    local count="$#"

    if [ "$count" -eq 0 ]; then
        return
    fi

    if [ "$count" -eq 1 ]; then
        printf '%s' "$1"
        return
    fi

    if [ "$count" -eq 2 ]; then
        printf '%s and %s' "$1" "$2"
        return
    fi

    printf '%s, %s, and %s' "$1" "$2" "$3"
}

build_auto_commit_message() {
    local repo_dir="$1"
    local path scope prefix
    local -a staged_paths=()
    local -a unique_scopes=()

    while IFS= read -r path; do
        [ -n "$path" ] && staged_paths+=("$path")
    done < <(git -C "$repo_dir" diff --cached --name-only)

    if [ "${#staged_paths[@]}" -eq 0 ]; then
        echo "chore: sync dotfiles"
        return
    fi

    prefix=$(detect_commit_prefix "${staged_paths[@]}")

    for path in "${staged_paths[@]}"; do
        scope=$(classify_scope "$path")
        [ -z "$scope" ] && continue

        case " ${unique_scopes[*]} " in
            *" $scope "*)
                ;;
            *)
                unique_scopes+=("$scope")
                ;;
        esac

        [ "${#unique_scopes[@]}" -ge 3 ] && break
    done

    if [ "${#unique_scopes[@]}" -eq 0 ]; then
        echo "${prefix}: update dotfiles"
        return
    fi

    echo "${prefix}: update $(join_scopes "${unique_scopes[@]}")"
}

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Push dotfiles"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [ -n "$USER_COMMIT_MESSAGE" ]; then
    COMMIT_MESSAGE="$(trim_text "$USER_COMMIT_MESSAGE")"
else
    stage_changes "$DOTFILES_DIR"
    COMMIT_MESSAGE="$(build_auto_commit_message "$DOTFILES_DIR")"
fi

echo "Commit message: $COMMIT_MESSAGE"
echo ""

push_repo "$DOTFILES_DIR" "dotfiles" "$COMMIT_MESSAGE"
echo ""
echo "Done"
