# hunk-review.nvim 使用说明

这份文档说明本 Neovim 配置中的 hunk-review.nvim。它用于审查 Git 工作区里的代码变更，特别适合在 Agent 修改多个文件之后，逐个文件、逐个变更块地检查结果。

## 1. 它解决什么问题

目标界面是：

~~~text
┌──────────────────────┬────────────────────────────────────┐
│ 变更文件列表          │ unified diff                        │
│ M config.lua         │ - 删除的内容                        │
│ M script.sh          │ + 新增的内容                        │
│ A new-file.md        │   未修改的上下文                      │
└──────────────────────┴────────────────────────────────────┘
~~~
左侧只列 Git 变更文件，右侧显示单栏 unified diff；新增内容和删除内容通过颜色区分，不会打开旧文件/新文件两栏的传统对照布局。

## 2. 当前配置关系

插件配置：

`~/dotfiles/config/nvim/lua/plugins/hunk-review.lua`

文档：

`~/dotfiles/config/nvim/HUNK-REVIEW.md`

几个 Git 工具的分工：

| 工具 | 作用 | 常用入口 |
|---|---|---|
| gitsigns.nvim | 当前文件的行级变更、hunk 跳转和暂存 | Space g h ... |
| Snacks.nvim | picker、通知、LazyGit 启动等基础设施 | 多个 Space 菜单 |
| hunk-review.nvim | 审查整个工作区的变更，给 Agent 留意见 | Space g H |
| LazyGit | 暂存、提交、分支、stash、推送 | Space g g |

diffview.nvim 已经移除，不再使用。

## 3. 进入审查界面

在普通 Normal 模式下按：

~~~text
Space → g → Shift+h
~~~

也就是：

~~~text
<leader>gH
~~~

这里的 H 必须是大写。小写 d 已经被 Gitsigns 用作 Diff This，因此不能用 Space g d 作为 Hunk Review 入口。

也可以直接输入：

~~~vim
:HunkReview
~~~

修改插件配置后需要重启 Neovim，确保新的快捷键被 lazy.nvim 重新注册。

## 4. 开始前的 Git 前提

必须在 Git 仓库目录，或者仓库的子目录中打开 Neovim：

~~~bash
cd ~/chezmoi
nvim .
~~~

或者：

~~~bash
cd ~/dotfiles
nvim config/nvim/lua/plugins/hunk-review.lua
~~~

插件会自动向上查找 Git 根目录。打开前可以先确认：

~~~bash
git status --short
git diff --stat
git diff --cached --stat
~~~

默认 Uncommitted 模式会显示：

- 已修改但未暂存的文件
- 已暂存的文件
- 新建但尚未被 Git 跟踪的文件
- 删除的文件
- Git diff 能识别的重命名或混合状态文件

被 .gitignore 忽略的文件不会显示，这是为了避免缓存、构建产物和密钥出现在审查列表中。

## 5. 左侧文件列表

打开界面后，焦点通常在左侧 Explorer。

| 按键 | 作用 |
|---|---|
| j / k | 向下/向上浏览文件 |
| Enter | 打开当前文件的第一个变更块 |
| o | 打开当前文件的第一个变更块 |
| / | 按文件名过滤 |
| x | 清除文件过滤 |
| Ctrl-l | 切换到右侧 diff |
| C | 打开/关闭评论列表 |
| r | 重新读取 Git 变更 |
| [ | 切换到上一个 diff 范围 |
| ] | 切换到下一个 diff 范围 |
| q | 关闭审查界面 |

最常用：

~~~text
j / k       选择文件
Enter       查看文件变更
Ctrl-l      切到右侧继续审查
~~~

## 6. 右侧 unified diff

右侧是审查用的 diff 缓冲区，不是直接编辑的源文件。

