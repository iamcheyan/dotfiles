#!/usr/bin/env bash
#
# SSH 免密登录与快捷配置脚本
# 作用：配置 SSH 免密登录，并将连接配置写入 ~/.ssh/config 并设置别名。
# 用法：./setup_ssh_key.sh username@ip_address
#

set -u

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # 无颜色

print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 1. 校验输入参数
if [ $# -ne 1 ]; then
    echo "用法: $0 username@ip_address"
    echo "示例: $0 tetsuya@192.168.3.82"
    exit 1
fi

USER_HOST="$1"

# 使用正则验证输入格式 (username@ip_or_host)
if [[ ! "$USER_HOST" =~ ^[a-zA-Z0-9._-]+@[a-zA-Z0-9.-]+$ ]]; then
    print_error "参数格式错误！必须为 username@ip_or_host 格式。"
    echo "示例: $0 tetsuya@192.168.3.82"
    exit 1
fi

REMOTE_USER="${USER_HOST%@*}"
REMOTE_HOST="${USER_HOST#*@}"

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}        SSH 免密登录与别名配置工具        ${NC}"
echo -e "${BLUE}========================================${NC}"
print_info "远程目标: ${CYAN}${REMOTE_USER}${NC} @ ${CYAN}${REMOTE_HOST}${NC}"
echo ""

# 2. 检查本地 SSH 密钥对，不存在则生成
SSH_DIR="$HOME/.ssh"
mkdir -p "$SSH_DIR"
chmod 700 "$SSH_DIR"

# 优先选择 Ed25519 密钥，其次 RSA 密钥
DEFAULT_KEY="$SSH_DIR/id_ed25519"
RSA_KEY="$SSH_DIR/id_rsa"
SELECTED_KEY=""

if [[ -f "$DEFAULT_KEY" ]]; then
    SELECTED_KEY="$DEFAULT_KEY"
    print_info "检测到现有的 Ed25519 密钥: $SELECTED_KEY"
elif [[ -f "$RSA_KEY" ]]; then
    SELECTED_KEY="$RSA_KEY"
    print_info "检测到现有的 RSA 密钥: $SELECTED_KEY"
else
    # 都不存在，则生成一个新的 Ed25519 密钥
    print_warning "未检测到本地 SSH 密钥，正在生成新的 Ed25519 密钥对..."
    if ssh-keygen -t ed25519 -N "" -f "$DEFAULT_KEY"; then
        SELECTED_KEY="$DEFAULT_KEY"
        print_success "成功生成密钥对: $SELECTED_KEY"
    else
        print_error "生成 SSH 密钥失败！"
        exit 1
    fi
fi

PUB_KEY="${SELECTED_KEY}.pub"
if [[ ! -f "$PUB_KEY" ]]; then
    print_error "未找到公钥文件: $PUB_KEY"
    exit 1
fi

# 3. 复制公钥到远程主机（提示用户输入密码）
print_info "正在复制公钥到远程主机，请在下方提示中输入远程用户的密码..."
echo ""

COPY_SUCCESS=false
if command -v ssh-copy-id &>/dev/null; then
    if ssh-copy-id -i "$PUB_KEY" "$USER_HOST"; then
        COPY_SUCCESS=true
    fi
else
    print_warning "本地未检测到 ssh-copy-id 命令，尝试通过 ssh 手动拷贝..."
    if cat "$PUB_KEY" | ssh "$USER_HOST" "mkdir -p ~/.ssh && chmod 700 ~/.ssh && cat >> ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys"; then
        COPY_SUCCESS=true
    fi
fi

echo ""
if [[ "$COPY_SUCCESS" == "true" ]]; then
    print_success "公钥复制成功！已启用免密登录。"
else
    print_error "复制公钥失败，请检查网络连接、用户名或密码。"
    exit 1
fi

# 4. 配置 SSH 配置文件 (~/.ssh/config)
SSH_CONFIG="$SSH_DIR/config"
touch "$SSH_CONFIG"
chmod 600 "$SSH_CONFIG"

echo ""
print_info "开始配置本地 SSH 别名快捷方式..."

read -p "请输入此远程主机的别名 (例如: nas, server) [默认: $REMOTE_HOST]: " HOST_ALIAS
HOST_ALIAS=$(echo "$HOST_ALIAS" | xargs) # 去除两端空格

if [[ -z "$HOST_ALIAS" ]]; then
    HOST_ALIAS="$REMOTE_HOST"
fi

# 检查别名是否已经被占用
if grep -iqE "^Host[[:space:]]+$HOST_ALIAS$" "$SSH_CONFIG" 2>/dev/null; then
    print_warning "别名 '$HOST_ALIAS' 已经在 $SSH_CONFIG 中定义。"
    read -p "是否覆盖已有的别名配置块? [y/N]: " CHOICE
    if [[ "$CHOICE" =~ ^[yY](es)?$ ]]; then
        # 使用 Python 脚本安全地删除已有的 Host 配置块
        print_info "正在移除旧的 '$HOST_ALIAS' 配置块..."
        python3 -c "
import sys
config_path = '$SSH_CONFIG'
alias = '$HOST_ALIAS'.lower()
with open(config_path, 'r') as f:
    lines = f.readlines()

new_lines = []
skip = False
for line in lines:
    stripped = line.strip()
    # 遇到新的 Host 定义
    if stripped.startswith('Host ') or stripped.startswith('Host\t'):
        parts = stripped.split()
        if len(parts) > 1 and parts[1].lower() == alias:
            skip = True
            continue
        else:
            skip = False
    
    # 如果处于要跳过的块中
    if skip:
        # 如果是空行、或缩进行，则继续跳过
        if stripped == '' or line.startswith(' ') or line.startswith('\t'):
            continue
        else:
            skip = False
            
    new_lines.append(line)

with open(config_path, 'w') as f:
    f.writelines(new_lines)
"
    else
        print_error "配置已取消。别名已存在且未被覆盖。"
        exit 1
    fi
fi

# 写入新的配置到 ~/.ssh/config
print_info "正在将配置写入 $SSH_CONFIG..."

# 确保配置尾部有换行
if [[ -s "$SSH_CONFIG" && "$(tail -c 1 "$SSH_CONFIG" 2>/dev/null)" != $'\n' ]]; then
    echo "" >> "$SSH_CONFIG"
fi

cat >> "$SSH_CONFIG" <<EOF

Host $HOST_ALIAS
    HostName $REMOTE_HOST
    User $REMOTE_USER
    IdentityFile $SELECTED_KEY
    PreferredAuthentications publickey
EOF

print_success "配置完成！已成功将别名写入 $SSH_CONFIG"
echo -e "${BLUE}========================================${NC}"
print_success "现在你可以直接使用别名一键登录到远程主机:"
echo -e "  ${CYAN}ssh $HOST_ALIAS${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""
