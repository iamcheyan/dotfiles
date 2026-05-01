# 🛠 Git 高效工作流指南

本配置集成了一套深度定制的 Git 增强体系，旨在通过 **快捷别名 (Aliases)**、**交互式工具 (Forgit)** 以及 **扩展功能集 (Git-Extras)** 提升开发效率。

## 1. 快捷别名 (Quick Aliases)
这些别名预设在 `aliases.conf` 中，旨在减少输入量。

| 别名 | 对应命令 | 说明 |
| :--- | :--- | :--- |
| **`git:init`** | 本地 `git init` + 安全模板生成 | **核心命令**：初始化仓库并生成完善的 `.gitignore` |
| **`g:a`** | `git add -A` | **一键暂存**：将所有修改加入暂存区 |
| **`g:u`** | `git reset HEAD` | **一键撤回**：取消所有已暂存的修改 |
| **`g:w`** | `git stash` | **临时存盘**：保存当前进度并清空工作区 (WIP) |
| **`g:p`** | `git stash pop` | **恢复进度**：将最近一次存盘内容弹回工作区 |
| **`g:s`** | `git status -s` | **简洁状态**：以极简格式显示当前仓库状态 |
| **`lg`** | `lazygit` | **终端 UI**：启动全功能 Git 终端界面 |
| **`git:clean`** | `scripts/dev/git_clean.sh` | **深度清理**：安全删除未跟踪的文件和目录 |

## 2. 交互式工具 (Forgit - 快捷键)
Forgit 提供了基于 `fzf` 的交互式界面，极大简化了筛选过程。

- **`ga` (Git Add)**：交互式选择文件进行暂存（按 `Space` 切换，`Enter` 确认）。
- **`glo` (Git Log)**：交互式浏览提交历史，右侧实时预览代码差异。
- **`gd` (Git Diff)**：交互式查看工作区与暂存区的差异。
- **`gss` (Git Stash)**：交互式预览和选择存盘记录。
- **`gi` (Git Ignore)**：从 `gitignore.io` 交互式下载并生成忽略模板。

## 3. 功能扩展集 (Git-Extras)
通过 `brew install git-extras` 安装的增强型命令行工具。

- **`git snap`**：为当前工作状态创建即时快照。
- **`git summary`**：输出当前仓库的作者统计、文件数量等概览信息。
- **`git effort`**：分析文件的修改活跃度，定位频繁改动的热点文件。
- **`git info`**：显示仓库的详细元数据信息。
- **`git branch-diff`**：查看两个分支之间的详细文件差异。

## 4. 自动化管理 (Scripts)
- **`.gitignore` 自动生成**：使用 `git:init` 时会自动注入包含 `ANGENS.md`、`GEMINI.md`、Node.js、Python、Rust 等常见环境的忽略规则。
- **多端同步**：通过 `dotsync:push` 和 `dotsync:pull` 快速管理 dotfiles 仓库的同步。

---
*建议经常运行 `g:s` 检查状态，配合 `ga` 进行精细化的文件管理。*
