> 摘要：init.sh 的 11 个步骤、失败策略、平台分支，以及为什么顺序是现在这样。

# init.sh

## 用途

`init.sh` 是新机器的一键初始化：检查/安装依赖、配置 shell、部署配置。它把十几件分散的事串成一条流程。

## 用法

```bash
bash init.sh                # 完整
bash init.sh --minimal      # 跳过字体、Neovim、大型额外组件
bash init.sh --repair       # 额外修复 zinit 插件
```

## 失败策略

```bash
run_step() {
    local step_name="$1"; shift
    if ! "$@"; then
        print_warning "$step_name failed, skipping..."
    fi
}
```

每个步骤包在 `run_step` 里：失败打印 warning，继续下一步。**不会整体中断**。

这意味着脚本跑完 ≠ 全部成功。必须自己核对（见 [安装后核对](../start/verify.html)）。

## 11 个步骤

### Step 1：定位仓库

```bash
detect_dotfiles_dir
```

找到脚本所在仓库的根目录。失败则整体退出。

### Step 2：zsh

```bash
install_zsh
```

按发行版选择安装命令：apt、dnf、pacman、zypper 等。已安装则跳过。安装后询问是否设为默认 shell。

### Step 3：基础工具

```bash
install_essentials
```

git、curl、build-essential、unzip、tar 等。这是后续所有步骤的前提。

### Step 3.5：子模块

```bash
init_git_submodules
```

`git submodule update --init --recursive`。不做这步，`config/nvim` 会是空目录。

### Step 4：zinit

```bash
install_zinit
```

克隆 `zdharma-continuum/zinit` 到 `~/.zinit/bin`。

### Step 4.5：修复（可选）

```bash
if [[ "$REPAIR" == "true" ]]; then
    repair_zinit_plugins
fi
```

只在 `--repair` 时执行。检查已知易损插件目录（atuin、broot）是否完整，不完整则重新拉取。

### Step 5：fnm

```bash
install_fnm
```

安装 Node 版本管理器。NixOS 上跳过，提示由系统配置管理。

### Step 5.5：Inshellisense

```bash
install_inshellisense
```

需要 npm 可用。通过 `npm install --global @microsoft/inshellisense` 安装，然后 `is init zsh` 生成集成。

### Step 6：Fresh

```bash
install_fresh
```

按平台选择安装方式：Linux/WSL 用官方 installer，macOS 用 Homebrew，Windows 用 winget。NixOS 跳过。

### Step 7：fzf

```bash
install_fzf
```

检查系统 fzf 版本，过旧时从 GitHub 安装新版。

### Step 8：dotlink

```bash
run_dotlink
```

调用 `dotlink` 建立所有软链接。**这一步之后配置就生效了**，即使后面失败。

### Step 8.5：Ranger 插件

```bash
install_ranger_devicons
install_ranger_archives
```

克隆两个 ranger 插件。它们也是 git 子模块，这里做兜底检查。

### Step 9：`.zshrc` 链接

创建 `~/.zshrc` → `~/dotfiles/zshrc` 的链接。

## 之后的额外步骤

脚本继续处理：

| 组件 | 说明 |
|---|---|
| 字体 | Meslo Nerd Font + Noto Serif CJK（`--minimal` 跳过） |
| Neovim | 调用子模块的 `init.sh --skip-plugins`（`--minimal` 跳过） |
| Docker | 仅 Linux |
| Zellij | 检查/安装 |
| gh-dash | gh 扩展 |
| Herdr | 本地 AI 助手 |

## 平台分支

```bash
case "$OS" in
    debian|ubuntu) ... ;;
    fedora) ... ;;
    arch) ... ;;
    void) ... ;;
    darwin) ... ;;
    nixos) ... ;;
esac
```

NixOS 的分支特殊：**不安装任何系统包**，只做用户目录配置，然后提示用户去 `nixos-config` 声明依赖。

## 覆盖提示

```bash
echo "This script will:"
echo "  1. Create symlinks for config files (replacing existing files)"
echo "  2. Create a ~/.zshrc symlink (replacing the existing file)"
echo -e "${RED}Warning: existing config files will be overwritten.${NC}"
for i in {3..1}; do
    echo -ne "$i... \r"
    sleep 1
done
```

明确告知会覆盖，倒数 3 秒。没有交互确认，倒数结束就继续。

## 为什么不幂等

脚本设计成可以重复运行，但**重复运行仍会重新走所有步骤**。已安装的会跳过，但不会跳过检查本身。

想只更新配置：

```bash
git pull --ff-only
bash dotlink/dotlink link
```

不需要重跑 `init.sh`。

## 排错

**某步失败但脚本继续了**：这是设计行为。看 warning 信息，手动补该步骤。

**字体没装**：`--minimal` 跳过了。单独运行 `bash scripts/install/install_font.sh`。

**Neovim 版本旧**：可能 Step 9 之后 Neovim 步骤失败。单独跑 `bash config/nvim/init.sh`。

**`~/.zshrc` 还是旧文件**：Step 9 失败。手动 `bash dotlink/dotlink link`。

**NixOS 上装不了 Docker**：预期行为，脚本明确跳过。
