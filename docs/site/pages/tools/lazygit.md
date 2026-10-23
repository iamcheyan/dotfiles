> 摘要：lazygit 是终端里的 Git 全功能界面，适合连续做多个操作。

# lazygit

## 用途

lazygit 把 Git 的常见操作组织成可键盘导航的面板：文件状态、分支、提交历史、stash。它不替代 Git，而是给你一个看得见全局的界面。

## 来源与安装

| 项目 | 说明 |
|---|---|
| 来源 | Zinit，从 GitHub Release 下载 |
| 加载位置 | `plugins/tools/tools.zsh` |

```zsh
zi_cmd jesseduffield/lazygit lazygit
```

## 启动

```bash
lazygit                # 在当前仓库打开
lazygit -p ~/project   # 指定仓库路径
lazygit log            # 启动时聚焦到 log 面板
lazygit branch         # 聚焦分支面板
lazygit status         # 聚焦状态面板
lazygit stash          # 聚焦 stash 面板
```

位置参数可以是 `status`、`branch`、`log`、`stash`，决定打开后光标停在哪。

## 面板结构

```text
┌─ Status ─┬─ Files ──────┬─ Diff ─────────────┐
│          │ M file1.lua  │ - old line         │
│          │ ?? file2.md  │ + new line         │
├──────────┴──────────────┴────────────────────┤
│ Branches / Commits / Stash                   │
└──────────────────────────────────────────────┘
```

左侧是仓库状态（分支、ahead/behind、stash 数），中间是文件列表，右侧是 diff。下方可切换分支、提交、stash 视图。

## 常用按键

| 键 | 作用 |
|---|---|
| `1`–`5` | 切换面板 |
| `↑` / `↓` 或 `j` / `k` | 移动 |
| `Space` | 暂存/取消暂存当前文件 |
| `a` | 暂存全部 |
| `c` | 提交 |
| `A` | 修改最后一次提交 |
| `P` | push |
| `p` | pull |
| `d` | 查看 diff |
| `Enter` | 进入详情 |
| `?` | 帮助（完整键位表） |
| `q` | 退出 |

`?` 是这里最重要的键——lazygit 的键位很多，帮助面板按上下文显示当前可用的操作。

## 常用流程

### 提交一部分改动

1. 在 Files 面板选中文件
2. 按 `Enter` 进入，用 `Space` 逐行/逐块暂存
3. 返回，按 `c` 提交

### 修改最后一次提交

```text
A → 编辑提交信息 → 确认
```

适合「刚提交完发现漏了一个文件」的场景。

### 交互式 rebase

在 Commits 面板选中某个提交，按 `e` 进入 rebase 编辑模式，可 squash、reword、drop。

## 配置文件

```bash
lazygit -c            # 打印默认配置
lazygit -cd           # 打印配置目录路径
```

默认位置：`~/.config/lazygit/config.yml`（Linux）。本仓库没有提供该文件，用上游默认值。

常用自定义：

```yaml
gui:
  theme:
    lightTheme: false
  nerdFontsVersion: "3"
```

## 与 forgit 的分工

| | forgit | lazygit |
|---|---|---|
| 形态 | shell 函数，单个操作 | 独立 TUI，全局视图 |
| 退出后 | 回到 shell | 回到 shell |
| 适合 | 快速 add 一个文件 | 整理提交历史、解决冲突 |

两者都装，按场景选。

## 排错

**`lazygit: command not found`**：Zinit 未下载。`zinit list | grep lazygit` 确认。

**界面乱码**：终端字体不是 Nerd Font，或 `$TERM` 不支持。装 Meslo 并检查 tmux 的 `default-terminal`。

**diff 颜色丢失**：lazygit 调用 `git diff` 时用了 `--color=never`。检查 `git.paging.colorArg` 配置。

**大仓库很慢**：lazygit 要扫描状态。可以在配置里关掉某些自动刷新，或对超大仓库改用 `git status` + forgit。

**在 tmux 里按键冲突**：tmux 的 prefix 可能拦截某些键。用 `Ctrl+B` 后按 `:` 临时发送，或改 tmux 键位。
