-- Keep only the Snacks file list and preview on the editor's blue background.
-- Run: nvim --headless -u NONE -l config/nvim/tests/snacks_picker_background_spec.lua
local this_file = debug.getinfo(1, "S").source:sub(2)
local nvim_root = vim.fn.fnamemodify(this_file, ":h:h")
vim.opt.runtimepath:prepend(nvim_root)
package.path = nvim_root .. "/lua/?.lua;" .. nvim_root .. "/lua/?/init.lua;" .. package.path
vim.cmd("filetype plugin indent on")
dofile(nvim_root .. "/lua/config/options.lua")
local ui = require("config.ui_highlights")
local normal = vim.api.nvim_get_hl(0, { name = "Normal", link = false })
local menu = vim.api.nvim_get_hl(0, { name = "Pmenu", link = false })
ui.apply_picker_highlights()

local list = vim.api.nvim_get_hl(0, { name = "SnacksPickerList", link = false })
local preview = vim.api.nvim_get_hl(0, { name = "SnacksPickerPreview", link = false })
local input = vim.api.nvim_get_hl(0, { name = "SnacksPickerInput", link = false })
assert(list.bg == normal.bg, "left file list should use the document's blue background")
assert(preview.bg == normal.bg, "right preview should use the document's blue background")
assert(input.bg == normal.bg, "left input pane should not retain the old green menu background")
for _, group in ipairs({ "SnacksPickerFooter", "SnacksPickerListFooter", "SnacksPickerFooterKey", "SnacksPickerFooterText", "SnacksPickerFooterSeparator" }) do
  assert(vim.api.nvim_get_hl(0, { name = group, link = false }).bg == normal.bg, group .. " should share the left pane background")
end

local selected = vim.api.nvim_get_hl(0, { name = "SnacksPickerListCursorLine", link = false })
local nostalgia = ui.nostalgia_palette()
assert(selected.bg == ui.to_rgb(nostalgia.menu_highlight_bg), "selected file row should use Fresh Nostalgia's green highlight")
assert(selected.fg == ui.to_rgb(nostalgia.menu_highlight_fg), "selected file row should use Fresh Nostalgia's white text")
for _, group in ipairs({ "SnacksPickerCursorLine", "SnacksPickerInputCursorLine", "SnacksPickerPreviewCursorLine", "SnacksPickerBoxCursorLine" }) do
  assert(vim.api.nvim_get_hl(0, { name = group, link = false }).bg == normal.bg, group .. " should not retain a green or pale-blue row background")
end

for _, group in ipairs({ "SnacksPickerBorder", "SnacksPickerInputBorder", "SnacksPickerListBorder", "SnacksPickerPreviewBorder", "SnacksPickerFooterBorder" }) do
  local border = vim.api.nvim_get_hl(0, { name = group, link = false })
  assert(border.fg == menu.fg, group .. " should retain the white border foreground")
  assert(border.bg == normal.bg, group .. " should not leave a green border background")
end

print("snacks_picker_background_spec: OK")