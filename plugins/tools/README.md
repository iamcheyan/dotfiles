# CLI 工具管理配置

## 简介

此文件负责通过 Zinit 管理各种 CLI 工具，从 GitHub Releases 自动下载和安装二进制工具（`as"command" from"gh-r"`）。所有工具都通过统一的 `zi_cmd` 辅助函数安装，确保配置简洁且易于维护。

## 文件位置

- **配置文件**: `~/dotfiles/plugins/tools/tools.zsh`
- **加载位置**: 在 `~/.zshrc` 中，于 `prompt.zsh` 之后、`completion.zsh` 之前加载

## 功能

### 通用安装函数

`zi_cmd` 函数简化了工具的安装过程：

```zsh
zi_cmd() {
  zinit ice as"command" from"gh-r" pick"$2"
  zinit light "$1"
}
```

**参数说明**:
- `$1`: GitHub 仓库（格式：`owner/repo`）
- `$2`: 二进制文件名

### 已安装的工具

#### 系统监控

- **btop**: 系统资源监控工具 (`aristocratos/btop`)
- **bottom (btm)**: 系统监控工具 (`ClementTsang/bottom`)
- **duf**: 磁盘使用情况查看器 (`muesli/duf`)

#### Git / 开发工具

- **lazygit**: Git 的终端 UI (`jesseduffield/lazygit`)
- **delta**: Git diff 查看器 (`dandavison/delta`)
- **gitui**: Git 的高速终端 UI (`gitui-org/gitui`)
- **gh**: GitHub CLI (`cli/cli`)

#### 文本处理

- **jq**: JSON 处理工具 (`jqlang/jq`)
- **yq**: YAML 处理工具 (`mikefarah/yq`)
- **sd**: 字符串替换工具 (`chmln/sd`)
- **choose**: 文本选择工具 (`theryangeary/choose`)
- **glow**: Markdown 渲染器 (`charmbracelet/glow`)
- **tealdeer (tldr)**: 高性能 tldr 客户端 (`tealdeer-rs/tealdeer`)

#### 网络工具

- **xh**: HTTP 客户端（curl 的替代品）(`ducaale/xh`)
- **gping**: 带图表的 ping 工具 (`orf/gping`)

#### 文件工具

- **bat**: 带语法高亮的 cat 替代品 (`sharkdp/bat`)
- **broot**: 交互式目录树导航器，支持 `br` 返回 shell 后自动 `cd` (`Canop/broot`)
- **fd**: 快速文件查找工具 (`sharkdp/fd`)
- **ripgrep (rg)**: 快速文本搜索工具 (`BurntSushi/ripgrep`)
- **zoxide**: 智能目录跳转工具 (`ajeetdsouza/zoxide`)
- **eza**: ls 的现代化替代品 (`eza-community/eza`)
- **procs**: ps 的现代化替代品 (`dalance/procs`)
- **zellij**: 终端多路复用器 (`zellij-org/zellij`)

#### 环境与历史工具

- **direnv**: 目录级环境变量管理 (`direnv/direnv`)
- **atuin**: 命令历史搜索与管理 (`atuinsh/atuin`)

#### fzf（特殊）

- **fzf**: 模糊查找工具。二进制由**系统包管理器**安装（PATH 中包含 `~/.fzf/bin`），`tools.zsh` 仅通过 Zinit snippet 加载官方的补全与键绑定：

```zsh
# 补全
zinit ice as"completion"
zinit snippet https://github.com/junegunn/fzf/raw/master/shell/completion.zsh

# 键绑定
zinit ice as"completion"
zinit snippet https://github.com/junegunn/fzf/raw/master/shell/key-bindings.zsh
```

## 特殊处理

### fd 和 ripgrep

这两个工具需要特殊处理，因为二进制文件在压缩包的子目录中：

```zsh
# fd
zinit ice as"command" from"gh-r" mv"fd-*/fd -> fd" pick"fd" sbin"fd"
zinit light sharkdp/fd

# ripgrep
zinit ice as"command" from"gh-r" mv"ripgrep-*/rg -> rg" pick"rg" sbin"rg"
zinit light BurntSushi/ripgrep
```

