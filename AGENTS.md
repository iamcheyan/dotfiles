# Public Dotfiles (Zsh + Neovim)

本仓库是一个可独立运行、面向公开分享的 Zsh + Neovim 配置项目。
它使用自研的 `dotlink` 建立软链接，不依赖 Chezmoi。

## 1. 仓库定位

本仓库只存放适合公开分享的通用配置：

- Zsh 启动文件、通用 aliases、插件、补全与 prompt
- Neovim 配置与公开插件
- Ranger、Vifm、Ghostty、Starship 等通用工具配置
- `dotlink` 软链接工具与跨平台初始化脚本
- `config/tmux/tmux.conf`：Tmux 通用主配置
- `local/`：用户自定义的本地覆盖配置

本机共有三个主要配置仓库：`~/nixos-config` 是 NixOS 系统层，`~/chezmoi`
是用户级私人编排层，本仓库是公开基础层。需要 `nixos-rebuild`、涉及 `/etc`、
系统服务/包/驱动/用户组的配置进入 nixos-config；不能公开或属于个人软件编排的
用户配置进入 chezmoi。

本仓库**不负责**个人私有配置。以下内容由私有 `~/chezmoi` 管理：

- Kitty、Yazi、Zellij、Fcitx5、Karabiner、Sumika Shell
- AI Agent wrappers、Agent quota、OpenCode 私人 provider 配置
- Tmux 主配置及私有 Agent 恢复规则
- API Key、Token、`.env`、私有服务器地址、机器专属脚本

公开仓库中不得提交密码、Token、API Key、SSH 私钥、真实凭据或个人机器的绝对路径。

## 2. 独立使用

不安装 Chezmoi 也可以独立使用本项目：

```bash
git clone https://github.com/iamcheyan/dotfiles.git ~/dotfiles
cd ~/dotfiles
bash init.sh
bash dotlink/dotlink link
```

`init.sh` 负责安装通用依赖和初始化环境；`dotlink` 负责建立配置软链接。

## 3. 修改配置

直接编辑仓库源文件，不要编辑软链接目标：

```bash
cd ~/dotfiles
$EDITOR zshrc
$EDITOR aliases.conf
$EDITOR config/nvim/lua/

bash dotlink/dotlink link
exec zsh
```

新增或删除需要部署的配置时，修改 `dotlink/dotlinkrc` 的 `[link]` 段，然后运行：

```bash
bash ~/dotfiles/dotlink/dotlink link
```

## 4. 路径与跨平台规则

- 使用 `$HOME`、`~` 和相对路径；禁止写死 `/Users/<name>` 或 `/home/<name>`。
- 公共 Zsh 保留通用的 `TERM` terminfo 降级保护。
- 不在公开 Zsh 中手动加载 Kitty shell integration。Kitty 自己的 shell integration 由私有 Kitty 配置管理。
- 公共配置可以探测可选命令，例如 `command -v eza`，缺少时应保留可用的 fallback，而不是启动失败。

## 5. 与 Chezmoi 的边界

主力机器的私有配置位于：

```text
~/chezmoi/
```

Chezmoi 会通过 `symlink_dot_zshrc.tmpl` 创建：

```text
~/.zshrc -> ~/dotfiles/zshrc
```

这意味着：

- `zshrc` 的通用内容在本公开仓库维护。
- `~/.config/aliases.conf` 等本机私有扩展由 Chezmoi提供，公开 Zsh 只在文件存在时加载。
- 修改 Kitty、Agent、Fcitx5、Karabiner 等私有内容时，进入 `~/chezmoi`，不要把它们复制回本仓库。

## 6. 提交前检查

```bash
zsh -n zshrc
bash -n init.sh
bash -n aliases.conf

git diff --check

git status
```

提交前确认：

- 没有 `.env`、密钥、Token 或凭据文件
- 没有个人绝对路径、内网 IP 或私有域名
- 没有个人 Agent wrapper 或 provider 配置
- README、脚本路径与实际目录一致

## 7. 发布流程

```bash
cd ~/dotfiles
git add .
git diff --cached --check
git commit -m "feat: describe the public configuration change"
git push origin main
```

发布后的配置应当能被另一台没有 `~/chezmoi` 的机器单独克隆并运行。若某项功能只有个人环境可用，应移到私有 Chezmoi，而不是在公开仓库中添加更多机器特判。

## 8. Neovim 独立仓库与随 dotfiles 安装

Neovim 配置源码由公开仓库 [`iamcheyan/nvim`](https://github.com/iamcheyan/nvim)
统一维护，并作为 `config/nvim` 子模块随 dotfiles 一起安装。完整运行 `init.sh` 会初始化
子模块、调用其 `init.sh` 检查或安装 Neovim 及依赖，并建立原有的 `~/.config/nvim` 软链接。
只使用 Neovim 的用户也可以直接克隆该仓库并运行它自己的 `init.sh`。

维护者本机只在 `~/nvim` 开发；dotlink 检测到该目录的 origin 为 `iamcheyan/nvim` 时，
会把 `~/.config/nvim` 链接到 `~/nvim`。其他用户没有该工作副本时，链接使用 dotfiles
内的 `config/nvim` 子模块。发布时在 `~/nvim` 提交并推送，然后更新 dotfiles 的子模块指针。
最低版本为 **Neovim 0.12**，Treesitter 还需要 Tree-sitter CLI 0.26.1+。插件首次启动时由 lazy.nvim 安装。
新用户和首次迁移者可运行 `git submodule update --init --recursive`。运行初始化后，
普通 `git pull` 会跟随主仓库记录的版本。Treesitter 说明见
[`config/nvim/docs/reference/TREESITTER.md`](config/nvim/docs/reference/TREESITTER.md)。
