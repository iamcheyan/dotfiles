> 摘要：Neovim 作为子模块固定版本，维护者与普通用户的不同链接路径。

# Neovim 子模块

## 关系

```text
iamcheyan/dotfiles
└── config/nvim  ──gitlink──▶  iamcheyan/nvim
```

`config/nvim` 不是普通目录，而是一个 git 子模块指针，记录另一个仓库的某个提交。

```bash
git submodule status
# fd9ac81ffd366a7674b71cb3b97daf53b9de06b7 config/nvim (heads/main-6-gfd9ac81)
```

这串哈希决定你拿到哪一版 Neovim 配置。

## 为什么要子模块

| 理由 | 说明 |
|---|---|
| 独立演进 | Neovim 配置有自己的插件、文档、站点 |
| 独立发布 | 可以单独克隆安装，不依赖 dotfiles |
| 版本固定 | dotfiles 记录一个确定的提交，不随 nvim 仓库漂移 |
| 体积 | Neovim 配置和文档量大，混在主仓库里难以维护 |

## 初始化

新克隆的仓库里 `config/nvim` 是空目录：

```bash
cd ~/dotfiles
git submodule update --init --recursive
```

`--recursive` 是因为子模块内部可能还有子模块。

## 两种链接路径

`dotlink` 里有一段特殊逻辑：

```bash
if [[ "$dest" == "$HOME/.config/nvim" && -f "$HOME/nvim/init.lua" ]]; then
    local nvim_remote
    nvim_remote=$(git -C "$HOME/nvim" remote get-url origin 2>/dev/null || true)
    if [[ "$nvim_remote" =~ (^|[:/])iamcheyan/nvim(\.git)?$ ]]; then
        src="$HOME/nvim"
    fi
fi
```

| 条件 | 链接目标 |
|---|---|
| 有 `~/nvim` 且 origin 是本仓库 | `~/nvim` |
| 其它情况 | `~/dotfiles/config/nvim` |

### 维护者路径

维护者在 `~/nvim` 开发，`~/.config/nvim` 直接指向它。改代码立即生效，不用进子模块目录。

### 普通用户路径

没有 `~/nvim` 工作副本，链接子模块。`git pull` 更新 dotfiles 时，子模块跟着更新到记录的提交。

## 更新

### 普通用户

```bash
cd ~/dotfiles
git pull --ff-only
git submodule update --init --recursive
```

拿到的是 dotfiles 主仓库记录的那个 nvim 提交，不一定是最新。

### 维护者

```bash
# 1. 在 nvim 仓库开发
cd ~/nvim
git add . && git commit && git push

# 2. 回 dotfiles 更新指针
cd ~/dotfiles
git add config/nvim
git commit -m "chore: update Neovim submodule"
git push
```

第 2 步记录新的提交哈希，其它用户 `git pull` 后才会拿到。

### 只想更新到 nvim 最新

```bash
cd ~/dotfiles/config/nvim
git fetch && git checkout origin/main
cd ~/dotfiles
git add config/nvim
git commit -m "chore: bump nvim"
```

这会让你的 dotfiles 偏离上游记录的版本。除非你确定，否则等维护者更新。

## Neovim 本体与配置的区别

两件事容易混淆：

| | Neovim 本体 | Neovim 配置 |
|---|---|---|
| 是什么 | 编辑器二进制 | Lua 配置和插件 |
| 谁管理 | `install_nvim.sh` / `nvim-update` | 子模块 `config/nvim` |
| 更新方式 | `nvim-update` | `git submodule update` |

升级编辑器用 `nvim-update`，更新配置用子模块。两者独立。

## 子模块常见状态

```bash
git submodule status
```

| 前缀 | 含义 |
|---|---|
| 空格 | 已初始化，提交匹配 |
| `+` | 已初始化，但提交与记录不同 |
| `-` | 未初始化 |
| `U` | 有冲突 |

看到 `+` 说明子模块里的提交和 dotfiles 记录的不一致。可能是你手动 checkout 过。

## 排错

**`config/nvim` 是空目录**：没初始化子模块。

**`~/.config/nvim` 是空目录**：dotlink 链接到了未初始化的子模块。

**改了配置不生效**：改的是 `~/.config/nvim`（软链接），实际写进了源文件但可能改错了位置。确认 `readlink -f ~/.config/nvim`。

**`git status` 显示子模块有修改**：你在子模块里改了文件。要么提交到 nvim 仓库，要么放弃修改。

**`git pull` 后 Neovim 配置没变**：主仓库的指针没更新，或没跑 `git submodule update`。

**子模块冲突**：`git submodule update --init --recursive --force` 强制同步到记录的提交（会丢弃子模块内的本地修改）。

## 完整文档

Neovim 配置的内容、插件、教程、键位都在独立站点：

- [nvim.iamcheyan.com](https://nvim.iamcheyan.com)
- [插件目录](https://nvim.iamcheyan.com/plugins.html)
- [安装说明](https://nvim.iamcheyan.com/install.html)
