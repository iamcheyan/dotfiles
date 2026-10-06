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
assert(input.bg == menu.bg, "picker input background must remain unchanged")

local border = vim.api.nvim_get_hl(0, { name = "SnacksPickerPreviewBorder", link = false })
assert(border.fg == menu.fg, "white preview border foreground must remain unchanged")
assert(border.bg == menu.bg, "preview border background must remain unchanged")

print("snacks_picker_background_spec: OK")