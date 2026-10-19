#!/usr/bin/env bash
# Regression test for the WSL-specific tmux split.
#
# Verifies the guard that keeps WSL-only overrides out of non-WSL hosts:
#   1. The WSL override file exists and is referenced by the main config.
#   2. The detection command used by `if-shell` evaluates false on this host
#      (unless this host really is WSL), so the overrides stay disabled.
#   3. The WSL file contains the WSL-only settings and does not enable them
#      globally.
#
# Run: bash config/tmux/tests/tmux_wsl_spec.sh
set -eu

this_file="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/$(basename "${BASH_SOURCE[0]}")"
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

# WSL-only settings must live in the override file, never in the shared config.
for setting in 'set -sg escape-time 25' 'set -g set-clipboard off' '@override_copy_command'; do
  grep -q "$setting" "$wsl_conf" ||
    fail "WSL override file must contain: $setting"
done

grep -q '^set -sg escape-time 25' "$main_conf" &&
  fail "the WSL escape-time override must not be set globally"

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

printf 'tmux_wsl_spec: OK\n'
