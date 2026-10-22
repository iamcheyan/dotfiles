> 摘要：从克隆到 exec zsh，按 init.sh 与 dotlink 的真实执行顺序走一遍安装。

# 安装流程

## 前置条件

`init.sh` 会自己检查或安装大部分依赖，但你至少需要一个可用的 shell、`git` 和网络。支持 Debian/Ubuntu、Arch、Fedora、Void、macOS、WSL；NixOS 只部署用户目录配置，系统包由声明式配置管理。

```bash
git --version
bash --version
```

## 四步安装

```bash
git clone https://github.com/iamcheyan/dotfiles.git ~/dotfiles
cd ~/dotfiles
git submodule update --init --recursive
bash init.sh
```

前三步是纯粹的获取代码，不会改动你的配置。真正会改动系统的是 `bash init.sh`。

`git submodule update` 这一步不能省：`config/nvim` 是 gitlink，不初始化它，dotlink 会链接到一个空目录。

## init.sh 实际做了什么

脚本按固定顺序执行 11 个步骤，每一步失败时打印 warning 并继续，不会整体中断：

| 步骤 | 动作 |
|---|---|
| 1 | 定位 dotfiles 仓库目录 |
| 2 | 检查/安装 zsh |
| 3 | 安装基础工具（git、curl、build-essential 等） |
| 3.5 | 初始化 git 子模块 |
| 4 | 检查/安装 zinit |
| 5 | 检查/安装 fnm |
| 5.5 | 安装并初始化 Inshellisense |
| 6 | 检查/安装 Fresh |
| 7 | 检查/安装 fzf |
| 8 | 调用 dotlink 建立软链接 |
| 8.5 | 检查 ranger 插件 |
| 9 | 创建 `~/.zshrc` 软链接 |

后面还有字体、Neovim、Docker、Zellij、gh-dash、Herdr 等额外组件。**注意顺序：软链接在字体和 Neovim 之前建立**，所以中途失败时链接可能已经生效，而依赖还没装好。

## 覆盖提示

`init.sh` 启动时会明确提示：会替换已有的配置文件，并倒数 3 秒。它不会静默覆盖。如果你想先看它会动哪些文件，先只运行链接部分：

```bash
bash dotlink/dotlink list
```

## 安装后必须做的一步

```bash
exec zsh
```

当前 shell 还是 bash 或旧配置，必须重新加载才能用上新的 `zshrc`。首次启动会触发 Zinit 下载插件和工具，可能需要几分钟，期间终端可能看起来卡住。

## 如果中途失败

按步骤名排查，而不是重跑整个脚本：

```bash
command -v zsh git fzf nvim fnm
zinit list
ls -l ~/.zshrc ~/.config/nvim
```

`--repair` 专门处理 Zinit 插件损坏（例如 atuin 目录不完整）：

```bash
bash init.sh --repair
```

## 与 Neovim 的关系

`init.sh` 会在 `config/nvim` 里调用 Neovim 仓库自己的 `init.sh --skip-plugins`，只检查/安装 Neovim 本体和依赖，插件留给首次启动的 lazy.nvim。Neovim 的安装细节见 [Neovim 安装器](../scripts/nvim-install.html)。
