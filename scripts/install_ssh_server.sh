#!/usr/bin/env bash

set -euo pipefail

if [[ "${EUID}" -ne 0 ]]; then
  echo "Please run this script with sudo or as root." >&2
  exit 1
fi

if [[ ! -f /etc/os-release ]]; then
  echo "Unsupported system: /etc/os-release not found." >&2
  exit 1
fi

# shellcheck disable=SC1091
source /etc/os-release

if [[ "${ID:-}" != "ubuntu" ]]; then
  echo "Warning: detected '${ID:-unknown}'. This script is intended for Ubuntu." >&2
fi

SSH_PORT="${SSH_PORT:-22}"
SSHD_CONFIG="/etc/ssh/sshd_config"
SUDO_USER_NAME="${SUDO_USER:-${USER:-root}}"
WSL_INTEROP_PRESENT="false"
SYSTEMD_PRESENT="false"

if [[ -n "${WSL_INTEROP:-}" ]] || grep -qi microsoft /proc/version 2>/dev/null; then
  WSL_INTEROP_PRESENT="true"
fi

if command -v systemctl >/dev/null 2>&1 && [[ -d /run/systemd/system ]]; then
  SYSTEMD_PRESENT="true"
fi

echo "==> Updating package index"
apt-get update

echo "==> Installing OpenSSH server"
DEBIAN_FRONTEND=noninteractive apt-get install -y openssh-server

echo "==> Ensuring runtime directories exist"
mkdir -p /run/sshd

echo "==> Ensuring SSH host keys exist"
ssh-keygen -A

if grep -Eq '^[#[:space:]]*Port[[:space:]]+' "${SSHD_CONFIG}"; then
  sed -i "s/^[#[:space:]]*Port[[:space:]].*/Port ${SSH_PORT}/" "${SSHD_CONFIG}"
else
  printf '\nPort %s\n' "${SSH_PORT}" >> "${SSHD_CONFIG}"
fi

if grep -Eq '^[#[:space:]]*PasswordAuthentication[[:space:]]+' "${SSHD_CONFIG}"; then
  sed -i 's/^[#[:space:]]*PasswordAuthentication[[:space:]].*/PasswordAuthentication yes/' "${SSHD_CONFIG}"
else
  printf 'PasswordAuthentication yes\n' >> "${SSHD_CONFIG}"
fi

if grep -Eq '^[#[:space:]]*PubkeyAuthentication[[:space:]]+' "${SSHD_CONFIG}"; then
  sed -i 's/^[#[:space:]]*PubkeyAuthentication[[:space:]].*/PubkeyAuthentication yes/' "${SSHD_CONFIG}"
else
  printf 'PubkeyAuthentication yes\n' >> "${SSHD_CONFIG}"
fi

if grep -Eq '^[#[:space:]]*PermitRootLogin[[:space:]]+' "${SSHD_CONFIG}"; then
  sed -i 's/^[#[:space:]]*PermitRootLogin[[:space:]].*/PermitRootLogin prohibit-password/' "${SSHD_CONFIG}"
else
  printf 'PermitRootLogin prohibit-password\n' >> "${SSHD_CONFIG}"
fi

echo "==> Validating sshd configuration"
sshd -t

start_sshd_without_systemd() {
  if pgrep -x sshd >/dev/null 2>&1; then
    pkill -x sshd || true
  fi
  /usr/sbin/sshd
}

if [[ "${SYSTEMD_PRESENT}" == "true" ]]; then
  echo "==> Enabling and restarting ssh service with systemd"
  systemctl enable ssh
  systemctl restart ssh
else
  echo "==> systemd not available, starting sshd directly"
  start_sshd_without_systemd
fi

HOSTNAME_VALUE="$(hostname 2>/dev/null || true)"
IP_LIST="$(hostname -I 2>/dev/null || true)"
PRIMARY_IP="$(awk '{print $1}' <<<"${IP_LIST}")"

echo
echo "SSH server setup completed."
echo "User: ${SUDO_USER_NAME}"
echo "Port: ${SSH_PORT}"
if [[ -n "${PRIMARY_IP}" ]]; then
  echo "Primary IP: ${PRIMARY_IP}"
fi
if [[ -n "${HOSTNAME_VALUE}" ]]; then
  echo "Hostname: ${HOSTNAME_VALUE}"
fi
if [[ "${WSL_INTEROP_PRESENT}" == "true" ]]; then
  echo "Environment: WSL detected"
  echo "Note: if colleagues connect from another machine, check Windows firewall and port forwarding."
fi
echo
echo "Suggested checks:"
echo "  ss -tlnp | grep \":${SSH_PORT} \""
if [[ "${SYSTEMD_PRESENT}" == "true" ]]; then
  echo "  systemctl status ssh --no-pager"
else
  echo "  ps -ef | grep [s]shd"
fi
echo
echo "Example login:"
if [[ -n "${PRIMARY_IP}" ]]; then
  echo "  ssh ${SUDO_USER_NAME}@${PRIMARY_IP} -p ${SSH_PORT}"
else
  echo "  ssh ${SUDO_USER_NAME}@<host-ip> -p ${SSH_PORT}"
fi
