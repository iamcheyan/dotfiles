# Zsh 交互式命令行工具

本文说明本仓库接入的 forgit 和 Pet：Git 交互操作与命令片段管理。

## 安装与初始化

在仓库根目录运行：

```bash
bash init.sh
```

Pet 由 Zinit 管理，forgit 由 `plugins/zsh-plugins.zsh` 加载。

```bash
exec zsh
```

Zinit 管理的工具都是可选的；shell 配置仅在检测到对应命令时执行集成。手动检查：

```bash
command -v fzf pet
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
| [Pet](https://github.com/knqyf263/pet) | 保存、搜索和复用命令片段 | `pet`、`Ctrl+X` 后 `Ctrl+R` |

## 长命令编辑

ZLE 里内置两个长命令编辑入口：

- `Ctrl+X`、`Ctrl+E`：把当前命令行交给 `$EDITOR` / `$VISUAL`（本仓库为 Neovim），保存退出后回到输入行，确认后再执行。
- `Ctrl+O`：在光标处插入换行，不执行命令。

实现见 `plugins/zle/zle.zsh`；`zsh-vi-mode` 的 Insert 键位在 `plugins/zsh-plugins.zsh` 的 `zvm_after_init` 中注册。完整说明与排错见 [长命令编辑](site/pages/shell/long-command-editing.md)。

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
command -v pet
```

如果 shell 启动报错，可确认对应工具能运行其初始化子命令（例如 `pet search`）。工具存在但无法运行或初始化失败时，hook 会跳过该集成，不影响 Zsh 启动。
