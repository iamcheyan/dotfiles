#!/usr/bin/env bash
# Run on a Proxmox VE host, not in the guest.
set -euo pipefail

usage() {
    printf '%s\n' 'Usage: bash init-checkpoint.sh {save|restore} VMID LABEL [--apply]' \
        'VM must already be stopped. Without --apply this command only previews.' \
        'Restore discards ALL guest disk changes since the checkpoint, not just init changes.'
}
fail() { printf '%s\n' "$*" >&2; exit 1; }

if [[ ${1:-} == --help ]]; then usage; exit 0; fi
if (( $# < 3 || $# > 4 )); then usage >&2; exit 2; fi
action=$1 vmid=$2 label=$3 apply=${4:-}
[[ $action == save || $action == restore ]] || fail 'Expected save or restore.'
[[ $vmid =~ ^[1-9][0-9]{2,8}$ ]] || fail 'Invalid VMID.'
[[ $label =~ ^[a-zA-Z0-9][a-zA-Z0-9_-]{0,23}$ ]] || fail 'Invalid checkpoint label.'
[[ $# == 3 || $apply == --apply ]] || fail 'Unknown option.'
command -v qm >/dev/null || fail 'Run on the Proxmox VE host with access to qm.'
snapshot="dfinit-$label"
status=$(qm status "$vmid")
[[ $status == 'status: stopped' ]] || fail 'Stop the intended VM before saving or restoring.'

case $action in
    save)
        operation=(snapshot "$vmid" "$snapshot" --vmstate 0 --description 'dotfiles-init-baseline')
        ;;
    restore)
        config=$(qm config "$vmid" --snapshot "$snapshot") || fail 'Checkpoint not found; nothing restored.'
        grep -Fxq 'description: dotfiles-init-baseline' <<< "$config" ||
            fail 'Snapshot does not have the expected pre-init marker; nothing restored.'
        operation=(rollback "$vmid" "$snapshot")
        ;;
esac
printf 'VM %s (%s): qm' "$vmid" "$status"
printf ' %q' "${operation[@]}"
printf '\n'
if [[ $apply != --apply ]]; then
    printf '%s\n' 'Preview only. Add --apply to execute.'
    exit 0
fi
qm "${operation[@]}"
if [[ $action == save ]]; then
    qm config "$vmid" --snapshot "$snapshot" >/dev/null
    printf 'Checkpoint verified: %s\n' "$snapshot"
else
    qm status "$vmid"
    printf '%s\n' 'Rollback finished. Boot the guest separately and verify its services and files.'
fi
