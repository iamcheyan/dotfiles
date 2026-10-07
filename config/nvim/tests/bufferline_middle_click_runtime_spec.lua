-- Runtime integration test for BufferLine's middle-click close dispatch.
local command = require("bufferline")
assert(command, "bufferline.nvim must be loaded by the real config")
assert(_G.___bufferline_private and _G.___bufferline_private.handle_click,
  "BufferLine must expose its click handler")

local buf = vim.api.nvim_create_buf(true, false)
vim.api.nvim_buf_set_name(buf, vim.fn.tempname() .. ".txt")
vim.api.nvim_buf_set_lines(buf, 0, -1, false, { "middle-click target" })
vim.api.nvim_set_current_buf(buf)
assert(vim.bo[buf].buflisted, "test buffer should be listed before the click")

_G.___bufferline_private.handle_click(buf, 1, "m")
local closed = vim.wait(1000, function()
  return not vim.api.nvim_buf_is_valid(buf) or not vim.bo[buf].buflisted
end, 10)
assert(closed, "middle click should run the configured close command")
print("bufferline_middle_click_runtime_spec: OK")
