> 摘要：starship.toml 的两行布局、各模块触发条件和颜色配置。

# Starship 配置

## 文件位置

| 项目 | 路径 |
|---|---|
| 仓库源文件 | `config/starship/starship.toml` |
| 部署目标 | `~/.config/starship.toml` |
| 是否自动链接 | 是 |

## 整体结构

```toml
add_newline = true
command_timeout = 2500

format = """
$hostname$directory$git_branch$git_status$python$nodejs$rust$golang$java$package$docker_context$kubernetes$aws$terraform$time
$character"""

right_format = """$status$cmd_duration$jobs"""
```

| 键 | 作用 |
|---|---|
| `add_newline` | 提示符前加一个空行，视觉上分隔命令 |
| `command_timeout` | 外部命令超时（毫秒） |
| `format` | 主行，分两行：信息行 + 字符行 |
| `right_format` | 右对齐部分 |

## 主行模块

路径、分支和 Git 状态色沿用 Neovim Blue / Nostalgia 的黄、青、绿、红色板。

### hostname

```toml
[hostname]
ssh_only = true
format = "[$hostname@ssh]($style) "
style = "bold red"
disabled = false
```

只在 SSH 会话显示，红色提示「你在远端」。

### directory

```toml
[directory]
truncation_length = 3
truncate_to_repo = true
style = "bold #ffff55"
```

| 键 | 效果 |
|---|---|
| `truncation_length = 3` | 最多显示 3 层路径 |
| `truncate_to_repo = true` | 在 Git 仓库内只显示仓库相对路径 |

两者配合：`~/projects/very/deep/nested/path/src/lib` 在仓库根为 `path/` 时显示成 `path/src/lib`。

### git_branch

```toml
[git_branch]
symbol = " "
style = "bold #55ffff"
```

`symbol` 是 Nerd Font 的分支图标。

### git_status

```toml
[git_status]
style = "bold #ffff55"
ahead = "⇡${count}"
behind = "⇣${count}"
diverged = "⇕⇡${ahead_count}⇣${behind_count}"
staged = "[+${count}](bold #00ff00)"
modified = "[~${count}](bold #ffff00)"
untracked = "[?${count}](bold #ff5555)"
deleted = "[-${count}](bold #ff5555)"
stashed = "[*${count}](bold #55ffff)"
```

| 符号 | 含义 | 颜色 |
|---|---|---|
| `+N` | 已暂存 N 个文件 | 绿 |
| `~N` | 已修改 N 个文件 | 黄 |
| `?N` | 未跟踪 N 个文件 | 红 |
| `-N` | 已删除 N 个文件 | 红 |
| `*N` | N 个 stash | 青 |
| `⇡N` | 领先远端 N 个提交 | — |
| `⇣N` | 落后远端 N 个提交 | — |

### 语言模块

```toml
[python]
symbol = " "
format = '[$symbol(${version} )(\($virtualenv\) )](bold yellow)'
detect_files = ["requirements.txt", "pyproject.toml", "setup.py", ".python-version", "Pipfile"]
detect_folders = [".venv", "venv"]

[nodejs]
symbol = " "
format = "[$symbol($version )]($style)"
style = "bold #00ff00"

[rust]
symbol = " "
format = "[$symbol($version )]($style)"
style = "bold #ff5555"

[golang]
symbol = " "
format = "[$symbol($version )]($style)"
style = "bold #55ffff"

[java]
symbol = " "
format = "[$symbol($version )]($style)"
style = "bold #5555ff"
```

Python 的 `format` 里 `\($virtualenv\)` 会在激活虚拟环境时显示环境名。

### 云与基础设施

```toml
[docker_context]
symbol = " "
format = "[$symbol$context]($style) "
style = "bold #55ffff"

[kubernetes]
symbol = "󱃾 "
format = '[$symbol$context( \($namespace\))]($style) '
style = "bold #55ffff"
disabled = false

[aws]
symbol = " "
format = '[$symbol($profile )(\\($region\\) )]($style)'
style = "bold yellow"
disabled = false

[terraform]
symbol = "󱁢 "
format = "[$symbol$workspace]($style) "
style = "bold #ff00ff"
```

四个都显式 `disabled = false`，只要检测到对应配置就显示。不用这些工具时可以改成 `true` 减少提示符宽度。

### package 和 time

```toml
[package]
symbol = "󰏗 "
format = "[$symbol$version]($style) "
style = "bold #ffff00"

[time]
disabled = false
format = "at [$time]($style) "
time_format = "%H:%M"
style = "#ffffff"
```

`package` 显示当前项目版本（从 `package.json`、`Cargo.toml` 等读取）。`time` 显示当前时间。

## 右对齐部分

```toml
[status]
disabled = false
symbol = " "
style = "bold red"

[cmd_duration]
min_time = 2_000
format = "[$duration](bold yellow) "

[jobs]
symbol = "󰒋 "
style = "bold #55ffff"
```

| 模块 | 触发 |
|---|---|
| status | 上一条命令退出码非零 |
| cmd_duration | 耗时超过 2000ms |
| jobs | 有后台任务 |

## 字符行

```toml
[character]
success_symbol = "[❯](bold green)"
error_symbol = "[❯](bold red)"
vimcmd_symbol = "[❯](bold yellow)"
```

`vimcmd_symbol` 在 vi 模式下的命令行模式显示黄色 `❯`。

## 调优建议

**提示符太长**：关掉不用的云模块：

```toml
[kubernetes]
disabled = true
```

**Git 状态慢**：大仓库里 `git_status` 会遍历所有变更。可以关掉：

```toml
[git_status]
disabled = true
```

**时间不需要**：`[time] disabled = true`。

**想改配色**：所有 `style` 都接受颜色名（`bold red`）或十六进制（例如主题黄 `bold #ffff55`）。

## 验证

```bash
starship explain          # 逐模块解释
starship timings          # 各模块耗时
starship module directory # 单独渲染
```

## 排错

**图标是方框**：字体不是 Nerd Font。

**提示符不显示 Python 版本**：`starship explain` 看原因，通常是没有触发文件。

**提示符有延迟**：`starship timings` 找慢模块。

**改了配置不生效**：确认改的是 `~/dotfiles/config/starship/starship.toml`（源文件），不是 `~/.config/starship.toml`（软链接）。

**时间显示不对**：`time_format` 用的是系统本地时区。
