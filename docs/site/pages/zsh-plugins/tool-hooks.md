> 摘要：navi、Pet 两个可选 CLI 工具的 shell 集成，工具缺失时静默跳过。

# 可选工具集成

## 定位

这两个不是 Zinit 插件，而是**外部 CLI 工具**。它们各自提供一段 shell 集成代码，由 `plugins/zsh-plugins.zsh` 里的 `zsh_plugins_load_shell_tools` 统一接入。

```zsh
zsh_plugins_load_shell_tools() {
  if command -v navi >/dev/null 2>&1; then
    eval "$(navi widget zsh)"
  fi

  if command -v pet >/dev/null 2>&1; then
    function pet-select() {
      BUFFER="$(pet search --query "$LBUFFER")"
      CURSOR=$#BUFFER
      zle redisplay
    }
    zle -N pet-select
    bindkey '^X^R' pet-select
  fi
}
```

两个 `command -v` 判断是核心：工具没装就什么也不做，shell 照常启动。

## 调用时机

`zshrc` 里：

```zsh
# Load optional tool widgets after fzf, while preserving Atuin's history bindings.
zsh_plugins_load_shell_tools
```

位置在 fzf 函数加载之后、Atuin 绑定之后。原因：

| 依赖 | 说明 |
|---|---|
| fzf | navi 和 Pet 的选择界面使用 fzf |
| Atuin | 不能覆盖 `↑` 的历史绑定 |

## navi

### 集成做了什么

```zsh
eval "$(navi widget zsh)"
```

注册一个 `zle` widget，把 navi 的 cheatsheet 选择器接到命令行。选中条目后，命令写回缓冲区，不直接执行。

### 用法

| 键 | 行为 |
|---|---|
| `Ctrl+G` | 打开 navi 选择器（默认绑定） |

选中后可以继续编辑再回车。

### 依赖

| 依赖 | 用途 |
|---|---|
| `navi` | 本体 |
| `fzf` | 选择界面 |
| cheatsheet 仓库 | 内容来源 |

首次使用需要导入 cheatsheet：

```bash
navi repo add denisidoro/cheats
```

### 没装时

跳过，`Ctrl+G` 保持终端默认行为（通常是无操作）。

## Pet

### 集成做了什么

pet-select widget 将 Pet 搜索结果写回命令行，允许先检查和编辑再执行。
## 两者对比

| | navi | Pet |
|---|---|---|
| 触发 | `Ctrl+G` | `Ctrl+X Ctrl+R` |
| 数据 | cheatsheet 仓库 | 本地片段库 |
| 输出 | 写回命令行 | 写回命令行 |
| 依赖 | fzf | Pet 自身 |

## 加一个新工具的集成

在 `zsh_plugins_load_shell_tools` 里追加：

```zsh
if command -v mytool >/dev/null 2>&1; then
  eval "$(mytool init zsh)"
fi
```

三条原则：

1. 必须有 `command -v` 判断
2. 初始化输出用 `eval`（或按工具文档的方式 source）
3. 不要覆盖已有的 `Ctrl+R`、`↑` 等高频绑定

## 排错

**`Ctrl+G` 没反应**：navi 没装，或 widget 没注册。`zle -l | grep navi` 检查。

**`Ctrl+X Ctrl+R` 没反应**：pet 没装，或 `pet-select` 没注册。`type pet-select` 检查。

**集成报错但工具在**：工具的 `init` 子命令输出格式变了。手动执行看输出：

```bash
navi widget zsh | head
```

**`Ctrl+R` 被覆盖**：某个工具在 Atuin 之后绑定了它。检查 `zshrc` 里 `zsh_plugins_load_shell_tools` 的位置。
