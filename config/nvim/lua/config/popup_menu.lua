-- Float menus keep separators outside the selection, including on mouse hover.
local M = {}
function M.open(entries, execute)
  if M.close then M.close() end
  local src = vim.api.nvim_get_current_win()
  local src_buf = vim.api.nvim_win_get_buf(src)
  local mode = vim.fn.mode():sub(1, 1)
  if mode == 'V' or mode == '\22' then mode = 'v' end
  local rows, lines, width = {}, {}, 24
  for _, entry in ipairs(entries) do
    if not entry.raw or entry.mode == 'a' or entry.mode == mode then
      rows[#rows + 1] = entry
      local text = entry.separator and '' or ('  ' .. entry[1] .. '  ')
      lines[#lines + 1] = text
      width = math.max(width, vim.fn.strdisplaywidth(text))
    end
  end
  width = math.min(width, vim.o.columns - 4)
  for i, entry in ipairs(rows) do
    if entry.separator then lines[i] = '  ' .. string.rep('─', math.max(1, width - 4)) .. '  ' end
  end
  local mouse = vim.fn.getmousepos()
  local height = math.min(#lines, vim.o.lines - 4)
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].bufhidden = 'wipe'
  vim.bo[buf].filetype = 'contextline_menu'
  vim.bo[buf].modifiable = false
  local win = vim.api.nvim_open_win(buf, false, {
    relative = 'editor', row = math.max(0, math.min(mouse.screenrow, vim.o.lines - height - 3)),
    col = math.max(0, math.min(mouse.screencol - 1, vim.o.columns - width - 2)),
    width = width, height = height, style = 'minimal', border = 'single', zindex = 250,
  })
  vim.wo[win].winhighlight = 'Normal:FreshMenu,NormalFloat:FreshMenu,FloatBorder:FreshMenuBorder'
  vim.wo[win].cursorline = false
  vim.wo[win].wrap = false
  vim.wo[win].scrolloff = 0
  local ns = vim.api.nvim_create_namespace('ContextPopupSelection')
  local selected = 1
  local function select(row)
    if not rows[row] or rows[row].separator then return end
    selected = row
    vim.api.nvim_win_set_cursor(win, { row, 0 })
    vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
    vim.api.nvim_buf_set_extmark(buf, ns, row - 1, 0, {
      end_row = row, hl_group = 'FreshMenuSelected', hl_eol = true, priority = 200,
    })
  end
  local saved_motion, saved_cursor = vim.o.mousemoveevent, vim.o.guicursor
  vim.o.mousemoveevent = true
  local surface = vim.api.nvim_get_hl(0, { name = 'FreshMenu', link = false })
  vim.api.nvim_set_hl(0, 'PopupHiddenCursor', { fg = surface.bg, bg = surface.bg, blend = 100 })
  vim.o.guicursor = 'a:PopupHiddenCursor-blinkon0'
  local saved = {}
  local group = vim.api.nvim_create_augroup('ContextPopupLifetime', { clear = true })
  local closed = false
  local function close()
    if closed then return end
    closed = true
    vim.api.nvim_del_augroup_by_id(group)
    for _, entry in ipairs(saved) do
      if vim.api.nvim_buf_is_valid(src_buf) then
        pcall(vim.keymap.del, entry.mode, entry.key, { buffer = src_buf })
        for _, mapping in ipairs(entry.maps) do
          vim.fn.mapset(entry.mode, false, mapping)
        end
      end
    end
    vim.o.mousemoveevent, vim.o.guicursor = saved_motion, saved_cursor
    if vim.api.nvim_win_is_valid(win) then vim.api.nvim_win_close(win, true) end
    if vim.api.nvim_win_is_valid(src) then vim.api.nvim_set_current_win(src) end
    M.close, M.win = nil, nil
  end
  M.close, M.win = close, win
  local function move(delta)
    local row = selected + delta
    while rows[row] do
      if not rows[row].separator then select(row); return end
      row = row + delta
    end
  end
  local function hover()
    local mp = vim.fn.getmousepos()
    if mp.winid == win then select(mp.line) end
  end
  local function activate()
    local entry = rows[selected]
    close()
    vim.schedule(function() execute(entry) end)
  end
  local function click()
    local mp = vim.fn.getmousepos()
    if mp.winid == win then
      if rows[mp.line] and not rows[mp.line].separator then select(mp.line); activate() end
    else
      close()
      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<LeftMouse>', true, false, true), 'm', false)
    end
  end
  local function wheel(delta, key)
    if vim.fn.getmousepos().winid == win then move(delta) else
      close()
      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(key, true, false, true), 'm', false)
    end
  end
  local handlers = {
    ['<MouseMove>'] = hover, ['<LeftMouse>'] = click,
    ['<ScrollWheelUp>'] = function() wheel(-1, '<ScrollWheelUp>') end,
    ['<ScrollWheelDown>'] = function() wheel(1, '<ScrollWheelDown>') end,
    ['<Up>'] = function() move(-1) end, ['<Down>'] = function() move(1) end,
    ['<CR>'] = activate, ['<Esc>'] = close,
  }
  for _, map_mode in ipairs({ 'n', 'x', 'i' }) do
    for key, callback in pairs(handlers) do
      local maps = {}
      for _, mapping in ipairs(vim.api.nvim_buf_get_keymap(src_buf, map_mode)) do
        if vim.api.nvim_replace_termcodes(mapping.lhs, true, false, true)
          == vim.api.nvim_replace_termcodes(key, true, false, true) then maps[#maps + 1] = mapping end
      end
      saved[#saved + 1] = { mode = map_mode, key = key, maps = maps }
      vim.keymap.set(map_mode, key, callback, { buffer = src_buf, silent = true, nowait = true })
    end
  end
  vim.api.nvim_create_autocmd({ 'BufLeave', 'WinLeave' }, { group = group, buffer = src_buf, callback = close })
  vim.api.nvim_create_autocmd('WinClosed', { group = group, pattern = tostring(win), callback = close })
  select(1)
end
return M
