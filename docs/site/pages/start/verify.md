> 摘要：安装完成后逐项核对命令、软链接、Neovim 版本和 shell 集成是否真的生效。

# 安装后核对

## 为什么需要这一步

`init.sh` 采用 best-effort 策略：单步失败只打印 warning 并继续。所以「脚本跑完了」不等于「环境可用」。下面的检查按依赖层级排列，从底层往上查。

## 第一层：命令是否存在

```bash
command -v zsh git curl
command -v fzf fd rg
command -v eza bat zoxide atuin
command -v nvim tmux
```

预期结果：每条都打印一个绝对路径。打印不出来说明该工具没装上，或者不在 PATH。

`eza` 和 `bat` 是可选的：`aliases.conf` 里用 `command -v eza` 做了判断，没有 eza 时 `l`/`ll`/`la` 别名根本不会定义，也不会报错。

## 第二层：软链接指向哪里

```bash
ls -l ~/.zshrc ~/.vimrc ~/.config/nvim ~/.config/starship.toml
```

每个都应该是 `->` 指向 `~/dotfiles/...` 的软链接。如果 `~/.zshrc` 还是普通文件，说明 dotlink 没跑成功，或者它被跳过了。

逐个核对全部映射：

```bash
sed -n '/^\[link\]/,$p' ~/dotfiles/dotlink/dotlinkrc
```

## 第三层：Neovim 版本

```bash
nvim --version | head -1
```

必须是 `NVIM v0.12.x` 或更高。低于 0.12 时 Treesitter 的 main 分支和部分插件会失败。

如果 `command -v nvim` 指向 `/usr/bin/nvim` 而系统版本过旧：

```bash
ls -l ~/.local/bin/nvim
```

正常情况这是指向 `~/.local/opt/neovim/<version>/bin/nvim` 的软链接。如果它指向了系统路径，用 `nvim-update` 重新建立用户级安装。

## 第四层：Zinit 是否正常

```bash
zinit list
```

应该列出已安装的插件和工具。空列表通常意味着 zinit 本体没装好，或者 `zshrc` 没被加载。

## 第五层：shell 集成

```bash
echo $SHELL
echo $FZF_DEFAULT_COMMAND
type f ffd ra v vssh
bindkey '^R'
```

- `$SHELL` 应为 zsh 的路径。
- `$FZF_DEFAULT_COMMAND` 应以 `fd` 或 `fdfind` 开头。
- `type` 应把每个函数显示为 `function`。
- `bindkey '^R'` 显示当前 Ctrl+R 绑定，用于确认是 fzf 还是 Atuin 接管。

## 第六层：实际用一次

```bash
f            # 应弹出文件选择器
z dotfiles   # 应跳转到仓库
nvim         # 应进入配置好的界面，而不是裸 Neovim
```

如果 `nvim` 打开后没有插件界面，多半是 `~/.config/nvim` 链接到了空目录（子模块没初始化）。

## 常见失败与对应原因

| 现象 | 原因 |
|---|---|
| `command not found: zsh` | 第 2 步失败，或没重新登录 |
| `~/.zshrc` 是普通文件 | dotlink 未执行或执行失败 |
| `nvim` 版本低于 0.12 | 用户级安装没建立，走了系统包 |
| `zinit list` 为空 | zinit 目录缺失或 `zshrc` 未加载 |
| `f` 未定义 | `plugins/fzf/fzf.zsh` 未加载，检查 `zshrc` |
| `~/.config/nvim` 为空 | 子模块未初始化 |

逐项修好后重新 `exec zsh`，再从第一层核对。
