> 摘要：navi、Pay Respects、Pet 三个可选 CLI 工具的 shell 集成，工具缺失时静默跳过。

# 可选工具集成

## 定位

这三个不是 Zinit 插件，而是**外部 CLI 工具**。它们各自提供一段 shell 集成代码，由 `plugins/zsh-plugins.zsh` 里的 `zsh_plugins_load_shell_tools` 统一接入。

```zsh
zsh_plugins_load_shell_tools() {
  if command -v navi >/dev/null 2>&1; then
    eval "$(navi widget zsh)"
  fi

  if command -v pay-respects >/dev/null 2>&1; then
    eval "$(pay-respects zsh --alias)"
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

三个 `command -v` 判断是核心：工具没装就什么也不做，shell 照常启动。

## 调用时机

`zshrc` 里：

```zsh
# Load optional tool widgets after fzf, while preserving Atuin's history bindings.
zsh_plugins_load_shell_tools
```

位置在 fzf 函数加载之后、Atuin 绑定之后。原因：

| 依赖 | 说明 |
|---|---|
| fzf | 三个工具的界面都基于 fzf |
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

## Pay Respects

### 集成做了什么

```zsh
eval "$(pay-respects zsh --alias)"
```

两件事：

1. 定义 `f` 别名，对最后一条失败命令求修正建议
2. 注册 `command_not_found_handler`，命令找不到时自动触发

### 用法

```bash
gti status      # 打错字
f               # 求建议
→ git status    # 确认后执行
```

### 安全注意

建议由规则生成，涉及以下操作时必须人工确认：

| 操作 | 风险 |
|---|---|
| `sudo` | 提权 |
| `rm` / `mv` | 破坏文件 |
| `git push --force` | 覆盖远端 |
| 覆盖类重定向 | 丢数据 |

它给的是「可能正确」，不是「一定正确」。

### 没装时

跳过，`f` 保持未定义。如果之前有别的工具定义过 `f`，不受影响。

## Pet

### 集成做了什么

```zsh
function pet-select() {
  BUFFER="$(pet search --query "$LBUFFER")"
  CURSOR=$#BUFFER
  zle redisplay
}
zle -N pet-select
bindkey '^X^R' pet-select
```

逐行解释：

| 行 | 作用 |
|---|---|
| `BUFFER="$(pet search ...)"` | 用当前已输入内容作初始查询，选中结果写回缓冲区 |
| `CURSOR=$#BUFFER` | 光标移到末尾 |
| `zle redisplay` | 重绘命令行 |
| `zle -N pet-select` | 把函数注册成 widget |
| `bindkey '^X^R'` | 绑定到 `Ctrl+X` 然后 `Ctrl+R` |

### 为什么用两段式快捷键

`Ctrl+R` 已经被 fzf 或 Atuin 占用。用 `Ctrl+X` 作为前缀键，避免冲突。

### 用法

```text
$ docker <Ctrl+X><Ctrl+R>
→ 从含 docker 的片段里选
→ 命令填入命令行
```

### 没装时

跳过，`Ctrl+X Ctrl+R` 无绑定。

## 三者对比

| | navi | Pay Respects | Pet |
|---|---|---|---|
| 触发 | `Ctrl+G` | 命令失败后 `f` | `Ctrl+X Ctrl+R` |
| 数据 | cheatsheet 仓库 | 内置规则 | 本地片段库 |
| 输出 | 写回命令行 | 直接执行 | 写回命令行 |
| 依赖 | fzf | 无 | fzf |

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

**`f` 命令不存在**：pay-respects 没装。`command -v pay-respects` 确认。

**`Ctrl+X Ctrl+R` 没反应**：pet 没装，或 `pet-select` 没注册。`type pet-select` 检查。

**集成报错但工具在**：工具的 `init` 子命令输出格式变了。手动执行看输出：

```bash
navi widget zsh | head
pay-respects zsh --alias | head
```

**`Ctrl+R` 被覆盖**：某个工具在 Atuin 之后绑定了它。检查 `zshrc` 里 `zsh_plugins_load_shell_tools` 的位置。
