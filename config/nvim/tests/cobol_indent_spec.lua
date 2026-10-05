-- Regression test for fixed-format indentation after loading the real options.lua.
-- Run: nvim --headless -u NONE -l config/nvim/tests/cobol_indent_spec.lua
local this_file = debug.getinfo(1, "S").source:sub(2)
local nvim_root = vim.fn.fnamemodify(this_file, ":h:h")
vim.opt.runtimepath:prepend(nvim_root)
package.path = nvim_root .. "/lua/?.lua;" .. nvim_root .. "/lua/?/init.lua;" .. package.path
vim.cmd("filetype plugin indent on")
dofile(nvim_root .. "/lua/config/options.lua")

local buf = vim.api.nvim_create_buf(false, true)
vim.api.nvim_set_current_buf(buf)
vim.api.nvim_buf_set_lines(buf, 0, -1, false, {
  "IDENTIFICATION DIVISION.",
  "PROGRAM-ID. PROBE.",
  "DATA DIVISION.",
  "WORKING-STORAGE SECTION.",
  "01  WS-NAME PIC X(10).",
  "PROCEDURE DIVISION.",
  "MAIN-PARA.",
  "DISPLAY WS-NAME.",
  "STOP RUN.",
})
vim.bo[buf].filetype = "cobol"
assert(vim.bo[buf].autoindent == false, "COBOL Enter should remain explicitly controlled")
assert(vim.bo[buf].indentexpr ~= "", "COBOL indentexpr must remain available for the = operator")
vim.cmd("normal! gg=G")
local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
for _, row in ipairs({ 1, 3, 4, 5, 6, 7 }) do
  assert(lines[row]:sub(1, 7) == string.rep(" ", 7), string.format("fixed-format Area A line %d lost its seven-column prefix: %q", row, lines[row]))
end
assert(lines[8]:sub(1, 11) == string.rep(" ", 11), "Area B statement should start in column 12")
assert(lines[9]:sub(1, 11) == string.rep(" ", 11), "following statement should remain in Area B")

-- The explicit Enter mapping must still continue the current line's indentation.
vim.api.nvim_win_set_cursor(0, { 8, #lines[8] })
vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("A<CR><Esc>", true, false, true), "xt", false)
local after_enter = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
assert(after_enter[9] == string.rep(" ", 11), "Enter should continue Area B indentation exactly once")

print("cobol_indent_spec: OK")
