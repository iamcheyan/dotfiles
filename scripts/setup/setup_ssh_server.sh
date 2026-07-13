#!/usr/bin/env bash

# Auto-elevate to root if not already root
if [[ "${EUID}" -ne 0 ]]; then
  echo "==> Re-running script with sudo to obtain root privileges..."
  exec sudo env "SSH_PORT=${SSH_PORT:-22}" "$0" "$@"
fi

set -euo pipefail

if [[ ! -f /etc/os-release ]]; then
  echo "Unsupported system: /etc/os-release not found." >&2
  exit 1
fi

# shellcheck disable=SC1091
source /etc/os-release

OS_ID="${ID:-unknown}"
echo "==> Detected OS: ${OS_ID}"

# Define package manager and ssh service name based on OS
if [[ "${OS_ID}" =~ (ubuntu|debian|linuxmint) ]]; then
  PKG_MANAGER="apt"
  SSH_SERVICE="ssh"
  SSH_PKG="openssh-server"
elif [[ "${OS_ID}" =~ (fedora|rhel|centos) ]]; then
  PKG_MANAGER="dnf"
  SSH_SERVICE="sshd"
  SSH_PKG="openssh-server"
else
  echo "Unsupported OS: ${OS_ID}. Only Debian/Ubuntu and Fedora/RHEL/CentOS are supported." >&2
  exit 1
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

echo "==> Installing ${SSH_PKG} via ${PKG_MANAGER}"
if [[ "${PKG_MANAGER}" == "apt" ]]; then
  apt-get update
  DEBIAN_FRONTEND=noninteractive apt-get install -y "${SSH_PKG}"
elif [[ "${PKG_MANAGER}" == "dnf" ]]; then
  dnf install -y "${SSH_PKG}"
fi

echo "==> Ensuring runtime directories exist"
mkdir -p /run/sshd

echo "==> Ensuring SSH host keys exist"
ssh-keygen -A

# Configure port
if grep -Eq '^[#[:space:]]*Port[[:space:]]+' "${SSHD_CONFIG}"; then
  sed -i "s/^[#[:space:]]*Port[[:space:]].*/Port ${SSH_PORT}/" "${SSHD_CONFIG}"
else
  printf '\nPort %s\n' "${SSH_PORT}" >> "${SSHD_CONFIG}"
fi

# Configure PasswordAuthentication
if grep -Eq '^[#[:space:]]*PasswordAuthentication[[:space:]]+' "${SSHD_CONFIG}"; then
  sed -i 's/^[#[:space:]]*PasswordAuthentication[[:space:]].*/PasswordAuthentication yes/' "${SSHD_CONFIG}"
else
  printf 'PasswordAuthentication yes\n' >> "${SSHD_CONFIG}"
fi

# Configure PubkeyAuthentication
if grep -Eq '^[#[:space:]]*PubkeyAuthentication[[:space:]]+' "${SSHD_CONFIG}"; then
  sed -i 's/^[#[:space:]]*PubkeyAuthentication[[:space:]].*/PubkeyAuthentication yes/' "${SSHD_CONFIG}"
else
  printf 'PubkeyAuthentication yes\n' >> "${SSHD_CONFIG}"
fi

# Configure PermitRootLogin
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
  echo "==> Enabling and restarting ${SSH_SERVICE} service with systemd"
  systemctl enable "${SSH_SERVICE}"
  systemctl restart "${SSH_SERVICE}"
else
  echo "==> systemd not available, starting sshd directly"
  start_sshd_without_systemd
fi

HOSTNAME_VALUE="$(hostname 2>/dev/null || true)"
IP_LIST="$(hostname -I 2>/dev/null || true)"
PRIMARY_IP="$(awk '{print $1}' <<<"${IP_LIST}")"

echo
echo "=================================================="
echo "SSH server setup completed successfully!"
echo "=================================================="
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
  echo "  systemctl status ${SSH_SERVICE} --no-pager"
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
echo "=================================================="
