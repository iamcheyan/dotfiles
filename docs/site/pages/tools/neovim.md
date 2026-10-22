> 摘要：Neovim 是本仓库的主力编辑器，源码在独立仓库，通过子模块固定版本。

# Neovim

## 用途

Neovim 是本仓库默认的编辑器：`$EDITOR`、`$VISUAL`、`vi` 函数、Ranger 的 `rifle.conf`、fzf 的选中动作，全部指向 `nvim`。

## 来源与版本

| 项目 | 说明 |
|---|---|
| 源码仓库 | `iamcheyan/nvim`（独立公开仓库） |
| 本仓库中的位置 | `config/nvim`，git 子模块 |
| 最低版本 | 0.12 |
| 安装 | `init.sh` 调用子模块的 `init.sh --skip-plugins` |

```bash
git submodule status
# fd9ac81ffd366a7674b71cb3b97daf53b9de06b7 config/nvim (heads/main-6-gfd9ac81)
```

这个 gitlink 决定了你拿到哪一版 Neovim 配置。

## 为什么要独立仓库

Neovim 配置本身是一个完整项目：几十个插件、教程、百科、键位文档、自己的站点。放在 dotfiles 里会让主仓库变得难以维护。

所以拆成两个仓库：

```text
iamcheyan/dotfiles  ──子模块──▶  iamcheyan/nvim
      │                                │
      ├── zshrc                        ├── lua/plugins/
      ├── aliases.conf                 ├── docs/
      ├── dotlink/                     ├── site/
      └── scripts/                     └── init.sh
```

## 安装路径

`init.sh` 不会直接装 Neovim，而是调用子模块自己的安装器：

```bash
bash "$nvim_init" --skip-plugins
```

`--skip-plugins` 表示只准备 Neovim 本体和依赖，插件留给首次启动的 lazy.nvim。这样做是因为插件安装需要完整运行时，在安装脚本里做容易失败。

## 版本升级

本地稳定版用 `nvim-update`：

```bash
nvim-update
```

它会下载 GitHub 最新稳定 release，校验 SHA-256，安装到 `~/.local/opt/neovim/<version>`，再原子切换 `~/.local/bin/nvim`。详见 [nvim-update](../scripts/nvim-update.html)。

配置本身的升级靠子模块指针：

```bash
cd ~/dotfiles
git pull --ff-only
git submodule update --init --recursive
```

## 配置入口

| 文件 | 作用 |
|---|---|
| `config/nvim/init.lua` | 入口，只 require `config.lazy` |
| `config/nvim/lua/config/` | 选项、键位、lazy 引导、UI |
| `config/nvim/lua/plugins/` | 每个插件一个文件 |
| `config/nvim/after/` | filetype 覆盖 |

`lua/config/lazy.lua` 里设置了 leader 键（空格）和 `maplocalleader`（反斜杠），然后 `require("lazy").setup({ { import = "plugins" } })`。

## 关键设计

### 不用发行版

本配置直接基于 `lazy.nvim`，不是 LazyVim/AstroNvim 之类的发行版。好处是每个插件为什么存在、怎么配置都清楚；代价是要自己维护。

### 键位生成而非手写

站点上的键位表由运行时导出生成，不是手写的。这样键位和实际配置永远一致。

### 文档即站点

`config/nvim/docs/` 里的 Markdown 同时是 GitHub 文档和站点内容源，一份内容两处用。

## 与 dotfiles 的联动

| 位置 | 联动方式 |
|---|---|
| `dotlink/dotlinkrc` | `config/nvim` → `~/.config/nvim` |
| `aliases.conf` | `vi` 函数优先调 nvim，`$EDITOR` 设为 nvim |
| `config/ranger/rifle.conf` | 用 `$VISUAL` 打开文件 |
| `plugins/fzf/fzf.zsh` | 选中文件用 `nvim` 打开 |
| `config/vim/vimrc` | 尽量镜像 Neovim 的通用键位 |

## 维护者机器上的特例

`dotlink` 里有一段：

```bash
if [[ "$dest" == "$HOME/.config/nvim" && -f "$HOME/nvim/init.lua" ]]; then
    local nvim_remote
    nvim_remote=$(git -C "$HOME/nvim" remote get-url origin 2>/dev/null || true)
    if [[ "$nvim_remote" =~ (^|[:/])iamcheyan/nvim(\.git)?$ ]]; then
        src="$HOME/nvim"
    fi
fi
```

如果本机有 `~/nvim` 且它的 origin 是这个仓库，就优先链接它，而不是子模块。这样维护者可以直接在 `~/nvim` 开发，不用每次进子模块目录。

普通用户没有这个工作副本，走子模块路径。

## 完整文档

Neovim 配置有自己的站点，内容比这里详细得多：

- [nvim.iamcheyan.com](https://nvim.iamcheyan.com) — 总入口
- [安装](https://nvim.iamcheyan.com/install.html) — 详细安装流程
- [插件目录](https://nvim.iamcheyan.com/plugins.html) — 每个插件的说明
- [教程](https://nvim.iamcheyan.com/tutorials.html) — 从 vi 历史讲起
- [百科](https://nvim.iamcheyan.com/wiki.html) — LSP、Treesitter、编码等概念
- [知识](https://nvim.iamcheyan.com/reference.html) — 选项、命令、术语表

## 排错

**`nvim` 版本低于 0.12**：走了系统包。`nvim-update` 建立用户级安装。

**打开是裸 Neovim**：`~/.config/nvim` 指向空目录。`git submodule update --init --recursive`。

**插件没装**：首次启动需要联网，lazy.nvim 会下载。检查 `:Lazy` 界面。

**键位和文档不符**：子模块版本落后。`git submodule update` 拉到最新。

**改了配置不生效**：确认改的是 `~/nvim`（维护者）或 `config/nvim`（普通用户），而不是软链接目标。
