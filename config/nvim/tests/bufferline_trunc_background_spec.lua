local this_file = debug.getinfo(1, "S").source:sub(2)
local nvim_root = vim.fn.fnamemodify(this_file, ":h:h")
vim.opt.runtimepath:prepend(nvim_root)
package.path = nvim_root .. "/lua/?.lua;" .. nvim_root .. "/lua/?/init.lua;" .. package.path

vim.cmd.colorscheme("blue")
local ui = require("config.ui_highlights")
ui.apply()
local options = ui.bufferline_highlights()

assert(options.trunc_marker and options.trunc_marker.bg == "NONE",
  "BufferLine truncation count/arrow should not paint a dark background")
assert(options.fill.bg == "NONE", "unused tabline fill after truncation should not paint a dark background")

for _, name in ipairs({ "BufferLineFill", "BufferLineNewBuffer", "BufferLineTruncMarker" }) do
  local hl = vim.api.nvim_get_hl(0, { name = name, link = false })
  assert(hl.bg == nil or hl.bg == 0, name .. " should have no explicit background")
end

local tabline_fill = vim.api.nvim_get_hl(0, { name = "TabLineFill", link = false })
assert(tabline_fill.bg ~= nil, "native TabLineFill palette should remain unchanged")

print("bufferline_trunc_background_spec: OK")
