# Zsh 交互式命令行工具

本文说明本仓库接入的三个工具：forgit、navi 和 Pet。它们分别覆盖 Git 交互操作、命令速查和命令片段管理。

## 安装与初始化

在仓库根目录运行：

```bash
bash init.sh
```

navi 和 Pet 作为 CLI 工具由 `plugins/tools/tools.zsh` 中的 Zinit 配置管理；forgit 由 `plugins/zsh-plugins.zsh` 加载。首次启动 Zsh 时，Zinit 会下载尚未安装的工具和插件。随后重新启动 shell：

```bash
exec zsh
```

工具都是可选的。shell 配置仅在检测到对应命令时执行集成，因此某个工具安装失败不会影响 Zsh 启动。手动检查：

```bash
command -v fzf navi pet
```

forgit 需要 Git、fzf 0.60.0 或更新版本。`init.sh` 会安装 fzf；如果系统仓库提供的版本过旧，请按 [fzf 官方安装说明](https://github.com/junegunn/fzf#installation)升级。

更新 Zinit 管理的组件：

```zsh
zinit update
```

## 快速对照

| 工具 | 主要用途 | 入口 |
| --- | --- | --- |
| [forgit](https://github.com/wfxr/forgit) | 用 fzf 交互选择 Git 对象并执行 Git 操作 | `ga`、`glo`、`gcb` 等 |
| [navi](https://github.com/denisidoro/navi) | 搜索、填充并运行 cheatsheet 命令 | `navi` 和其 Zsh widget |
| [Pet](https://github.com/knqyf263/pet) | 保存、搜索和复用命令片段 | `pet`、`Ctrl+X` 后 `Ctrl+R` |

## forgit：交互式 Git

forgit 基于 fzf，把文件、分支、提交、stash 和 worktree 放进交互选择器。常用命令：

```zsh
ga       # 选择文件并加入暂存区
gd       # 浏览文件 diff
glo      # 交互浏览提交历史
gcb      # 切换分支
gsw      # 选择并切换分支
gss      # 浏览 stash
gsp      # 选择文件创建 stash
gcp      # 选择提交并 cherry-pick
grb      # 交互式 rebase
gwt      # 浏览 worktree
gi       # 生成 .gitignore 条目
```

使用 `Tab` 标记多个条目，`Enter` 确认，`?` 显示或隐藏预览。forgit 的命令会直接调用 Git，尤其是 `gbd`（删除分支）、`gclean`（清理文件）、`grh`（从暂存区移除）、`grs`（恢复文件）和 rebase/cherry-pick 等操作，应在确认选择后再提交。完整命令列表可用 `functions` 查看，或参考 [forgit README](https://github.com/wfxr/forgit#usage)。

修改某个功能的 fzf 行为可设置对应环境变量，例如：

```zsh
export FORGIT_LOG_FZF_OPTS='--height 80% --border'
export FORGIT_ADD_GIT_OPTS='--others --cached --modified'
```

默认快捷命令较短，可能与个人别名冲突。forgit 支持在加载插件前通过 `forgit_add`、`forgit_log` 等变量改名；也可以设置 `FORGIT_NO_ALIASES=1` 禁用这些别名，仅使用 `forgit::...` 函数。

## navi：交互式命令速查

运行 `navi` 搜索 cheatsheet，选择条目后按提示填写参数。命令先写入当前命令行，确认后再执行。首次使用时可按提示浏览或导入 cheatsheet 仓库。个人 cheatsheet 默认存放于 `~/.local/share/navi/cheats/`，配置可放在 `~/.config/navi/`。

示例 cheatsheet（`.cheat` 文件）：

```text
% git, branch

# 创建并切换到分支
 git switch -c <branch>

$ branch: git branch --format='%(refname:short)'
```

`<branch>` 是需要填写的参数，`$ branch:` 行给出候选值。直接运行 `navi --help` 查看筛选标签、仓库管理和导入命令。Zsh widget 由 `navi widget zsh` 注册；如要单独使用此功能，在没有本仓库配置的 shell 中执行：

```zsh
eval "$(navi widget zsh)"
```

## Pet：保存命令片段

新增片段：

```zsh
pet new
```

按提示填写命令、说明和标签。然后使用：

```zsh
pet search                 # 交互搜索
pet search --query docker  # 带初始查询
pet edit                   # 编辑片段
pet --help                 # 查看其他子命令
```

本仓库将 `Ctrl+X` 后按 `Ctrl+R` 绑定到 Pet 搜索。选中的命令填入当前输入行，可以先修改再执行。Pet 片段保存在用户配置目录下的 TOML 文件；常见位置为 `~/.config/pet/snippet.toml`。需要同步时可按 Pet 的配置接入 Gist 或 GitLab Snippets，不要把私人 token 写入本仓库。

## 快捷键和排错

- Pet 使用 `Ctrl+X`、再按 `Ctrl+R`，不占用 Atuin 的上箭头历史搜索。
- forgit 的选择和预览按键只在其 fzf 窗口内生效。

若新增/更新插件后某个命令不可用，重启 Zsh，并可清除补全缓存：

```zsh
rm -f ~/.zcompdump*
exec zsh
```

检查某个 Zinit 工具是否安装：

```zsh
zinit list
command -v navi pet
```

如果 shell 启动报错，可临时注释 `plugins/zsh-plugins.zsh` 中对应工具 hook，或确认该可执行文件能运行其初始化子命令（例如 `navi widget zsh`）。所有 hook 都有 `command -v` 检查；工具尚未安装时会被跳过。
