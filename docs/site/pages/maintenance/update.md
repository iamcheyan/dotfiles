> 摘要：更新配置、子模块、Neovim 本体和插件的四条独立路径。

# 更新流程

## 四条路径

| 更新什么 | 命令 |
|---|---|
| 配置 | `git pull` + `dotlink link` |
| Neovim 配置 | `git submodule update` |
| Neovim 本体 | `nvim-update` |
| Zinit 插件和工具 | `zinit update` |

它们互相独立，不要混为一谈。

## 更新配置

```bash
cd ~/dotfiles
git pull --ff-only
bash dotlink/dotlink link
exec zsh
```

`--ff-only` 保证不产生意外的 merge commit。如果本地有提交导致无法 fast-forward，先处理本地提交。

`dotlink link` 用于同步新增/删除的映射。如果只是改了文件内容，软链接已经指向源文件，不需要重跑。

`exec zsh` 让新配置生效。

## 更新 Neovim 配置

```bash
cd ~/dotfiles
git submodule update --init --recursive
```

这会把 `config/nvim` 拉到主仓库记录的提交。

查看当前版本：

```bash
git submodule status
# fd9ac81ffd366a7674b71cb3b97daf53b9de06b7 config/nvim (heads/main-6-gfd9ac81)
```

前面的哈希是当前 checkout 的提交。

### 如果子模块有本地修改

```bash
cd ~/dotfiles/config/nvim
git status
```

有修改时 `git submodule update` 会拒绝或覆盖。先决定：提交到 nvim 仓库，还是丢弃。

## 更新 Neovim 本体

```bash
nvim-update
```

这是独立的脚本，把编辑器二进制升级到最新稳定版。详见 [nvim-update](../scripts/nvim-update.html)。

验证：

```bash
nvim --version | head -1
```

## 更新 Zinit 插件和工具

```zsh
zinit update
```

这更新 Zinit 管理的所有插件和从 GitHub Release 下载的二进制。

只更新一个：

```zsh
zinit update sharkdp/fd
```

## 完整更新流程

想全部更新时：

```bash
# 1. 配置
cd ~/dotfiles
git pull --ff-only

# 2. Neovim 配置
git submodule update --init --recursive

# 3. 软链接
bash dotlink/dotlink link

# 4. Neovim 本体
nvim-update

# 5. Zinit 插件
zsh -ic 'zinit update'

# 6. 重载 shell
exec zsh
```

## 回退

### 配置回退

```bash
cd ~/dotfiles
git log --oneline -5
git checkout <commit> -- <file>
```

或者整体回退：

```bash
git reset --hard <commit>
```

**注意**：`reset --hard` 会丢弃所有本地修改。

### Neovim 本体回退

```bash
ls ~/.local/opt/neovim/
ln -sf ~/.local/opt/neovim/0.11.4/bin/nvim ~/.local/bin/nvim
```

旧版本保留着，改软链接即可。

### Zinit 插件回退

```zsh
zinit delete <plugin>
zinit light <plugin>
```

或者进插件目录手动 checkout 旧提交。

## 维护者更新 Neovim 指针

```bash
# 1. 在 nvim 仓库提交
cd ~/nvim
git add . && git commit -m "..." && git push

# 2. 回 dotfiles 更新指针
cd ~/dotfiles
git add config/nvim
git commit -m "chore: update Neovim submodule"
git push
```

第 2 步记录新哈希，其他用户 `git pull` 后才会拿到。

## 检查更新结果

```bash
# 配置
git -C ~/dotfiles log -1 --oneline

# 子模块
git -C ~/dotfiles submodule status

# Neovim
nvim --version | head -1

# Zinit
zsh -ic 'zinit list | head -20'

# 软链接
ls -l ~/.zshrc ~/.config/nvim
```

## 排错

**`git pull` 失败「not possible to fast-forward」**：本地有提交或分叉。`git log --oneline origin/main..HEAD` 看本地多了什么。

**子模块更新后 Neovim 配置没变**：`readlink -f ~/.config/nvim` 确认链接指向哪。维护者机器可能指向 `~/nvim`。

**`nvim-update` 后插件报错**：新版本可能改 API。`nvim --version` 确认，必要时回退。

**`zinit update` 后命令消失**：某个插件的 release 资产名变了。`zinit delete` 后重新 `zinit light`。

**更新后 shell 启动变慢**：新插件在同步下载。第二次启动应该正常。
