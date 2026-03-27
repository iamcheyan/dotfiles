# Neovim 插件审计报告（2026-03-09）

## 审计范围与方法

- 数据源：
- `config/nvim/lazy-lock.json`（已安装插件快照）
- `config/nvim/lua/plugins/*.lua`（本地启用/禁用与自定义键位）
- 结论属性：
- “已安装”来自 lockfile（共 49 个）
- “启用/禁用”基于你当前本地 spec（`enabled = false`）

## 总览

- 已安装插件：49
- 当前启用：45
- 已安装但被你显式禁用：4
- 配置中声明禁用且当前未安装：4

## 已启用插件与用法

| 插件 | 作用 | 你当前用法/入口 |
| --- | --- | --- |
| LazyVim | 发行版与默认键位体系 | 启动即生效，提供默认 `<leader>` 工作流 |
| lazy.nvim | 插件管理器 | `:Lazy` 查看/更新插件 |
| which-key.nvim | 按键提示面板 | 按 `<leader>` 后查看可用键位 |
| snacks.nvim | UI/Picker/Dashboard 综合增强 | 启动页、picker、通知等由其接管（你自定义了边框） |
| telescope.nvim | 文件/内容搜索 | `<leader>/`、`<leader>fr`、`<leader>gf` 等 |
| telescope-fzf-native.nvim | Telescope 排序加速 | 自动生效（由 telescope 扩展加载） |
| neo-tree.nvim | 文件树 | `<leader>e` 打开/关闭文件树 |
| aerial.nvim | 符号大纲 | `<leader>cs` 切换 Symbols 面板 |
| trouble.nvim | 诊断/引用问题列表 | `:Trouble` 或 LazyVim 默认 Trouble 键位 |
| grug-far.nvim | 项目级搜索替换 | `<leader>sr`（项目）、`<leader>sR`（当前文件） |
| nvim-hlslens | 搜索结果增强显示 | `n/N/*/#/g*/g#` 已绑定触发 lens |
| flash.nvim | 快速跳转 | 用于增强跳转（沿用 LazyVim 默认键位） |
| vim-visual-multi | 多光标编辑 | `<C-n>` 选中下一个，`<C-j>/<C-k>` 增减光标 |
| nvim-lspconfig | LSP 基础配置 | 打开代码文件自动附加 LSP |
| mason.nvim | LSP/Formatter/Linter 安装器 | `:Mason` |
| mason-lspconfig.nvim | Mason 与 lspconfig 桥接 | 自动把 Mason 装的 server 接到 lspconfig |
| lazydev.nvim | Lua 开发体验增强 | 编辑 Neovim Lua 配置时自动生效 |
| blink.cmp | 自动补全引擎 | 插入模式自动弹出补全 |
| friendly-snippets | 片段库 | 与补全引擎联动自动提供 snippets |
| conform.nvim | 代码格式化框架 | 与你的 `<leader>fo` 格式化流程同域 |
| nvim-lint | 代码 lint 框架 | 按 LazyVim/你的触发策略执行 |
| nvim-treesitter | 语法树高亮/选择 | 打开代码自动生效 |
| nvim-treesitter-textobjects | Treesitter 文本对象 | 代码对象选择/跳转增强 |
| nvim-ts-autotag | 标签自动闭合 | HTML/JSX 等自动补全标签 |
| ts-comments.nvim | 注释系统增强 | 与 Treesitter commentstring 联动 |
| mini.ai | 文本对象增强 | `a`/`i` 系列对象选择更智能 |
| mini.pairs | 自动括号配对 | 输入括号/引号时自动补全 |
| gitsigns.nvim | Git 行级变更标记 | 左侧 signcolumn 显示 +/~/-, hunk 操作 |
| vim-gitgutter | 另一套 Git 行标记 | 默认关闭；`<leader>uG` 临时开关 |
| neovim-project | 项目管理与自动会话 | 启动时加载最近项目/会话 |
| neovim-session-manager | 会话持久化依赖 | 由 neovim-project 使用 |
| heirline.nvim | 状态栏 | 你已启用并替代 lualine |
| bufferline.nvim | Buffer 标签栏 | 顶部标签栏显示/切换 buffer |
| nvim-web-devicons | 文件图标 | 在 bufferline/neo-tree/telescope 中显示图标 |
| plenary.nvim | Lua 工具库依赖 | 作为 telescope/neo-tree 等依赖 |
| nui.nvim | UI 组件依赖 | 作为 neo-tree/snacks 依赖 |
| im-select.nvim | 中英文输入法自动切换 | Insert 进入/离开自动切换（Windows `im-select.exe`） |
| sbzr.nvim.im (ZFVimIM) | 本地输入法插件 | `;;` 切换输入法映射（n/i/v） |
| fidget.nvim | LSP 进度浮窗 | LSP 工作时自动显示 |
| indent-blankline.nvim (ibl) | 缩进引导线 | 自动显示缩进层级与作用域 |
| nvim-colorizer.lua | 颜色值可视化 | `#rrggbb/rgb()/hsl()` 自动着色 |
| glow.nvim | Markdown 预览 | `:Glow` 或 `<leader>mg` |
| tokyonight.nvim | 主题依赖包 | 可在 `:colorscheme` 切换 |
| catppuccin | 主题依赖包 | 可在 `:colorscheme` 切换 |
| vim-colorschemes | 主题集合（含 `af` 等） | 你当前 `LazyVim` 设为 `colorscheme = "af"` |
| todo-comments.nvim | TODO/FIXME 高亮与导航 | 代码中 TODO 注释高亮与检索 |

