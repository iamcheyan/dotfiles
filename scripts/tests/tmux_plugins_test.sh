#!/usr/bin/env bash
# Exercise the installer with a real isolated tmux server and local TPM fixtures.
set -euo pipefail
root=$(cd "$(dirname "$0")/../.." && pwd)
command -v tmux >/dev/null || { echo 'SKIP: tmux unavailable'; exit 0; }
fixture=$(mktemp -d)
socket="tpm-test-$$"
real_tmux=$(command -v tmux)
trap '"$real_tmux" -L "$socket" kill-server 2>/dev/null || true; rm -rf "$fixture"' EXIT
mkdir -p "$fixture/bin" "$fixture/user/.config/tmux" "$fixture/plugin" "$fixture/tpm/bin"
# Fake only the network TPM checkout; verify the server environment at both calls.
for action in install update; do
 cat > "$fixture/tpm/bin/${action}_plugins" <<'SCRIPT'
#!/usr/bin/env bash
set -eu
tmux show-environment -g TMUX_PLUGIN_MANAGER_PATH | grep -F "=$HOME/.config/tmux/plugins/"
printf '%s %s\n' "${0##*/}" "$*" >> "$HOME/calls"
SCRIPT
 chmod +x "$fixture/tpm/bin/${action}_plugins"
done
cat > "$fixture/bin/git" <<SCRIPT
#!/usr/bin/env bash
if [ "\${1:-}" = clone ]; then
 echo clone >> "$fixture/clones"
 mkdir -p "\${@: -1}/.git"
 cp -R "$fixture/tpm/bin" "\${@: -1}/"
 exit 0
fi
exec "$(command -v git)" "\$@"
SCRIPT
cat > "$fixture/bin/tmux" <<SCRIPT
#!/usr/bin/env bash
exec "$real_tmux" -L "$socket" -f /dev/null "\$@"
SCRIPT
chmod +x "$fixture/bin/"*
export HOME="$fixture/user" PATH="$fixture/bin:$PATH"
unset TMUX TMUX_PLUGIN_MANAGER_PATH XDG_CONFIG_HOME
printf 'set -g @plugin "example/plugin"\n' > "$HOME/.config/tmux/tmux.conf"
bash "$root/scripts/install/install_tmux_plugins.sh"
bash "$root/scripts/install/install_tmux_plugins.sh"
test "$(wc -l < "$fixture/clones")" -eq 1
test "$(grep -c '^install_plugins ' "$HOME/calls")" -eq 2
test "$(grep -c '^update_plugins all$' "$HOME/calls")" -eq 2
! tmux has-session 2>/dev/null
# Existing user sessions must survive repeated initialization.
tmux new-session -d -s keep
bash "$root/scripts/install/install_tmux_plugins.sh"
tmux has-session -t keep
printf 'PASS: cold start, repeat installation, updates, and existing session preservation\n'
