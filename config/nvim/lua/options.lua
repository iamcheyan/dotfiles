-- Hint: use `:h <option>` to figure out the meaning if needed
vim.opt.clipboard = 'unnamedplus' -- 使用系统剪贴板
vim.opt.completeopt = { 'menu', 'menuone', 'noselect' } -- 自动完成菜单选项
vim.opt.mouse = 'a' -- 允许使用鼠标

-- Tab 相关
vim.opt.tabstop = 4 -- 每个 TAB 显示的空格数
vim.opt.softtabstop = 4 -- 编辑时一个 tab 的空格数
vim.opt.shiftwidth = 4 -- 按下 Tab 键插入 4 个空格
vim.opt.expandtab = true -- 使用空格代替 Tab，主要用于 Python

-- UI 配置
vim.opt.number = true -- 显示行号
vim.opt.relativenumber = true -- 在当前行左侧显示相对行号
vim.opt.cursorline = true -- 突出显示光标所在行
vim.opt.splitbelow = true -- 新窗口默认分割在下方
vim.opt.splitright = true -- 新窗口默认分割在右侧
vim.opt.termguicolors = true -- 启用 TUI 的 24 位 RGB 颜色支持
vim.opt.showmode = true -- "-- INSERT --" 提示

-- 搜索相关
vim.opt.incsearch = true -- 输入查询内容时即开始匹配
vim.opt.hlsearch = true -- 高亮显示匹配项
vim.opt.ignorecase = true -- 忽略大小写
vim.opt.smartcase = true -- 如果查询中含有大写字母则区分大小写

-- 对于 nvim-tree
-- 在 init.lua 的开头禁用 netrw 插件（强烈建议）
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
