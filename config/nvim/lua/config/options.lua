-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

vim.g.have_nerd_font = true -- 开启 Nerd Font 支持，修复图标显示为问号或 $ 的问题

-- 全局母版开关：强制所有 LSP 悬浮窗和诊断窗使用直角单线边框
local border = "single"

vim.opt.winborder = border -- 新增：Neovim 0.10+ 的全局边框设置

vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = border })
vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signatureHelp, { border = border })

vim.diagnostic.config({
  float = { border = border },
})