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

-- 多设备跨平台剪贴板智能适配：
-- 优先级：本地 Wayland (wl-copy) -> macOS (pbcopy) -> WSL (win32yank) -> X11 (xclip) -> tmux -> 终端 OSC 52 (降级兜底)
if vim.env.WAYLAND_DISPLAY and vim.env.WAYLAND_DISPLAY ~= "" and vim.fn.executable("wl-copy") == 1 and vim.fn.executable("wl-paste") == 1 then
  vim.g.clipboard = "wl-copy"
elseif vim.fn.has("mac") == 1 and vim.fn.executable("pbcopy") == 1 then
  vim.g.clipboard = "pbcopy"
elseif vim.fn.executable("win32yank.exe") == 1 then
  vim.g.clipboard = "win32yank"
elseif vim.env.DISPLAY and vim.env.DISPLAY ~= "" and vim.fn.executable("xclip") == 1 then
  vim.g.clipboard = "xclip"
elseif vim.env.TMUX and vim.env.TMUX ~= "" and vim.fn.executable("tmux") == 1 then
  vim.g.clipboard = "tmux"
else
  -- 无原生 GUI 显示服务时（如纯终端 SSH 远程连接），自动降级使用 OSC 52 终端剪贴板
  vim.g.clipboard = "osc52"
end
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
vim.opt.laststatus = 3
-- Keep the command line hidden when idle; it temporarily overlays the
-- bottom statusline while entering commands or searches.
if vim.fn.exists("&cmdheight") == 1 then
  vim.opt.cmdheight = 0
end
vim.opt.statusline = " "
vim.opt.incsearch = true
vim.opt.hlsearch = true
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- 告诉 Neovim 自动尝试这些编码
vim.opt.fileencodings = "ucs-bom,utf-8,iso-2022-jp,cp932,euc-jp,default,latin1"

-- Neovim's default detector is case-sensitive for extensions.  COBOL sources
-- commonly use uppercase .COB/.CBL, so normalize all common extensions to the
-- same filetype and let the COBOL-only palette apply automatically.
vim.filetype.add({
  extension = {
    cob = "cobol",
    cbl = "cobol",
    cobol = "cobol",
  },
  pattern = {
    ["*.COB"] = "cobol",
    ["*.CBL"] = "cobol",
    ["*.COBOL"] = "cobol",
  },
})

vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  pattern = { "*.COB", "*.CBL", "*.COBOL" },
  callback = function()
    vim.bo.filetype = "cobol"
  end,
})

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

-- 去掉窗口分隔线
vim.opt.fillchars = {
  vert = "│",      -- Fresh 风格的垂直分隔线
  horiz = "─",     -- Fresh 风格的水平分隔线
  eob = "~",       -- Make the end-of-buffer area explicit
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

-- ── Colorscheme ──
-- Primary theme: high-contrast-plus (exact 1:1 port of Fresh editor theme)
pcall(vim.cmd.colorscheme, "high-contrast-plus")

-- ── Baseline options previously provided by LazyVim (lazyvim.config.options) ──
-- Re-declared here so removing LazyVim does not silently revert them to Neovim
-- defaults. Intentional user overrides (tabstop=4, expandtab=false, laststatus=3,
-- showmode=true, smoothscroll=false, cursorcolumn=true) are left untouched.
vim.opt.undofile = true -- persistent undo
vim.opt.undolevels = 10000
vim.opt.swapfile = false -- disable swap files (prevents E325 ATTENTION and lockups in async plugins like diffview)
vim.opt.updatetime = 200 -- faster CursorHold
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