| 按键 | 作用 |
|---|---|
| j / k | 在变更内容中移动 |
| ]h | 跳到下一个 hunk |
| [h | 跳到上一个 hunk |
| Space | 切换逐行审查模式 |
| c | 给当前变更块添加或编辑评论 |
| d | 删除当前评论 |
| o | 跳到真实源文件对应位置 |
| p | 临时查看源文件，带 LSP 支持 |
| C | 打开/关闭评论列表 |
| Ctrl-h | 回到左侧文件列表 |
| r | 刷新审查内容 |
| q | 退出审查 |

### 逐行审查

默认情况下，c 针对当前变更块发表评论。如果要针对一行或多行发表评论：

1. 在右侧按 Space 进入逐行模式。
2. 使用 j/k 移动，或使用 Vim 的 v/V 选择内容。
3. 按 c 添加评论。
4. 完成后按 Esc 退出逐行模式。

在视觉选择模式下按 c 或 Enter，也可以直接给选中范围添加评论。

## 7. 三种 diff 范围

使用左侧或右侧的 [、] 切换比较范围。

### Uncommitted

默认模式，比较当前工作区相对于 HEAD 的全部变更：

- 已暂存变更
- 未暂存变更
- 未跟踪的新文件

这是审查 Agent 修改结果时最应该使用的模式。

### Target

如果当前分支有远程跟踪分支，或者关联了 GitHub Pull Request，插件可能识别目标分支，并显示当前分支相对于目标分支的变更。

### Main

插件会尝试寻找 main、master 或 develop，然后比较当前分支和主分支 merge-base，适合检查一个功能分支累计产生的全部改动。

如果没有对应的目标分支或主分支，某些模式不会出现。

## 8. 给 Agent 留意见

推荐流程：

1. 让 Agent 完成一轮修改。
2. 按 Space → g → Shift+h 打开 Hunk Review。
3. 在左侧按文件顺序检查。
4. 在右侧阅读每个 hunk 的上下文。
5. 有问题的变更块按 c 添加评论。
6. 按 e 导出结构化 review，或按 Enter 复制文字版 review。
7. 把结果交给 Agent，要求它按文件和行号修复。
8. Agent 修改后按 r 刷新，再检查一轮。

评论不会自动修改源文件，也不会自动暂存、提交或推送，只属于当前审查会话。

## 9. 导出审查结果

### JSON 导出

在右侧按：

~~~text
e
~~~

插件会生成结构化 JSON，包含文件路径、变更块位置、diff 内容、评论内容和评论对应的行号或范围。这个格式适合交给 Agent 或其他自动化工具。

### 文字版复制

在非逐行模式下按：

~~~text
Enter
~~~

插件会把当前 review 整理成文字格式并复制到剪贴板。随后可以粘贴给 Agent。

## 10. 审查后修改源文件

Hunk Review 主要负责“看”和“评论”。真正修改代码时：

- 在右侧按 o，跳到真实源文件对应位置。
- 或按 e 导出 review，再让 Agent 根据评论修改。

推荐把审查和修改分开：

~~~text
Hunk Review 写评论
        ↓
导出 review
        ↓
Agent 修改源文件
        ↓
Hunk Review 按 r 刷新复查
~~~

## 11. 审查后提交和推送

确认没有问题后，再执行普通 Git 工作流：

~~~bash
git status --short
git diff
git diff --cached
~~~

确认范围正确后：

~~~bash
git add path/to/changed-file
git diff --cached --check
git commit -m "描述这次修改"
git push
~~~

如果只想暂存某个 hunk，可以使用：

~~~text
Space → g → h → s
~~~

或者：

~~~bash
git add -p
~~~

不要因为 Hunk Review 显示了某个文件，就直接执行 git add .。先检查变更范围，确认没有把密钥、缓存和临时文件加入提交。

## 12. 和其他 Git 功能的区别

### Gitsigns

适合当前正在编辑的单个文件：

~~~text
Space → g → h → s    暂存当前 hunk
Space → g → h → r    重置当前 hunk
Space → g → h → p    预览当前 hunk
Space → g → h → d    查看当前文件 diff
~~~

它不会提供整个仓库的 review 工作区。

### Snacks

Snacks 是 Neovim 的通用工具集合，负责 picker、通知、LazyGit 启动等。Hunk Review 使用它的能力，所以仍然是必要依赖。

### LazyGit

LazyGit 适合完整 Git 操作：

~~~text
Space → g → g    在仓库根目录打开 LazyGit
Space → g → G    在当前目录打开 LazyGit
~~~

需要暂存、取消暂存、提交、分支、stash、push 时，LazyGit 更方便；需要审查 Agent 变更时，Hunk Review 更专注。

## 13. 常见问题

### Space g d 进入的是 Diff This

这是正常的。Space g d 属于 Gitsigns。

Hunk Review 使用：

~~~text
Space → g → Shift+h
~~~

### 菜单里看不到 Hunk Review

重启 Neovim，然后执行：

~~~vim
:verbose nmap <leader>gH
~~~

应该看到描述：

~~~text
Git Diff: review changes
~~~

### 显示 No hunks found

检查：

~~~bash
git rev-parse --show-toplevel
git status --short
git diff HEAD --stat
~~~

可能原因：

- 当前文件不在 Git 仓库内
- 当前仓库没有变更
- 变更已经提交到当前 HEAD
- 文件被 .gitignore 忽略
- 当前处于错误的工作目录

### 新文件没有显示

确认 Git 是否能发现它：

~~~bash
git ls-files --others --exclude-standard
~~~

被 .gitignore 忽略的文件会被插件故意跳过。先确认是否真的应该纳入 Git，不要为了显示它而随意删除忽略规则。

### 重新读取 Agent 刚产生的修改

按：

~~~text
r
~~~

或者执行：

~~~vim
:HunkReviewRefresh
~~~

### 检查插件依赖

执行：

~~~vim
:checkhealth hunk-review
~~~

它会检查 Git、Snacks、Treesitter 等依赖。

## 14. 当前本地配置

配置文件：

~~~text
~/dotfiles/config/nvim/lua/plugins/hunk-review.lua
~~~

主要参数：

~~~lua
layout = {
  width = 0.96,
  height = 0.92,
  explorer_width = 0.28,
},
diff_context = 3,
~~~

含义：

- 审查窗口占 Neovim 的 96% 宽度
- 审查窗口占 Neovim 的 92% 高度
- 左侧文件列表约占审查窗口宽度的 28%
- 每个变更块前后显示 3 行上下文

如果左侧太窄，把 explorer_width 改成 0.22；如果想显示更多上下文，把 diff_context 改成 5。

修改源文件后：

~~~bash
cd ~/dotfiles
bash dotlink/dotlink link
~~~

然后重启 Neovim。

## 15. 建议的学习顺序

第一步，只看变更：

~~~text
Space → g → Shift+h
j / k
Enter
q
~~~

第二步，定位 hunk：

~~~text
]h
[h
o
p
~~~

第三步，写 review：

~~~text
c
C
e
Enter
~~~

第四步，刷新和切换范围：

~~~text
r
[
]
~~~

第五步，确认 Git 状态后再提交：

~~~bash
git status --short
git diff --check
git add ...
git commit ...
git push
~~~

推荐始终遵循：

~~~text
Agent 修改
  → Hunk Review 审查
  → 写评论
  → Agent 修复
  → 刷新复查
  → git add
  → commit
  → push
~~~
