> 摘要：dotlinkrc 里每条映射的源、目标、作用，以及哪些配置不在此列。

# 映射清单

## 自动部署的配置

`dotlink/dotlinkrc` 的 `[link]` 段：

| 源 | 目标 | 作用 |
|---|---|---|
| `zshrc` | `~/.zshrc` | Zsh 主入口 |
| `config/starship/starship.toml` | `~/.config/starship.toml` | 提示符主题 |
| `config/nano/nanorc` | `~/.nanorc` | Nano 设置 |
| `config/atuin` | `~/.config/atuin` | Atuin 配置目录 |
| `config/herdr/config.toml` | `~/.config/herdr/config.toml` | Herdr 配置 |
| `config/ranger` | `~/.config/ranger` | Ranger 配置目录 |
| `config/gvim/gvimrc` | `~/.gvimrc` | GVim 外观 |
| `config/vim/vimrc` | `~/.vimrc` | Vim 通用配置 |
| `config/nvim` | `~/.config/nvim` | Neovim（子模块） |
| `config/tmux/tmux.conf` | `~/.config/tmux/tmux.conf` | tmux 主配置 |
| `config/vifm/vifmrc` | `~/.config/vifm/vifmrc` | Vifm 主配置 |
| `config/vifm/colors` | `~/.config/vifm/colors` | Vifm 配色 |
| `config/vifm/scripts` | `~/.config/vifm/scripts` | Vifm 脚本 |
| `scripts/sync-webapps.py` | `~/.local/bin/sync-webapps` | Web App 同步脚本 |

## 未列入映射的配置

| 文件 | 说明 |
|---|---|
| `config/ghostty/config` | Ghostty 终端配置，需手动链接 |
| `config/yazi/flavors/` | Yazi 配色，需手动使用 |
| `config/vim/tests/` | 测试文件，不需要部署 |

要手动链接 Ghostty：

```bash
mkdir -p ~/.config/ghostty
ln -sf ~/dotfiles/config/ghostty/config ~/.config/ghostty/config
```

## 映射写法

```ini
$HOME/dotfiles/zshrc:$HOME/.zshrc	# zsh 配置文件
```

三部分：

1. `$HOME/dotfiles/...` — 源，展开 `$HOME`
2. `:` — 分隔符
3. `$HOME/.zshrc` — 目标
4. `#` 之后 — 注释

目录映射和文件映射写法相同，`dotlink` 会判断源是文件还是目录。

## 通配符映射

```ini
$HOME/dotfiles/config/vifm/*:$HOME/.config/vifm/*
```

对源目录下每个匹配项，在目标目录建立同名链接。当前 `dotlinkrc` 里 Vifm 的三条规则是显式写出的，没有用通配符；通配符能力在 `process_wildcard_pattern` 里实现，供将来扩展。

## Neovim 的特殊分支

```ini
$HOME/dotfiles/config/nvim:$HOME/.config/nvim	# Neovim 配置文件
```

实际链接目标可能不是 `config/nvim`：`dotlink` 检测到 `~/nvim` 且它的 origin 是本仓库时，改链接 `~/nvim`。

## 验证映射

```bash
bash ~/dotfiles/dotlink/dotlink list
```

它会展开所有规则并打印，不修改文件。用这个确认「到底会链接什么」。

## 添加新映射

```ini
[link]
...
$HOME/dotfiles/config/newtool:$HOME/.config/newtool   # 新工具配置
```

然后：

```bash
bash ~/dotfiles/dotlink/dotlink list    # 先看
bash ~/dotfiles/dotlink/dotlink link    # 再执行
```

## 排错

**某个配置没生效**：先 `ls -l` 目标路径，确认是不是软链接。不是就说明没在映射里。

**`~/.config/ghostty/config` 不存在**：Ghostty 不在映射里，需手动链接。

**链接指向错误**：`readlink -f ~/.config/nvim` 查看实际目标。

**`config/vifm/*` 规则没生效**：确认源目录存在。源不存在时 dotlink 静默跳过。
