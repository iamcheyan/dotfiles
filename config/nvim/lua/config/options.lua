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

-- COBOL source may be pasted starting at column 1, so indentation keys shift the
-- entire line rather than treating columns 1-7 as untouchable sequence fields.
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "cobol", "cbl", "cob" },
  callback = function(ev)
    -- Use an explicit Enter mapping instead of filetype-dependent indentexpr behavior.
    -- This always copies exactly the current line's leading whitespace, including col 8.
    vim.opt_local.autoindent = false
    vim.keymap.set("i", "<CR>", function()
      local ok, blink = pcall(require, "blink.cmp")
      if ok and blink.is_menu_visible() then return "<C-y>" end
      local indent = vim.api.nvim_get_current_line():match("^%s*") or ""
      return "<CR>" .. indent
    end, { buffer = ev.buf, expr = true, desc = "COBOL: continue previous line indentation" })
    vim.opt_local.smartindent = false
    vim.opt_local.cindent = false
    vim.opt_local.indentexpr = ""

    local function shift_cobol_line(row, direction, count)
      local line = vim.api.nvim_buf_get_lines(ev.buf, row - 1, row, false)[1] or ""
      local amount = count * (vim.bo[ev.buf].shiftwidth > 0 and vim.bo[ev.buf].shiftwidth or 4)
      if direction > 0 then
        line = string.rep(" ", amount) .. line
      else
        local indent = line:match("^ *") or ""
        local remove = math.min(#indent, amount)
        line = line:sub(remove + 1)
      end
      vim.api.nvim_buf_set_lines(ev.buf, row - 1, row, false, { line })
    end

    local function shift_cobol_range(first, last, direction, count)
      if first > last then first, last = last, first end
      for row = first, last do
        shift_cobol_line(row, direction, count)
      end
    end

    local function shift_cobol_selection(direction)
      shift_cobol_range(vim.fn.line("v"), vim.fn.line("."), direction, vim.v.count1 or 1)
      vim.cmd("normal! gv")
    end

    local function shift_cobol_current(direction)
      shift_cobol_line(vim.api.nvim_win_get_cursor(0)[1], direction, vim.v.count1 or 1)
    end

    local function format_cobol_buffer()
      local original = vim.api.nvim_buf_get_lines(ev.buf, 0, -1, false)
      local view = vim.fn.winsaveview()
      local saved = {
        indentexpr = vim.bo[ev.buf].indentexpr,
        indentkeys = vim.bo[ev.buf].indentkeys,
        autoindent = vim.bo[ev.buf].autoindent,
        smartindent = vim.bo[ev.buf].smartindent,
        cindent = vim.bo[ev.buf].cindent,
        expandtab = vim.bo[ev.buf].expandtab,
      }
      local ok, err = pcall(function()
        vim.cmd("runtime! indent/cobol.vim")
        vim.bo[ev.buf].indentexpr = "GetCobolIndent(v:lnum)"
        vim.bo[ev.buf].autoindent = true
        vim.bo[ev.buf].smartindent = false
        vim.bo[ev.buf].cindent = false
        vim.cmd("silent keepjumps normal! gg=G")
        local formatter_ok, formatter = pcall(require, "cobol.formatter")
        if formatter_ok then
          formatter.format_range(ev.buf, 1, vim.api.nvim_buf_line_count(ev.buf))
        end
      end)
      if not ok then
        vim.api.nvim_buf_set_lines(ev.buf, 0, -1, false, original)
        vim.notify("COBOL format failed: " .. tostring(err), vim.log.levels.ERROR)
      end

      vim.bo[ev.buf].indentexpr = saved.indentexpr
      vim.bo[ev.buf].indentkeys = saved.indentkeys
      vim.bo[ev.buf].autoindent = saved.autoindent
      vim.bo[ev.buf].smartindent = saved.smartindent
      vim.bo[ev.buf].cindent = saved.cindent
      vim.bo[ev.buf].expandtab = saved.expandtab
      vim.fn.winrestview(view)
    end

    -- VS Code-style indentation keys: whole-line adjustment in Normal mode,
    -- selected-line adjustment in Visual/Select mode, and Shift-Tab in Insert.
    vim.keymap.set("n", "<Tab>", function() shift_cobol_current(1) end, { buffer = ev.buf, desc = "Indent COBOL line" })
    vim.keymap.set("n", "<S-Tab>", function() shift_cobol_current(-1) end, { buffer = ev.buf, desc = "Unindent COBOL line" })
    vim.keymap.set({ "x", "s" }, "<Tab>", function() shift_cobol_selection(1) end, { buffer = ev.buf, desc = "Indent COBOL selection" })
    vim.keymap.set({ "x", "s" }, "<S-Tab>", function() shift_cobol_selection(-1) end, { buffer = ev.buf, desc = "Unindent COBOL selection" })
    vim.keymap.set("x", ">", function() shift_cobol_selection(1) end, { buffer = ev.buf, desc = "Indent COBOL selection" })
    vim.keymap.set("x", "<", function() shift_cobol_selection(-1) end, { buffer = ev.buf, desc = "Unindent COBOL selection" })
    vim.keymap.set("i", "<S-Tab>", "<C-d>", { buffer = ev.buf, desc = "Unindent COBOL line" })
    vim.keymap.set("n", "<leader>cO", format_cobol_buffer, { buffer = ev.buf, desc = "Format entire COBOL buffer" })

    -- A period terminates COBOL words/sentences; hide any completion menu it triggers.
    local group = vim.api.nvim_create_augroup("CobolNoPeriodCompletion_" .. ev.buf, { clear = true })
    vim.api.nvim_create_autocmd("InsertCharPre", {
      group = group,
      buffer = ev.buf,
      callback = function()
        if vim.v.char == "." then
          vim.schedule(function()
            local ok, blink = pcall(require, "blink.cmp")
            if ok and blink.hide then blink.hide() end
          end)
        end
      end,
    })
  end,
})

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
if vim.fn.exists("&mousemoveevent") == 1 then
  vim.opt.mousemoveevent = true
