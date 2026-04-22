# Zsh Plugin Inventory

本文档根据当前仓库中的 [zshrc](zshrc) 以及其引用的配置文件整理，描述这套 Zsh 环境会加载哪些组件、它们的作用，以及它们的加载方式。

说明：

- 这里记录的是“当前配置会加载的组件”，不是对 `~/.zinit` 实际磁盘内容的全盘扫描。
- 我把内容分成三类：
  - Zsh 插件/补全/提示符组件
  - 通过 `zinit` 安装并加入 `PATH` 的命令行工具
  - 本地 `source` 的功能配置
- “加载方式”中的常见含义：
  - `source`：直接读入本地 `.zsh` 文件
  - `zinit light`：以普通插件方式加载
  - `zinit snippet`：加载远程脚本、Oh My Zsh 片段或本地片段
  - `zinit light` + `as"command"`：下载二进制命令并放入可执行路径，不是传统 Zsh 插件
  - `wait"0"`：提示符出现后异步加载
  - `_evalcache ...`：对初始化输出做缓存，再 `eval`

## 1. 启动入口

当前启动路径如下：

1. `zshrc`
2. `source ~/.dotfiles/plugins/zinit/zinit.zsh`
3. `source ~/.dotfiles/plugins/prompt/prompt.zsh`
4. `source ~/.dotfiles/plugins/tools/tools.zsh`
5. `source ~/.dotfiles/plugins/completion/completion.zsh`
6. `zinit light mroth/evalcache`
7. `zinit light jeffreytse/zsh-vi-mode`
8. `zinit light zsh-users/zsh-history-substring-search`
9. `zinit snippet ~/.dotfiles/plugins/plugins/plugins.zsh` with `wait"0"`
10. `source ~/.dotfiles/plugins/fzf/fzf.zsh`
11. `_evalcache atuin init zsh`
12. `_evalcache zoxide init zsh`
13. `_evalcache direnv hook zsh`
14. `source ~/.dotfiles/plugins/spf/superfile.zsh` if present
15. `source ~/.dotfiles/plugins/local/local.zsh` if present

## 2. Zsh 插件、补全和提示符组件

| 组件 | 作用 | 加载方式 | 加载时机 |
| --- | --- | --- | --- |
| `romkatv/powerlevel10k` | 高性能提示符主题，显示目录、Git 状态、环境信息等 | `zinit light`，随后 `source ~/.p10k.zsh` | 同步加载 |
| `mroth/evalcache` | 缓存 `atuin init zsh`、`zoxide init zsh`、`direnv hook zsh` 的输出，减少重复初始化成本 | `zinit light` | 同步加载 |
| `jeffreytse/zsh-vi-mode` | 为 Zsh 提供 Vim 模式编辑、模式切换和按键绑定 | `zinit light` | 同步加载 |
| `zsh-users/zsh-history-substring-search` | 用上下键按当前输入内容搜索历史命令 | `zinit light` | 同步加载 |
| `zsh-users/zsh-completions` | 补充大量额外补全定义 | `zinit light` with `blockf` | 同步加载 |
| `Aloxaf/fzf-tab` | 用 `fzf` 接管 Tab 补全选择界面，并支持预览和分组 | `zinit light` | 同步加载，位于 `compinit` 之后 |
| `zsh-users/zsh-autosuggestions` | 根据历史记录和补全结果显示灰色命令建议 | `zinit light` | 异步加载，来自本地片段 |
| `zdharma-continuum/fast-syntax-highlighting` | 输入时高亮命令、参数、路径和错误语法 | `zinit light` | 异步加载，来自本地片段 |
| `hlissner/zsh-autopair` | 自动补全括号、引号等成对字符 | `zinit light` | 异步加载，来自本地片段 |
| `wfxr/forgit` | 基于 `fzf` 的 Git 交互工具，如交互式 `add`、`log`、`diff` | `zinit load` with `wait"0"` | 异步加载 |
| `OMZP::sudo` | 输入两次 `Esc` 后自动给上一条命令加 `sudo` | `zinit snippet` | 异步加载 |
| `OMZP::git` | 提供一组 Git 别名和辅助函数 | `zinit snippet` | 异步加载 |
| `1mykull/zshcp` | 剪贴板辅助功能，供路径/文件复制类功能使用 | `zinit light` | 异步加载 |
| `OMZP::copypath` | 复制文件或目录路径到剪贴板 | `zinit snippet` | 异步加载 |
| `OMZP::copyfile` | 复制文件内容到剪贴板 | `zinit snippet` | 异步加载 |
| `MichaelAquilina/zsh-you-should-use` | 当你输入了已有别名的原始命令时给出提示 | `zinit light` | 异步加载 |
| `le0me55i/zsh-extract` | 用一个命令解压多种常见压缩格式 | `zinit light` | 异步加载 |
| `paulirish/git-open` | 快速在浏览器打开当前仓库、分支、提交或文件对应的远程页面 | `zinit light` | 异步加载 |
| `OMZP::colored-man-pages` | 为 `man` 页增加颜色 | `zinit snippet` | 异步加载 |
| `Tarrasch/zsh-bd` | 通过目录名快速跳回上级目录 | `zinit light` | 异步加载 |
| `zdharma-continuum/zsh-navigation-tools` | 一组基于终端 UI 的导航工具 | `zinit light` | 异步加载 |
| `junegunn/fzf` shell snippets | 提供 `fzf` 的官方补全和按键绑定脚本 | `zinit snippet` 加载远程 `completion.zsh` 与 `key-bindings.zsh`，并在本地 `fzf.zsh` 中兼容系统安装版 | 同步注册补全；本地功能配置异步加载 |

