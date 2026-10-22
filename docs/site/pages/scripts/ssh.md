> 摘要：vssh 从 SSH config 选主机并连接，vifm-sshfs 把远端目录挂载后在 Vifm 里浏览。

# SSH 与 SSHFS

## 两个脚本

| 脚本 | 作用 | 入口 |
|---|---|---|
| `plugins/sshfs/vssh.sh` | 选主机并 SSH 连接 | `vssh` 别名 |
| `plugins/sshfs/vifm-sshfs.sh` | SSHFS 挂载 + Vifm 浏览 | 直接调用 |

两者共享主机列表逻辑：从 `~/.ssh/config`、`conf.d/`、`config.d/` 收集 Host 项。

## vssh

### 用法

```bash
vssh                                  # 交互选主机
vssh build-box                        # 直接连
vssh build-box -p 2222                # 指定端口
vssh build-box -u deploy              # 指定用户
vssh build-box -p 2222 -u deploy      # 两者都指定
```

`vssh` 是 `aliases.conf` 里的别名：

```zsh
alias vssh='$HOME/dotfiles/plugins/sshfs/vssh.sh'
```

### 主机列表

```bash
list_ssh_config_hosts() {
	local files=()
	[ -f "$HOME/.ssh/config" ] && files+=("$HOME/.ssh/config")
	[ -d "$HOME/.ssh/conf.d" ] && files+=("$HOME"/.ssh/conf.d/*)
	[ -d "$HOME/.ssh/config.d" ] && files+=("$HOME"/.ssh/config.d/*)
	[ -g ${#files[@]} -gt 0 ] || return 0

	awk '
		tolower($1) == "host" {
			for (i = 2; i <= NF; i++) {
				if ($i !~ /[*?!]/) print $i
			}
		}
	' "${files[@]}" 2>/dev/null | sort -u
}
```

三个目录都读，用 awk 提取 Host 行，**排除含 `*`、`?`、`!` 的通配项**，去重排序。

### 交互预览

```bash
selected="$(
  printf '%s\n' "$hosts" |
    FZF_DEFAULT_OPTS= fzf \
      --height=30% --layout=reverse --border \
      --preview '
        ssh -G {} 2>/dev/null | grep -E "user|hostname|port"
        echo "----"
        ssh -o ConnectTimeout=1 {} "uptime" 2>/dev/null
      '
)"
```

预览区显示：

1. `ssh -G` 解析出的实际 user/hostname/port
2. 分隔线
3. 1 秒超时的 `uptime` 输出

第 3 项能让你在连接前知道主机是否可达、负载如何。

`FZF_DEFAULT_OPTS=` 清空全局 fzf 选项，避免本仓库的默认预览（bat/ls）干扰。

### 没有 fzf 时

```bash
PS3="ssh host> "
select selected in $hosts; do
	[ -n "$selected" ] && break
done
```

退化成 bash 的 `select` 菜单。

## vifm-sshfs

### 用法

```bash
bash plugins/sshfs/vifm-sshfs.sh
bash plugins/sshfs/vifm-sshfs.sh build-box
bash plugins/sshfs/vifm-sshfs.sh build-box -p 2222
bash plugins/sshfs/vifm-sshfs.sh build-box -d ~/project
bash plugins/sshfs/vifm-sshfs.sh build-box -p 2222 -d ~/project
```

| 参数 | 作用 |
|---|---|
| 位置参数 | SSH 主机别名 |
| `-p` | 端口 |
| `-d` | 远端路径，默认登录目录 |
| `-h` / `--help` | 显示用法 |

### 挂载点命名

```bash
sanitize_mount_name() {
	printf '%s' "$1" | sed 's#[/:]#_#g'
}

MOUNT_NAME="$(sanitize_mount_name "$HOST_ALIAS")"
[ -n "$PORT" ] && MOUNT_NAME="${MOUNT_NAME}_p${PORT}"
MOUNT_DIR="$HOME/.sshfs/$MOUNT_NAME"
```

把主机名里的 `/` 和 `:` 替换成 `_`，有端口时加 `_p<port>` 后缀。所以：

| 输入 | 挂载点 |
|---|---|
| `build-box` | `~/.sshfs/build-box` |
| `build-box -p 2222` | `~/.sshfs/build-box_p2222` |
| `user@host:22` | `~/.sshfs/user_host_22` |

### 幂等挂载

```bash
if ! mount | grep -Fq "$MOUNT_DIR"; then
	echo "[INFO] Mounting $HOST_ALIAS:$REMOTE_PATH -> $MOUNT_DIR"
	sshfs ... "$HOST_ALIAS:$REMOTE_PATH" "$MOUNT_DIR" || { ... exit 1; }
else
	echo "[INFO] Already mounted: $MOUNT_DIR"
fi
```

已挂载时跳过，不重复挂。

### 启动 Vifm

```bash
vifm "$MOUNT_DIR" "$HOME"
```

左栏远端目录，右栏本地 home，方便对拷。

### ~ 的处理

```bash
[ "$REMOTE_PATH" = "~" ] && REMOTE_PATH="."
```

sshfs 对 `~` 的处理和 ssh 不同，改成 `.` 表示登录目录。

## 依赖

| 脚本 | 依赖 |
|---|---|
| vssh | ssh、fzf（可选） |
| vifm-sshfs | ssh、sshfs、vifm、fzf（可选） |

```bash
# Debian
sudo apt install sshfs
# macOS
brew install --cask macfuse && brew install sshfs
```

## 卸载挂载

```bash
fusermount -u ~/.sshfs/build-box        # Linux
umount ~/.sshfs/build-box               # 或
diskutil unmount ~/.sshfs/build-box     # macOS
```

## 排错

**`vssh: command not found`**：`aliases.conf` 没加载。

**「No ssh hosts found」**：`~/.ssh/config` 里没有 Host 行，或全是通配项。

**预览显示 `ssh: connect to host ... failed`**：主机不可达。这不阻止你继续连接（可能只是 ICMP/ping 被禁）。

**SSHFS 挂载失败**：检查 `sshfs` 是否安装，以及 SSH 是否已配置免密（sshfs 需要非交互认证）。

**挂载点已存在但为空**：`mount` 检查显示未挂载但目录残留。`rmdir` 后重试。

**macOS 上 sshfs 报 macFUSE 错误**：需要在系统设置里允许 macFUSE 扩展。

**Vifm 打不开**：vifm 没装。`sudo apt install vifm`。
