# 开发视觉增强插件说明

## 安装结果与冲突说明

- `gitsigns.nvim`：已存在于 LazyVim（已安装），本次保留并显式配置。
- `vim-gitgutter`：已新增，但默认关闭（`g:gitgutter_enabled = 0`）。
  - 原因：`vim-gitgutter` 与 `gitsigns.nvim` 都会在 signcolumn 显示 Git 标记，同时开启会重复/混乱。
  - 需要时可手动切换开启。
- `nvim-hlslens`：已新增（你列表里重复写了两次，按一次安装处理）。
- `j-hui/fidget.nvim`：已新增。
- `NvChad/nvim-colorizer.lua`：已新增。
- `ellisonleao/glow.nvim`：已新增。
- `lukas-reineke/indent-blankline.nvim`：已新增（`ibl`）。

## 快捷键与命令

## fidget.nvim（LSP 进度浮窗）

- 功能：显示 LSP 正在处理任务的状态（诊断、索引、分析等）。
- 使用：无需手动命令，打开代码并触发 LSP 时自动显示。

## gitsigns.nvim（Git 行级标记）

- 功能：在左侧 signcolumn 显示增删改标记。
- 使用：默认随文件自动生效（Git 仓库内）。

## vim-gitgutter（备用 Git 标记实现）

- 默认关闭，避免与 gitsigns 冲突。
- `<leader>uG`：开关 GitGutter
- `]h`：下一处 hunk
- `[h`：上一处 hunk
- `<leader>hp`：预览当前 hunk

## nvim-hlslens（搜索增强高亮）

- 功能：增强 `/` 搜索结果提示与跳转反馈。
- 常用按键（已绑定增强行为）：
- `n` / `N`：下一个 / 上一个匹配
- `*` / `#`：当前单词向前 / 向后搜索
- `g*` / `g#`：当前部分单词向前 / 向后搜索

## nvim-colorizer.lua（颜色值可视化）

- 功能：把 `#RRGGBB`、`rgb()`、`hsl()` 等颜色直接渲染在文本中。
- 使用：打开文件自动生效（所有 filetype）。

## glow.nvim（Markdown 终端预览）

- `:Glow`：预览当前 Markdown
- `<leader>mg`：预览当前 Markdown

## indent-blankline.nvim（缩进引导线）

- 功能：显示缩进层级竖线，并高亮当前作用域。
- 使用：自动生效（部分特殊 filetype 已排除）。

## 建议

- 日常建议保留 `gitsigns.nvim` 为主。
- 仅在你想比较显示风格时，临时开启 `vim-gitgutter`。
