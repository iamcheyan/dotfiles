local this_file = debug.getinfo(1, "S").source:sub(2)
local nvim_root = vim.fn.fnamemodify(this_file, ":h:h")
vim.opt.runtimepath:prepend(nvim_root)
package.path = nvim_root .. "/lua/?.lua;" .. nvim_root .. "/lua/?/init.lua;" .. package.path

local spec = dofile(nvim_root .. "/lua/plugins/blink.lua")[1]
local keymap = spec.opts.keymap
assert(keymap["<CR>"] and keymap["<CR>"][1] == "select_and_accept", "Enter should select and accept a completion item")
assert(keymap["<Up>"] and keymap["<Up>"][1] == "select_prev", "Up should select the previous completion item")
assert(keymap["<Down>"] and keymap["<Down>"][1] == "select_next", "Down should select the next completion item")
print("blink_keymap_spec: OK")
