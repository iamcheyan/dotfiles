local this_file = debug.getinfo(1, "S").source:sub(2)
local nvim_root = vim.fn.fnamemodify(this_file, ":h:h")
vim.opt.runtimepath:prepend(nvim_root)
package.path = nvim_root .. "/lua/?.lua;" .. nvim_root .. "/lua/?/init.lua;" .. package.path

local accepted
local fake_menu = {}
fake_menu.win = {
  is_open = function() return true end,
  get_win = function() return vim.api.nvim_get_current_win() end,
}
fake_menu.items = { {}, {}, {} }
fake_menu.set_selected_item_idx = function(index) fake_menu.selected_item_idx = index end
local fake_list = {}
fake_list.items = fake_menu.items
fake_list.selected_item_idx = 1
fake_list.select = function(index) fake_list.selected_item_idx = index; fake_menu.set_selected_item_idx(index); return true end
package.loaded["blink.cmp.completion.windows.menu"] = fake_menu
package.loaded["blink.cmp.completion.list"] = fake_list
package.loaded["blink.cmp"] = {
  select_and_accept = function() accepted = fake_list.selected_item_idx; return true end,
}

require("config.blink_menu").setup()
local buf = vim.api.nvim_create_buf(false, true)
vim.api.nvim_set_current_buf(buf)
vim.api.nvim_buf_set_lines(buf, 0, -1, false, { "one", "two", "three" })
vim.bo[buf].filetype = "blink-cmp-menu"

local function mapping(key)
  local value = vim.fn.maparg(key, "n", false, true)
  assert(type(value.callback) == "function", "missing Normal-mode menu mapping for " .. key)
  return value.callback
end

mapping("<Down>")()
assert(fake_list.selected_item_idx == 2, "Down should select the next completion item")
mapping("<Up>")()
assert(fake_list.selected_item_idx == 1, "Up should select the previous completion item")
vim.api.nvim_win_set_cursor(0, { 3, 0 })
local saved_getmousepos = vim.fn.getmousepos
vim.fn.getmousepos = function() return { winid = 0, line = 0 } end
mapping("<LeftMouse>")()
vim.fn.getmousepos = saved_getmousepos
assert(fake_list.selected_item_idx == 3 and accepted == 3, "clicking a row should accept that completion")
print("blink_menu_spec: OK")
