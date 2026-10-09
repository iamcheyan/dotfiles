local this_file = debug.getinfo(1, "S").source:sub(2)
local nvim_root = vim.fn.fnamemodify(this_file, ":h:h")
vim.opt.runtimepath:prepend(nvim_root)
package.path = nvim_root .. "/lua/?.lua;" .. nvim_root .. "/lua/?/init.lua;" .. package.path

vim.cmd.colorscheme("blue")
local menu = vim.api.nvim_get_hl(0, { name = "Pmenu", link = false })
-- Simulate a theme that gives the completion kind and trailing-description
-- columns their own accent background; those cells should blend into the menu.
vim.api.nvim_set_hl(0, "PmenuKind", { fg = menu.fg, bg = 0xff0000, ctermfg = menu.ctermfg, ctermbg = 9 })
vim.api.nvim_set_hl(0, "PmenuExtra", { fg = menu.fg, bg = 0xff0000, ctermfg = menu.ctermfg, ctermbg = 9 })
for _, group in ipairs({ "BlinkCmpLabelDetail", "BlinkCmpLabelDescription", "BlinkCmpLabelDeprecated", "BlinkCmpSource" }) do
  vim.api.nvim_set_hl(0, group, { link = "PmenuExtra" })
end

local ui = require("config.ui_highlights")
ui.apply_menu_highlights()
local menu_bg = vim.api.nvim_get_hl(0, { name = "BlinkCmpMenu", link = false })
for _, group in ipairs({ "PmenuKind", "PmenuExtra" }) do
  local attrs = vim.api.nvim_get_hl(0, { name = group, link = false })
  assert(attrs.bg == menu_bg.bg, group .. " GUI background should match the completion menu")
  assert(attrs.ctermbg == menu_bg.ctermbg, group .. " terminal background should match the completion menu")
end
for _, group in ipairs({ "BlinkCmpLabelDetail", "BlinkCmpLabelDescription", "BlinkCmpLabelDeprecated", "BlinkCmpSource" }) do
  local attrs = vim.api.nvim_get_hl(0, { name = group, link = true })
  assert(attrs.link == "PmenuExtra", group .. " should inherit the normalized extra-column highlight")
end
print("completion_bg_spec: OK")
