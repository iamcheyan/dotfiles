# Neovim 插件清单

本文按当前公开与私有 `lazy.nvim` 插件声明整理，包含运行依赖和本地自研插件。版本以公开层 `lazy-lock.json` 与各私有插件当前源代码为准；插件目录里残留的旧缓存不代表仍在使用。

截至 2026-10-07，配置共使用 **44 个插件**：39 个第三方插件（含插件管理器和依赖）以及 5 个自研插件。

## 插件管理器与第三方插件

| 插件 | 来源层 | 用途 |
|---|---|---|
| `lazy.nvim` | 公开 | 插件安装、加载和更新管理。 |
| `aerial.nvim` | 公开；私有层添加 COBOL 后端 | 符号大纲和侧栏导航。 |
| `auto-session` | 公开 | 保存和恢复编辑会话。 |
| `blink.cmp` | 公开 | 补全菜单与 LSP 补全。 |
| `bufferline.nvim` | 公开 | 顶部缓冲区标签栏。 |
| `ccc.nvim` | 公开 | 交互式颜色选择和颜色格式转换。 |
| `conform.nvim` | 公开 | 代码格式化和保存时格式化。 |
| `diffview.nvim` | 公开 | Git 差异、提交和文件历史视图。 |
| `fidget.nvim` | 公开 | 显示 LSP 工作进度。 |
| `flash.nvim` | 公开 | 按字符快速定位和跳转。 |
| `gitsigns.nvim` | 公开 | 显示并操作行级 Git 变更。 |
| `grug-far.nvim` | 公开 | 跨文件查找和替换。 |
| `heirline.nvim` | 公开 | 绘制状态栏、标签栏和上下文栏。 |
| `indent-blankline.nvim` | 公开 | 缩进参考线；COBOL 文件排除该通用缩进线。 |
| `markview.nvim` | 公开 | 在 Neovim 中预览 Markdown。 |
| `mason.nvim` | 公开 | 安装和管理 LSP、格式化器等外部工具。 |
| `mason-lspconfig.nvim` | 公开 | 将 Mason 安装的服务器接入 Neovim LSP。 |
| `mini.ai` | 公开 | 扩展文本对象。 |
| `mini.hipatterns` | 公开 | 高亮代码中的颜色值等文本模式。 |
| `mini.pairs` | 公开 | 自动补齐括号等成对字符。 |
| `neo-tree.nvim` | 公开 | 文件树和侧栏导航。 |
| `nui.nvim` | 公开，依赖 | 为 Neo-tree 等插件提供界面组件。 |
| `nvim-hlslens` | 公开 | 增强搜索匹配位置提示。 |
| `nvim-lspconfig` | 公开 | 配置 Neovim 内置 LSP 客户端。 |
| `nvim-treesitter` | 公开 | Treesitter 语法解析和高亮。 |
| `nvim-treesitter-textobjects` | 公开 | 基于语法树的文本对象和移动。 |
| `nvim-ufo` | 公开 | 代码折叠。 |
| `nvim-web-devicons` | 公开，依赖 | 为文件和界面提供图标。 |
| `oil.nvim` | 公开 | 将目录作为可编辑缓冲区管理文件。 |
| `plenary.nvim` | 公开，依赖 | 为多个插件提供 Lua 通用工具。 |
| `promise-async` | 公开，依赖 | 为 `nvim-ufo` 提供异步 Promise 支持。 |
| `rainbow-delimiters.nvim` | 公开 | 为括号等嵌套分隔符着色。 |
| `satellite.nvim` | 公开 | 在窗口边缘显示搜索、诊断和滚动标记。 |
| `smart-paste.nvim` | 私有 | 调整粘贴内容缩进；私有配置扩展了 COBOL 和系统剪贴板处理。 |
| `snacks.nvim` | 公开 | 提供 Dashboard、Picker、通知和状态列等功能；本配置关闭其 Explorer、Scroll 模块。 |
| `todo-comments.nvim` | 公开 | 标记和查找 TODO、FIX 等注释。 |
| `vim-visual-multi` | 公开 | 多光标和多处同时编辑。 |
| `which-key.nvim` | 公开 | 显示快捷键提示和分组。 |
| `yanky.nvim` | 公开 | 剪贴板历史和增强粘贴。 |

## 自研插件

| 插件 | 所在层 | 用途 |
|---|---|---|
| `batch.nvim` | 私有 | Windows Batch 文件的结构解析、诊断、折叠、标签跳转和大纲。 |
| `bookmark.nvim` | 私有 | 可点击的行书签，支持按项目持久化并通过 Snacks Picker 管理。 |
| `cobol.nvim` | 私有 | COBOL 专用列标尺、格式辅助、注释操作、诊断和记录布局计算。 |
| `contextline.nvim` | 私有 | 为状态栏和顶部上下文栏提供语言结构上下文与可交互层级菜单。 |
| `VimQuest.nvim` | 私有 | 英语词汇练习和复习。 |

## 统计口径

- 第三方插件按当前公开锁文件中仍由插件规格引用的条目统计，并计入私有层声明的 `smart-paste.nvim`。
- 私有层对 `aerial.nvim` 和 `indent-blankline.nvim` 的配置是对公开插件的扩展，不重复计数。
- `sqlite.lua` 和 `vim-cutlass` 仍可能出现在旧锁文件或本地插件缓存中，但当前插件规格已不再引用，因此不列为现用插件。
- `lazy-lock.json` 保存公开层锁定版本；私有自研插件按 chezmoi 中的源代码和子模块版本管理。
