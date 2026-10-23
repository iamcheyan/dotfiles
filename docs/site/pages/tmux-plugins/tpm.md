> 摘要：TPM 是 tmux 的插件管理器，负责克隆、加载和更新 tmux.conf 里声明的插件。

# TPM

## 用途

tmux 没有内置插件系统。TPM（Tmux Plugin Manager）提供了：

- 读取 `tmux.conf` 里的 `@plugin` 声明
- 克隆对应仓库到插件目录
- 启动时 source 每个插件的 `.tmux` 文件
- 提供安装 / 更新 / 清理的快捷键

## 声明方式

```tmux
set -g @plugin 'tmux-plugins/tpm'
set -g @plugin 'tmux-plugins/tmux-sensible'
set -g @plugin 'hyoretsu/tmux-persist'
set -g @plugin 'tmux-plugins/tmux-continuum'
set -g @plugin 'tmux-plugins/tmux-yank'
set -g @plugin 'christoomey/vim-tmux-navigator'
set -g @plugin 'sainnhe/tmux-fzf'

run '~/.config/tmux/plugins/tpm/tpm'
```

最后一行的 `run` 是**必需的**，且必须在所有 `@plugin` 之后。它启动 TPM 本体。

也可以写完整 URL 或本地路径：

```tmux
set -g @plugin 'https://github.com/user/plugin'
set -g @plugin '~/my/local/plugin'
```

## 安装位置

```tmux
run-shell 'tmux set-environment -g TMUX_PLUGIN_MANAGER_PATH "$HOME/.config/tmux/plugins/"'
```

本仓库改成 `~/.config/tmux/plugins/`，默认是 `~/.tmux/plugins/`。

`run-shell` 而不是直接 `set-environment`，是为了让 shell 先展开 `$HOME`。tmux 自己解析变量在不同版本下行为不一致。

## 快捷键

| 键 | 作用 |
|---|---|
| `Prefix + I` | 安装新声明的插件，并更新已装的 |
| `Prefix + U` | 更新所有插件 |
| `Prefix + Alt+u` | 删除未在配置里声明的插件 |

`I` 是大写 i（install），`U` 是大写 u（update）。

状态栏会显示进度。完成后提示：

```text
TMUX environment reloaded.
Done, press ENTER to continue.
```

## 手动安装

不想用快捷键，或在没有交互的场景：

```bash
# 克隆 TPM 本体
git clone https://github.com/tmux-plugins/tpm ~/.config/tmux/plugins/tpm

# 启动 tmux 后执行安装脚本
~/.config/tmux/plugins/tpm/bin/install_plugins

# 更新
~/.config/tmux/plugins/tpm/bin/update_plugins all

# 清理
~/.config/tmux/plugins/tpm/bin/clean_plugins
```

## 目录结构

```text
~/.config/tmux/plugins/
├── tpm/
├── tmux-sensible/
├── tmux-persist/
├── tmux-continuum/
├── tmux-yank/
├── vim-tmux-navigator/
└── tmux-fzf/
```

每个插件目录里有一个或多个 `*.tmux` 文件，TPM 在启动时 source 它们。

## 配置重载

改了 `tmux.conf` 后：

```bash
tmux source-file ~/.config/tmux/tmux.conf
```

如果新增了 `@plugin`，还需要 `Prefix + I` 才会下载。

## 与 tmux 版本的关系

TPM 需要 tmux 1.9 以上。本仓库的 tmux 配置用了 `terminal-features` 等较新选项，建议 tmux 3.2+。

```bash
tmux -V
```

## 排错

**`Prefix + I` 没反应**：TPM 没加载。检查 `tmux.conf` 末尾的 `run` 行是否指向正确路径。

**插件下载失败**：网络问题。手动 `git clone` 到插件目录，再 `Prefix + I`。

**插件装了但不生效**：TPM 只 source 插件目录里的 `*.tmux` 文件。检查该文件是否存在。

**路径不对**：

```bash
# 在 tmux 里执行
tmux show-environment -g TMUX_PLUGIN_MANAGER_PATH
```

**权限问题**：插件目录不可写。检查 `~/.config/tmux/` 的权限。

**插件之间冲突**：见各插件文档的排错部分。常见是键位重叠，比如 vim-tmux-navigator 和某个 pane 切换插件都绑 `Ctrl+h`。
