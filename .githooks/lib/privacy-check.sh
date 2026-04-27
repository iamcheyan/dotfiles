#!/usr/bin/env bash

set -euo pipefail

ZERO_SHA="0000000000000000000000000000000000000000"
HOOK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
REPO_ROOT="$(git rev-parse --show-toplevel)"
USER_HOME="${HOME:-$(getent passwd "$(id -un)" | cut -d: -f6 2>/dev/null || pwd)}"
DOTFILES_DIR="${DOTFILES_DIR:-$REPO_ROOT}"
WIN_HOME_DEFAULT="/mnt/c/Users/${USER:-$(id -un)}"
WIN_HOME="${WIN_HOME:-$WIN_HOME_DEFAULT}"
RIME_DIR="${RIME_DIR:-$WIN_HOME/AppData/Roaming/Rime}"
WIN_HOME_BASENAME="$(basename "$WIN_HOME")"
RIME_SUFFIX="${RIME_DIR#"$WIN_HOME"/}"

regex_escape() {
  printf '%s' "$1" | sed 's/[][(){}.^$+*?|\\/]/\\&/g'
}

HOME_RE="$(regex_escape "$USER_HOME")"
DOTFILES_RE="$(regex_escape "$DOTFILES_DIR")"
WIN_HOME_RE="$(regex_escape "$WIN_HOME")"
RIME_RE="$(regex_escape "$RIME_DIR")"
RIME_SUFFIX_RE="$(regex_escape "$RIME_SUFFIX")"
WIN_HOME_WIN_RE="$(printf '%s' "$WIN_HOME_BASENAME" | sed 's/[][(){}.^$+*?|\\/]/\\&/g')"
export USER_HOME DOTFILES_DIR WIN_HOME RIME_DIR WIN_HOME_BASENAME RIME_SUFFIX

SECRET_REGEX='(AKIA[0-9A-Z]{16}|ASIA[0-9A-Z]{16}|ghp_[A-Za-z0-9]{20,}|github_pat_[A-Za-z0-9_]{20,}|sk-[A-Za-z0-9]{20,}|BEGIN (RSA|OPENSSH|EC|DSA) PRIVATE KEY|aws_access_key_id|aws_secret_access_key|authorization:[[:space:]]*Bearer[[:space:]]+[A-Za-z0-9._=-]+|token=[A-Za-z0-9._=-]+|client_secret[[:space:]:=]+[^[:space:]]+|password[[:space:]:=]+[^[:space:]]+|passwd[[:space:]:=]+[^[:space:]]+)'
PRIVACY_REGEX="([A-Za-z0-9._%+-]+@(outlook\\.com|gmail\\.com|hotmail\\.com|qq\\.com|icloud\\.com|yahoo\\.com|sbilife\\.co\\.jp)|([0-9]{1,3}\\.){3}[0-9]{1,3}|${DOTFILES_RE}|${HOME_RE}|${RIME_RE}|${WIN_HOME_RE}|${RIME_SUFFIX_RE}|\\\\Users\\\\${WIN_HOME_WIN_RE})"
SAFE_EMAIL_REGEX='(@users[.]noreply[.]github[.]com|@example[.]com|@outlook[.]com)$'

privacy_tmpdir=

privacy_init_tmpdir() {
  privacy_tmpdir="$(mktemp -d)"
  trap 'rm -rf "$privacy_tmpdir"' EXIT
}

