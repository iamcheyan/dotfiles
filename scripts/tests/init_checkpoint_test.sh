#!/usr/bin/env bash
set -euo pipefail
script=$(cd -- "$(dirname -- "$0")/.." && pwd)/init-checkpoint.sh
sandbox=$(mktemp -d)
trap 'rm -rf -- "$sandbox"' EXIT
export CHECKPOINT_LOG="$sandbox/log" CHECKPOINT_STATE="$sandbox/state" VM_STATUS=stopped
export PATH="$sandbox:$PATH"

printf '%s\n' '#!/usr/bin/env bash' 'set -eu' \
  'case "$1" in' \
  '  status) printf "status: %s\n" "$VM_STATUS" ;;' \
  '  config) test "$2 $3 $4" = "123 --snapshot dfinit-before"; cat "$CHECKPOINT_STATE" ;;' \
  '  snapshot) test "$*" = "snapshot 123 dfinit-before --vmstate 0 --description dotfiles-init-baseline"; printf "%s\n" "description: dotfiles-init-baseline" > "$CHECKPOINT_STATE"; printf "%s\n" "$1" >> "$CHECKPOINT_LOG" ;;' \
  '  rollback) test "$*" = "rollback 123 dfinit-before"; printf "%s\n" "$1" >> "$CHECKPOINT_LOG" ;;' \
  '  *) exit 99 ;;' 'esac' > "$sandbox/qm"
chmod +x "$sandbox/qm"

reject() {
    if bash "$script" "$@" > /dev/null 2>&1; then
        printf 'Unexpected success: %s\n' "$*" >&2
        exit 1
    fi
}

bash "$script" save 123 before
reject restore 123 before --apply
reject save 123 'bad label' --apply
VM_STATUS=running reject save 123 before --apply
test ! -e "$CHECKPOINT_LOG"
bash "$script" save 123 before --apply
bash "$script" restore 123 before
VM_STATUS=running reject restore 123 before --apply
test "$(<"$CHECKPOINT_LOG")" = snapshot
bash "$script" restore 123 before --apply
test "$(<"$CHECKPOINT_LOG")" = $'snapshot\nrollback'
printf '%s\n' 'description: unrelated snapshot' > "$CHECKPOINT_STATE"
reject restore 123 before --apply
test "$(<"$CHECKPOINT_LOG")" = $'snapshot\nrollback'
printf '%s\n' 'PASS: previews, save/restore arguments, invalid inputs, running VM and unrelated snapshot guards'
