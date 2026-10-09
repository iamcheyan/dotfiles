# 🚀 Dotfiles — 现代化终端开发环境一键配置

> 基于 **Zsh + Vim/GVim + 自管 Neovim (lazy.nvim) + 本地 AI 工具 (Herdr)** 的全套极速、开箱即用终端配置方案。
> 纯公开、可独立使用；非 NixOS 平台支持一行命令跨平台初始化，NixOS 系统包由 `~/nixos-config` 管理。

## 🗺️ 配置仓库边界

本仓库是三层配置中的 **公开基础层**：只保存可公开复用的 Zsh、Vim/GVim、Neovim 和 CLI
配置。NixOS 系统包、服务、硬件及 Nixarchy 接线位于 `~/nixos-config`；个人
软件、Agent、输入法、终端与敏感配置编排位于私有 `~/chezmoi`。同一配置只在
一个仓库拥有，不跨仓库复制。

Neovim 配置源码由独立公开仓库 [`iamcheyan/nvim`](https://github.com/iamcheyan/nvim)
维护，并作为 `config/nvim` 子模块随本仓库一起安装。使用 dotfiles 的用户运行本仓库
`init.sh` 即可初始化子模块、准备 Neovim 并建立 `~/.config/nvim` 软链接；无需另行安装
Neovim 配置仓库。只想安装 Neovim 的用户也可以直接克隆该仓库，单独运行它自己的 `init.sh`。
本机维护时只编辑 `~/nvim`；dotlink 会识别它并让 `~/.config/nvim` 直接指向该工作树。其他用户没有这份工作树时，自动使用 dotfiles 内的子模块。

---

## 🌟 核心卖点

### 1. ⚡ 一键初始化（One-Click Setup）
* **跨平台全自动适配**：原生支持 **Debian / Ubuntu / Arch Linux / Fedora / Void / NixOS / macOS**。
* **NixOS 软件包边界**：检测到 NixOS 时，`init.sh` 不执行任何 Nix 软件包安装，只提示用户通过 `~/nixos-config` 的包模块声明并重建系统；用户目录配置和插件仍由本仓库部署。
* **一行命令完成初始化**：在支持的非 NixOS 平台自动安装所需工具链（`eza`、`bat`、`fd`、`ripgrep`、`zoxide`、`fzf`、`jq`、`btop` 等）、Nerd Font 字体、Zsh 插件与软链接；NixOS 的系统软件包和字体由 `~/nixos-config` 管理。

### 2. 🐚 极速现代化 Zsh 终端体验
* **Zinit 异步加载**：零延迟秒开，告别臃肿缓慢的 oh-my-zsh。
* **Starship 智能 Prompt**：优雅、信息丰富、极速渲染的终端提示符。
* **zsh-vi-mode 深度整合**：原生 Vim 命令行编辑模式，在终端直接享受 `hjkl`。
* **强大的补全与历史**：
  * `fzf-tab`：可视化的模糊搜索交互补全界面。
  * `zsh-autosuggestions` + `zsh-autopair`：智能历史建议与括号自动配对。
  * `Atuin`（`Ctrl+R`）：支持上下文关联的增强版命令历史搜索。
  * `Zoxide`（`z`）：智能目录学习与快速跳转。
* **现代 CLI 替换传统命令**：
  * `ls` $\rightarrow$ `eza`（带色彩与图标的高颜值文件列表，支持 `l`, `ll`, `la`）
  * `cat` $\rightarrow$ `bat`（带语法高亮与行号的文件查看器）
  * `find` $\rightarrow$ `fd` / `grep` $\rightarrow$ `ripgrep`（千百倍极速文本与文件检索）

### 3. 📝 开箱即用的专业自管 Neovim（基于 lazy.nvim）
* **纯自管轻量架构**：直接基于 `lazy.nvim` 精心构建，**非** 臃肿黑盒发行版（非 AstroNvim/LazyVim），代码结构透明清晰，启动时间 < 50ms。
* **完整的现代 IDE 能力**：
  * **LSP 自动管理**：Mason + Mason-LSPconfig 一键安装并管理各语言 Language Server。
  * **代码补全与格式化**：Blink.cmp 极速智能补全 + Conform 自动代码格式化。
  * **语法分析与高亮**：Treesitter 语法高亮、代码折叠与文本对象。
    **需要 Neovim 0.12 或更高版本**（`nvim-treesitter` 的 `main` 分支 + ABI-15 parser）。
    分支选择、parser 管理与常见报错处理见 [`config/nvim/docs/reference/TREESITTER.md`](config/nvim/docs/reference/TREESITTER.md)。
    COBOL、批处理脚本与手写配置文件的**大小写不敏感扩展名检测**见
    [`config/nvim/docs/reference/FILETYPE-DETECTION.md`](config/nvim/docs/reference/FILETYPE-DETECTION.md)。
* **生产力神器合集**：
  * `Snacks.picker`：查找文件、文本、缓冲区和符号，并提供启动页、通知与状态列。
  * `Neo-tree`：侧边栏文件树、缓冲区列表和 Git 状态视图。
  * `Flash.nvim`：键盘任意位置双键直达跳转。
  * `Gitsigns` + `Diffview`：行级 Git 变更、差异查看与文件历史。
  * `Auto-session`：根据工作目录（cwd）全自动保存和恢复编辑现场。
  * `Yanky.nvim`：支持持久化剪贴板历史与循环粘贴。
  * `鼠标选区与剪贴板`：提供选区复制、智能粘贴和跨平台剪贴板适配。
    详细用法见 [`config/nvim/docs/guides/MOUSE-AND-CLIPBOARD.md`](config/nvim/docs/guides/MOUSE-AND-CLIPBOARD.md)。
  * `Caps Lock 状态实时指示器`：底部状态栏实时指示大写锁定状态（`CAPS ON` / `CAPS OFF` / `CAPS ?`），针对 WSL/tmux 环境提供零开销常驻 Worker 检测。
    技术原理与排错见 [`config/nvim/docs/guides/CAPS-LOCK.md`](config/nvim/docs/guides/CAPS-LOCK.md)。
  * `VimQuest`、`contextline.nvim`、`cobol.nvim`、`batch.nvim` 和 `bookmark.nvim`：由 lazy.nvim 安装的独立公开自研扩展，提供词汇练习、代码上下文、COBOL/Batch 工具和书签管理。
  * Neovim 插件使用书按类别列出公开、私有插件和依赖，并为每项提供独立操作章节与练习，见 [`config/nvim/docs/plugins/PLUGINS.md`](config/nvim/docs/plugins/PLUGINS.md)。

### 4. 🤖 本地 AI 工具与终端复用生态
* **内置热门本地 AI 助手 Herdr**：
  * `init.sh` 脚本自动安装并配置当前热门的终端本地 AI 编程助手 [Herdr](https://herdr.dev/)。
  * 预置优雅的主题配置文件（`~/.config/herdr/config.toml`），开箱即用。
* **轻量文件管理器**：内置配置好的 `Ranger`（按 `ra` 快速调用）与 `Vifm`（按 `v` 快速调用）。
* **自研零依赖软链工具 `dotlink`**：纯 Shell 编写的极简配置软链管理器，不依赖 Chezmoi 或任何外部工具即可独立运转。

---

## 📦 快速安装与使用

### 第一步：克隆本仓库

```bash
git clone https://github.com/iamcheyan/dotfiles.git ~/dotfiles
cd ~/dotfiles
```

### 第二步：运行初始化脚本

```bash
bash init.sh              # 推荐：完整初始化（NixOS 系统包由 nixos-config 管理）
bash init.sh --minimal    # 轻量安装（跳过字体等大型组件）
bash init.sh --repair     # 修复损坏的插件缓存
```

> **初始化脚本会自动完成**：
> 1. 按平台检查或安装 Zsh，并在用户确认后设为默认 Shell。
> 2. 在非 NixOS 平台安装必备现代工具链（`git`、`curl`、`ripgrep`、`fd`、`bat`、`eza`、`zoxide`、`fzf`、`jq`、`btop` 等）；NixOS 由 `~/nixos-config` 管理。
> 3. 安装配置 `zinit`、`Starship`、`Atuin`；非 NixOS 平台额外配置 `fnm`。
> 4. 初始化 `config/nvim` 子模块，并运行其中的 `init.sh` 检查或安装 Neovim 0.12+、准备依赖、把 `~/.config/nvim` 链接到子模块源码；插件由首次启动时的 lazy.nvim 安装。NixOS 软件包由 `~/nixos-config` 管理。
> 5. 在支持的非 NixOS Linux 发行版安装 Docker 与 Herdr 本地 AI 助手。
> 6. 通过 `dotlink` 自动建立全部配置文件的符号链接。
> 7. 初始化后可运行 `nvim-update` 安全升级至官方最新稳定版；脚本校验 GitHub release SHA-256，不替换系统包。

### Fresh Terminal IDE

`init.sh` 会按平台安装 [Fresh](https://github.com/sinelaw/fresh)：Linux/WSL 使用官方 universal installer，macOS 使用 Homebrew，Windows（Git Bash/MSYS/Cygwin）使用 winget。NixOS 不执行独立安装，由 `~/nixos-config` 的 `fresh-editor` 包管理；安装后可用 `fr` 启动。

### 第三步：应用软链接并进入环境

```bash
bash dotlink/dotlink link
exec zsh
```

### Optional local Zsh configuration

Personal aliases and Zsh overrides can be stored in the repository's local
directory. The directory is prepared with a usage guide, while user-created
files remain ignored:

```bash
mkdir -p "$HOME/dotfiles/local"
$EDITOR "$HOME/dotfiles/local/custom.zsh"
```

Every regular file in `local/` is loaded last by `zshrc`, after the public
aliases and plugins, so the files can define aliases, functions, environment
variables, and other Zsh settings. `README.md` is skipped. Only
`local/README.md` is tracked. Other files under `local/` are ignored by Git
and are never overwritten by a `git pull` or dotfiles update. `init.sh` does
not create this directory; create it only when you need local overrides.

Example:

```zsh
# ~/dotfiles/local/custom.zsh
alias work='cd ~/work'
export PROJECTS_DIR="$HOME/projects"
```

---

## 📂 部署目标软链接清单

通过 `dotlink` 会在系统中建立以下干净的符号链接：

| 源码路径 | 目标部署路径 | 对应功能 |
|---|---|---|
| `~/dotfiles/zshrc` | `~/.zshrc` | Zsh 主配置文件 |
| `~/dotfiles/config/vim/vimrc` | `~/.vimrc` | Vim 默认主题与配置 |
| `~/dotfiles/config/gvim/gvimrc` | `~/.gvimrc` | GVim 图形配置 |
| `~/dotfiles/config/nvim` | `~/.config/nvim` | Neovim 完整 IDE 配置 |
| `~/dotfiles/config/ranger` | `~/.config/ranger` | Ranger 终端文件管理器 |
| `~/dotfiles/config/vifm/*` | `~/.config/vifm/*` | Vifm 终端文件管理器 |
| `~/dotfiles/config/atuin` | `~/.config/atuin` | Atuin 命令历史搜索配置 |
| `~/dotfiles/config/herdr/config.toml` | `~/.config/herdr/config.toml` | Herdr 本地 AI 助手配置 |
| `~/dotfiles/config/starship/starship.toml` | `~/.config/starship.toml` | Starship 终端提示符主题 |

---

## ⌨️ 常用快捷键速查

### 1. 终端命令行（Zsh Vim 模式）
* **`Ctrl + R`**：呼出 Atuin 增强版历史命令搜索
* **`Esc`**：进入命令行 Vim 普通模式（支持 `h/j/k/l` 移动、`w/b` 跳词、`dd` 删行、`cw` 改词）
* **`l` / `ll` / `la`**：调用 `eza` 查看带图标与 Git 状态的文件列表
* **`z <目录名>`**：Zoxide 智能跳转目录
* **`ra`**：打开 Ranger 并在退出时自动 `cd` 到最后停留的目录
* **`v`**：打开 Vifm 并在退出时自动 `cd` 到最后停留的目录

### 2. Neovim 核心键位（空格键 Leader）
* **`<Space> e`**：展开/折叠 Neo-tree 侧边栏文件树
* **`-`**：打开 Oil 目录编辑器（直接把目录当作 Buffer 增删重命名文件）
* **`<Space> ff`**：全局模糊查找文件（Find Files）
* **`<Space> fg`**：全局代码文本搜索（Live Grep）
* **`<Space> gg`**：打开 Lazygit 交互界面
* **`<Space> xx`**：打开 Trouble 错误与警告诊断列表
* **`s` + 双字符**：Flash 屏幕任意位置双键直达跳转
* **`gcc`**：单行注释 / 取消注释
* **`gc`**：选中区域代码块注释

---

## 🛠️ 项目目录结构

```text
dotfiles/
├── zshrc                  # Zsh 主入口配置
├── aliases.conf           # 通用别名与实用函数
├── init.sh                # 跨平台初始化脚本
├── dotlink/               # 自研轻量符号链接管理器
├── config/                # 应用配置集合
│   ├── vim/               # Vim 终端配置与 Blue 主题
│   ├── gvim/              # GVim 图形配置
│   ├── nvim/              # iamcheyan/nvim 子模块；由 dotfiles init 一起安装
│   ├── herdr/             # Herdr 本地 AI 助手配置
│   ├── ranger/            # Ranger 文件管理器配置
│   ├── vifm/              # Vifm 文件管理器配置
│   ├── atuin/             # Atuin 命令历史配置
│   └── starship/          # Starship 提示符主题
├── plugins/               # Zsh 插件与补全辅助
├── scripts/               # 安装、升级与系统检测脚本
│   ├── install/           # init.sh 调用的安装脚本
│   ├── setup/             # shell 运行时 source 的配置脚本
│   ├── update_nvim.sh     # 官方稳定版 Neovim 升级脚本（alias nvim-update）
│   └── tests/             # 脚本回归测试
└── tools/                 # 通用实用工具脚本
```

---

## 🔒 纯净与安全承诺

* **100% 通用开源**：本仓库**绝不包含**任何个人 API Key、密码、Token、私有服务器 IP 或硬编码绝对路径。
* **独立运行**：不强绑 Chezmoi 或任何私有系统，任何人均可放心 Fork 与二次定制。

---

## 📄 开源许可证

本项目基于 [MIT 许可证](LICENSE) 开源。欢迎 Star 🌟 与 Fork！

## Neovim 独立仓库与随 dotfiles 安装

Neovim 源码位于公开的 [`iamcheyan/nvim`](https://github.com/iamcheyan/nvim)，本仓库通过
`config/nvim` 子模块固定配置版本。完整运行 `init.sh` 时会初始化子模块，调用其中的
`init.sh` 安装或检查 Neovim 和依赖；随后 dotlink 会在维护者本机优先链接 `~/nvim`，其他用户链接子模块。插件在首次
启动 Neovim 时由 lazy.nvim 安装；原有 dotlink 路径保持不变。

普通用户无需单独克隆 nvim 仓库，新克隆 dotfiles 后运行 `bash init.sh` 即可一起安装。
也可以分别运行 `git submodule update --init --recursive` 和 `bash dotlink/dotlink link`
来初始化并链接配置。只想使用 Neovim 时，直接克隆 nvim 仓库并运行其 `init.sh` 即可，
无需安装本 dotfiles 仓库。

Neovim 需要 **0.12+**，Treesitter 还需要 Tree-sitter CLI 0.26.1+。运行过初始化的
clone 会启用递归 Git 更新，普通 `git pull` 会跟随 dotfiles 记录的配置版本。维护者在
`~/nvim` 内编辑和提交，再回 dotfiles 更新 `config/nvim` 子模块指针。Treesitter 详情见
[`config/nvim/docs/reference/TREESITTER.md`](config/nvim/docs/reference/TREESITTER.md)。
