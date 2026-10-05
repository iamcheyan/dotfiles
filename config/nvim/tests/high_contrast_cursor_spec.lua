-- Headless regression test for the high-contrast row/column cursor guides.
-- Run: nvim --headless -u NONE -l config/nvim/tests/high_contrast_cursor_spec.lua
local this_file = debug.getinfo(1, "S").source:sub(2)
local nvim_root = vim.fn.fnamemodify(this_file, ":h:h")
vim.opt.runtimepath:prepend(nvim_root)
local theme = dofile(nvim_root .. "/lua/theme/high-contrast-plus.lua")
theme.load()

local expected = tonumber("303030", 16)
local cursor_line = vim.api.nvim_get_hl(0, { name = "CursorLine", link = false })
local cursor_column = vim.api.nvim_get_hl(0, { name = "CursorColumn", link = false })
local cursor_line_number = vim.api.nvim_get_hl(0, { name = "CursorLineNr", link = false })
assert(cursor_line.bg == expected, "CursorLine should use a brighter, distinct background")
assert(cursor_column.bg == expected, "CursorColumn should use a brighter, distinct background")
assert(cursor_line_number.bg == expected, "CursorLineNr should match the brighter row guide")

print("high_contrast_cursor_spec: OK")
