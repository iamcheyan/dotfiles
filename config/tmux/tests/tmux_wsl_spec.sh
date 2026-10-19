#!/usr/bin/env bash
# Regression test for the WSL-specific tmux split.
#
# Guards the WSL + tmux + tmux-yank + clip.exe fix:
#   1. The WSL override file exists and is referenced by the main config.
#   2. The WSL file is loaded through an if-shell guard, not unconditionally,
#      and that guard runs before TPM initialization.
#   3. The WSL file must use win32yank.exe and must never reference clip.exe.
#   4. WSL-only settings must live in the override file, never globally.
#   5. When tmux is available, load the config in a simulated WSL environment
#      and assert escape-time=25 / set-clipboard=off /
#      @override_copy_command=win32yank.exe; assert the real (non-WSL) host
#      keeps escape-time=0 and no win32yank override.
#
# Run: bash config/tmux/tests/tmux_wsl_spec.sh
set -eu

tmux_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
main_conf="$tmux_root/tmux.conf"
wsl_conf="$tmux_root/tmux-wsl.conf"

fail() {
  printf 'FAIL: %s\n' "$1" >&2
  exit 1
}

[ -f "$main_conf" ] || fail "missing main tmux config: $main_conf"
[ -f "$wsl_conf" ] || fail "missing WSL override config: $wsl_conf"

grep -q 'tmux-wsl.conf' "$main_conf" ||
  fail "main config must conditionally source tmux-wsl.conf"

grep -q 'if-shell' "$main_conf" ||
  fail "tmux-wsl.conf must be loaded through an if-shell guard, not unconditionally"

# The override must be applied before TPM runs, otherwise tmux-yank never
# reads @override_copy_command.
wsl_line=$(grep -n 'tmux-wsl.conf' "$main_conf" | head -n 1 | cut -d: -f1)
tpm_line=$(grep -n 'plugins/tpm/tpm' "$main_conf" | head -n 1 | cut -d: -f1)
[ -n "$wsl_line" ] && [ -n "$tpm_line" ] ||
  fail "both the WSL guard and the TPM init line must exist in the main config"
[ "$wsl_line" -lt "$tpm_line" ] ||
  fail "the WSL guard must run before TPM init (line $wsl_line vs $tpm_line)"

# clip.exe must not be used as a copy command (comments explaining why are fine).
if grep -Ev '^[[:space:]]*#' "$wsl_conf" | grep -q 'clip\.exe'; then
  fail "WSL override must not use clip.exe as a copy command"
fi
grep -q "win32yank.exe -i --lf" "$wsl_conf" ||
  fail "WSL override must set win32yank.exe -i --lf as the tmux-yank copy command"

# WSL-only settings must live in the override file, never in the shared config.
for setting in 'set -sg escape-time 25' 'set -g set-clipboard off' '@override_copy_command'; do
  grep -q "$setting" "$wsl_conf" ||
    fail "WSL override file must contain: $setting"
done

grep -q '^set -sg escape-time 25' "$main_conf" &&
  fail "the WSL escape-time override must not be set globally"
grep -q '^set -g set-clipboard off' "$main_conf" &&
  fail "the WSL set-clipboard override must not be set globally"

# Detection must not claim WSL on a plain Linux/WSL-free host.
is_wsl=1
if grep -qiE 'microsoft|wsl' /proc/sys/kernel/osrelease 2>/dev/null; then
  is_wsl=0
elif [ -n "${WSL_DISTRO_NAME:-}" ]; then
  is_wsl=0
fi

if [ "$is_wsl" -eq 0 ]; then
  printf 'tmux_wsl_spec: SKIP (host reports WSL; run the non-WSL assertions elsewhere)\n'
  exit 0
fi

# Non-WSL host: the shared default must remain 0 (unchanged behaviour).
grep -q '^set -sg escape-time 0' "$main_conf" ||
  fail "non-WSL default escape-time must remain 0 in the shared config"

if ! command -v tmux >/dev/null 2>&1; then
  printf 'tmux_wsl_spec: OK (static only; tmux not installed)\n'
  exit 0
fi

# --- Runtime checks on a private socket, so no user session is touched ---
sock="tmux-wsl-spec-$$"
cleanup() { tmux -L "$sock" kill-server >/dev/null 2>&1 || true; }
trap cleanup EXIT

get_opt() { tmux -L "$sock" show -gv "$1" 2>/dev/null || true; }

# Non-WSL: overrides must stay off.
tmux -L "$sock" -f "$main_conf" new-session -d -s spec -x 120 -y 30 'sleep 20' >/dev/null 2>&1
sleep 1
host_escape="$(get_opt escape-time)"
host_clip="$(get_opt set-clipboard)"
host_override="$(get_opt @override_copy_command)"
cleanup
sleep 1

[ "$host_escape" = "0" ] ||
  fail "non-WSL host must keep escape-time 0, got '$host_escape'"
[ "$host_clip" = "external" ] ||
  fail "non-WSL host must keep set-clipboard external, got '$host_clip'"
case "$host_override" in
  *win32yank*) fail "non-WSL host must not set the win32yank override, got '$host_override'" ;;
esac

# Simulated WSL: the override file must be applied.
# Prefer a fake win32yank.exe on PATH so the primary branch is exercised;
# WSLg hosts without it fall back to wl-copy. clip.exe is never acceptable.
fake_bin="$(mktemp -d)"
cleanup() {
  tmux -L "$sock" kill-server >/dev/null 2>&1 || true
  rm -rf "$fake_bin"
}
printf '#!/bin/sh\ncat >/dev/null\n' > "$fake_bin/win32yank.exe"
chmod +x "$fake_bin/win32yank.exe"

env WSL_DISTRO_NAME=Ubuntu PATH="$fake_bin:$PATH" \
  tmux -L "$sock" -f "$main_conf" new-session -d -s spec -x 120 -y 30 'sleep 20' >/dev/null 2>&1
sleep 1
wsl_escape="$(get_opt escape-time)"
wsl_clip="$(get_opt set-clipboard)"
wsl_override="$(get_opt @override_copy_command)"
cleanup

[ "$wsl_escape" = "25" ] ||
  fail "simulated WSL must set escape-time 25, got '$wsl_escape'"
[ "$wsl_clip" = "off" ] ||
  fail "simulated WSL must set set-clipboard off, got '$wsl_clip'"
case "$wsl_override" in
  *clip.exe*) fail "WSL copy command must never be clip.exe, got '$wsl_override'" ;;
  *win32yank*|*wl-copy*) : ;;
  *) fail "simulated WSL must set a win32yank (or wl-copy) override, got '$wsl_override'" ;;
esac

printf 'tmux_wsl_spec: OK\n'
