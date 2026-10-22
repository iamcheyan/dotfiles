> 摘要：Starship 是跨 shell 的提示符渲染器，本仓库用它生成两行提示符。

# Starship

## 用途

Starship 读取当前目录、Git 状态、语言运行时版本等信息，输出一个提示符字符串。它本身不绑定某个 shell，通过 `starship init zsh` 生成的代码在每个提示符前被调用。

本仓库的提示符、颜色、图标全部由 `config/starship/starship.toml` 定义。

## 来源与安装

| 项目 | 说明 |
|---|---|
| 来源 | Zinit，按 OS/CPU 选择 GitHub Release 包 |
| 加载位置 | `plugins/prompt/prompt.zsh` |
| 配置文件 | `config/starship/starship.toml` → `~/.config/starship.toml` |

```zsh
local _starship_bpick
if [[ "$OSTYPE" == "darwin"* ]]; then
  if [[ "$(uname -m)" == "arm64" ]]; then
    _starship_bpick="*aarch64-apple-darwin.tar.gz"
  else
    _starship_bpick="*x86_64-apple-darwin.tar.gz"
  fi
else
  if [[ "$(uname -m)" == "aarch64" ]] || [[ "$(uname -m)" == "arm64" ]]; then
    _starship_bpick="*aarch64-unknown-linux-musl.tar.gz"
  else
    _starship_bpick="*x86_64-unknown-linux-musl.tar.gz"
  fi
fi

zinit ice as"command" from"gh-r" bpick"${_starship_bpick}" pick"starship" sbin"starship"
zinit light starship/starship

if command -v starship >/dev/null 2>&1; then
  eval "$(starship init zsh)"
fi
```

Linux 用 musl 版本，静态链接，不依赖系统 glibc 版本。

## 提示符结构

```toml
format = """
$hostname$directory$git_branch$git_status$python$nodejs$rust$golang$java$package$docker_context$kubernetes$aws$terraform$time
$character"""

right_format = """$status$cmd_duration$jobs"""
```

第一行是一串信息模块，第二行只有 `$character`（`❯` 符号）。右侧单独一行显示退出状态、耗时、后台任务数。

## 各模块的配置

### directory

```toml
[directory]
truncation_length = 3
truncate_to_repo = true
style = "bold #50fa7b"
```

路径最多显示 3 层，进入 Git 仓库后只显示仓库相对路径。这解决了「路径太长把提示符撑爆」的问题。

### git_branch / git_status

```toml
[git_branch]
symbol = " "
style = "bold purple"

[git_status]
ahead = "⇡${count}"
behind = "⇣${count}"
diverged = "⇕⇡${ahead_count}⇣${behind_count}"
staged = "[+${count}](bold green)"
modified = "[~${count}](bold yellow)"
untracked = "[?${count}](bold red)"
deleted = "[-${count}](bold red)"
stashed = "[*${count}](bold blue)"
```

用符号和颜色区分六种状态：已暂存、已修改、未跟踪、已删除、stash、领先/落后远端。

### 语言模块

| 模块 | 触发文件 |
|---|---|
| python | `requirements.txt`、`pyproject.toml`、`setup.py`、`.python-version`、`Pipfile`、`.venv/`、`venv/` |
| nodejs | `package.json` |
| rust | `Cargo.toml` |
| golang | `go.mod` |
| java | `pom.xml`、`build.gradle` |

python 模块还会显示虚拟环境名：

```toml
[python]
format = '[$symbol(${version} )(\($virtualenv\) )](bold yellow)'
```

### 云与基础设施

| 模块 | 显示内容 |
|---|---|
| docker_context | 非默认 Docker context 名 |
| kubernetes | context 和 namespace |
| aws | profile 和 region |
| terraform | workspace |

这些默认是 `disabled = false`，只要检测到对应配置就显示。如果你不用它们，可以在 `local/` 里覆盖成 `disabled = true`。

### cmd_duration

```toml
[cmd_duration]
min_time = 2_000
format = "[$duration](bold yellow) "
```

只显示超过 2 秒的命令，避免每条命令都出现 `0ms`。

### hostname

```toml
[hostname]
ssh_only = true
format = "[$hostname@ssh]($style) "
```

只在 SSH 会话显示，提示你「现在操作的是远端机器」。

## 常用命令

```bash
starship explain              # 解释当前提示符每个模块
starship prompt               # 打印当前提示符
starship module directory     # 单独渲染某模块
starship config               # 打开配置文件
starship preset --list        # 列出内置预设
starship preset nerd-font-symbols -o ~/.config/starship.toml
starship timings              # 各模块耗时（排查慢）
```

`starship explain` 是排查提示符问题最快的手段：它会逐模块说明「为什么显示」或「为什么不显示」。

## 性能

Starship 每次渲染提示符都会执行，模块越多越慢。排查方法：

```bash
starship timings
```

输出每个模块的耗时。常见慢项：

- `git_status` 在大仓库里慢（要遍历所有变更文件）
- `kubernetes` / `aws` 要读配置文件和执行外部命令
- `cmd_duration` 依赖 shell hook

如果提示符有明显延迟，先关掉不用的云模块。

## Nerd Font 依赖

配置里大量使用 Nerd Font 私有区字符（`❯`、``、``、`󰏗`）。终端字体必须是 Nerd Font，否则显示成方框。

本仓库用 Meslo Nerd Font，由 `scripts/install/install_font.sh` 安装。装完后在终端设置里选择 `MesloLGS Nerd Font`。

## 与 Ghostty 的关系

Ghostty 提供字体和配色，Starship 提供文字内容。两者独立：换 Ghostty 主题不影响 Starship 输出，但字体缺失会让图标变成方块。

## 排错

**提示符是默认的 `%`**：`starship init zsh` 没执行。检查 `plugins/prompt/prompt.zsh` 是否被 source，以及它是否在 `[[ -t 1 ]]` 条件内被跳过（非交互场景）。

**图标显示成方框**：字体不对。装 Meslo Nerd Font 并在终端里选中。

**Git 状态不显示**：不在仓库内，或 `git_status` 被 `disabled = true`。

**提示符有延迟**：`starship timings` 找出慢模块，在 `local/` 里关掉。

**Python 版本不显示**：当前目录没有触发文件。`starship explain` 会说明。
