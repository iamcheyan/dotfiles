local root = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":h:h")
vim.opt.rtp:prepend(root)
vim.opt.rtp:append(vim.fn.stdpath("data") .. "/lazy/heirline.nvim")
local ok, heirline = pcall(require, "heirline")
if not ok then print("winbar_refresh_spec: SKIP (Heirline unavailable)"); return end
vim.o.termguicolors = true
vim.cmd.colorscheme("blue")
vim.api.nvim_set_hl(0, "WinBar", { fg = "#000087", bg = "#000087" })
heirline.setup({ winbar = { hl = "WinBar", provider = "DATA", update = { "CursorMoved" } } })
vim.wo.winbar = "%{%v:lua.require'heirline'.eval_winbar()%}"
local function rendered()
  return vim.api.nvim_eval_statusline(vim.wo.winbar, { winid = 0, use_winbar = true, highlights = true })
end
rendered() -- Cache the initial component before the deferred UI adapter runs.
require("config.ui_highlights").apply()
local bar = vim.api.nvim_get_hl(0, { name = "WinBar", link = false })
local ev = rendered()
for _, highlight in ipairs(ev.highlights) do
  if highlight.group:match("^Stl") then
    local h = vim.api.nvim_get_hl(0, { name = highlight.group, link = false })
    assert(h.fg == bar.fg and h.bg == bar.bg, "Heirline retained the initial winbar palette after UI apply")
  end
end
print("winbar_refresh_spec: OK")
