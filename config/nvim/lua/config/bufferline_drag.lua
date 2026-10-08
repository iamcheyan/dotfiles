local M = {
  _namespace = nil,
  _drag = nil,
}

local keycodes = {}
for _, name in ipairs({ "<LeftMouse>", "<LeftDrag>", "<LeftRelease>" }) do
  keycodes[vim.api.nvim_replace_termcodes(name, true, false, true)] = name
end

---Return the visible BufferLine component under a tabline column.
---@param components table[]
---@param left_offset integer
---@param column integer
---@return table|nil
function M.element_at_column(components, left_offset, column)
  if type(column) ~= "number" then return nil end
  local start = tonumber(left_offset) or 0
  for _, component in ipairs(components or {}) do
    local width = tonumber(component.length) or 0
    if width > 0 and column >= start and column < start + width then
      return component
    end
    start = start + width
  end
end

---Move a source element to the target's position while preserving intervening order.
---@param bufferline table
---@param source_id integer
---@param target_id integer
---@return boolean
function M.move_to_element(bufferline, source_id, target_id)
  if source_id == nil or target_id == nil or source_id == target_id then return false end

  local ok, result = pcall(bufferline.get_elements)
  if not ok or type(result) ~= "table" or type(result.elements) ~= "table" then return false end

  local source_index, target_index
  for index, element in ipairs(result.elements) do
    if element.id == source_id then source_index = index end
    if element.id == target_id then target_index = index end
  end
  if not source_index or not target_index or source_index == target_index then return false end

  if source_index < target_index then
    for index = source_index, target_index - 1 do
      bufferline.move_to(index + 1, index)
    end
  else
    for index = source_index, target_index + 1, -1 do
      bufferline.move_to(index - 1, index)
    end
  end
  return true
end

function M.begin_drag(element, position)
  if not element or not element.id or not position
    or type(position.screenrow) ~= "number" or type(position.screencol) ~= "number" then
    M._drag = nil
    return false
  end
  M._drag = {
    source_id = element.id,
    last_target_id = element.id,
    start_row = position.screenrow,
    start_col = position.screencol,
    moved = false,
  }
  return true
end

local function advance_drag(drag, element, position)
  if not drag or not position then return false end
  local distance = math.abs((position.screenrow or drag.start_row) - drag.start_row)
    + math.abs((position.screencol or drag.start_col) - drag.start_col)
  if not drag.moved and distance < 2 then return false end

  drag.moved = true
  local target_id = element and element.id
  if target_id and target_id ~= drag.source_id and target_id ~= drag.last_target_id then
    drag.last_target_id = target_id
    return true, drag.source_id, target_id
  end
  return true
end

---Track a mouse drag and return whether it crossed the click-jitter threshold.
---@param element table|nil
---@param position table
---@return boolean moved
---@return integer|nil source_id
---@return integer|nil target_id
function M.drag_to(element, position)
  return advance_drag(M._drag, element, position)
end

function M.finish_drag()
  local moved = M._drag and M._drag.moved or false
  M._drag = nil
  return moved
end

local function mouse_position()
  local ok, position = pcall(vim.fn.getmousepos)
  if ok then return position end
end

local function element_under_mouse(position)
  if not position or position.screenrow ~= 1 then return nil end
  local ok, state = pcall(require, "bufferline.state")
  if not ok then return nil end
  return M.element_at_column(state.visible_components, state.left_offset_size, position.screencol)
end

local function handle_key(key)
  local key_name = keycodes[key]
  if not key_name then return end
  if key_name == "<LeftMouse>" then
    local position = mouse_position()
    if position and position.screenrow == 1 then
      M.begin_drag(element_under_mouse(position), position)
    else
      M._drag = nil
    end
  elseif key_name == "<LeftDrag>" and M._drag then
    local drag = M._drag
    local position = mouse_position()
    if not advance_drag(drag, nil, position) then return end
    -- BufferLine refreshes its layout during the mouse press. Resolve this
    -- event's captured pointer position after the layout has settled.
    vim.defer_fn(function()
      local element = element_under_mouse(position)
      local moved, source_id, target_id = advance_drag(drag, element, position)
      if moved and source_id and target_id then
        local ok, bufferline = pcall(require, "bufferline")
        if ok then M.move_to_element(bufferline, source_id, target_id) end
      end
    end, 10)
    -- A drag starting in the tabline must not fall through into text selection.
    return ""
  elseif key_name == "<LeftRelease>" and M._drag then
    -- Preserve ordinary tab clicks; suppress only the release after a real drag.
    if M.finish_drag() then return "" end
  end
end

function M.setup()
  if M._namespace then return end
  if not pcall(require, "bufferline") then return end

  M._namespace = vim.api.nvim_create_namespace("BufferLineMouseDrag")
  vim.on_key(handle_key, M._namespace)
  vim.api.nvim_create_autocmd("VimLeavePre", {
    group = vim.api.nvim_create_augroup("BufferLineMouseDragCleanup", { clear = true }),
    callback = function()
      if M._namespace then
        vim.on_key(nil, M._namespace)
        M._namespace = nil
      end
      M._drag = nil
    end,
    desc = "Clear BufferLine mouse drag handler",
  })
end

return M
