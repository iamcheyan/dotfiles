> 摘要：启动报错、插件缺失、预览空白、提示符异常的分层排查方法。

# 排错清单

## 先分层，再动手

shell 问题几乎都能定位到四层之一：语法、加载顺序、依赖缺失、运行时状态。按顺序排查比反复重装有效。

## 第一层：语法

```bash
zsh -d -n ~/dotfiles/zshrc
zsh -d -n ~/dotfiles/plugins/zsh-plugins.zsh
bash -n ~/dotfiles/init.sh
bash -n ~/dotfiles/aliases.conf
```

`-n` 只解析不执行。任何一行报错，后面的加载都不会发生。

## 第二层：加载顺序

```bash
zsh -x -i -c 'true' 2>&1 | head -80
```

`-x` 打印每行执行内容。看最后几行就知道卡在哪个文件。

常见症状与原因：

| 症状 | 原因 |
|---|---|
| 启动很慢（>3 秒） | 某个 `zinit light` 在同步下载 |
| 提示 `compdef: command not found` | 插件在 `compinit` 前调用了 `compdef` |
| 补全候选为空 | `compinit` 没运行，或 `zcompdump` 损坏 |
| 语法高亮失效 | 高亮插件不在最后加载 |

## 第三层：依赖

```bash
command -v fd rg fzf bat eza zoxide atuin starship fnm
```

任何一个缺失，依赖它的功能就静默不生效。本仓库大量使用 `command -v` 判断，所以**不会报错，只会功能缺失**——这一点容易误判成「配置坏了」。

## 第四层：运行时状态

### Zinit 缓存损坏

```bash
zinit list              # 看是否有异常项
zinit report            # 更详细的状态
bash ~/dotfiles/init.sh --repair
```

### 补全缓存过期

```bash
rm -f ~/.zcompdump*
exec zsh
```

### 函数没定义

```bash
type f ffd ra v vssh zz
```

`type` 会明确告诉你它是函数、别名、还是找不到。

## 按症状查

### fzf 预览空白

```bash
command -v bat ls
echo $FZF_DEFAULT_OPTS
```

`bat` 缺失时预览会退化成只有目录列表。`FZF_DEFAULT_OPTS` 为空说明 `fzf.zsh` 没加载。

### 提示符没有 Python 版本

```bash
starship explain
```

它会逐模块解释显示或隐藏的原因。常见是当前目录没有 `pyproject.toml` 之类触发文件。

### 提示符显示方框

字体不是 Nerd Font。装 Meslo：

```bash
bash ~/dotfiles/scripts/install/install_font.sh --meslo
```

然后在终端设置里选择 `MesloLGS Nerd Font`。

### tmux 里颜色不对

三层都要检查：

```bash
echo $TERM                    # 应该是 tmux-256color 或 xterm-256color
tmux show -g default-terminal
tmux show -g terminal-features
```

如果 `$TERM` 是 `screen` 或 `xterm`，说明 tmux 配置没加载。

### Neovim 打开是裸界面

```bash
ls -l ~/.config/nvim
```

应该是软链接。如果是空目录，子模块没初始化：

```bash
cd ~/dotfiles && git submodule update --init --recursive
```

### `Ctrl+R` 行为和预期不符

```bash
bindkey '^R'
```

fzf、Atuin、Zsh 原生三方都可能接管。要在 `local/` 里显式覆盖：

```zsh
bindkey '^R' fzf-history-widget
```

### 命令执行后提示「你本可以用 xxx」

这是 `zsh-you-should-use` 的正常行为。想关掉，在 `local/` 里设置对应变量。

## 最后手段

如果确认是配置本身损坏，而 `--repair` 无效：

```bash
cd ~/dotfiles
git status                    # 确认没有未提交改动
git stash                     # 或先备份
git pull --ff-only
bash dotlink/dotlink link
exec zsh
```

不要直接删 `~/.zinit` 或 `~/.config/nvim`，那会丢掉所有已下载的插件，重新下载要很久。
