> 摘要：clear.sh 是 WSL 清理脚本，会执行破坏性操作；winetricks.sh 负责在特殊发行版上转发调用。

# 清理与系统脚本

## tools/clear.sh

### 用途

WSL 全系统清理：Cargo 缓存、Rust 旧工具链、pip 缓存、apt 缓存、journal 日志、Snap 缓存、`/tmp`，最后列出大文件和目录用量。

### 会做什么

```bash
# 1. Cargo 缓存
cargo cache -a

# 2. Rust 旧工具链
rustup cleanup -y

# 3. pip 缓存
rm -rf ~/.cache/pip

# 4. apt 缓存与无用包
sudo apt clean
sudo apt autoremove -y

# 5. journal 日志（保留 3 天）
sudo journalctl --vacuum-time=3d

# 6. Snap 缓存
sudo du -hx /var/lib/snapd/snaps

# 7. /tmp
sudo rm -rf /tmp/*

# 8. 列出 >500MB 文件
sudo find / -xdev -type f -size +500M

# 9. 列出顶层目录用量
sudo du -hx --max-depth=1 /
```

### 风险

| 操作 | 风险 |
|---|---|
| `rm -rf /tmp/*` | 删除所有临时文件，运行中的程序可能出错 |
| `apt autoremove -y` | 删除「不再需要」的包，可能误删 |
| `rustup cleanup -y` | 删除旧工具链，无法回退 |
| `journalctl --vacuum-time=3d` | 删除 3 天前的日志，事后无法追查 |

**脚本不做任何确认**，直接执行。运行前读一遍，确认当前环境。

### 使用建议

```bash
# 先看会做什么
less ~/dotfiles/tools/clear.sh

# 在容器或测试机上先跑
# 生产环境慎用，尤其 rm -rf /tmp/*
```

### 适用场景

它是为 WSL 设计的：WSL 的虚拟磁盘会随使用膨胀，需要定期清理。在普通 Linux 服务器上，`/tmp` 可能有正在运行的服务文件，不要盲目执行。

## tools/winetricks.sh

### 用途

智能运行 winetricks：

- Silverblue/Kinoite（不可变系统）通过 Toolbox 容器转发
- 其它系统检查并安装 winetricks，然后执行传入命令

### 用法

```bash
bash tools/winetricks.sh corefonts
bash tools/winetricks.sh --help
```

### 逻辑

```bash
main() {
    if is_silverblue_kinoite; then
        toolbox run --container wine winetricks "$@"
        exit 0
    fi

    if ! command -v winetricks &> /dev/null; then
        install_winetricks
    fi

    if [ $# -eq 0 ]; then
        echo "Provide the winetricks command to run as an argument"
        exit 1
    fi

    winetricks "$@"
}
```

### 发行版检测

```bash
is_silverblue_kinoite() {
    grep -q "silverblue\|kinoite" /etc/os-release
}
```

Fedora 的不可变变体不能直接装包，所以通过 Toolbox 容器运行。

### 安装分支

| 系统 | 命令 |
|---|---|
| apt | `sudo apt install -y winetricks` |
| dnf | `sudo dnf install -y winetricks` |
| pacman | `sudo pacman -S --noconfirm winetricks` |
| 其它 | 报错，要求手动安装 |

### 注意

`install_winetricks` 会执行 `sudo apt update` 等操作，属于系统级变更。在没有 WINE 需求的机器上不要运行。

## 这两个脚本的定位

它们不在 `init.sh` 的默认流程里，是**按需手动运行**的工具脚本。设计上假设使用者知道自己在做什么。

与其它脚本的对比：

| 脚本 | 是否自动运行 | 是否破坏性 |
|---|---|---|
| `install_font.sh` | 是（init.sh） | 否 |
| `install_nvim.sh` | 是（init.sh） | 否 |
| `clear.sh` | 否 | 是 |
| `winetricks.sh` | 否 | 可能（装包） |

## 排错

**clear.sh 删掉了正在用的文件**：`/tmp` 被清空导致程序出错。重启相关服务。

**`cargo cache` 不存在**：没装 `cargo-cache`。脚本用 `command -v cargo` 判断，但 `cargo cache` 是子命令，需要单独安装 `cargo-cache`。

**`rustup cleanup` 失败**：脚本用 `|| echo` 兜底，不中断。

**winetricks 在 Silverblue 上找不到容器**：需要先创建名为 `wine` 的 Toolbox 容器。

**`Provide the winetricks command`**：没传参数。至少要给一个子命令，比如 `corefonts`。
