> 摘要：forgit 把 Git 的常见操作包装成 fzf 选择器，本仓库用它的短别名做日常操作。

# forgit

## 用途

forgit 是一组 shell 函数，每个函数打开一个 fzf 选择器，选完直接执行对应的 Git 命令。它把「记参数」变成「选条目」。

## 加载方式

```zsh
zsh_plugins_load_main() {
  ...
  zinit light wfxr/forgit
  ...
}
```

在 main 阶段加载，位置在 autosuggestions 之后、syntax-highlighting 之前。

**依赖**：fzf 0.60.0 或更新。版本太旧时 forgit 会报错。

## 命令清单

### 暂存与撤销

| 命令 | 作用 | 底层 |
|---|---|---|
| `ga` | 选文件加入暂存区 | `git add` |
| `grh` | 从暂存区移除 | `git reset HEAD` |
| `grs` | 恢复文件到某次提交 | `git checkout` |
| `gclean` | 清理未跟踪文件 | `git clean` |

### 查看

| 命令 | 作用 |
|---|---|
| `gd` | 浏览文件 diff |
| `glo` | 浏览提交历史 |
| `gss` | 浏览 stash 列表 |

### 分支

| 命令 | 作用 |
|---|---|
| `gcb` | 切换分支 |
| `gsw` | 选择并切换分支 |
| `gbd` | 删除分支 |
| `grb` | 交互式 rebase |

### 提交与补丁

| 命令 | 作用 |
|---|---|
| `gcp` | 选择提交 cherry-pick |
| `gsp` | 选择文件创建 stash |
| `gwt` | 浏览 worktree |
| `gi` | 生成 `.gitignore` 条目 |

## 界面内按键

| 键 | 作用 |
|---|---|
| `Tab` | 标记多个条目 |
| `Enter` | 确认 |
| `?` | 显示/隐藏预览 |
| `Ctrl+/` | 切换预览窗口 |

## 危险命令

以下命令**回车即执行**，没有二次确认：

| 命令 | 风险 |
|---|---|
| `gbd` | 删除分支，未合并提交可能丢失 |
| `gclean` | 删除未跟踪文件，无法恢复 |
| `grs` | 覆盖工作区文件 |
| `grb` | rebase 改写历史，可能冲突 |
| `gcp` | cherry-pick 可能冲突 |
| `grh` | 从暂存区移除（可恢复） |

确认选择内容再按 Enter。

## 自定义 fzf 行为

每个功能有对应的环境变量：

```zsh
export FORGIT_LOG_FZF_OPTS='--height 80% --border'
export FORGIT_ADD_GIT_OPTS='--others --cached --modified'
export FORGIT_DIFF_FZF_OPTS='--preview-window=right:60%'
```

命名规律：`FORGIT_<功能名>_FZF_OPTS`。

放在 `local/custom.zsh` 里覆盖。

## 别名冲突

forgit 的短命令可能和你的别名撞。两种处理：

```zsh
# 完全禁用短别名，只用 forgit:: 前缀
export FORGIT_NO_ALIASES=1

# 或加载前改名
forgit_add=gadd
zinit light wfxr/forgit
```

本仓库没有禁用，所以 `ga`、`gd` 等是生效的。

## 与 lazygit / gitui 的分工

| 工具 | 形态 | 适合 |
|---|---|---|
| forgit | shell 函数 + fzf | 单个操作，快进快出 |
| lazygit | 独立 TUI | 连续多个操作，看全局 |
| gitui | 独立 TUI | 同上，Rust 实现 |

「只想 add 两个文件」用 forgit 最快，「整理提交历史」用 lazygit。

## 实用流程

### 暂存部分文件

```text
$ ga
→ 勾选 file1.lua、file2.md（Tab 多选）
→ Enter
→ 两个文件进暂存区
```

### 查看某个提交改了什么

```text
$ glo
→ 浏览提交列表，右侧预览 diff
→ Enter 查看详情
```

### 从别的分支挑一个提交

```text
$ gcp
→ 选中提交
→ cherry-pick 到当前分支
```

## 排错

**`ga` 等命令不存在**：forgit 没加载。`zinit list | grep forgit` 确认。

**报 fzf 版本太低**：

```bash
fzf --version
```

低于 0.60.0 时用官方安装脚本升级，系统包往往太旧。

**预览空白**：预览依赖 `git diff` 和 bat/less。`command -v bat` 检查。

**在非 Git 目录执行报错**：预期行为，forgit 需要仓库上下文。

**`gclean` 删了想要的文件**：无法恢复。这就是为什么它列在危险命令里。日常先 `git status` 看清楚。

**中文路径显示异常**：fzf 的显示宽度计算问题，不影响实际操作。
