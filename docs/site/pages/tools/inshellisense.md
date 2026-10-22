> 摘要：Inshellisense 在命令行下方浮出参数建议，类似 IDE 的补全体验。

# Inshellisense

## 用途

Inshellisense 是微软开源的命令行补全工具。它读取一组 command specs，在你输入命令时于下方浮出参数说明和建议，类似 IDE 的自动补全。

它与 Zsh 原生补全、fzf-tab 并行工作，不替换它们。

## 来源与安装

| 项目 | 说明 |
|---|---|
| 来源 | init.sh 通过 npm 全局安装 |
| 依赖 | Node.js / npm（由 fnm 提供） |
| 集成 | 交互式 Zsh 首次启动时 `is init zsh` 生成 |

```bash
npm install --global @microsoft/inshellisense
is init zsh
```

`is init zsh` 会生成一个集成文件并打印一条 source 命令。注意它**打印的是命令文本**，不是可直接 eval 的代码。

## 本仓库的集成方式

```zsh
if [[ -o interactive ]] && [[ -z "${ISTERM:-}" ]] && command -v is >/dev/null 2>&1; then
    if [[ ! -r "${XDG_DATA_HOME:-$HOME/.local/share}/inshellisense/init/zsh/init.zsh" ]]; then
        is init zsh >/dev/null 2>&1 || true
    fi
    if [[ -r "${XDG_DATA_HOME:-$HOME/.local/share}/inshellisense/init/zsh/init.zsh" ]]; then
        export USER_ZDOTDIR="${ZDOTDIR:-$HOME}"
        source "${XDG_DATA_HOME:-$HOME/.local/share}/inshellisense/init/zsh/init.zsh"
    fi
fi
```

三个判断条件：

| 条件 | 原因 |
|---|---|
| `-o interactive` | 非交互场景（脚本、cron）不加载 |
| `-z "${ISTERM:-}"` | 防止在它自己启动的子 shell 里递归加载 |
| `command -v is` | 没装就跳过 |

`USER_ZDOTDIR` 用于让子 shell 保持原来的 ZDOTDIR 设置。

## 用法

```bash
is                      # 进入 Inshellisense 会话
is doctor               # 检查安装健康度
is complete 'git '      # 查看某前缀的补全
is specs                # 管理 spec 列表
is uninstall            # 卸载并清理缓存
is reinit               # 重新生成集成文件
```

## 界面内的按键

| 键 | 作用 |
|---|---|
| `Tab` | 接受当前建议 |
| `↑` / `↓` | 在建议间切换 |
| `Esc` | 关闭建议面板 |
| `Ctrl+C` | 退出会话 |

## 与 fzf-tab 的分工

| | fzf-tab | Inshellisense |
|---|---|---|
| 触发 | Tab 键 | 输入时自动 |
| 数据源 | Zsh 补全系统 | 自带 command specs |
| 展示 | fzf 全屏/半屏选择器 | 命令行下方浮层 |
| 覆盖范围 | 所有注册了补全的命令 | 有 spec 的命令 |

两者不冲突：Inshellisense 的建议显示时 Tab 归它，否则 Tab 交给 fzf-tab。

## 配置文件

按优先级：

1. `~/.inshellisenserc`
2. `~/.config/inshellisense/rc.toml`

可配置项包括主题、是否显示描述、spec 路径等。查看默认值：

```bash
is specs
```

## 更新

```bash
npm install --global @microsoft/inshellisense
is reinit
```

升级后必须 `is reinit` 重新生成集成文件，否则可能加载旧版本。

## 排错

**`is` 命令找不到**：npm 全局 bin 目录没进 PATH。先触发一次 `node` 让 fnm 初始化：

```zsh
node --version
command -v is
```

**没有建议浮层**：`is doctor` 检查。常见原因是集成文件没生成，或终端不是交互式。

**Tab 行为变了**：建议显示时 Tab 被它接管。按 Esc 关掉建议，Tab 就回到 fzf-tab。

**每次启动 shell 很慢**：集成文件在每次启动时被 source。确认它不是每次重新生成——本仓库的代码先检查文件是否存在。

**在 tmux 里不显示**：某些终端复用器会干扰浮层的坐标计算。尝试在 tmux 外测试，或检查 `$TERM`。

**NixOS 上装不上**：npm 不可用时 init.sh 会跳过。先让系统提供 Node，再手动 `npm install --global @microsoft/inshellisense`。
