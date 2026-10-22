> 摘要：按实际安装与配置来源列出 shell 工具、交互命令、文件管理器和终端组件。

# 工具目录

## 目录范围

init.sh 会准备基础工具；Zinit 在 Zsh 启动时下载一些 release 二进制和插件；其他工具可能由系统包管理器提供。这里记录仓库实际配置或集成的程序，不把安装器提及的每个依赖都说成仓库自带配置。

## 日常命令

| 工具 | 配置来源 | 常用入口 |
|---|---|---|
| **eza** | 可选，检测到时定义列表别名 | `l`、`ll`、`la`；`ll` 带大小、权限和 Git 状态 |
| **bat** | Zinit release 命令 | `bat file`；也用于 fzf 文件预览 |
| **fd** | Zinit 安装；Debian 的 `fdfind` 有后备 | `fd pattern [path]`；fzf 默认文件枚举 |
| **ripgrep** | Zinit 提供 `rg` | `rg pattern [path]`，遵守 ignore 规则 |
| **fzf** | init.sh 检查/安装；Zsh source 上游补全和按键 | Ctrl+T 文件，Alt+C 目录，Ctrl+R 历史；另有 `f`、`ffd` |
| **zoxide** | Zinit 命令并初始化 shell hook | `z project`；`zi` 交互选择，`za` 添加，`zr` 移除 |
| **Atuin** | 系统版本优先，Zinit 兜底 | `atuin` 历史搜索；上箭头绑定 shell-up |
| **direnv** | Zinit release 命令和 hook | 在项目放 `.envrc`，用 `direnv allow` 授权 |
| **Starship** | 按 OS/CPU 下载 release | `starship explain` 查看提示符各段 |
| **Inshellisense** | init.sh 通过 npm 安装 | Tab 接受建议；`is doctor` 排错 |
| **fnm** | init.sh 安装，Shell 包装器惰性加载 | `fnm install --lts`、`fnm use`、`node --version` |

## Git 与系统查看

| 工具 | 配置来源 | 用法 |
|---|---|---|
| **forgit** | Zsh 插件 | `ga` 暂存、`gd` diff、`glo` 历史、`gcb` 分支、`gss` stash、`gcp` cherry-pick、`grb` rebase、`gwt` worktree |
| **lazygit** | Zinit release | 在仓库运行 `lazygit` 管理提交和分支 |
| **GitHub CLI** | Zinit 提供 `gh` | `gh auth status`、`gh repo view` |
| **gitui** | OS/CPU 对应 release | 在仓库运行 `gitui` |
| **delta** | Zinit release 子目录 | Git diff pager 程序 |
| **btop** | Zinit release | `btop` 查看资源与进程 |
| **bottom** | Zinit 命令 `btm` | `btm` 资源监视器 |
| **duf** | Zinit 命令 | `duf` 文件系统用量 |
| **procs** | Zinit 命令 | `procs` 列进程，传名称可筛选 |
| **gping** | OS/架构 release | `gping host` 观察延迟曲线 |
| **xh** | Zinit 命令 | `xh https://example.com` 发 HTTP 请求 |
| **jq / yq** | Zinit release | `.json` 用 jq，YAML 用 yq 读取或改写 |
| **sd** | Zinit release | `sd 'old' 'new' file` 替换文本 |
| **choose** | Zinit release | `printf 'a b c\n' \\| choose 1` 抽取文本列 |
| **glow** | Zinit release | `glow README.md` 阅读 Markdown |
| **tealdeer** | 安装为 `tldr` | `tldr tar` 查命令示例 |
| **broot** | OS/架构 release | `broot` 浏览目录；Zsh 启动时生成 `br` 函数 |
| **zellij** | Zinit 命令和可选安装脚本 | `zellij` 启动终端多路复用器 |
| **Fresh** | init.sh 按平台安装 | `fr` 启动 Fresh 终端 IDE |
| **HTTPie** | 可选安装器 `install:httpie` | `http GET URL`、`http POST URL key=value` |

工具的安装入口和跨平台选择分别见 [init.sh](https://github.com/iamcheyan/dotfiles/blob/main/init.sh) 与 [tools.zsh](https://github.com/iamcheyan/dotfiles/blob/main/plugins/tools/tools.zsh)。forgit、navi、Pay Respects、Pet 和 Inshellisense 的详细步骤另见 [Zsh CLI 工具说明](https://github.com/iamcheyan/dotfiles/blob/main/docs/ZSH-CLI-TOOLS.md)。

## 命令片段和建议

- **navi** 搜索 cheatsheet、填写参数，再把命令放回当前命令行。个人片段默认在 `~/.local/share/navi/cheats/`。
- **Pet**：`pet new` 新建片段，`pet search` 搜索，`pet edit` 编辑。`Ctrl+X` 再 `Ctrl+R` 将选中命令填入输入行。
- **Pay Respects**：命令失败后输入 `f` 看修正建议，确认前先检查命令内容。
- **fzf-tab**：以 fzf 交互筛选 Zsh 补全候选，`<`、`>` 切换分组。
- **zsh-autosuggestions**：根据历史显示异步建议。

## 文件管理器

### Ranger

Ranger 显示隐藏文件，启用文件预览、边框和 devicons。Archives 插件注册 `:extract`、`:compress`，映射为 `ex`、`ec`。包装函数 `ra [目录]` 在退出后把 shell 切到 Ranger 留下的目录。

### Vifm

Vifm 用 Neovim 作编辑器、启用 trash 和隐藏文件。`a` 新建、`r` 重命名、`d` 移入 trash、`D` 直接删除；Tab/Shift-Tab 切 tab；`<Space>p` 切单栏/双栏。`cc`、`cf`、`cd`、`cn` 通过剪贴板脚本复制当前项路径、文件名、父目录或无扩展名名称。`v` 包装函数可在退出后切目录。

剪贴板脚本按 wl-copy、xclip、xsel、pbcopy、clip.exe 选择后端；没有后端会返回错误。

## 终端与编辑器

- **tmux** 配置 RGB、鼠标、vi copy mode、pane 导航和 session 恢复插件。快捷操作见 [应用配置](configs.html)。
- **Ghostty** 有独立字体、颜色和按键配置文件；当前 dotlink 映射未包含该文件，需手动链接。
- **Yazi** flavor 随仓库保存，但 Yazi 主配置属于私有配置边界。
- **Neovim** 由独立仓库维护，完整文档见 [nvim.iamcheyan.com](https://nvim.iamcheyan.com)。
