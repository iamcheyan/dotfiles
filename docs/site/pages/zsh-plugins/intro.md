> 摘要：Zsh 环境的 13 个插件各自负责什么，按哪个阶段加载，读哪一篇。

# 本章导读

## 插件全景

`plugins/zsh-plugins.zsh` 和 `plugins/tools/tools.zsh` 一共加载 12 项。它们不是平铺的，而是按 Zsh 的初始化约束分三段加载。

| 阶段 | 插件 | 为什么在这个位置 |
|---|---|---|
| compinit 前 | zsh-completions | 补全定义必须先进入 `$fpath` |
| compinit 后 | fzf-tab | 需要 `compinit` 建立的补全系统 |
| main 阶段 | evalcache | 缓存后续 hook 的输出 |
| main 阶段 | zsh-vi-mode | 必须在 autosuggestions 之前，避免键位冲突 |
| main 阶段 | zsh-autosuggestions | 依赖 vi-mode 的键位已就位 |
| main 阶段 | zsh-autopair | 无顺序依赖 |
| main 阶段 | you-should-use | 无顺序依赖 |
| main 阶段 | forgit | 依赖 fzf |
| main 阶段 | zsh-syntax-highlighting | **必须最后**，否则 hook 被覆盖 |
| 任意 | Zinit 本体 | 一切的前提 |
| 任意 | fzf 补全/键绑定 snippet | 上游脚本，非插件 |
| 运行时 | navi / Pet hook | 工具装了才接入 |

## 为什么顺序不能乱

三个硬约束：

1. **compinit 之前必须有 zsh-completions**。`compinit` 扫描 `$fpath` 生成补全缓存，之后再加载的补全定义不会自动生效。
2. **fzf-tab 必须在 compinit 之后**。它替换的是补全菜单的显示层，没有补全系统就没有可替换的东西。
3. **syntax-highlighting 必须最后**。它通过 `zle` 的 `line-pre-redraw` hook 上色，任何在它之后设置 hook 的插件都会打断着色。

违反任一条，症状都很隐蔽：不报错，只是功能静默失效。

## 阅读顺序

| 想了解 | 读哪篇 |
|---|---|
| 插件怎么装、怎么更新 | [Zinit](zinit.html) |
| Tab 补全不好用 | [zsh-completions](zsh-completions.html)、[fzf-tab](fzf-tab.html) |
| 启动太慢 | [evalcache](evalcache.html) |
| 命令行 Vim 键位 | [zsh-vi-mode](vi-mode.html) |
| 建议文字颜色/行为 | [zsh-autosuggestions](autosuggestions.html) |
| 括号自动补全 | [zsh-autopair](autopair.html) |
| 别名提醒烦人 | [you-should-use](you-should-use.html) |
| Git 交互命令 | [forgit](forgit.html) |
| 语法高亮失效 | [zsh-syntax-highlighting](syntax-highlighting.html) |
| `Ctrl+T` / `Ctrl+R` | [fzf 补全与键绑定](fzf-snippets.html) |
| `f`、`Ctrl+X Ctrl+R` 从哪来 | [可选工具集成](tool-hooks.html) |

## 加一个插件的流程

```bash
$EDITOR ~/dotfiles/plugins/zsh-plugins.zsh
```

1. 判断它属于哪个阶段，放进对应的 `zsh_plugins_load_*` 函数。
2. `zinit light owner/repo`，需要参数时先 `zinit ice`。
3. 把该插件的环境变量、`zstyle`、hook 紧挨着写在下面，不要分散到别的文件。
4. 检查：

```bash
zsh -d -n ~/dotfiles/plugins/zsh-plugins.zsh
TERM=xterm-256color zsh -lic 'source ~/dotfiles/zshrc >/dev/null 2>&1; true'
```

## 一条设计原则

所有可选集成都是「先探测、再加载」：

```zsh
if command -v navi >/dev/null 2>&1; then
  eval "$(navi widget zsh)"
fi
```

工具没装时什么也不做，shell 照常启动。这条规则让整个配置在没有 Zinit 缓存、没有额外工具的新机器上也能启动。
