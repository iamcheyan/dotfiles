local M = {}

local function current_menu_state()
  local ok_menu, menu = pcall(require, "blink.cmp.completion.windows.menu")
  local ok_list, list = pcall(require, "blink.cmp.completion.list")
  if not ok_menu or not ok_list or not menu.win:is_open() then return nil end
  return menu, list
end

local function menu_row(menu, list)
  local win = menu.win:get_win()
  if not win or not vim.api.nvim_win_is_valid(win) then return list.selected_item_idx or 1 end
  if vim.api.nvim_get_current_win() == win then
    return vim.api.nvim_win_get_cursor(win)[1]
  end
  local mouse = vim.fn.getmousepos()
  if mouse and mouse.winid == win and mouse.line > 0 then return mouse.line end
  return vim.api.nvim_win_get_cursor(win)[1]
end

local function with_source_window(menu, callback)
  local bufnr = menu.context and menu.context.bufnr
  local win = bufnr and vim.fn.bufwinid(bufnr) or -1
  if win and win > 0 and vim.api.nvim_win_is_valid(win) then
    return vim.api.nvim_win_call(win, callback)
  end
  return callback()
end

local function select_row(menu, list, row)
  row = math.max(1, math.min(#list.items, row))
  if #list.items == 0 then return false end
  return with_source_window(menu, function() return list.select(row) end)
end

local function move(delta)
  local menu, list = current_menu_state()
  if not menu or #list.items == 0 then return end
  local row = menu_row(menu, list)
  select_row(menu, list, row + delta)
end

local function accept()
  local menu, list = current_menu_state()
  if not menu or #list.items == 0 then return end
  select_row(menu, list, menu_row(menu, list))
  with_source_window(menu, function() require("blink.cmp").select_and_accept() end)
end

function M.setup()
  local group = vim.api.nvim_create_augroup("BlinkCompletionMenuNavigation", { clear = true })
  vim.api.nvim_create_autocmd("FileType", {
    group = group,
    pattern = "blink-cmp-menu",
    callback = function(ev)
      local opts = { buffer = ev.buf, nowait = true, silent = true, desc = "Blink completion menu navigation" }
      vim.keymap.set("n", "<Up>", function() move(-1) end, opts)
      vim.keymap.set("n", "<Down>", function() move(1) end, opts)
      vim.keymap.set("n", "<CR>", accept, opts)
      vim.keymap.set("n", "<LeftMouse>", accept, opts)
    end,
  })
end

return M
