> 摘要：install_httpie.sh 用三级回退安装 HTTPie，覆盖有 root、有 pipx、只有 pip 三种环境。

# HTTPie 安装器

## 用途

`scripts/install/install_httpie.sh` 安装 HTTPie。它按环境能力逐级降级，尽量在没有 root 的机器上也能装成功。

## 用法

```zsh
install:httpie
install:httpie --method package
install:httpie --method pipx
install:httpie --method pip
install:httpie --force
```

`install:httpie` 是 `plugins/tools/tools.zsh` 里定义的函数：

```zsh
unalias install:httpie 2>/dev/null || true
install:httpie() {
  bash "$HOME/dotfiles/scripts/install/install_httpie.sh" "$@"
}
```

先 `unalias` 是为了处理「之前定义成别名」的旧配置。

## 三级回退

```bash
case "$METHOD" in
  auto)
    install_with_package_manager || install_with_pipx || install_with_pip || {
      print_error "Failed to install HTTPie"
      exit 1
    }
    ;;
esac
```

| 级别 | 方法 | 前提 |
|---|---|---|
| 1 | 系统包管理器 | 有 sudo，发行版源里有 httpie |
| 2 | pipx | 装了 pipx，无需 root |
| 3 | pip --user | 只有 Python，无需 root |

`auto` 是默认值，按顺序尝试。

## 包管理器分支

```bash
detect_os() {
  if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    if command_exists apt-get; then echo "debian"
    elif command_exists dnf; then echo "fedora"
    elif command_exists yum; then echo "rhel"
    elif command_exists pacman; then echo "arch"
    else echo "linux"
    fi
  elif [[ "$OSTYPE" == "darwin"* ]]; then echo "macos"
  else echo "unknown"
  fi
}
```

| 系统 | 命令 |
|---|---|
| debian | `apt-get install -y httpie` |
| fedora | `dnf install -y httpie` |
| rhel | `dnf` 或 `yum` |
| arch | `pacman -S --noconfirm httpie` |
| macos | `brew install httpie` |

每级都先检查 `sudo` 或 `brew` 是否存在，缺失就返回失败，交给下一级。

## 已安装检测

```bash
if command_exists http && [[ "$FORCE" -ne 1 ]]; then
  print_success "HTTPie is already installed: $(http --version)"
  exit 0
fi
```

已有 `http` 且没加 `--force` 就跳过。

## 参数解析

```bash
while [[ $# -gt 0 ]]; do
  case "$1" in
    --force) FORCE=1 ;;
    --method) METHOD="${2:-}"; shift ;;
    *) print_error "Unknown option: $1"; exit 1 ;;
  esac
  shift
done
```

与 `init.sh` 不同，这个脚本对未知参数**报错退出**，不会静默跳过。

## 安装后检查

```bash
if command_exists http; then
  print_success "HTTPie installed successfully: $(http --version)"
else
  print_warning "HTTPie may have been installed, but 'http' is not yet in PATH for this shell"
  print_info "Open a new shell or run: source ~/.zshrc"
fi
```

pip 用户安装会装到 `~/.local/bin`，当前 shell 的 PATH 可能还没刷新，所以给了明确提示。

## 手动安装

不想用脚本时：

```bash
# 系统包
sudo apt install httpie

# pipx
pipx install httpie

# pip
python3 -m pip install --user httpie
```

## 与 xh 的选择

本仓库同时提供 `xh`（Zinit 安装的 Rust 版本）。两者语法相近：

| | http | xh |
|---|---|---|
| 安装 | 需要 Python 或包管理器 | Zinit 自动 |
| 启动 | 慢一点 | 快 |
| 依赖 | Python | 无 |

如果只是偶尔用，`xh` 更省事；如果已有 Python 环境，`http` 也够。

## 排错

**`install:httpie: command not found`**：`plugins/tools/tools.zsh` 没加载。

**三级全失败**：环境里既没有 sudo、也没有 pipx 和 pip。装 Python 或手动下载。

**装完 `http` 找不到**：`~/.local/bin` 不在 PATH。`source ~/.zshrc` 或新开终端。

**`Unknown option` 错误**：参数拼写错。只接受 `--force` 和 `--method`。

**包管理器版本太旧**：`http --version` 检查。太旧时用 `--method pip` 装最新。
