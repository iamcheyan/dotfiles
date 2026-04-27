_wdiff_dir="${XDG_STATE_HOME:-$HOME/.local/state}/wdiff"
_wdiff_index="$_wdiff_dir/index.tsv"

_wdiff_init() {
    mkdir -p "$_wdiff_dir"
    [[ -f "$_wdiff_index" ]] || : > "$_wdiff_index"
}

_wdiff_now() {
    date "+%Y-%m-%d %H:%M:%S"
}

_wdiff_next_id() {
    _wdiff_init
    if [[ ! -s "$_wdiff_index" ]]; then
        echo 1
        return
    fi

    local last_id
    last_id=$(tail -n 1 "$_wdiff_index" | cut -f1)
    if [[ "$last_id" =~ ^[0-9]+$ ]]; then
        echo $((last_id + 1))
    else
        echo 1
    fi
}

_wdiff_add_record() {
    local id="$1"
    local kind="$2"
    local left="$3"
    local right="$4"
    local note="$5"

    _wdiff_init
    printf "%s\t%s\t%s\t%s\t%s\t%s\n" "$id" "$(_wdiff_now)" "$kind" "$left" "$right" "$note" >> "$_wdiff_index"
}

_wdiff_open() {
    local left="$1"
    local right="$2"
    local neutral_cwd="${TMPDIR:-/tmp}"
    (
        builtin cd "$neutral_cwd" || return 1
        WDIFF_NVIM=1 command nvim \
            -c 'set showtabline=0' \
            -d "$left" "$right"
    )
}

_wdiff_trim() {
    local text="$1"
    local limit="${2:-32}"
    text="${text//$'\n'/ }"
    text="${text//$'\t'/ }"
    text="${text## }"
    text="${text%% }"

    if (( ${#text} > limit )); then
        echo "${text[1,limit]}..."
    else
        echo "$text"
    fi
}

_wdiff_summary_for() {
    local kind="$1"
    local path="$2"

    if [[ "$kind" == "path" ]]; then
        echo "${path:t}"
        return
    fi

    if [[ -f "$path" ]]; then
        local first_line
        while IFS= read -r first_line; do
            [[ -n "$first_line" ]] && break
        done < "$path"
        if [[ -n "$first_line" ]]; then
            _wdiff_trim "$first_line" 28
        else
            echo "<empty>"
        fi
        return
    fi

    echo "${path:t}"
}

_wdiff_format_record() {
    local line="$1"
    local id ts kind left right note
    IFS=$'\t' read -r id ts kind left right note <<< "$line"

    local left_summary right_summary
    left_summary=$(_wdiff_summary_for "$kind" "$left")
    right_summary=$(_wdiff_summary_for "$kind" "$right")

    printf "%-4s %-19s %-6s %-30s %-30s %s\n" \
        "$id" "$ts" "$kind" "$left_summary" "$right_summary" "$note"
}

_wdiff_from_paths() {
    local left="$1"
    local right="$2"

    if [[ ! -e "$left" ]]; then
        echo "wdiff: left path not found: $left" >&2
        return 1
    fi
    if [[ ! -e "$right" ]]; then
        echo "wdiff: right path not found: $right" >&2
        return 1
    fi

    local id
    id=$(_wdiff_next_id)
    _wdiff_add_record "$id" "path" "$(realpath "$left" 2>/dev/null || echo "$left")" "$(realpath "$right" 2>/dev/null || echo "$right")" "path diff"
    _wdiff_open "$left" "$right"
}

_wdiff_from_stdin() {
    _wdiff_init

    local id left_file right_file
    id=$(_wdiff_next_id)
    left_file="$_wdiff_dir/${id}.left.txt"
    right_file="$_wdiff_dir/${id}.right.txt"

    echo "=== LEFT (Ctrl-D to finish) ==="
    cat > "$left_file"
    echo "=== RIGHT (Ctrl-D to finish) ==="
    cat > "$right_file"

    _wdiff_add_record "$id" "stdin" "$left_file" "$right_file" "pasted text"
    _wdiff_open "$left_file" "$right_file"
}

_wdiff_print_list() {
    _wdiff_init
    if [[ ! -s "$_wdiff_index" ]]; then
        echo "No wdiff history."
        return 0
    fi

    printf "%-4s %-19s %-6s %-30s %-30s %s\n" "ID" "TIME" "TYPE" "LEFT" "RIGHT" "NOTE"
    tail -n 30 "$_wdiff_index" | while IFS= read -r line; do
        _wdiff_format_record "$line"
    done
}

_wdiff_reopen_id() {
    local wanted_id="$1"
    _wdiff_init

    local line
    line=$(awk -F '\t' -v id="$wanted_id" '$1 == id { print $0 }' "$_wdiff_index" | tail -n 1)
    if [[ -z "$line" ]]; then
        echo "wdiff: history id not found: $wanted_id" >&2
        return 1
    fi

    local id ts kind left right note
    IFS=$'\t' read -r id ts kind left right note <<< "$line"

    if [[ ! -e "$left" ]]; then
        echo "wdiff: left source missing: $left" >&2
        return 1
    fi
    if [[ ! -e "$right" ]]; then
        echo "wdiff: right source missing: $right" >&2
        return 1
    fi

    _wdiff_open "$left" "$right"
}

_wdiff_list() {
    _wdiff_init

    if [[ -n "$1" ]]; then
        _wdiff_reopen_id "$1"
        return
    fi

    if [[ ! -s "$_wdiff_index" ]]; then
        echo "No wdiff history."
        return 0
    fi

    if [[ -t 0 && -t 1 ]] && command -v fzf >/dev/null 2>&1; then
        local picked
        picked=$(
            tac "$_wdiff_index" | while IFS= read -r line; do
                _wdiff_format_record "$line"
            done | fzf --prompt="wdiff history > " --height=40% --reverse --preview='' --preview-window=hidden --header="ID   TIME                TYPE   LEFT                           RIGHT                          NOTE"
        )
        [[ -z "$picked" ]] && return 0
        _wdiff_reopen_id "${picked%% *}"
        return
    fi

    _wdiff_print_list
}

wdiff() {
    if [[ "$1" == "reload" ]]; then
        source "${(%):-%N}"
        return
    fi

    if [[ "$1" == "list" || "$1" == "ls" ]]; then
        shift
        _wdiff_list "$@"
        return
    fi

    if [[ $# -eq 1 && "$1" =~ ^[0-9]+$ ]]; then
        _wdiff_reopen_id "$1"
        return
    fi

    if [[ $# -eq 2 ]]; then
        _wdiff_from_paths "$1" "$2"
        return
    fi

    if [[ $# -eq 0 ]]; then
        _wdiff_from_stdin
        return
    fi

    echo "Usage: wdiff [list|ls [id] | reload | <left> <right>]" >&2
    return 1
}

widff() {
    wdiff "$@"
}
