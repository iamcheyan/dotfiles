> 摘要：从克隆、检查依赖到建立软链接，按实际 init.sh 与 dotlink 流程安装公开配置。

# 开始使用

## 先了解这套配置

仓库提供 Zsh 启动环境、CLI 配置、应用配置、安装脚本和自研软链接工具 `dotlink`。Neovim 源码是独立仓库，通过 `config/nvim` 子模块固定版本；插件目录、教程和键位查找见 [Neovim 配置站](https://nvim.iamcheyan.com)。

安装会改动用户配置目录。`dotlink` 对已有普通文件或目录会备份后移除并创建软链接；运行前确认需要保留的目标已有备份。`init.sh` 显示覆盖提示和倒数后继续。

## 安装

```bash
git clone https://github.com/iamcheyan/dotfiles.git ~/dotfiles
cd ~/dotfiles
git submodule update --init --recursive
bash init.sh
bash dotlink/dotlink link
exec zsh
```

`init.sh` 检测平台并准备基础依赖、Zsh、Zinit、fnm、Inshellisense、Fresh、fzf 和 Neovim，再建立配置链接。多个步骤按 best-effort 执行；失败时会输出 warning 并继续，安装后请检查需要的命令。

## 初始化选项

| 命令 | 效果 |
|---|---|
| `bash init.sh --minimal` | 跳过字体、Neovim 和部分大型额外组件 |
| `bash init.sh --repair` | 检查并修复损坏的 Zinit 插件 |

脚本遇到未知参数会跳过它；只使用表中的选项。NixOS 不由本仓库安装系统包，用户目录配置仍由 dotlink 部署。

## 安装后检查

```bash
command -v zsh git fzf nvim
command -v eza bat fd rg zoxide atuin
nvim --version
```

Zinit 管理的工具和插件在首次 Zsh 启动时下载。Neovim 插件由 lazy.nvim 首次启动时安装。查看实际链接映射：

```bash
sed -n '/^\[link\]/,$p' ~/dotfiles/dotlink/dotlinkrc
```

## 仓库路径可变

`zshrc` 从自身来源文件推导仓库目录，不要求必须安装在 `~/dotfiles`。`dotlink/dotlink` 使用 `$HOME` 展开规则，并在维护者机器上检测 `~/nvim` 是否指向预期 Neovim 仓库；普通用户则使用 `config/nvim` 子模块。
