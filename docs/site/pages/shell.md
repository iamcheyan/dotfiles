> 摘要：理解 Zsh 如何加载 Zinit、补全、交互插件、fzf 函数和可选工具集成。

# Zsh 与终端

## 从 zshrc 进入

`zshrc` 是主入口。它先设置历史与 shell 选项、检查 TERM terminfo，再从当前文件位置推导仓库根目录，按顺序加载 Zinit、插件、工具、补全、fnm 和 fzf 函数。仓库不必固定在 `~/dotfiles`。

```text
zshrc
├── plugins/zinit/zinit.zsh
├── plugins/zsh-plugins.zsh
├── plugins/tools/tools.zsh
├── plugins/completion/completion.zsh
├── scripts/setup/setup_fnm.sh
├── plugins/fzf/fzf.zsh
└── aliases.conf
```

Zsh 插件分三个阶段：zsh-completions 在 compinit 前加载，fzf-tab 在 compinit 后加载，其余插件在 main 阶段加载，syntax-highlighting 最后执行。Starship 只在交互终端加载；多数可选工具先用 `command -v` 检查。

## Vim 风格命令行和历史

`zsh-vi-mode` 提供命令行 Vim 模式，启动时在 Insert 模式。Esc 切入普通模式。历史文件为 `~/.zsh_history`，容量 100000，配置共享历史、去重、去多余空白、执行前确认历史扩展。

```zsh
Ctrl+R       # fzf/Atuin 历史搜索，按当前绑定生效
↑            # Atuin shell-up 搜索
Esc          # 命令行 Vim 普通模式
z <目录>      # Zoxide 智能跳转
zi           # Zoxide 交互选择
```

fzf 与 Atuin 都提供历史入口；绑定可能受插件加载影响。可用 `bindkey '^R'` 和 `bindkey '^[[A'` 检查当前映射。

## fzf 文件搜索

`FZF_DEFAULT_COMMAND` 优先使用 `fd --hidden --follow --exclude .git`，然后尝试 `fdfind`，最后回退到 `find`。文件预览使用 bat 行号和语法高亮；目录预览使用 ls。

```zsh
f                  # 当前目录的交互文件列表
ls | f             # 从管道读取列表
ffd                # 在 HOME 下按文件名搜索
ffd bundle.mjs     # 搜索指定文件名
ffd . main.py      # 从当前目录搜索
ffd ~/work '*.lua' # 从指定目录搜索
```

`f` 里 Enter 用 Neovim 打开文件、用 Ranger 打开目录；Alt+Enter 强制打开 Ranger；Alt+C 复制路径。`ffd` 选中文件/目录后沿用相同的打开方式。移动键包括 Tab、Shift-Tab、Alt+j/k、Alt+J/K。

## 目录管理和 SSH

| 命令 | 行为 |
|---|---|
| `ra [目录]` | Ranger 包装器，退出时切到最后访问的目录 |
| `v [参数]` | Vifm 包装器，读取退出时选择的目录 |
| `vssh [主机] [-p 端口] [-u 用户]` | 交互选择或直接 SSH 连接 |
| `vssh [主机] [-p 端口] [-d 路径]` | 另一个 Vifm SSHFS 包装脚本，挂载后浏览远端 |
| `l`、`ll`、`la` | 仅在 eza 存在时定义的列表别名 |
| `zz [目录]` | fzf 目录选择，默认从 HOME 搜索并混合 zoxide 历史 |

`vssh` 从 `~/.ssh/config`、`conf.d`、`config.d` 读取具体 Host 项；有 fzf 时预览解析后的 SSH 参数和短超时 uptime。SSHFS 脚本把挂载点放在 `~/.sshfs/`，需要本机安装 sshfs。

## 插件和补全

- **fzf-tab** 用 fzf 选择 shell 补全候选，可用 `<`、`>` 切换候选组。
- **zsh-autosuggestions** 异步显示历史或补全建议。
- **zsh-autopair** 自动配对括号与引号。
- **you-should-use** 提醒使用已有别名。
- **forgit** 为 Git 暂存、diff、历史、分支、stash、rebase、worktree 提供 fzf 选择器，例如 `ga`、`gd`、`glo`、`gcb`、`gss`、`gcp`、`grb`、`gwt`。
- **zsh-syntax-highlighting** 实时高亮命令，必须最后加载。
- **zsh-completions** 在 compinit 前补充命令完成定义。

## fnm、Node 与命令建议

`setup_fnm.sh` 把 `node`、`npm`、`npx`、`corepack` 做成惰性包装。首次调用时执行 fnm 环境初始化并选择默认 Node 版本；没有 fnm 时退回系统 Node。macOS 会把 Homebrew 路径加到 PATH。

```zsh
fnm install --lts
fnm default <版本>
node --version
```

init.sh 在 Node/npm 可用时安装 Inshellisense。交互式 Zsh 第一次启动会运行 `is init zsh` 生成集成脚本，随后 source 它。Tab 接受建议；`is doctor` 检查集成状态。

## Starship、Ghostty 和 tmux

Starship 提示符显示目录、Git 状态、语言运行时、Docker/Kubernetes/AWS/Terraform context、命令状态和耗时，分成两行。配置源在 `config/starship/starship.toml`。

Ghostty 配置 Meslo Nerd Font、真彩色暗色配色、选中复制与 F11 全屏。tmux 开启 RGB、鼠标、vi copy mode、编号从 1 开始、新窗口继承当前路径；H/J/K/L 调整 pane，X 确认后结束 session。TPM 插件包括 persist、continuum、yank、vim-tmux-navigator、tmux-fzf。私有 tmux 覆盖由独立文件接入。

## 排错

```zsh
zsh -d -n ~/dotfiles/zshrc
zinit list
type f ffd ra v vssh zz
echo $FZF_DEFAULT_COMMAND
bindkey '^R'
```

缺少 fzf 预览时检查 `fzf`、`fd`/`fdfind` 和 `bat`。插件没安装时重新启动 Zsh 或运行 `zinit update`。具体命令见 [工具目录](tools.html)。
