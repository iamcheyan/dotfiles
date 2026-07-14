# plugins/ - Zsh 插件和工具配置

此目录包含所有 Zsh 插件和工具的配置文件，通过 `~/.zshrc` 按顺序加载。所有插件都通过 [Zinit](https://github.com/zdharma-continuum/zinit) 插件管理器管理。

> 提示符主题使用 **Starship**（不再是 Powerlevel10k），详见 `prompt/`。

## 文件列表和加载顺序

配置文件按以下顺序在 `~/.zshrc` 中加载（真实顺序，见 `zshrc`）：

```
1. zinit/zinit.zsh      → Zinit 引导和初始化
2. prompt/prompt.zsh    → Starship 提示符主题
3. tools/tools.zsh      → CLI 工具管理（基于 as"command" from"gh-r"）
4. completion/completion.zsh → 补全系统 + fzf-tab + PATH
5. zinit light mroth/evalcache        → 缓存 init 脚本
6. scripts/setup/setup_fnm.sh         → fnm 环境（首次调用时初始化）
7. zinit light zsh-users/zsh-autosuggestions
8. zinit light hlissner/zsh-autopair
9. zinit light jeffreytse/zsh-vi-mode
10. plugins/plugins.zsh  → 其余 Zsh 功能插件
11. fzf/fzf.zsh          → fzf 配置与自定义函数
12. atuin init zsh       → 命令历史搜索（_evalcache 缓存）
13. zoxide init zsh      → 智能目录跳转（_evalcache 缓存）
```

> 注意：没有 `broot.zsh`、`aliases.conf` 或 `~/.p10k.zsh`，旧文档中的这些文件与当前配置不符。

## 文件详细说明

### 1. zinit/zinit.zsh - Zinit 插件管理器引导

**作用：**
- 自动安装 Zinit（如果不存在）
- 初始化 Zinit 插件管理器
- 提供 `zz` 函数，用于交互式选目录并切换

**调用方式：**
- 在 `~/.zshrc` 中通过 `source ~/dotfiles/plugins/zinit/zinit.zsh` 加载
- 必须在所有其他插件配置之前加载

### 2. prompt/prompt.zsh - Starship 提示符主题

**作用：**
- 通过 Zinit 从 GitHub Releases 安装 Starship 二进制
- 加载 Starship 的 Zsh 集成（`starship init zsh`）

**调用方式：**
- 在 `~/.zshrc` 中通过 `source ~/dotfiles/plugins/prompt/prompt.zsh` 加载
- 在 `zinit.zsh` 之后加载

**提供的功能：**
- 极速、跨 Shell 的现代化提示符
- 自定义配置位于 `~/.config/starship.toml`

### 3. tools/tools.zsh - CLI 工具管理

**作用：**
- 通过 Zinit 从 GitHub Releases 自动安装 CLI 工具的二进制文件（`as"command" from"gh-r"`）
- 使用统一的 `zi_cmd()` 函数简化安装
- fzf 的二进制由**系统包管理器**安装，这里只加载 fzf 的官方补全与键绑定 snippet

**调用方式：**
- 在 `~/.zshrc` 中通过 `source ~/dotfiles/plugins/tools/tools.zsh` 加载
- 工具会在首次使用时自动下载安装

### 4. completion/completion.zsh - 补全和 PATH 设置

**作用：**
- 初始化 Zsh 补全系统（`compinit`）
- 加载 `zsh-completions` 扩展补全定义
- 配置 `fzf-tab` 补全增强（用 fzf 替换默认补全菜单）
- 配置 PATH，确保所有工具可用

**调用方式：**
- 在 `~/.zshrc` 中通过 `source ~/dotfiles/plugins/completion/completion.zsh` 加载
- 必须在 `plugins/plugins.zsh` 和 `fzf/fzf.zsh` 之前加载（fzf-tab 需要在 `compinit` 之后、`zsh-autosuggestions` 之前）

**加载的插件：**
- `zsh-users/zsh-completions` - 额外补全定义集（`blockf`）
- `Aloxaf/fzf-tab` - 用 fzf 替换 Zsh 的默认补全选择菜单

### 5. plugins/plugins.zsh - Zsh 功能插件

**作用：**
- 管理 Zsh 功能增强插件
- 替代 Oh My Zsh，只加载需要的插件（不使用任何 OMZ 片段）

**调用方式：**
- 在 `~/.zshrc` 中通过 `source ~/dotfiles/plugins/plugins/plugins.zsh` 加载

**加载的插件：**
- `1mykull/zshcp` - Zsh 剪贴板管理
- `MichaelAquilina/zsh-you-should-use` - 提醒使用已存在的别名
- `le0me55i/zsh-extract` - 自动解压各种压缩文件
- `zdharma-continuum/fast-syntax-highlighting` - 语法高亮（必须最后加载）

**在 zshrc 中直接加载的功能插件（位于 plugins.zsh 之前）：**
- `mroth/evalcache` - 缓存 init 脚本输出
- `zsh-users/zsh-autosuggestions` - 历史记录自动建议
- `hlissner/zsh-autopair` - 括号/引号自动配对
- `jeffreytse/zsh-vi-mode` - Vim 模式编辑（必须在 autosuggestions 之前加载）

### 6. fzf/fzf.zsh - fzf 模糊查找器配置

**作用：**
- 配置 fzf 的默认行为和预览
- 提供自定义搜索函数：`ff` / `rf` / `zd` / `zc` / `y`

**调用方式：**
- 在 `~/.zshrc` 中通过 `source ~/dotfiles/plugins/fzf/fzf.zsh` 加载
- 在 `tools.zsh` 之后加载（确保 fzf 可用）

**说明：** fzf 二进制由系统包管理器安装（PATH 中已包含 `~/.fzf/bin`），`tools.zsh` 仅加载 fzf 的官方补全与键绑定 snippet。

## 调用流程

```
用户启动 zsh
    ↓
~/.zshrc 被加载
    ↓
1. zinit/zinit.zsh      → 初始化 Zinit
    ↓
2. prompt/prompt.zsh    → 加载 Starship
    ↓
3. tools/tools.zsh      → 安装 CLI 工具（首次使用时下载）
    ↓
4. completion/completion.zsh → 设置补全、fzf-tab 和 PATH
    ↓
5. evalcache            → 缓存 init 脚本
    ↓
6. setup_fnm.sh         → fnm 环境（首次调用时初始化）
    ↓
7. autosuggestions      → 历史建议
    ↓
8. zsh-autopair         → 括号配对
    ↓
9. zsh-vi-mode          → Vim 模式
    ↓
10. plugins/plugins.zsh → 其余功能插件 + fast-syntax-highlighting
    ↓
11. fzf/fzf.zsh         → 配置 fzf 和自定义函数
    ↓
12. atuin / zoxide      → 历史搜索 + 目录跳转
    ↓
完成，提示符显示
```

## 工具调用方式总结

### 直接命令调用
所有通过 `tools.zsh` 安装的工具都可以直接使用：
```bash
bat file.txt          # 查看文件
fd pattern            # 搜索文件
rg "search"           # 搜索内容
z path/to/dir         # 跳转目录
lazygit               # Git TUI
```

### 自定义函数调用
通过 `fzf.zsh` 提供的函数：
```bash
ff [查询]             # 文件/目录搜索
rf [关键字]           # 内容搜索
zd                     # 目录跳转
zc                     # 命令历史
y [目录]               # Yazi 文件管理器（退出后自动切换目录）
```

## 完整插件列表

### Zsh 功能插件

| 插件 | 仓库 | 加载位置 | 功能描述 |
|------|------|----------|----------|
| **evalcache** | `mroth/evalcache` | zshrc | 缓存 init 脚本输出，减少重复开销 |
| **zsh-autosuggestions** | `zsh-users/zsh-autosuggestions` | zshrc | 命令自动建议，根据历史记录提示 |
| **zsh-autopair** | `hlissner/zsh-autopair` | zshrc | 括号/引号自动配对 |
| **zsh-vi-mode** | `jeffreytse/zsh-vi-mode` | zshrc | Vim 模式支持，提供 Vim 键绑定 |
| **zshcp** | `1mykull/zshcp` | plugins.zsh | Zsh 剪贴板管理（历史记录、快捷键） |
| **you-should-use** | `MichaelAquilina/zsh-you-should-use` | plugins.zsh | 提醒使用已存在的别名 |
| **zsh-extract** | `le0me55i/zsh-extract` | plugins.zsh | 自动解压各种压缩文件 |
| **fast-syntax-highlighting** | `zdharma-continuum/fast-syntax-highlighting` | plugins.zsh | 语法高亮，实时高亮命令语法（必须最后加载） |

**加载顺序要求**:
- `zsh-vi-mode` 必须在 `zsh-autosuggestions` 之前加载
- `fzf-tab` 必须在 `compinit` 之后、`zsh-autosuggestions` 之前加载
- `fast-syntax-highlighting` 必须最后加载

### 补全 / 导航插件（completion.zsh）

| 插件 | 仓库 | 功能描述 |
|------|------|----------|
| **zsh-completions** | `zsh-users/zsh-completions` | 额外的补全定义集 |
| **fzf-tab** | `Aloxaf/fzf-tab` | 用 fzf 替换 Zsh 的默认补全选择菜单 |

### 提示符主题

| 插件 | 仓库 | 功能描述 |
|------|------|----------|
| **starship** | `starship/starship` | 极速、跨 Shell 的现代化提示符 |

### CLI 工具（tools.zsh，基于 `as"command" from"gh-r"`）

#### 系统监控
| 工具 | 命令 | 仓库 |
|------|------|------|
| **btop** | `btop` | `aristocratos/btop` |
| **bottom** | `btm` | `ClementTsang/bottom` |
| **duf** | `duf` | `muesli/duf` |

#### Git / 开发
| 工具 | 命令 | 仓库 |
|------|------|------|
| **lazygit** | `lazygit` | `jesseduffield/lazygit` |
| **delta** | `delta` | `dandavison/delta` |
| **gitui** | `gitui` | `gitui-org/gitui` |
| **gh** | `gh` | `cli/cli` |

#### 文本处理
| 工具 | 命令 | 仓库 |
|------|------|------|
| **jq** | `jq` | `jqlang/jq` |
| **yq** | `yq` | `mikefarah/yq` |
| **sd** | `sd` | `chmln/sd` |
| **choose** | `choose` | `theryangeary/choose` |
| **glow** | `glow` | `charmbracelet/glow` |
| **tealdeer** | `tldr` | `tealdeer-rs/tealdeer` |

#### 网络工具
| 工具 | 命令 | 仓库 |
|------|------|------|
| **xh** | `xh` | `ducaale/xh` |
| **gping** | `gping` | `orf/gping` |

#### 文件工具
| 工具 | 命令 | 仓库 |
|------|------|------|
| **bat** | `bat` | `sharkdp/bat` |
| **broot** | `broot` | `Canop/broot` |
| **fd** | `fd` | `sharkdp/fd` |
| **ripgrep** | `rg` | `BurntSushi/ripgrep` |
| **zoxide** | `z` | `ajeetdsouza/zoxide` |
| **eza** | `eza` | `eza-community/eza` |
| **procs** | `procs` | `dalance/procs` |
| **zellij** | `zellij` | `zellij-org/zellij` |

#### 环境与历史工具
| 工具 | 命令 | 仓库 |
|------|------|------|
| **direnv** | `direnv` | `direnv/direnv` |
| **atuin** | `atuin` | `atuinsh/atuin` |

#### fzf（特殊）
| 工具 | 命令 | 说明 |
|------|------|------|
| **fzf** | `fzf` | 二进制由系统包管理器安装；`tools.zsh` 仅加载官方补全与键绑定 snippet |

> 说明：`~/.zinit/plugins` 目录中可能存在 `zsh-history-substring-search`、`zsh-navigation-tools`、`dust` 等历史遗留目录，但当前配置**不再加载**它们。如需清理可运行 `zinit delete --clean`。

## 注意事项

1. **首次使用**：工具会在首次使用时自动下载，可能需要等待几秒钟
2. **PATH 设置**：所有工具都通过 `completion.zsh` 自动添加到 PATH
3. **加载顺序**：不要随意更改加载顺序，某些配置有依赖关系
   - `zinit.zsh` → `prompt.zsh` → `tools.zsh` → `completion.zsh` → `evalcache` → `autosuggestions` → `autopair` → `zsh-vi-mode` → `plugins.zsh` → `fzf.zsh` → `atuin`/`zoxide`
   - `fzf-tab` 必须在 `compinit` 之后、`zsh-autosuggestions` 之前加载
   - `zsh-vi-mode` 必须在 `zsh-autosuggestions` 之前加载
   - `fast-syntax-highlighting` 必须最后加载

## 故障排除

### 工具找不到
- 检查 `completion.zsh` 是否正确加载
- 运行 `zinit install <工具仓库>` 手动安装
- 检查 `~/.zinit/plugins/` 目录

### 函数冲突
- 使用 `type <命令>` 查看命令类型

### 字体安装失败
- 检查网络连接
- 手动运行：`bash ~/dotfiles/scripts/install/install_font.sh --force`