## 3. 通过 hook 或 init 接入的命令行组件

这些组件不完全属于“传统插件”，但确实会在 Zsh 里注册 hook、函数、补全或 shell 集成。

| 组件 | 作用 | 加载方式 | 加载时机 |
| --- | --- | --- | --- |
| `atuin` | 增强 shell 历史，支持全文搜索、同步和更强的历史检索 | 先用 `zinit light` + `as"command"` 下载命令，再通过 `_evalcache atuin init zsh` 初始化 | 二进制同步可用，hook 同步初始化 |
| `zoxide` | 更智能的目录跳转工具 | 先用 `zinit light` + `as"command"` 下载命令，再通过 `_evalcache zoxide init zsh` 初始化 | 二进制同步可用，hook 同步初始化 |
| `direnv` | 进入目录时自动加载/卸载环境变量 | 先用 `zinit light` + `as"command"` 下载命令，再通过 `_evalcache direnv hook zsh` 初始化 | 二进制同步可用，hook 同步初始化 |
| `pyenv` | Python 版本管理 | 本地 `eval "$(pyenv init -)"` | 同步初始化 |
| `pyenv-virtualenv` | Python 虚拟环境集成 | 本地 `eval "$($PYENV_ROOT/plugins/pyenv-virtualenv/bin/pyenv-virtualenv-init -)"` | 同步初始化，条件加载 |
| `nvm` | Node.js 版本管理 | 在 `zshrc` 中定义 `load_nvm` 和 `nvm()` 惰性加载函数，首次调用 `nvm` 时才 `source ~/.nvm/nvm.sh` | 惰性加载 |
| `superfile` | 若本地配置存在，则加载 superfile 相关 shell 配置 | `source ~/.dotfiles/plugins/spf/superfile.zsh` | 条件同步加载 |

## 4. 通过 zinit 安装并加入 PATH 的命令行工具

这些主要是命令行工具，不会像 `zsh-autosuggestions` 那样直接拦截键盘输入；它们通常通过 `zinit light` + `as"command"` 从 GitHub Release 下载。