end
require("config.context_menu").setup()
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.cursorline = true
vim.opt.cursorcolumn = true
vim.opt.splitbelow = true
vim.opt.splitright = true
-- Keep sidebar splits from being equalized or stolen down to 1 column.
-- Vim's default winwidth=20 is why a restored file-tree can collapse to icons.
vim.opt.equalalways = false
vim.opt.winwidth = 1
vim.opt.winminwidth = 1
vim.opt.termguicolors = true
vim.opt.showmode = true
vim.opt.laststatus = 3
-- Keep the command line merged with the global statusline while idle; active
-- commands temporarily overlay this row.
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

-- ── Case-insensitive extension detection ──
-- Neovim registers each extension with the exact spelling used in its own
-- filetype table, so `.bat` is highlighted while `.BAT` receives no filetype at
-- all and silently loses highlighting.  Batch scripts, COBOL programs and
-- copybooks, and hand-written configuration files routinely use upper- or
-- mixed-case extensions, so register the families we actually work with
-- case-insensitively.
--
-- Two traps when editing this table:
--   * `vim.filetype.add` wraps every `pattern` key as '^' .. key .. '$', so the
--     key must be a Lua pattern matching the whole file name.  A glob such as
--     "*.[bB][aA][tT]" becomes "^*.[bB][aA][tT]$", where the leading "*"
--     quantifies the "^" character and the pattern can therefore never match.
--     Use ".*%.[bB][aA][tT]" instead, and never append "$" (it would double).
--   * Negative priority keeps these broad rules behind Neovim's specific ones,
--     so ~/.config/tmux/tmux.conf still resolves to `tmux` rather than the
--     generic `conf` rule below.
local function ci_pattern(ext)
  return ".*%." .. ext:gsub("%a", function(c)
    return "[" .. c:lower() .. c:upper() .. "]"
  end)
