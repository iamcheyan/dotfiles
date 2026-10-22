> 摘要：shell 环境由哪些文件组成，为什么按这个顺序读。

# 本章导读

## 组成

Zsh 环境由四层叠起来：

1. **`zshrc`** — 入口。设置选项、推导仓库路径、按顺序 source 其它文件。
2. **`plugins/zsh-plugins.zsh`** — 插件层。Zinit 加载补全、fzf-tab、vi-mode、autosuggestions、forgit、语法高亮。
3. **`plugins/tools/tools.zsh`** — 工具层。用 Zinit 从 GitHub Release 下载 CLI 二进制，并初始化 direnv/atuin。
4. **`plugins/fzf/fzf.zsh`** — 交互层。`f`、`ffd` 两个函数和 `FZF_DEFAULT_OPTS`。

提示符（`plugins/prompt/prompt.zsh`）和补全（`plugins/completion/completion.zsh`）各自独立，在 `zshrc` 里按位置插入。

## 为什么顺序重要

Zsh 插件对加载时机敏感：

- `zsh-completions` 必须在 `compinit` **之前**加载，否则补全定义不生效。
- `fzf-tab` 必须在 `compinit` **之后**加载，否则它拿不到补全系统。
- `zsh-syntax-highlighting` 必须**最后**加载，否则它的 hook 会被后续插件覆盖。
- `zsh-vi-mode` 必须在 `zsh-autosuggestions` 之前，避免按键绑定冲突。

`zsh-plugins.zsh` 用三个函数把这些约束显式化：`zsh_plugins_load_pre_compinit`、`zsh_plugins_load_post_compinit`、`zsh_plugins_load_main`。`zshrc` 在正确的位置调用它们。

## 阅读顺序建议

| 想解决的问题 | 读哪篇 |
|---|---|
| 启动报错、某个命令没定义 | [启动与加载顺序](loading.html) |
| 历史搜索、vi 模式、按键 | [历史与命令行编辑](history.html) |
| Tab 补全不好用 | [补全系统](completion.html) |
| 想加/删插件 | [交互插件](plugins.html) |
| `f` 或 `ffd` 行为不符预期 | [f 与 ffd 函数](fzf-functions.html) |
| Node 版本、npm 命令异常 | [fnm 与 Node 工具链](fnm-node.html) |
| 提示符、终端、tmux | [终端与提示符](terminal.html) |

## 一个原则

shell 配置只做「探测后加载」：几乎所有可选集成都先用 `command -v` 判断命令是否存在。某个工具没装，shell 仍然能正常启动。这条规则在 `plugins/zsh-plugins.zsh` 的 `zsh_plugins_load_shell_tools` 里最明显。
