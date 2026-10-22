> 摘要：local/ 目录与 aliases 子仓库的正确用法，以及它们与公开配置的边界。

# 私人覆盖

## 三种覆盖机制

| 机制 | 位置 | 被 Git 跟踪 |
|---|---|---|
| `local/` | `~/dotfiles/local/` | 只有 README |
| `~/.config/aliases.conf` | 用户配置目录 | 否（在仓库外） |
| `aliases/` | `~/dotfiles/aliases/` | 独立子仓库 |

## local/

### 加载机制

`zshrc` 末尾：

```zsh
for dotfiles_local_file in "$dotfiles_root"/local/*(N.D.); do
    [[ "${dotfiles_local_file:t}" == "README.md" ]] && continue
    source "$dotfiles_local_file"
done
unset dotfiles_local_file
```

`(N.D.)` 是 zsh 通配限定符：

| 限定符 | 含义 |
|---|---|
| `N` | 无匹配时不报错 |
| `D` | 包含以点开头的文件 |
| `.` | 只匹配普通文件（不含目录） |

所以 `local/` 下所有普通文件（含隐藏文件）都会被 source，README.md 除外。

### Git 忽略

`.gitignore`：

```text
/local/
!/local/
/local/*
!/local/README.md
```

效果：

| 路径 | 状态 |
|---|---|
| `local/` | 目录被跟踪 |
| `local/README.md` | 被跟踪 |
| `local/custom.zsh` | 被忽略 |
| `local/.secret` | 被忽略 |

### 用法

```bash
mkdir -p ~/dotfiles/local
$EDITOR ~/dotfiles/local/custom.zsh
```

内容示例：

```zsh
# 个人 alias
alias work='cd ~/projects/work'
alias deploy='./scripts/deploy.sh'

# 环境变量
export PROJECTS_DIR="$HOME/projects"
export EDITOR=nvim

# 覆盖公开配置
export FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS --height 60%"
bindkey '^R' fzf-history-widget
```

### 为什么最后加载

`local/` 在 `zshrc` 最末尾 source，所以：

- 可以覆盖前面所有 `alias`
- 可以覆盖 `bindkey`
- 可以覆盖 `export` 的变量
- 可以重定义函数

这是有意设计的：私人配置优先级最高。

### 不要放什么

| 内容 | 原因 |
|---|---|
| 密钥、token | 明文文件，容易被误备份/截图 |
| 大段脚本 | 放 `~/.local/bin/` 更合适 |
| 需要版本控制的内容 | 它在 `.gitignore` 里，`git pull` 不会保护它 |

密钥应该放系统钥匙串、密码管理器，或至少 `chmod 600` 的独立文件。

## ~/.config/aliases.conf

### 加载机制

```zsh
[[ -f ~/.config/aliases.conf ]] && source ~/.config/aliases.conf
[[ -f "$dotfiles_root/aliases.conf" ]] && source "$dotfiles_root/aliases.conf"
```

顺序：先加载私有的 `~/.config/aliases.conf`，再加载公开的 `aliases.conf`。

**注意顺序**：公开配置在后，会覆盖同名的私有定义。想覆盖公开别名，应该用 `local/`（它最后加载）。

### 为什么存在这个机制

Chezmoi 会创建 `~/.config/aliases.conf` 作为私有扩展点。这样私有内容可以放在 chezmoi 仓库里，通过 chezmoi 部署，不需要污染 dotfiles。

### 与 local/ 的分工

| | `~/.config/aliases.conf` | `local/` |
|---|---|---|
| 位置 | 仓库外 | 仓库内 |
| 管理 | Chezmoi 或手动 | 手动 |
| 加载顺序 | 中 | 最后 |
| 适合 | 私有别名 | 覆盖任何配置 |

## aliases/ 子仓库

### 是什么

`~/dotfiles/aliases/` 是一个**独立的 git 仓库**，有自己的 `.git`。

```bash
cd ~/dotfiles/aliases
git status
git remote -v
```

### 内容

```text
aliases/
├── dev.conf
├── dotfiles.conf
├── git.conf
├── morph.conf
├── rime.conf
├── rsync.conf
├── system.conf
├── tools.conf
├── yazi.conf
├── z.conf
├── zellij.conf
└── scripts/
```

这些是更细分的别名集合，包括一些带个人环境的脚本（比如 `morph.conf` 里的部署脚本、`scripts/claude2kimi/.env`）。

### 重要边界

**`aliases/` 里有 `.env` 文件**：

```text
aliases/scripts/claude2kimi/.env
```

它有独立的 `.gitignore`，且属于私有配置。**不要把这个子仓库的内容复制到公开仓库**，也不要在公开文档里展开它的内容。

### 是否被 zshrc 加载

`zshrc` **不加载** `aliases/` 目录。它只 source：

1. `~/.config/aliases.conf`
2. `$dotfiles_root/aliases.conf`

`aliases/` 需要手动 source，或在 `local/` 里 source：

```zsh
# local/custom.zsh
for f in ~/dotfiles/aliases/*.conf; do
    source "$f"
done
```

## 三种机制的选择

| 需求 | 用哪个 |
|---|---|
| 加个人别名 | `local/custom.zsh` |
| 覆盖公开配置 | `local/` |
| 由 Chezmoi 管理 | `~/.config/aliases.conf` |
| 分主题的大量别名 | `aliases/` + 在 `local/` 里 source |
| 密钥 | 都不用，用密码管理器 |

## 排错

**`local/` 里的配置没生效**：文件名是 `.md`？或者放在了子目录里（`(.)` 只匹配普通文件，不递归）。

**私有别名被覆盖**：`aliases.conf`（公开）在 `~/.config/aliases.conf`（私有）之后加载。用 `local/` 覆盖。

**`aliases/` 里的内容没生效**：它不会被自动加载，需要手动 source。

**`git status` 显示 `local/` 有新文件**：不应该。检查 `.gitignore` 是否完整。

**误把密钥放进 `local/`**：虽然被 Git 忽略，但文件在磁盘明文。移到密码管理器或加密存储。
