#!/usr/bin/env bash
set -u

# Compatibility wrapper: keep the grep CLI while using rg for safe common cases.
# Unsupported options and directory semantics fall back to the system grep.

GREP_BIN="$(command -v grep || true)"
if [[ -z "$GREP_BIN" ]]; then
  printf '%s\n' 'grep wrapper: system grep is not available' >&2
  exit 127
fi

if ! command -v rg >/dev/null 2>&1; then
  exec "$GREP_BIN" "$@"
fi

rg_args=()
patterns=()
files=()
recursive=0
end_options=0
saw_pattern=0
fallback=0
index=1
argc=$#

while (( index <= argc )); do
  arg="${!index}"
  if (( end_options )); then
    if (( saw_pattern )); then files+=("$arg"); else patterns+=("$arg"); saw_pattern=1; fi
    (( index++ )); continue
  fi
  case "$arg" in
    --)
      end_options=1
      ;;
    -r)
      recursive=1
      ;;
    -R)
      # Symlink traversal differs between BSD/GNU grep and rg; preserve the
      # host grep semantics instead of guessing.
      fallback=1
      ;;
    -E|-G|-F|-i|-I|-v|-w|-x|-n|-H|-h|-o|-c|-l|-L|-q|-s|-b|-a)
      case "$arg" in
        # grep BRE/ERE and rg Rust regex are not fully interchangeable.
        -E|-G) fallback=1 ;;
        -F) rg_args+=(--fixed-strings) ;;
        -I) ;; # rg already skips binary files by default.
        -i) rg_args+=(--ignore-case) ;;
        -v) rg_args+=(--invert-match) ;;
        -w) rg_args+=(--word-regexp) ;;
        -x) rg_args+=(--line-regexp) ;;
        -n) rg_args+=(--line-number) ;;
        -H) rg_args+=(--with-filename) ;;
        -h) rg_args+=(--no-filename) ;;
        -o) rg_args+=(--only-matching) ;;
        -c) rg_args+=(--count) ;;
        -l) rg_args+=(--files-with-matches) ;;
        -L) rg_args+=(--files-without-match) ;;
        -q) rg_args+=(--quiet) ;;
        -s) rg_args+=(--no-messages) ;;
        -b) rg_args+=(--byte-offset) ;;
        -a) rg_args+=(--text) ;;
      esac
      ;;
    -Z|--null) rg_args+=(--null) ;;
    --color=*) rg_args+=("$arg") ;;
    --include=*) rg_args+=(--glob "${arg#--include=}"); recursive=1 ;;
    --exclude=*) rg_args+=(--glob "!${arg#--exclude=}"); recursive=1 ;;
    --exclude-dir=*) rg_args+=(--glob "!${arg#--exclude-dir=}"'/**'); recursive=1 ;;
    -A|-B|-C|-m)
      if (( index >= argc )); then
        fallback=1
        break
      fi
      (( index++ ))
      [[ "${!index}" =~ ^[0-9]+$ ]] || fallback=1
      case "$arg" in
        -A) rg_args+=(--after-context "${!index}") ;;
        -B) rg_args+=(--before-context "${!index}") ;;
        -C) rg_args+=(--context "${!index}") ;;
        -m) rg_args+=(--max-count "${!index}") ;;
      esac
      ;;
    -e|--regexp)
      if (( index >= argc )); then
        fallback=1
        break
      fi
      (( index++ ))
      patterns+=("${!index}")
      ;;
    -P|--perl-regexp|-D|--devices=*|-d|--directories=*|--binary-files=*|--label|--file|--exclude-from)
      fallback=1
      ;;
    -[A-Za-z]* )
      # Handle common compact flags such as -rin and reject unknown ones.
      compact="${arg#-}"
      if [[ "$compact" =~ ^[rRinvswhoqlLHFebxacEGI]+$ ]]; then
        for (( char=0; char<${#compact}; char++ )); do
          flag="-${compact:char:1}"
          case "$flag" in
            -r) recursive=1 ;;
            -R) fallback=1 ;;
            -E|-G) fallback=1 ;;
            -F) rg_args+=(--fixed-strings) ;;
            -I) ;;
            -i) rg_args+=(--ignore-case) ;;
            -v) rg_args+=(--invert-match) ;;
            -w) rg_args+=(--word-regexp) ;;
            -x) rg_args+=(--line-regexp) ;;
            -n) rg_args+=(--line-number) ;;
            -H) rg_args+=(--with-filename) ;;
            -h) rg_args+=(--no-filename) ;;
            -o) rg_args+=(--only-matching) ;;
            -q) rg_args+=(--quiet) ;;
            -l) rg_args+=(--files-with-matches) ;;
            -L) rg_args+=(--files-without-match) ;;
            -c) rg_args+=(--count) ;;
            -s) rg_args+=(--no-messages) ;;
            -b) rg_args+=(--byte-offset) ;;
            -a) rg_args+=(--text) ;;
            *) fallback=1 ;;
          esac
        done
      else
        fallback=1
      fi
      ;;
    -*) fallback=1 ;;
    *)
      if (( saw_pattern )); then files+=("$arg"); else patterns+=("$arg"); saw_pattern=1; fi
      ;;
  esac
  (( index++ ))
done

if (( ${#patterns[@]} == 0 )); then
  fallback=1
fi

# grep without -r rejects directories; rg would recurse, so preserve that behavior.
if (( ! recursive )); then
  for file in "${files[@]}"; do
    [[ -d "$file" ]] && fallback=1
  done
fi

if (( fallback )); then
  exec "$GREP_BIN" "$@"
fi

if (( recursive )); then
  rg_args+=(--hidden --no-ignore)
fi
for pattern in "${patterns[@]}"; do
  rg_args+=(--regexp "$pattern")
done
rg_args+=("${files[@]}")
exec rg "${rg_args[@]}"