| 工具 | 作用 | 加载方式 |
| --- | --- | --- |
| `btop` | 资源监控面板 | `zinit light` + `as"command"` |
| `btm` (`bottom`) | 终端系统监控 | `zinit light` + `as"command"` |
| `duf` | 以更友好的形式查看磁盘使用情况 | `zinit light` + `as"command"` |
| `lazygit` | Git TUI | `zinit light` + `as"command"` |
| `delta` | Git diff 高亮查看器 | `zinit light` + `as"command"` |
| `gh` | GitHub CLI | `zinit light` + `as"command"` |
| `jq` | JSON 处理工具 | `zinit light` + `as"command"` |
| `yq` | YAML/JSON/XML 处理工具 | `zinit light` + `as"command"` |
| `sd` | 类似 `sed` 的现代文本替换工具 | `zinit light` + `as"command"` |
| `choose` | 文本字段筛选工具 | `zinit light` + `as"command"` |
| `glow` | 在终端渲染 Markdown | `zinit light` + `as"command"` |
| `tldr` (`tealdeer`) | `tldr` 客户端，快速查命令示例 | `zinit light` + `as"command"`，按平台选发行包 |
| `xh` | 类似 HTTPie 的 HTTP 客户端 | `zinit light` + `as"command"` |
| `gping` | 图形化 `ping` | `zinit light` + `as"command"`，按平台选发行包 |
| `bat` | 带高亮的 `cat` 替代 | `zinit light` + `as"command"` |
| `fd` | 更快的文件查找工具 | `zinit light` + `as"command"`，带特殊 `mv/pick/sbin` 规则 |
| `rg` (`ripgrep`) | 高性能文本搜索工具 | `zinit light` + `as"command"`，带特殊 `mv/pick/sbin` 规则 |
| `zoxide` | 智能目录跳转 | `zinit light` + `as"command"` |
| `yazi` | 终端文件管理器 | `zinit light` + `as"command"`，按平台选发行包 |
| `eza` | 现代版 `ls` | `zinit light` + `as"command"` |
| `dust` | 现代版磁盘占用查看 | `zinit light` + `as"command"` |
| `procs` | 现代版 `ps` | `zinit light` + `as"command"` |
| `zellij` | 终端多路复用器 | `zinit light` + `as"command"` |
| `direnv` | 环境变量目录钩子工具本体 | `zinit light` + `as"command"` |
| `atuin` | shell 历史工具本体 | `zinit light` + `as"command"`，按平台选发行包 |

## 5. 本地功能配置和自定义函数

这些不是外部插件，但它们确实是当前 Zsh 行为的一部分。

| 本地配置 | 作用 | 加载方式 |
| --- | --- | --- |
| `plugins/completion/completion.zsh` | 初始化 `compinit`、配置 `fzf-tab`、补全缓存、PATH 整理 | `source` |
| `plugins/fzf/fzf.zsh` | 配置 `FZF_DEFAULT_COMMAND`、`FZF_DEFAULT_OPTS`，定义 `ff`、`rf`、`zd`、`zc`、`y` 等函数 | `source` |
| `plugins/local/local.zsh` | 本机专用配置，目前包含字体安装提示逻辑 | `source`，条件加载 |
| `aliases.conf` | 命令别名 | `source` |
| `load_nvm` / `nvm()` | `nvm` 惰性加载入口 | 在 `zshrc` 中定义函数 |
| `vi()` | 优先使用 `nvim` 的包装函数 | 在 `zshrc` 中定义函数 |
| `zvm_after_init()` | 给 `zsh-vi-mode` 设置历史搜索按键绑定 | 在 `zshrc` 中定义函数，供插件回调 |

## 6. 当前加载方式总结

### 同步加载

- `source ~/.dotfiles/plugins/zinit/zinit.zsh`
- `source ~/.dotfiles/plugins/prompt/prompt.zsh`
- `source ~/.dotfiles/plugins/tools/tools.zsh`
- `source ~/.dotfiles/plugins/completion/completion.zsh`
- `zinit light mroth/evalcache`
- `zinit light jeffreytse/zsh-vi-mode`
- `zinit light zsh-users/zsh-history-substring-search`
- `_evalcache atuin init zsh`
- `_evalcache zoxide init zsh`
- `_evalcache direnv hook zsh`

### 异步加载

- `zinit snippet ~/.dotfiles/plugins/plugins/plugins.zsh` with `wait"0"`
- 这两个片段内部声明的 `zinit light` / `zinit snippet` 组件也随之延后生效

### 惰性加载

- `nvm`

## 7. 哪些组件最可能影响交互性能

如果你后面要继续排“打字卡”，优先关注这几类：

- `zsh-users/zsh-autosuggestions`
- `zdharma-continuum/fast-syntax-highlighting`
- `hlissner/zsh-autopair`
- `jeffreytse/zsh-vi-mode`
- `Aloxaf/fzf-tab`
- `romkatv/powerlevel10k` 的 `vcs` 段和右侧环境段
- `direnv`、`pyenv`、`atuin` 在提示符或目录切换时带来的额外开销