end

-- Generic *.conf/*.cnf/*.config files are a grab bag: shell fragments that zsh
-- sources (aliases.conf, machine.conf, zsh's znt/*.conf), KEY=VALUE settings
-- (btop.conf, fcitx5), CLI flag lists (chromium-flags.conf), or an
-- application's own DSL (ranger's rc.conf).  Neovim's `conf` syntax understands
-- only `#` comments and leaves nearly all of them unhighlighted, so count shell
-- and assignment constructs in the head of the buffer and pick a syntax that
-- actually covers the content.  Thresholds are deliberately conservative: a
-- file must look consistently shell-like to be treated as shell.
local function detect_generic_config(_, bufnr)
  -- Called with bufnr == -1 when matching a name without a buffer; keep the
  -- conservative default there.
  if bufnr < 0 then
    return "conf"
  end

  local shell, ini = 0, 0
  local last = math.min(120, vim.api.nvim_buf_line_count(bufnr))
  for _, line in ipairs(vim.api.nvim_buf_get_lines(bufnr, 0, last, false)) do
    if
      line:match("^%s*[#;]")
      or line:match("^%s*$")
      or line:match("^%s*//")
      or line:match("^%s*%-%-") -- CLI flag such as --ozone-platform=wayland
    then
      -- Comment, blank, or flag line: no signal either way.
    elseif
      line:match("^%s*alias%s")
      or line:match("^%s*function%s")
      or line:match("^%s*local%s")
      or line:match("^%s*export%s")
      or line:match("^%s*case%s")
      or line:match("^%s*esac")
      or line:match("^%s*then%s*$")
      or line:match("^%s*fi%s*$")
      or line:match("^%s*for%s")
      or line:match("^%s*done%s*$")
      or line:match("^%s*if%s")
      or line:match("^%s*while%s")
      or line:find("%[%[", 1, true)
      or line:find("%$%(", 1, true)
      or line:find("${", 1, true)
      or line:find("&&", 1, true)
      or line:find("||", 1, true)
      or line:find(">/dev/null", 1, true)
      or line:match("^%s*[%w_]+%s*=%s*%$")
      or line:match("^%s*[%w_]+%s*=%s*%(")
    then
      shell = shell + 1
    elseif line:find("=", 1, true) then
      ini = ini + 1
    end
  end

  if shell >= 5 and shell > ini then
    return "sh"
  end
  if ini >= 1 then
    return "dosini"
  end
  return "conf"
end

local filetype_patterns = {}

for _, ext in ipairs({ "conf", "cnf", "config" }) do
  filetype_patterns[ci_pattern(ext)] = { detect_generic_config, { priority = -1 } }
end

-- Batch scripts.  Uppercase *.CMD is mapped straight to `dosbatch`; Neovim's
-- own `detect.cmd` also considers OS/2 REXX and MS linker command files, which
-- only ever appear in lowercase.
for _, ext in ipairs({ "bat", "cmd" }) do
  filetype_patterns[ci_pattern(ext)] = { "dosbatch", { priority = -1 } }
end

-- COBOL programs and copybooks.
for _, ext in ipairs({ "cob", "cbl", "cobol", "cpy" }) do
  filetype_patterns[ci_pattern(ext)] = { "cobol", { priority = -1 } }
end

-- INI-style settings and environment files.
filetype_patterns[ci_pattern("ini")] = { "dosini", { priority = -1 } }
filetype_patterns[ci_pattern("env")] = { "env", { priority = -1 } }

vim.filetype.add({ pattern = filetype_patterns })

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
-- 'showtabline' is intentionally not set here. bufferline.nvim renders into the
-- same tabline slot (vim.o.tabline = "%!v:lua.nvim_bufferline()") and manages
-- 'showtabline' itself via auto_toggle_bufferline, so any value assigned here is
-- overwritten on the next render. Setting 0 would also hide bufferline itself.

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
