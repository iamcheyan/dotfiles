local this_file = debug.getinfo(1, "S").source:sub(2)
local nvim_root = vim.fn.fnamemodify(this_file, ":h:h")
vim.opt.runtimepath:prepend(nvim_root)
package.path = nvim_root .. "/lua/?.lua;" .. nvim_root .. "/lua/?/init.lua;" .. package.path

local spec = dofile(nvim_root .. "/lua/plugins/bufferline.lua")[1]
local options = spec.opts().options
assert(options.middle_mouse_command == options.close_command,
  "middle-clicking a buffer tab should close that buffer using BufferLine's configured close command")
print("bufferline_middle_click_spec: OK")
