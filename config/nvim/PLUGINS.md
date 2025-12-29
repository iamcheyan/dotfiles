# Neovim Installed Plugins

此列表基于 `lazy-lock.json` 自动生成。

## 核心框架与管理 (Core & Management)
*   **LazyVim**: Neovim 核心配置框架，提供开箱即用的体验。
*   **lazy.nvim**: 现代化的插件管理器，负责下载、更新和加载所有插件。
*   **snacks.nvim**: 提升 Neovim 体验的工具集 (界面、调试、大文件处理等)。
*   **persistence.nvim**: 会话管理，可自动保存和恢复之前的编辑状态。

## AI 辅助 (AI Assistant)
*   **avante.nvim**: AI 驱动的代码助手 (当前配置为使用 Gemini)。
*   **dressing.nvim**: 改进 `vim.ui.select` 和 `vim.ui.input` 界面 (Avante 的重要依赖，提供更好看的输入框)。

## 代码智能与语言支持 (LSP & Languages)
*   **nvim-lspconfig**: 配置 LSP (Language Server Protocol) 的官方插件。
*   **mason.nvim**: 便携式包管理器，用于安装 LSP server、DAP server、Linter 和 Formatter。
*   **mason-lspconfig.nvim**: 连接 Mason 和 lspconfig，自动配置安装好的 LSP。
*   **conform.nvim**: 轻量级且强大的代码格式化工具 (Formatter)。
*   **nvim-lint**: 异步代码检查工具 (Linter)。
*   **lazydev.nvim**: 专为 Neovim Lua 配置开发提供的 LSP 支持 (基于 LuaLS)。
*   **ts-comments.nvim**: 增强 TypeScript/TSX 的注释支持。

## 语法高亮与解析 (Syntax & Treesitter)
*   **nvim-treesitter**: 基于 Treesitter 的语法高亮、缩进和折叠引擎。
*   **nvim-treesitter-textobjects**: 基于语法的文本对象选择 (如按函数、类选择)。
*   **nvim-ts-autotag**: 自动闭合 HTML/XML 标签。
*   **mini.ai**: 增强的文本对象选择 (如 `va)` 选择圆括号内容)。
*   **mini.pairs**: 自动补全成对的符号 (括号、引号)。

## 界面美化 (UI & Aesthetics)
*   **catppuccin**: 柔和的护眼主题。
*   **tokyonight.nvim**: 现代化的暗色主题。
*   **lualine.nvim**:由于性能和外观极佳的状态栏。
*   **bufferline.nvim**: 类似 IDE 的顶部标签栏/Buffer 栏。
*   **nui.nvim**: UI 组件库 (被 avante.nvim, noice.nvim 等依赖)。
*   **nvim-web-devicons** / **mini.icons**: 文件图标支持。
*   **gitsigns.nvim**: 在行号旁显示 Git 增删改状态。
*   **which-key.nvim**: 按下按键时显示快捷键提示菜单。
*   **noice.nvim**: (当前由于与 avante 冲突可能已禁用) 用于美化命令行消息和弹窗。

## 导航与搜索 (Navigation & Search)
*   **telescope.nvim**: 强大的模糊搜索器 (搜索文件、grep、git 等)。
*   **plenary.nvim**: Lua 实用函数库 (Telescope 等插件的依赖)。
*   **flash.nvim**: 极速光标跳转插件 (类似 Easymotion/Sneak)。
*   **trouble.nvim**: 漂亮的诊断、引用和快速修复列表。
*   **todo-comments.nvim**: 高亮并列出代码中的 TODO, FIXME, HACK 等注释。
*   **grug-far.nvim**: 全局搜索和替换工具 (基于 ripgrep)。

## 自动补全 (Autocompletion)
*   **blink.cmp**: 新一代高性能自动补全引擎 (取代了 nvim-cmp)。
*   **friendly-snippets**: 丰富的代码片段集合 (支持多种语言)。

## 输入法 (Input Method)
*   **sbzr.nvim.im**: 在 Neovim 内集成的输入法支持。
