-- Native tabline click callbacks fire on mouse-down. Paint only that target,
-- deriving its pressed colors from the current theme on each redraw.
local M = { active = nil, generation = 0 }
function M.press(handler, id)
  M.generation = M.generation + 1
  local generation = M.generation
  M.active = handler .. ':' .. tostring(id or 0)
  vim.cmd('redrawtabline')
  if M.on_redraw then M.on_redraw() end
  vim.defer_fn(function()
    if M.generation == generation then
      M.active = nil
      vim.cmd('redrawtabline')
      if M.on_redraw then M.on_redraw() end
    end
  end, 220)
end
function M.paint(line, active, base_group)
  active = active or M.active
  if not active then return line end
  local target, group = nil, base_group or 'TabLine'
  local function highlight(name)
    local selected = active:match('^___bufferline_private%.handle_click:')
      and 'BufferLineBufferSelected' or 'FreshStatusLineAccent'
    local colors = vim.api.nvim_get_hl(0, { name = selected, link = false })
    -- Keep the breadcrumb's positioning marker visible to its popup locator.
    local pressed = name == 'ContextlineActiveMenu' and name or ('BarPressed' .. name)
    vim.api.nvim_set_hl(0, pressed, { fg = colors.fg, bg = colors.bg, bold = false })
    return '%#' .. pressed .. '#'
  end
  return (line:gsub('%%[^%%]*', function(token)
    -- Stop at the end of each statusline control token, preserving its text.
    local name, tail = token:match('^%%#([^#]+)#(.*)$')
    if name then
      group = name
      if name == "BufferLineFill" then target = nil end
      return (target == active and highlight(group) or '%#' .. group .. '#') .. tail
    end
    local id, handler, rest = token:match('^%%(%d*)@v:lua%.([^@]+)@(.*)$')
    if handler then
      target = handler .. ':' .. tostring(tonumber(id) or 0)
      return '%' .. id .. '@v:lua.' .. handler .. '@'
        .. (target == active and highlight(group) or '%#' .. group .. '#') .. rest
    end
    if token:sub(1, 2) == '%*' then
      group = base_group or 'TabLine'
      return (target == active and highlight(group) or '%*') .. token:sub(3)
    end
    local ending, rest_end = token:match('^%%([XT])(.*)$')
    if ending then
      target = nil
      return '%' .. ending .. '%#' .. group .. '#' .. rest_end
    end
    return token
  end))
end
return M
