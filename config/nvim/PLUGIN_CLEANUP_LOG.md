# Neovim 插件审计与精简重构记录 (Plugin Cleanup & Refactor Log)

- **记录日期**：2026-09-20
- **重构目标**：消除功能重叠插件、卸载闲置常驻主题、将历史搜索工具统一汇聚至下一代 `Snacks.picker`，修复被历史配置误删的 LSP `gr` 代码引用跳转，实现更轻量、更纯粹、更迅速的 Neovim 架构。

---

## 一、重构前基线审计 (Baseline Audit)

- **初始插件总数**：45 个（由 `lazy.nvim` 管理）
- **审计发现的核心问题**：

### 1. 搜索体系重叠：`telescope.nvim` + `telescope-fzf-native.nvim` vs `snacks.nvim`
- **现状**：在 `lua/config/keymaps-lazyvim.lua` 中，所有高频全局搜索快捷键（找文件 `<leader><space>`、搜内容 `<leader>fg` / `<leader>/`、查缓冲区 `<leader>fb` / `<leader>,`、最近文件 `<leader>fr`、帮助文档 `<leader>fh` 等 20 余个键位）已经全部由 `Snacks.picker` 负责。
- **问题**：`telescope.nvim`（连带 C 动态库扩展 `telescope-fzf-native` 和 `plenary.nvim`）在当前配置中仅被用于一个按键：`yanky.nvim` 的剪贴板历史选择（`<leader>fy`）。
- **优化**：`yanky.nvim` 原生内置了对 `snacks.nvim` 的无缝支持（`require("yanky.sources.snacks").pick()`），能直接唤出完全相同风格的高性能 Snacks 浮窗。卸载 Telescope 可省去庞大的模块加载与 C 扩展构建。

### 2. Git 审查重叠：`hunk-review.nvim` vs `diffview.nvim` + `gitsigns.nvim` + `lazygit`
- **现状**：已配置全功能双屏对比 `diffview.nvim`（`<leader>gd` / `<leader>gv`）、单文件历史快照（`<leader>gD`）、行内修改预览 `gitsigns.nvim`（`<leader>gp`）、以及全屏终端 `lazygit`（`<leader>gg`）。
- **问题**：`hunk-review.nvim`（`<leader>gH`）仅仅是在屏幕中央弹出一个浮动 diff 预览，功能 100% 被现有工具覆盖，平时极少使用。
- **优化**：直接移除 `hunk-review.nvim`。

### 3. 颜色渲染重叠：`ccc.nvim` vs `mini.hipatterns`
- **现状**：`ccc.nvim` 设置了 `highlighter.auto_enable = true`，而 `mini.hipatterns` 设置了 `gen_highlighter.hex_color()`。
- **问题**：同一个代码文件打开时，两个插件都在监听 buffer 文本并同时给十六进制颜色加背景色，造成双重计算。
- **优化**：保留轻量、无任何额外依赖的 `mini.hipatterns`，移除 `ccc.nvim`。

### 4. 闲置常驻主题：`cyberdream.nvim`
- **现状**：系统主力主题为 1:1 移植的 `high-contrast-plus`（由 `omarchy-theme.lua` 驱动）。
- **问题**：`cyberdream.lua` 配置了 `lazy = false, priority = 1000`，每次启动都会在最高优先级被提前加载，但实际上并未作为生效主题。
- **优化**：直接移除未使用的主题插件。

### 5. 关键按键失效修复：`plugins/lsp-keymaps.lua`
- **历史背景**：早先为了防止与已卸载的 `substitute.nvim` 插件按键冲突，该文件添加了一个全局 Autocmd：在 LSP 连接时强行删除 `gr` 映射。
- **严重 Bug**：导致在任意编程语言中，Neovim 最核心的 **`gr`（查看函数/变量的所有引用，Go to References）完全失灵**！
- **优化**：彻底删除 `plugins/lsp-keymaps.lua`，将原生 `gr` 完美交还给 LSP。

---

## 二、精简方案与迁移对照表 (Migration Map)

| 序号 | 移除的项目 / 文件 | 原用途 | 替代与迁移方案 |
|---|---|---|---|
| 1 | `lua/plugins/telescope.lua` | 模糊搜索框架 + C 编译扩展 | 统一由 `snacks.nvim` 接管；`yanky.nvim` 的 `<leader>fy` 迁移为原生 `require("yanky.sources.snacks").pick()` |
| 2 | `lua/plugins/hunk-review.lua` | 浮窗预览 Git 差异 (`<leader>gH`) | 统一由 `diffview.nvim` (`<leader>gd`) 与 `gitsigns` (`<leader>gp`) 接管 |
| 3 | `lua/plugins/cyberdream.lua` | 备用赛博朋克深色主题 | 移除未启用的闲置主题包，消除启动开销 |
| 4 | `lua/plugins/ccc.lua` | 调色板与实时十六进制高亮 | 十六进制颜色背景预览统一由超轻量的 `mini.hipatterns` 负责 |
| 5 | `lua/plugins/lsp-keymaps.lua` | 禁用 LSP `gr` 的历史遗留文件 | 删除该文件，**彻底恢复 LSP 标准的 `gr`（查看所有引用）核心功能** |

---

## 三、回滚保障手册 (Rollback Guide)

如果在未来的使用中需要恢复任何一个被精简的插件，可以通过 Git 历史快速单文件恢复：

```bash
cd ~/dotfiles

# 1. 恢复 Telescope
git checkout <commit_hash>~1 -- config/nvim/lua/plugins/telescope.lua

# 2. 恢复 HunkReview
git checkout <commit_hash>~1 -- config/nvim/lua/plugins/hunk-review.lua

# 3. 恢复 Cyberdream 主题
git checkout <commit_hash>~1 -- config/nvim/lua/plugins/cyberdream.lua

# 4. 恢复 CCC 调色板
git checkout <commit_hash>~1 -- config/nvim/lua/plugins/ccc.lua
```

---

## 四、执行与验证结果 (Execution & Verification)

### 4.1 执行变更记录
1. **删除冗余插件配置文件**：
   - 已删除 `lua/plugins/telescope.lua`
   - 已删除 `lua/plugins/hunk-review.lua`
   - 已删除 `lua/plugins/cyberdream.lua`
   - 已删除 `lua/plugins/ccc.lua`
   - 已删除 `lua/plugins/lsp-keymaps.lua`
2. **迁移 `yanky.nvim` 剪贴板历史选择器**：
   - 修改 `lua/plugins/yanky-substitute.lua`：
   - 移除了 `opts.picker.telescope` 配置块。
   - `<leader>fy` 绑定为原生 Snacks 选择器：
     ```lua
     {
       "<leader>fy",
       function()
         require("yanky.sources.snacks").pick()
       end,
       desc = "Yank History (Snacks Picker)",
     }
     ```

### 4.2 验证结果实测

- **插件总数变化**：
  - 精简前：45 个插件
  - 精简后：**40 个插件**（`telescope.nvim`, `telescope-fzf-native.nvim`, `hunk-review.nvim`, `cyberdream.nvim`, `ccc.nvim` 5 个插件已彻底卸除，无残留依赖）
- **功能实测**：
  - `require("yanky.sources.snacks").pick()` 运行状态：**NORMAL (Loaded)**
  - LSP `gr`（`vim.lsp.buf.references`）覆盖已移除：**已彻底恢复**
  - 十六进制颜色高亮（`#ff0055`, `#10B981` 等）：由 `mini.hipatterns` 正常渲染
  - 无头启动与语法检查：零错误，零告警

