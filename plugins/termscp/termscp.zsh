unalias install:termscp 2>/dev/null || true
install:termscp() {
  bash "$HOME/dotfiles/plugins/termscp/install_termscp.sh" "$@"
}

typeset -g TERMSCP_LAB_HOST="${TERMSCP_LAB_HOST:-localhost}"
typeset -g TERMSCP_LAB_PORT="${TERMSCP_LAB_PORT:-2222}"
typeset -g TERMSCP_LAB_USER="${TERMSCP_LAB_USER:-student}"
typeset -g TERMSCP_LAB_REMOTE_DIR="${TERMSCP_LAB_REMOTE_DIR:-/home/student}"
typeset -g TERMSCP_LAB_PROTOCOL="${TERMSCP_LAB_PROTOCOL:-sftp}"

if ! command -v termscp >/dev/null 2>&1; then
  return 0
fi

alias tscp='termscp'

termscp-lab() {
  termscp "${TERMSCP_LAB_PROTOCOL}://${TERMSCP_LAB_USER}@${TERMSCP_LAB_HOST}:${TERMSCP_LAB_PORT}:${TERMSCP_LAB_REMOTE_DIR}" "$@"
}

termscp-lab-scp() {
  termscp "scp://${TERMSCP_LAB_USER}@${TERMSCP_LAB_HOST}:${TERMSCP_LAB_PORT}:${TERMSCP_LAB_REMOTE_DIR}" "$@"
}