### gitui

根据操作系统与架构选择不同的 release 资源（macOS / Linux aarch64 / x86_64 / armv7 等）。

### tealdeer

使用 musl 静态版本，并重命名为 `tldr`：

```zsh
zinit ice as"command" from"gh-r" bpick"tealdeer-linux-*-musl" mv"tealdeer* -> tldr" pick"tldr"
zinit light tealdeer-rs/tealdeer
```

### atuin

只下载二进制，不再在 `tools.zsh` 内自动初始化；初始化在 `~/.zshrc` 中通过 `_evalcache atuin init zsh` 完成。

### direnv

GitHub release 为单一二进制，使用 `sbin` 直接安装到 `$ZPFX/bin`：

```zsh
zinit ice as"command" from"gh-r" sbin"direnv"
zinit light direnv/direnv
```

## 使用说明

### 添加新工具

要添加新工具，只需在文件中添加一行：

```zsh
zi_cmd owner/repo binary_name
```

**示例**:
```zsh
zi_cmd charmbracelet/vhs vhs
```

### 查看已安装的工具

```bash
# 列出所有工具
zinit list

# 查看特定工具
zinit list | grep tool_name
```

### 更新工具

```bash
# 更新所有工具
zinit update

# 更新特定工具
zinit update owner/repo
```

### 删除工具

```bash
# 删除工具
zinit delete owner/repo
```

## 工具说明

### 系统监控工具

- **btop**: `btop` - 实时系统监控
- **bottom**: `btm` - 系统监控（类似 htop）
- **duf**: `duf` - 磁盘使用情况（比 df 更友好）

### Git 工具

- **lazygit**: `lazygit` - Git 的 TUI
- **delta**: `delta` - Git diff 查看器
- **gitui**: `gitui` - Git 的终端 UI
- **gh**: `gh` - GitHub CLI

### 文本处理

- **jq**: `jq` - JSON 处理
- **yq**: `yq` - YAML 处理
- **sd**: `sd` - 字符串替换（比 sed 更快）
- **choose**: `choose` - 文本选择工具
- **glow**: `glow` - Markdown 渲染器
- **tealdeer**: `tldr` - 高性能 tldr 客户端

### 网络工具

- **xh**: `xh` - 面向 API 调试的 HTTP 客户端
- **gping**: `gping` - 带实时图表的 ping

### 文件工具

- **bat**: `bat` - 带语法高亮的 cat
- **broot**: `broot` / `br` - 交互式目录浏览与目录跳转
- **fd**: `fd` - 快速文件查找
- **ripgrep**: `rg` - 快速文本搜索
- **zoxide**: `z` - 智能目录跳转
- **eza**: `eza` - ls 的现代化替代品
- **procs**: `procs` - ps 的现代化替代品
- **zellij**: `zellij` - 终端多路复用器

### 环境与历史工具

- **direnv**: `direnv` - 目录级环境变量
- **atuin**: `atuin` - 命令历史搜索与管理

### 其他工具

- **fzf**: `fzf` - 模糊查找（二进制由系统安装，仅补全/键绑定由此文件加载）

## 注意事项

### 系统包管理器安装的工具

某些工具建议使用系统包管理器安装（已在注释中说明）：

- **ncdu**: `sudo apt install ncdu`
- **htop**: `sudo apt install htop`
- **glances**: `pip install glances`
- **tig**: `sudo apt install tig`
- **dog**: `sudo apt install dog`
- **fzf**: 由系统包管理器安装（此文件只加载其补全与键绑定）

### 架构兼容性

某些工具可能不支持所有架构（如 arm64），已在注释中按 `uname -m` 选择对应 release。

## 相关文件

- **fzf 配置**: `~/dotfiles/plugins/fzf/fzf.zsh` - fzf 的详细配置和函数
- **补全配置**: `~/dotfiles/plugins/completion/completion.zsh` - 补全系统配置

## 参考资源

- [Zinit 文档](https://github.com/zdharma-continuum/zinit)
- [GitHub Releases](https://docs.github.com/en/repositories/releasing-projects-on-github/managing-releases-in-a-repository)
