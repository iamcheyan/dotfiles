-- Fixed-format COBOL Backspace must reverse the configured Tab stops.
-- Run: nvim --headless -u NONE -l config/nvim/tests/cobol_backspace_spec.lua
local this_file = debug.getinfo(1, "S").source:sub(2)
local nvim_root = vim.fn.fnamemodify(this_file, ":h:h")
package.loaded.cobol = { detect_format = function() return "fixed" end }

local blink = dofile(nvim_root .. "/lua/plugins/blink.lua")[1]
local backspace_keymap = blink.opts.keymap["<BS>"]
assert(backspace_keymap and type(backspace_keymap[1]) == "function", "Blink should provide a COBOL Backspace handler")
local backspace = backspace_keymap[1]

local buf = vim.api.nvim_create_buf(false, true)
vim.api.nvim_set_current_buf(buf)
vim.bo[buf].filetype = "cobol"

local function check(line, cursor_byte, expected, label)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, { line })
  vim.api.nvim_win_set_cursor(0, { 1, cursor_byte })
  local handled = backspace({})
  assert(handled == true, label .. ": fixed-format Backspace should handle the tab stop")
  vim.wait(50)
  local actual = vim.api.nvim_get_current_line()
  assert(actual == expected, string.format("%s: expected %q, got %q", label, expected, actual))
end

check("      X", 5, "X", "col 7 back to col 1")
check("       X", 6, "      X", "col 8 back to col 7")
check("           X", 10, "       X", "col 12 back to col 8")
check("               X", 14, "           X", "normal indent back to col 12")
check("       01  X", 10, "       01X", "name stop back to level number")
check("       01  EOF-FLG" .. string.rep(" ", 21) .. "X", 38, "       01  EOF-FLGX", "PIC stop back to data name")

print("cobol_backspace_spec: OK")
