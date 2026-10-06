-- Headless regression test for the high-contrast row/column cursor guides.
-- Run: nvim --headless -u NONE -l config/nvim/tests/high_contrast_cursor_spec.lua
local this_file = debug.getinfo(1, "S").source:sub(2)
local nvim_root = vim.fn.fnamemodify(this_file, ":h:h")
vim.opt.runtimepath:prepend(nvim_root)
local theme = dofile(nvim_root .. "/lua/theme/high-contrast-plus.lua")
theme.load()
local ui_highlights = require("config.ui_highlights")
ui_highlights.apply()

local expected = tonumber("303030", 16)
local cursor_line = vim.api.nvim_get_hl(0, { name = "CursorLine", link = false })
local cursor_column = vim.api.nvim_get_hl(0, { name = "CursorColumn", link = false })
local cursor_line_number = vim.api.nvim_get_hl(0, { name = "CursorLineNr", link = false })
local completion_doc = vim.api.nvim_get_hl(0, { name = "BlinkCmpDoc", link = false })
local completion_doc_border = vim.api.nvim_get_hl(0, { name = "BlinkCmpDocBorder", link = false })
local normal = vim.api.nvim_get_hl(0, { name = "Normal", link = false })
assert(cursor_line.bg == expected, "CursorLine should use a brighter, distinct background")
assert(cursor_column.bg ~= cursor_line.bg, "CursorColumn must differ from CursorLine so the crosshair intersection stays visible")
assert(cursor_line_number.bg == expected, "CursorLineNr should match the brighter row guide")
assert(completion_doc.bg == normal.bg, "completion documentation should use a distinct editor surface")
assert(completion_doc.fg == vim.api.nvim_get_hl(0, { name = "BlinkCmpMenu", link = false }).fg, "completion documentation text should use the menu's readable foreground")
assert(completion_doc_border.fg == completion_doc.fg, "completion documentation border should remain visible against its surface")

-- Blue and several built-in themes assign the same GUI and terminal color to
-- both guides. Verify the adapter separates both color paths at the crossing.
vim.api.nvim_set_hl(0, "CursorLine", { bg = "#005faf", ctermbg = 25 })
vim.api.nvim_set_hl(0, "CursorColumn", { bg = "#005faf", ctermbg = 25 })
ui_highlights.apply()
cursor_line = vim.api.nvim_get_hl(0, { name = "CursorLine", link = false })
cursor_column = vim.api.nvim_get_hl(0, { name = "CursorColumn", link = false })
assert(cursor_column.bg ~= cursor_line.bg, "theme adapter should separate identical GUI guide colors")
assert(cursor_column.ctermbg ~= cursor_line.ctermbg, "theme adapter should separate identical terminal guide colors")

local blink_spec = dofile(nvim_root .. "/lua/plugins/blink.lua")[1].opts.completion
assert(blink_spec.menu.border == "rounded", "completion list should use the shared rounded menu style")
assert(blink_spec.documentation.window.border == "rounded", "completion docs should match the list border")
assert(blink_spec.documentation.window.max_width == 60, "completion docs should have a bounded width")
assert(blink_spec.menu.draw.align_to == "label", "completion text should align to the candidate labels")

print("high_contrast_cursor_spec: OK")
