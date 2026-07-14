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
vim.opt.laststatus = 0
vim.opt.statusline = " "
vim.opt.incsearch = true
vim.opt.hlsearch = true
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- 告诉 Neovim 自动尝试这些编码
vim.opt.fileencodings = "ucs-bom,utf-8,iso-2022-jp,cp932,euc-jp,default,latin1"

-- 禁用诊断图标和诊断功能
vim.opt.signcolumn = "yes"

-- 完全禁用诊断显示
vim.diagnostic.config({
	enabled = false,
	virtual_text = false,
	signs = false,
	underline = false,
	update_in_insert = false,
	severity_sort = false,
})
-- Neovim 0.10+ 才支持的选项
if vim.version().minor >= 10 then
  vim.opt.smoothscroll = false -- 关闭平滑滚动
end
vim.opt.showtabline = 0 -- 隐藏顶部的 Tab Page 标签栏（通过 leader+tab 管理）

-- Keep the custom top winbar, but prevent Neovim's bottom statusline from
-- reappearing with the current file path if a later plugin toggles it.
vim.api.nvim_create_autocmd({ "VimEnter", "WinEnter", "BufWinEnter" }, {
  callback = function()
    if vim.o.laststatus ~= 0 then
      vim.o.laststatus = 0
    end
  end,
})

-- 去掉窗口分隔线
vim.opt.fillchars = {
  vert = " ",      -- 垂直分隔线（侧栏和编辑区之间）
  horiz = " ",     -- 水平分隔线
}
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

-- ── Colorscheme (previously applied via LazyVim opts.colorscheme) ──
-- `oceanblack` is a local colors file (colors/oceanblack.vim), no plugin needed.
pcall(vim.cmd.colorscheme, "oceanblack")

-- ── Baseline options previously provided by LazyVim (lazyvim.config.options) ──
-- Re-declared here so removing LazyVim does not silently revert them to Neovim
-- defaults. Intentional user overrides (tabstop=4, expandtab=false, laststatus=0,
-- showmode=true, smoothscroll=false, cursorcolumn=true) are left untouched.
vim.opt.undofile = true -- persistent undo
vim.opt.undolevels = 10000
vim.opt.updatetime = 200 -- faster CursorHold / swap write
vim.opt.timeoutlen = 300 -- snappier which-key
vim.opt.scrolloff = 4 -- keep context above/below cursor
vim.opt.sidescrolloff = 8
vim.opt.conceallevel = 2 -- hide *markdown* markup, keep markers
vim.opt.foldmethod = "indent" -- matches prior LazyVim behavior
vim.opt.foldlevel = 99 -- start with folds open
vim.opt.foldtext = ""
vim.opt.grepprg = "rg --vimgrep" -- :grep uses ripgrep
vim.opt.grepformat = "%f:%l:%c:%m"
vim.opt.smartindent = true
vim.opt.shiftround = true -- round indent to shiftwidth
vim.opt.wrap = false -- do not wrap long lines
vim.opt.autowrite = true -- auto-write on :next / :make etc.
vim.opt.confirm = true -- confirm unsaved changes
vim.opt.formatoptions = "jcroqlnt" -- sensible comment/format behavior
vim.opt.inccommand = "nosplit" -- incremental substitute preview
vim.opt.shortmess:append({ W = true, I = true, c = true, C = true })
vim.opt.jumpoptions = "view"
