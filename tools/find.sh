#!/usr/bin/env bash
set -u

# Compatibility wrapper: keep the find CLI while using fd for safe common cases.
# Complex expressions deliberately fall back to the system find implementation.

FIND_BIN="$(command -v find || true)"
if [[ -z "$FIND_BIN" ]]; then
  printf '%s\n' 'find wrapper: system find is not available' >&2
  exit 127
fi

if ! command -v fd >/dev/null 2>&1; then
  exec "$FIND_BIN" "$@"
fi

fd_args=(--hidden --no-ignore)
paths=()
name_pattern=""
use_name=0
has_predicate=0
saw_action=0
index=1
argc=$#

while (( index <= argc )); do
  arg="${!index}"
  case "$arg" in
    --)
      # A literal -- is uncommon in find expressions; preserve exact semantics.
      exec "$FIND_BIN" "$@"
      ;;
    -name|-iname)
      (( index++ )); (( index <= argc )) || exec "$FIND_BIN" "$@"
      if (( use_name )); then exec "$FIND_BIN" "$@"; fi
      name_pattern="${!index}"
      use_name=1
      [[ "$arg" == -iname ]] && fd_args+=(--ignore-case)
      has_predicate=1
      ;;
    -type)
      (( index++ )); (( index <= argc )) || exec "$FIND_BIN" "$@"
      case "${!index}" in
        f) fd_args+=(--type f) ;;
        d) fd_args+=(--type d) ;;
        l) fd_args+=(--type l) ;;
        b) fd_args+=(--type b) ;;
        c) fd_args+=(--type c) ;;
        s) fd_args+=(--type s) ;;
        p) fd_args+=(--type p) ;;
        *) exec "$FIND_BIN" "$@" ;;
      esac
      has_predicate=1
      ;;
    -maxdepth|-mindepth)
      (( index++ )); (( index <= argc )) || exec "$FIND_BIN" "$@"
      [[ "${!index}" =~ ^[0-9]+$ ]] || exec "$FIND_BIN" "$@"
      if [[ "$arg" == -maxdepth ]]; then fd_args+=(--max-depth "${!index}"); else fd_args+=(--min-depth "${!index}"); fi
      has_predicate=1
      ;;
    -print) has_predicate=1 ;;
    -print0) fd_args+=(-0); has_predicate=1 ;;
    -H|-L|-P|-xdev|-mount|-depth|-d|-prune|-delete|-ls|-exec|-execdir|-ok|-okdir|-newer|-newermt|-mtime|-atime|-ctime|-size|-user|-group|-perm|-printf|-path|-ipath|-regex|-iregex|-readable|-writable|-executable|-empty|-links|-inum|-samefile|-uid|-gid|-fstype|-daystart|-follow|-ignore_readdir_race|-noignore_readdir_race)
      saw_action=1
      ;;
    -*)
      # Unknown options, boolean expressions, and actions need exact find semantics.
      saw_action=1
      ;;
    *)
      if (( has_predicate )); then
        # A bare token after predicates is not a path in normal find syntax.
        saw_action=1
      else
        paths+=("$arg")
      fi
      ;;
  esac
  (( index++ ))
done

(( saw_action == 0 )) || exec "$FIND_BIN" "$@"
((${#paths[@]} > 0)) || paths=(.)

fd_args+=(--glob)
if (( use_name )); then
  fd_args+=("$name_pattern")
else
  fd_args+=("*")
fi
fd_args+=("${paths[@]}")
exec fd "${fd_args[@]}"
