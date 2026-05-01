-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

vim.g.have_nerd_font = true -- 开启 Nerd Font 支持，修复图标显示为问号或 $ 的问题
vim.g.snacks_animate = false -- 关闭 LazyVim/Snacks 的全局动画
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- Keep literal tabs by default.
vim.opt.tabstop = 4
vim.opt.softtabstop = 0
vim.opt.shiftwidth = 4
vim.opt.expandtab = false

vim.opt.clipboard = "unnamedplus"
vim.opt.completeopt = { "menu", "menuone", "noselect" }
vim.opt.mouse = "a"
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.cursorline = true
vim.opt.cursorcolumn = true
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.termguicolors = true
vim.opt.showmode = true
vim.opt.incsearch = true
vim.opt.hlsearch = true
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- 告诉 Neovim 自动尝试这些编码
vim.opt.fileencodings = "ucs-bom,utf-8,iso-2022-jp,cp932,euc-jp,default,latin1"

-- 诊断图标常驻左侧，避免代码区提示干扰
vim.opt.signcolumn = "yes"
vim.opt.smoothscroll = false -- 关闭平滑滚动
vim.opt.list = true
vim.opt.listchars = {
  tab = "»·",
  trail = "•",
  nbsp = "␣",
  extends = "⟩",
  precedes = "⟨",
  eol = "↴",
}

-- Built-in yaml ftplugin resets indentation to spaces, so force tabs back locally.
vim.api.nvim_create_autocmd("FileType", {
  pattern = "yaml",
  callback = function()
    vim.opt_local.tabstop = 4
    vim.opt_local.softtabstop = 0
    vim.opt_local.shiftwidth = 4
    vim.opt_local.expandtab = false
  end,
})
