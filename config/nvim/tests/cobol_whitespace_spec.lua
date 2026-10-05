-- Regression test for hiding visible whitespace only in COBOL windows.
-- Run: nvim --headless -u NONE -l config/nvim/tests/cobol_whitespace_spec.lua
local this_file = debug.getinfo(1, "S").source:sub(2)
local nvim_root = vim.fn.fnamemodify(this_file, ":h:h")
vim.opt.runtimepath:prepend(nvim_root)
package.path = nvim_root .. "/lua/?.lua;" .. nvim_root .. "/lua/?/init.lua;" .. package.path
vim.cmd("filetype plugin indent on")
dofile(nvim_root .. "/lua/config/options.lua")

local buf = vim.api.nvim_create_buf(false, true)
vim.api.nvim_set_current_buf(buf)
vim.bo[buf].filetype = "cobol"
assert(vim.wo.list == false, "COBOL should hide whitespace markers")
vim.bo[buf].filetype = "lua"
assert(vim.wo.list == true, "leaving COBOL should restore normal whitespace markers")
vim.bo[buf].filetype = "cobol"
assert(vim.wo.list == false, "switching back to COBOL should hide whitespace markers again")
local other = vim.api.nvim_create_buf(false, true)
vim.bo[other].filetype = "lua"
vim.api.nvim_set_current_buf(other)
assert(vim.wo.list == true, "entering a non-COBOL buffer should restore whitespace markers")

print("cobol_whitespace_spec: OK")