privacy_filter_hits() {
  local input_file="$1"
  local output_file="$2"

  awk '
    BEGIN {
      comment_regex = "^[[:space:]]*(#|//|;|--|/\\*|\\*)"
      doc_path_regex = "\\.(md|markdown|mdx|adoc|txt)$"
      example_secret_regex = "(Authorization:\"Bearer (TOKEN|\\$TOKEN)\"|http -a username:password GET https://httpbin\\.org/basic-auth/username/password)"
    }
    {
      if (match($0, /^[^:]+:([^:]+):[0-9]+:(.*)$/, m)) {
        path = m[1]
        line = m[2]
      } else if (match($0, /^([^:]+):[0-9]+:(.*)$/, m)) {
        path = m[1]
        line = m[2]
      } else {
        next
      }

      if (path == ".githooks/pre-push") next
      if (path == ".githooks/pre-commit") next
      if (path == ".githooks/lib/privacy-check.sh") next
      if (path == "git.md" && line ~ /(\/home\/[^[:space:]]+\/\.dotfiles|\\\$HOME\/\.dotfiles)/) next
      if (path == "doc/git.md" && line ~ /(\/home\/[^[:space:]]+\/\.dotfiles|\\\$HOME\/\.dotfiles)/) next
      if (line ~ comment_regex) next
      if (path ~ doc_path_regex && line ~ example_secret_regex) next
      if (line ~ /127[.]0[.]0[.]1/) next
      if (line ~ /0[.]0[.]0[.]0/) next
      if (path ~ "^scripts/system/initialization\\.sh$" && line ~ /wps-office/) next
      print
    }
  ' "$input_file" > "$output_file"
}

privacy_build_path_hints() {
  local input_file="$1"
  local output_file="$2"

  awk '
    BEGIN {
      dotfiles = ENVIRON["DOTFILES_DIR"]
      home = ENVIRON["USER_HOME"]
      win_home = ENVIRON["WIN_HOME"]
      rime_dir = ENVIRON["RIME_DIR"]
      win_home_basename = ENVIRON["WIN_HOME_BASENAME"]
    }
    {
      if (match($0, /^[^:]+:([^:]+):[0-9]+:(.*)$/, m)) {
        path = m[1]
        line = m[2]
      } else if (match($0, /^([^:]+):[0-9]+:(.*)$/, m)) {
        path = m[1]
        line = m[2]
      } else {
        next
      }

      if (dotfiles != "" && index(line, dotfiles)) {
        print path ": replace hardcoded dotfiles path with ${DOTFILES_DIR:-$HOME/.dotfiles}"
      }
      if (home != "" && index(line, home)) {
        print path ": replace hardcoded home path with $HOME"
      }
      if (rime_dir != "" && index(line, rime_dir)) {
        print path ": replace hardcoded Rime path with ${RIME_DIR}"
      }
      if (win_home != "" && index(line, win_home)) {
        print path ": replace hardcoded Windows home path with ${WIN_HOME}"
      }
      if (ENVIRON["RIME_SUFFIX"] != "" && index(line, ENVIRON["RIME_SUFFIX"])) {
        print path ": replace AppData/Roaming/Rime with ${RIME_DIR}"
      }
      if (win_home_basename != "" && line ~ ("\\\\Users\\\\" win_home_basename)) {
        print path ": replace \\\\Users\\\\" win_home_basename " with ${WIN_HOME_WIN}"
      }
    }
  ' "$input_file" | sort -u > "$output_file"
}

privacy_check_identities() {
  local output_file="$1"

  {
    git var GIT_AUTHOR_IDENT 2>/dev/null || true
    git var GIT_COMMITTER_IDENT 2>/dev/null || true
  } | awk -v safe_email_regex="$SAFE_EMAIL_REGEX" '
    match($0, /^(.*) <([^>]+)> /, m) {
      if (m[2] !~ safe_email_regex) {
        print m[1] "\t" m[2]
      }
    }
  ' | sort -u > "$output_file"
}

