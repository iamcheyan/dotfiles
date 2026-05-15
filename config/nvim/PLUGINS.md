# Neovim Installed Plugins

此列表基于 `lazy-lock.json` 自动生成。更新时间: 2026-05-14

## 核心框架与管理 (Core & Management)

| 插件 | 说明 |
|------|------|
| **LazyVim** | Neovim 核心配置框架，提供开箱即用的体验。 |
| **lazy.nvim** | 现代化的插件管理器，负责下载、更新和加载所有插件。 |
| **snacks.nvim** | 提升 Neovim 体验的工具集 (界面、通知、大文件处理等)。 |
| **persistence.nvim** | 会话管理，可自动保存和恢复之前的编辑状态。 |

## 主题与外观 (Theme & Aesthetics)

| 插件 | 说明 |
|------|------|
| **tokyonight.nvim** | 现代化的暗色主题 (当前使用的主题)。 |
| **catppuccin** | 柔和的护眼主题 (可切换)。 |
| **vim-colorschemes** | 主题合集，包含多种配色方案。 |
| **lualine.nvim** | 高性能、高颜值的底部状态栏。 |
| **bufferline.nvim** | 类似 IDE 的顶部标签栏/Buffer 栏。 |
| **heirline.nvim** | 可高度自定义的状态栏 (LazyVim 内置)。 |
| **nvim-web-devicons** | 文件图标支持。 |

## 代码智能与语言支持 (LSP & Languages)

| 插件 | 说明 |
|------|------|
| **nvim-lspconfig** | 配置 LSP (Language Server Protocol) 的官方插件。 |
| **mason.nvim** | 便携式包管理器，用于安装 LSP server、DAP server、Linter 和 Formatter。 |
| **mason-lspconfig.nvim** | 连接 Mason 和 lspconfig，自动配置安装好的 LSP。 |
| **conform.nvim** | 轻量级且强大的代码格式化工具 (Formatter)。 |
| **nvim-lint** | 异步代码检查工具 (Linter)。 |
| **lazydev.nvim** | 专为 Neovim Lua 配置开发提供的 LSP 支持 (基于 LuaLS)。 |
| **ts-comments.nvim** | 增强 TypeScript/TSX 的注释支持。 |
| **fidget.nvim** | LSP 服务器加载状态提示。 |

## 语法高亮与解析 (Syntax & Treesitter)

| 插件 | 说明 |
|------|------|
| **nvim-treesitter** | 基于 Treesitter 的语法高亮、缩进和折叠引擎。 |
| **nvim-treesitter-textobjects** | 基于语法的文本对象选择 (如按函数、类选择)。 |
| **nvim-ts-autotag** | 自动闭合 HTML/XML 标签。 |
| **mini.ai** | 增强的文本对象选择 (如 `va)` 选择圆括号内容)。 |
| **mini.pairs** | 自动补全成对的符号 (括号、引号)。 |
| **indent-blankline.nvim** | 显示缩进引导线。 |

## 自动补全 (Autocompletion)

| 插件 | 说明 |
|------|------|
| **blink.cmp** | 新一代高性能自动补全引擎 (取代了 nvim-cmp)。 |
| **friendly-snippets** | 丰富的代码片段集合 (支持多种语言)。 |

## 导航与搜索 (Navigation & Search)

| 插件 | 说明 |
|------|------|
| **telescope.nvim** | 强大的模糊搜索器 (搜索文件、grep、git 等)。 |
| **telescope-fzf-native.nvim** | Telescope 的 FZF 排序器，提升搜索性能。 |
| **plenary.nvim** | Lua 实用函数库 (Telescope 等插件的依赖)。 |
| **flash.nvim** | 极速光标跳转插件 (类似 Easymotion/Sneak)。 |
| **nvim-hlslens** | 搜索结果高亮和 lenses 显示。 |
| **yazi.nvim** | 在 Neovim 浮窗里打开 Yazi 文件管理器。 |
| **oil.nvim** | 把目录当成可编辑 buffer 的文件管理器。 |
| **nvim-tree.lua** | 经典的目录树文件浏览器。 |
| **trouble.nvim** | 漂亮的诊断、引用和快速修复列表。 |
| **todo-comments.nvim** | 高亮并列出代码中的 TODO, FIXME, HACK 等注释。 |
| **grug-far.nvim** | 全局搜索和替换工具 (基于 ripgrep)。 |
| **nvim-spectre** | 高级搜索和替换工具。 |
| **aerial.nvim** | 代码结构大纲/符号导航。 |
| **muren.nvim** | 多光标编辑工具。 |

## 终端与集成 (Terminal & Integration)

| 插件 | 说明 |
|------|------|
| **toggleterm.nvim** | 可开关的浮动终端，适合用快捷键呼出临时命令行。 |
| **neovim-project** | 项目管理工具。 |
| **neovim-session-manager** | 会话管理器。 |

## Git 集成 (Git Integration)

| 插件 | 说明 |
|------|------|
| **gitsigns.nvim** | 在行号旁显示 Git 增删改状态。 |
| **vim-gitgutter** | Git 变更标记 (行号旁显示 +/-/~)。 |

## 输入法 (Input Method)

| 插件 | 说明 |
|------|------|
| **ZFVimIM** | 中文输入法支持。 |
| **VimTeacher** | Vim 学习插件。 |

## 实用工具 (Utilities)

| 插件 | 说明 |
|------|------|
| **bookmarks.nvim** | 书签管理。 |
| **ccc.nvim** | 颜色拾取器。 |
| **glow.nvim** | Markdown 预览工具。 |
| **vim-visual-multi** | 多光标编辑 (类似 VSCode 多光标)。 |
| **nui.nvim** | UI 组件库 (被多个插件依赖)。 |
| **which-key.nvim** | 按下按键时显示快捷键提示菜单。 |

## 插件总数

当前安装插件数量: **52** 个核心插件 (不含依赖)