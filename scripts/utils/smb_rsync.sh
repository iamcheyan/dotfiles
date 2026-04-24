#!/bin/bash

# 加载 .env 变量
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="$SCRIPT_DIR/.env"

if [ -f "$ENV_FILE" ]; then
  # 更加健壮的加载方式：读取文件，过滤注释和空行
  while IFS= read -r line || [ -n "$line" ]; do
    # 忽略以 # 开头的行和空行
    [[ $line =~ ^#.*$ ]] && continue
    [[ -z $line ]] && continue
    # 去掉行尾注释并导出变量
    export "${line%%#*}"
  done <"$ENV_FILE"
else
  echo "错误: 未找到 .env 文件 ($ENV_FILE)"
  echo "请根据 .env.example 创建 .env 并填写 SMB 凭据。"
  exit 1
fi

SMB_URL=$1
LOCAL_DEST=$2

if [ -z "$SMB_URL" ] || [ -z "$LOCAL_DEST" ]; then
  echo "用法: $0 smb://host/share/subfolder /local/path"
  echo "示例: $0 smb://192.168.x.x/nas/filename /home/username/Backups/filename"
  exit 1
fi

# 检查必要变量
if [ -z "$SMB_USER" ] || [ -z "$SMB_PASS" ]; then
  echo "错误: .env 中未设置 SMB_USER 或 SMB_PASS"
  exit 1
fi

# 解析 SMB URL
RAW_PATH=${SMB_URL#smb://}
HOST=${RAW_PATH%%/*}
REMAINING=${RAW_PATH#*/}
SHARE=${REMAINING%%/*}
SUBPATH=${REMAINING#*/}

# 处理没有子路径的情况
if [ "$SHARE" == "$SUBPATH" ]; then
  SUBPATH=""
fi

MOUNT_POINT="/tmp/smb_rsync_$(date +%s)"
mkdir -p "$MOUNT_POINT"

CREDENTIALS_FILE="$(mktemp /tmp/smb_rsync_credentials.XXXXXX)"

cleanup() {
  if mountpoint -q "$MOUNT_POINT" 2>/dev/null; then
    sudo umount "$MOUNT_POINT" || true
  fi
  rm -f "$CREDENTIALS_FILE"
  rmdir "$MOUNT_POINT" 2>/dev/null || true
}

trap cleanup EXIT

user_key="username"
pass_key="password"
{
  printf '%s=%s\n' "$user_key" "$SMB_USER"
  printf '%s=%s\n' "$pass_key" "$SMB_PASS"
  if [ -n "${SMB_DOMAIN:-}" ]; then
    printf 'domain=%s\n' "$SMB_DOMAIN"
  fi
} >"$CREDENTIALS_FILE"
chmod 600 "$CREDENTIALS_FILE"

OPTS="credentials=$CREDENTIALS_FILE,iocharset=utf8,vers=3.0,sec=ntlmssp"

echo "------------------------------------------"
echo "远程主机: $HOST"
echo "共享名称: $SHARE"
echo "子路径:   $SUBPATH"
echo "本地目标: $LOCAL_DEST"
echo "------------------------------------------"

echo "正在执行挂载..."
# 尝试挂载。如果需要 sudo 密码，它会在终端提示
sudo mount -t cifs "//$HOST/$SHARE" "$MOUNT_POINT" -o "$OPTS"

if [ $? -ne 0 ]; then
  echo "错误: 挂载失败。请检查网络、用户名密码或是否安装了 cifs-utils。"
  exit 1
fi

# 确保目标目录存在
mkdir -p "$LOCAL_DEST"

# 执行 rsync
# 注意: 加上 / 后缀表示同步目录下的内容
SOURCE_PATH="$MOUNT_POINT/$SUBPATH"
echo "开始同步 (rsync)..."
rsync -ah --info=progress2 "$SOURCE_PATH/" "$LOCAL_DEST/"

# 卸载并清理
echo "同步任务结束，正在卸载并清理临时目录..."
sudo umount "$MOUNT_POINT"

echo "完成！"
