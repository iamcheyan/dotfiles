#!/bin/bash

set -euo pipefail

repo_dir="${1:?repo_dir is required}"
branch="${2:?branch is required}"
remote_name="${3:-origin}"

origin_url="$(git -C "$repo_dir" remote get-url "$remote_name")"

push_output=""

run_push() {
  local target="$1"
  local branch_ref="$2"
  local upstream_flag="${3:-}"

  if [ -n "$upstream_flag" ]; then
    if push_output="$(git -C "$repo_dir" push "$upstream_flag" "$target" "$branch_ref" 2>&1)"; then
      [ -n "$push_output" ] && printf '%s\n' "$push_output"
      return 0
    fi
  else
    if push_output="$(git -C "$repo_dir" push "$target" "$branch_ref" 2>&1)"; then
      [ -n "$push_output" ] && printf '%s\n' "$push_output"
      return 0
    fi
  fi

  printf '%s\n' "$push_output" >&2
  return 1
}

extract_owner_and_path() {
  local url="$1"

  case "$url" in
    https://github.com/*)
      local path="${url#https://github.com/}"
      local owner="${path%%/*}"
      printf '%s\n%s\n' "$owner" "$path"
      ;;
    http://github.com/*)
      local path="${url#http://github.com/}"
      local owner="${path%%/*}"
      printf '%s\n%s\n' "$owner" "$path"
      ;;
    git@github.com:*)
      local path="${url#git@github.com:}"
      local owner="${path%%/*}"
      printf '%s\n%s\n' "$owner" "$path"
      ;;
    *)
      return 1
      ;;
  esac
}

if run_push "$remote_name" "$branch" "-u"; then
  exit 0
fi

primary_error="$push_output"

case "$primary_error" in
  *"Permission to"*|*"The requested URL returned error: 403"*|*"HTTP code = 403"*)
    ;;
  *)
    exit 1
    ;;
esac

mapfile -t remote_parts < <(extract_owner_and_path "$origin_url") || {
  echo "Error: cannot build PAT fallback URL from remote: $origin_url" >&2
  exit 1
}

owner="${remote_parts[0]}"
repo_path="${remote_parts[1]}"
fallback_url="https://${owner}@github.com/${repo_path}"

echo "Push via origin failed with GitHub 403. Retrying with PAT credentials for ${owner}..." >&2

if run_push "$fallback_url" "${branch}:${branch}"; then
  git -C "$repo_dir" branch --set-upstream-to "${remote_name}/${branch}" "$branch" >/dev/null 2>&1 || true
  exit 0
fi

exit 1