privacy_report_and_exit() {
  local mode="$1"
  local metadata_hits="$2"
  local content_hits="$3"
  local path_hints="$4"

  if [[ ! -s "$metadata_hits" && ! -s "$content_hits" ]]; then
    return 0
  fi

  echo "${mode}: blocked due to possible privacy/secrets." >&2
  echo >&2

  if [[ -s "$metadata_hits" ]]; then
    if [[ "$mode" == "pre-commit" ]]; then
      echo "Commit identity requiring review:" >&2
    else
      echo "Commit metadata requiring review:" >&2
    fi
    sed -n '1,40p' "$metadata_hits" >&2
    echo >&2
    echo "Allowed commit email regex: ${SAFE_EMAIL_REGEX}" >&2
    echo >&2
  fi

  if [[ -s "$content_hits" ]]; then
    echo "Content matches requiring review:" >&2
    sed -n '1,80p' "$content_hits" >&2
    echo >&2
  fi

  if [[ -s "$path_hints" ]]; then
    echo "Suggested environment-variable replacements for hardcoded paths:" >&2
    sed -n '1,40p' "$path_hints" >&2
    echo >&2
  fi

  if [[ "$mode" == "pre-commit" ]]; then
    echo "Fix the staged files before committing." >&2
    echo "If this is intentional, edit .githooks/pre-commit or .githooks/lib/privacy-check.sh instead of bypassing it." >&2
  else
    echo "Fix the matching commits/files before pushing." >&2
    echo "If this is intentional, edit .githooks/pre-push or .githooks/lib/privacy-check.sh instead of bypassing it." >&2
  fi
  exit 1
}

run_pre_commit_check() {
  privacy_init_tmpdir

  local metadata_hits="$privacy_tmpdir/metadata_hits.txt"
  local raw_content_hits="$privacy_tmpdir/content_hits_raw.txt"
  local content_hits="$privacy_tmpdir/content_hits.txt"
  local path_hints="$privacy_tmpdir/path_hints.txt"
  local -a staged_paths=()

  while IFS= read -r -d '' path; do
    staged_paths+=("$path")
  done < <(git diff --cached --name-only -z --diff-filter=ACMR)

  if [[ "${#staged_paths[@]}" -eq 0 ]]; then
    exit 0
  fi

  privacy_check_identities "$metadata_hits"
  git grep --cached -n -I -E "${SECRET_REGEX}|${PRIVACY_REGEX}" -- "${staged_paths[@]}" > "$raw_content_hits" || true
  privacy_filter_hits "$raw_content_hits" "$content_hits"
  privacy_build_path_hints "$content_hits" "$path_hints"
  privacy_report_and_exit "pre-commit" "$metadata_hits" "$content_hits" "$path_hints"
}

run_pre_push_check() {
  privacy_init_tmpdir

  local commits_file="$privacy_tmpdir/commits.txt"
  local metadata_hits="$privacy_tmpdir/metadata_hits.txt"
  local raw_content_hits="$privacy_tmpdir/content_hits_raw.txt"
  local content_hits="$privacy_tmpdir/content_hits.txt"
  local path_hints="$privacy_tmpdir/path_hints.txt"

  touch "$commits_file" "$metadata_hits" "$raw_content_hits" "$content_hits" "$path_hints"

  while read -r local_ref local_sha remote_ref remote_sha; do
    [[ -z "${local_ref:-}" ]] && continue
    [[ "$local_sha" == "$ZERO_SHA" ]] && continue

    if [[ "$remote_sha" == "$ZERO_SHA" ]]; then
      git rev-list "$local_sha" >> "$commits_file"
    else
      git rev-list "${remote_sha}..${local_sha}" >> "$commits_file"
    fi
  done

  sort -u "$commits_file" -o "$commits_file"

  if [[ ! -s "$commits_file" ]]; then
    exit 0
  fi

  while read -r commit; do
    git show -s --format='%H%x09%an%x09%ae%x09%cn%x09%ce%x09%s' "$commit"
  done < "$commits_file" | awk -F'\t' -v safe_email_regex="$SAFE_EMAIL_REGEX" '
    $3 !~ safe_email_regex || $5 !~ safe_email_regex {
      print
    }
  ' > "$metadata_hits" || true

  while read -r commit; do
    git grep -n -I -E "${SECRET_REGEX}|${PRIVACY_REGEX}" "$commit" -- || true
  done < "$commits_file" > "$raw_content_hits"

  privacy_filter_hits "$raw_content_hits" "$content_hits"
  privacy_build_path_hints "$content_hits" "$path_hints"
  privacy_report_and_exit "pre-push" "$metadata_hits" "$content_hits" "$path_hints"
}
