#!/bin/bash

# 将本地 dotfiles 同步到 SMB 备份目录
# 用法: ./sync-dotfiles-to-smb.sh [user:password@host[/share/path]]

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="$SCRIPT_DIR/.env"

AUTH_ARG="${1:-}"
SMB_HOST="192.168.3.10"
SMB_PATH="nas/BAK/dotfiles"

if [ -n "$AUTH_ARG" ]; then
  # 解析 user:password@host/share/path
  if [[ "$AUTH_ARG" == *@* ]]; then
    AFTER_AT="${AUTH_ARG#*@}"
    AUTH="${AUTH_ARG%@*}"

    # 分离 host 和 path
    if [[ "$AFTER_AT" == */* ]]; then
      SMB_HOST="${AFTER_AT%%/*}"
      SMB_PATH="${AFTER_AT#*/}"
    else
      SMB_HOST="$AFTER_AT"
    fi
  else
    AUTH="$AUTH_ARG"
  fi

  SMB_USER="${AUTH%%:*}"
  SMB_PASS="${AUTH#*:}"

  if [ -z "$SMB_USER" ] || [ "$SMB_USER" == "$AUTH" ] || [ -z "$SMB_PASS" ]; then
    echo "错误: 凭据格式应为 user:password 或 user:password@host 或 user:password@host/share/path"
    echo "示例: $0 tetsuya:mypass"
    echo "       $0 tetsuya:mypass@192.168.3.10"
    echo "       $0 tetsuya:mypass@192.168.3.10/nas/dotfiles_bak"
    exit 1
  fi
elif [ -f "$ENV_FILE" ]; then
  while IFS= read -r line || [ -n "$line" ]; do
    [[ $line =~ ^#.*$ ]] && continue
    [[ -z $line ]] && continue
    export "${line%%#*}"
  done <"$ENV_FILE"
else
  echo "错误: 未找到 .env 文件 ($ENV_FILE)，且未提供命令行凭据"
  echo "用法: $0 [user:password@host[/share/path]]"
  exit 1
fi

DOTFILES_DIR="$HOME/dotfiles"
SMB_URL="smb://${SMB_HOST}/${SMB_PATH}"

if [ ! -d "$DOTFILES_DIR" ]; then
  echo "错误: 未找到 dotfiles 目录 ($DOTFILES_DIR)"
  exit 1
fi

if [ -z "${SMB_USER:-}" ] || [ -z "${SMB_PASS:-}" ]; then
  echo "错误: 未设置 SMB 凭据"
  exit 1
fi

# 解析 SMB URL
RAW_PATH=${SMB_URL#smb://}
HOST=${RAW_PATH%%/*}
REMAINING=${RAW_PATH#*/}
SHARE=${REMAINING%%/*}
SUBPATH=${REMAINING#*/}

if [ "$SHARE" == "$SUBPATH" ]; then
  SUBPATH=""
fi

MOUNT_POINT="/tmp/smb_sync_$(date +%s)"
mkdir -p "$MOUNT_POINT"

CREDENTIALS_FILE="$(mktemp /tmp/smb_sync_credentials.XXXXXX)"

cleanup() {
  if mountpoint -q "$MOUNT_POINT" 2>/dev/null; then
    sudo umount "$MOUNT_POINT" || true
  fi
  rm -f "$CREDENTIALS_FILE"
  rmdir "$MOUNT_POINT" 2>/dev/null || true
}

trap cleanup EXIT

{
  printf 'username=%s\n' "$SMB_USER"
  printf 'password=%s\n' "$SMB_PASS"
  if [ -n "${SMB_DOMAIN:-}" ]; then
    printf 'domain=%s\n' "$SMB_DOMAIN"
  fi
} >"$CREDENTIALS_FILE"
chmod 600 "$CREDENTIALS_FILE"

OPTS="credentials=$CREDENTIALS_FILE,iocharset=utf8,vers=3.0,sec=ntlmssp,uid=$(id -u),gid=$(id -g),file_mode=0777,dir_mode=0777,noperm"

echo "------------------------------------------"
echo " 源目录:  $DOTFILES_DIR"
echo " 远程:    $SMB_URL"
echo " 用户:    $SMB_USER"
echo "------------------------------------------"

echo "正在挂载 SMB..."
sudo mount -t cifs "//$HOST/$SHARE" "$MOUNT_POINT" -o "$OPTS"

# 检查目标路径是否可写
TARGET_DIR="$MOUNT_POINT/${SUBPATH:-}"
if [ -n "$SUBPATH" ]; then
  mkdir -p "$TARGET_DIR" 2>/dev/null || true
fi

TEST_FILE="$TARGET_DIR/.write_test_$$"
if ! touch "$TEST_FILE" 2>/dev/null; then
  echo ""
  echo "错误: 目标路径不可写 ($TARGET_DIR)"
  echo ""
  echo "可能原因:"
  echo "  1. SMB 服务器上该目录对 '$SMB_USER' 是只读的"
  echo "  2. 共享权限或 ACL 限制了写入"
  echo ""
  echo "解决方式:"
  echo "  - 去 NAS 上把目标目录改为可读写"
  echo "  - 或换一个有写权限的目标路径，例如:"
  echo "    $0 $SMB_USER:你的密码@$SMB_HOST/$SHARE/其他目录"
  exit 1
fi
rm -f "$TEST_FILE"

echo "开始同步 (rsync)..."
rsync -rlDvh --delete \
  --no-t --no-g --no-perms \
  --include='.env' \
  --exclude='.git/' \
  --exclude='.gitignore' \
  --exclude='.githooks/' \
  --exclude='.DS_Store' \
  --exclude='__pycache__/' \
  --exclude='*.pyc' \
  "$DOTFILES_DIR/" "$TARGET_DIR/"

echo "同步完成！"
