> 摘要：forgit 把 Git 的常见操作接到 fzf 上，提供 ga、gd、glo、gcb 等一组交互命令。

# forgit

## 用途

forgit 是一个 Zsh 插件，把 Git 操作包装成 fzf 选择器。你不用记 `git add -p` 的交互流程，直接 `ga` 选文件；不用记 `git log --graph --oneline`，直接 `glo` 浏览。

## 来源与安装

| 项目 | 说明 |
|---|---|
| 来源 | Zinit 插件，`plugins/zsh-plugins.zsh` |
| 依赖 | Git、fzf 0.60.0+ |
| 加载位置 | `zsh_plugins_load_main` 阶段 |

```zsh
zinit light wfxr/forgit
```

## 命令列表

### 暂存与撤销

| 命令 | 作用 | 底层 |
|---|---|---|
| `ga` | 选择文件加入暂存区 | `git add` |
| `grh` | 从暂存区移除 | `git reset HEAD` |
| `grs` | 恢复文件到某次提交 | `git checkout` |
| `gclean` | 清理未跟踪文件 | `git clean` |

### 查看

| 命令 | 作用 | 底层 |
|---|---|---|
| `gd` | 浏览文件 diff | `git diff` |
| `glo` | 浏览提交历史 | `git log` |
| `gss` | 浏览 stash 列表 | `git stash list` |

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
| `Enter` | 确认选择 |
| `?` | 显示/隐藏预览 |
| `Ctrl+/` | 切换预览窗口 |

## 危险命令

以下命令会改变仓库状态，回车即执行：

| 命令 | 风险 |
|---|---|
| `gbd` | 删除分支，未合并的提交可能丢失 |
| `gclean` | 删除未跟踪文件，无法恢复 |
| `grh` | 从暂存区移除 |
| `grs` | 覆盖工作区文件 |
| `grb` | rebase 可能产生冲突，改写历史 |
| `gcp` | cherry-pick 可能产生冲突 |

确认选择内容后再回车。forgit 不做二次确认，它信任你的选择。

## 自定义 fzf 行为

每个功能对应一个环境变量：

```zsh
export FORGIT_LOG_FZF_OPTS='--height 80% --border'
export FORGIT_ADD_GIT_OPTS='--others --cached --modified'
export FORGIT_DIFF_FZF_OPTS='--preview-window=right:60%'
```

命名规律：`FORGIT_<功能名>_FZF_OPTS`。

## 别名冲突

forgit 的短命令可能与你的别名冲突。两种处理：

```zsh
# 方案一：完全禁用短别名，只用 forgit:: 前缀
export FORGIT_NO_ALIASES=1

# 方案二：加载前改名
forgit_add=gadd
zinit light wfxr/forgit
```

## 与 lazygit / gitui 的分工

| 工具 | 适合场景 |
|---|---|
| forgit | 单个操作，快进快出，留在当前 shell |
| lazygit | 需要连续做多个操作，看全局状态 |
| gitui | 同上，偏好 Rust 实现 |

forgit 不需要进入另一个界面，适合「只想 add 两个文件」这类小操作。

## 排错

**`ga` 等命令不存在**：forgit 没加载。`zinit list | grep forgit` 确认。

**报 fzf 版本太低**：需要 0.60.0+。`fzf --version` 检查，系统包太旧就用官方安装脚本。

**预览区空白**：预览依赖 `git diff` 和 bat/less。`command -v bat` 确认。

**在非 Git 目录里执行报错**：正常行为，forgit 需要仓库上下文。

**`gclean` 删了想要的文件**：无法恢复。这就是为什么它被列在危险命令里。日常用 `git status` 先看清楚。
