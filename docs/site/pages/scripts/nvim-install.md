> 摘要：install_nvim.sh 检查或安装 Neovim，处理平台、架构和版本约束。

# Neovim 安装器

## 用途

`scripts/install/install_nvim.sh` 负责把 Neovim 装到用户目录，不依赖系统包管理器。`init.sh` 会调用它，也可以单独运行。

与 `nvim-update` 的分工：安装器负责「从无到有」，更新器负责「从旧到新」。

## 用法

```bash
bash scripts/install/install_nvim.sh
bash scripts/install/install_nvim.sh --version 0.12.5
bash scripts/install/install_nvim.sh --force
```

## 参数

| 参数 | 作用 |
|---|---|
| 无 | 检查已安装版本，不满足最低要求则安装最新 |
| `--version <V>` / `-v <V>` | 安装指定版本 |
| `--force` / `-f` | 强制重装，即使已满足版本要求 |

最低版本要求由脚本内的常量定义（当前 0.12）。

## 平台与架构

```bash
case "$machine" in
    x86_64|amd64) ... ;;
    aarch64|arm64) ... ;;
esac
```

| 平台 | 架构 | 下载包 |
|---|---|---|
| Linux | x86_64 | `nvim-linux-x86_64.tar.gz` |
| Linux | aarch64 | `nvim-linux-arm64.tar.gz` |
| macOS | x86_64 | `nvim-macos-x86_64.tar.gz` |
| macOS | arm64 | `nvim-macos-arm64.tar.gz` |

## 安装位置

```text
~/.local/nvim/bin/nvim          # 可执行文件
~/.local/nvim/share/nvim/       # runtime
```

注意这与 `nvim-update` 的路径不同：

| 工具 | 安装根 |
|---|---|
| `install_nvim.sh` | `~/.local/nvim` |
| `nvim-update` | `~/.local/opt/neovim/<version>` |

两者都能用，但**不要混用**——`nvim-update` 会拒绝覆盖非自己管理的软链接。

## 版本检测

```bash
installed_version=$(TERM=dumb nvim --version 2>&1 | grep -vE '^\[' | head -n 1 \
  | grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+' | sed 's/^v//')
```

`TERM=dumb` 和 `--headless` 用来抑制终端控制序列，避免把转义码混进解析。

## 校验安装

```bash
vimruntime=$(TERM=dumb "$install_dir/bin/nvim" --clean --headless \
  +'lua print(vim.env.VIMRUNTIME)' +q 2>&1 | grep -v "^$" | grep -vE '^\[' | tail -1)
```

安装后检查 `$VIMRUNTIME` 是否指向正确目录。这能捕获「二进制存在但 runtime 缺失」的不完整安装。

## 与 init.sh 的关系

```bash
bash "$nvim_init" --skip-plugins
```

`init.sh` 调用时传 `--skip-plugins`：只装 Neovim 本体和依赖，插件留给首次启动的 lazy.nvim。

原因：插件安装需要完整运行时（Treesitter parser、编译器），在安装脚本里做容易半途失败。

## 单独使用的场景

```bash
# 只想要 Neovim，不要整套 dotfiles
git clone https://github.com/iamcheyan/nvim.git ~/nvim
bash ~/nvim/init.sh
```

Neovim 仓库有自己的 `init.sh`，本脚本是它在 dotfiles 里的副本/包装。

## 排错

**`Unsupported platform`**：架构不在支持列表。检查 `uname -m`。

**下载失败**：网络问题。脚本用 curl/wget，检查代理设置。

**安装后 `nvim` 还是旧版本**：PATH 里 `~/.local/nvim/bin` 不在前面，或系统包优先。`command -v nvim` 确认。

**`--version` 指定的版本不存在**：检查 GitHub release 页面确认 tag 名。

**和 nvim-update 冲突**：两者管理不同的安装根。选一个用，不要交替。若已混用，先删掉 `~/.local/bin/nvim` 软链接再重建。