## 已安装但当前禁用（你本地显式关闭）

| 插件 | 禁用来源 | 说明 |
| --- | --- | --- |
| lualine.nvim | `lua/plugins/heirline.lua` | 被 heirline 取代，避免双状态栏 |
| muren.nvim | `lua/plugins/muren.lua` | 多文件替换 UI 已关闭 |
| nvim-spectre | `lua/plugins/spectre.lua` | 搜索替换工具已关闭（你用 grug-far） |
| persistence.nvim | `lua/plugins/persistence.lua` | 会话恢复由 neovim-project 体系承担 |

## 配置中声明禁用且当前未安装

| 插件 | 来源 | 说明 |
| --- | --- | --- |
| nvim-tree.lua | `lua/plugins/neo-tree.lua` | 你使用 neo-tree，不再使用 nvim-tree |
| nvim-mini/mini.icons | `lua/plugins/icons.lua` | 用 nvim-web-devicons 替代 |
| noice.nvim | `lua/plugins/noice.lua` | 已配置禁用，当前 lockfile 中不存在 |
| folke/trouble.nvim (来自 example) | `lua/plugins/example.lua` | `example.lua` 顶部 `if true then return {} end`，不参与加载 |

## 功能重复/冲突分析与建议

1. `gitsigns.nvim` vs `vim-gitgutter`
- 重复点：都在 signcolumn 显示 Git 变更，hunk 导航/预览能力高度重叠。
- 现状：你已把 `gitgutter` 默认关闭（正确）。
- 建议：长期只保留 `gitsigns`；若要对比显示风格，再临时开 `gitgutter`。

2. `telescope.nvim` vs `snacks.nvim` picker
- 重复点：都能做文件检索/grep/buffers。
- 现状：你主用 telescope，snacks 仍启用 picker 能力。
- 建议：二选一作为主入口。若继续主用 telescope，可减少 snacks picker 相关映射与来源配置，降低认知负担。

3. `grug-far.nvim` vs `nvim-spectre` vs `muren.nvim`
- 重复点：都属于搜索替换工具链。
- 现状：你已禁用 spectre 与 muren，仅保留 grug-far（这是最清晰的方案）。
- 建议：保持当前状态，不要再并行启用多个替换 UI。

4. `heirline.nvim` vs `lualine.nvim`
- 重复点：同为状态栏框架。
- 现状：已禁用 lualine，启用 heirline（正确）。
- 建议：可以从 lockfile 清理 lualine（可选），减少历史包残留。

5. 会话管理：`neovim-project` + `neovim-session-manager` vs `persistence.nvim`
- 重复点：会话保存/恢复。
- 现状：persistence 已禁用。
- 建议：保持单栈（当前方案合理）。

6. 输入法切换：`im-select.nvim` 与 `sbzr.nvim.im`
- 风险点：两者都影响输入体验，边界场景可能出现切换时机不一致。
- 建议：若出现抖动或误切换，优先保留一个主方案；通常中文输入需求重时保留 `sbzr.nvim.im`，系统级切换需求重时保留 `im-select.nvim`。

## 精简建议（可执行）

1. 若你追求稳定与简洁：卸载 `vim-gitgutter`，只留 `gitsigns.nvim`。
2. 若你追求统一检索入口：确定 `telescope` 或 `snacks picker` 单一主入口。
3. 清理已禁用但仍在 lockfile 的历史插件（如 `lualine.nvim`、`muren.nvim`、`nvim-spectre`、`persistence.nvim`），让环境与配置一致。

## 关键自定义入口速查

- 格式化当前文件：`<leader>fo`
- 全局搜索替换：`<leader>sr`
- 当前文件替换：`<leader>sR`
- 文件树：`<leader>e`
- Markdown 预览：`<leader>mg`
- GitGutter 开关：`<leader>uG`
