local this_file = debug.getinfo(1, "S").source:sub(2)
local nvim_root = vim.fn.fnamemodify(this_file, ":h:h")
vim.opt.runtimepath:prepend(nvim_root)
package.path = nvim_root .. "/lua/?.lua;" .. nvim_root .. "/lua/?/init.lua;" .. package.path

local drag = require("config.bufferline_drag")

local components = {
  { id = 11, length = 5 },
  { id = 22, length = 7 },
  { id = 33, length = 4 },
}
assert(drag.element_at_column(components, 3, 3) == components[1], "left boundary belongs to first tab")
assert(drag.element_at_column(components, 3, 7) == components[1], "right edge before next tab belongs to first tab")
assert(drag.element_at_column(components, 3, 8) == components[2], "next tab begins at the next column")
assert(drag.element_at_column(components, 3, 19) == nil, "columns after the last tab are not draggable targets")
assert(drag.element_at_column(components, 3, nil) == nil, "unknown columns are not draggable targets")

local function fake_bufferline(ids)
  local api = {}
  api.get_elements = function()
    local elements = {}
    for _, id in ipairs(ids) do elements[#elements + 1] = { id = id } end
    return { elements = elements }
  end
  api.move_to = function(to_index, from_index)
    ids[to_index], ids[from_index] = ids[from_index], ids[to_index]
  end
  return api, ids
end

local api, ids = fake_bufferline({ 11, 22, 33, 44 })
assert(drag.move_to_element(api, 11, 33), "drag should move the source tab")
assert(vim.deep_equal(ids, { 22, 33, 11, 44 }), "dragging over a later tab inserts source after crossed tabs")

api, ids = fake_bufferline({ 11, 22, 33, 44 })
assert(drag.move_to_element(api, 44, 22), "drag should move a tab left")
assert(vim.deep_equal(ids, { 11, 44, 22, 33 }), "dragging over an earlier tab preserves the crossed order")

api, ids = fake_bufferline({ 11, 22, 33 })
assert(not drag.move_to_element(api, 22, 22), "dragging onto the source tab is a no-op")
assert(vim.deep_equal(ids, { 11, 22, 33 }), "same-tab drag leaves ordering unchanged")
assert(not drag.move_to_element(api, 99, 22), "missing source must be ignored")
assert(not drag.move_to_element(api, 22, 99), "missing target must be ignored")

assert(not drag.begin_drag(components[1], { screenrow = 1 }), "incomplete mouse coordinates do not start a drag")
assert(not drag.finish_drag(), "invalid mouse coordinates leave no active drag")
assert(drag.begin_drag(components[1], { screenrow = 1, screencol = 3 }), "tab press starts drag tracking")
assert(not drag.drag_to(components[1], { screenrow = 1, screencol = 4 }), "one-column hand jitter remains a click")
assert(not drag.finish_drag(), "a click without a real drag should preserve the normal click action")

api, ids = fake_bufferline({ 11, 22, 33 })
assert(drag.begin_drag(components[1], { screenrow = 1, screencol = 3 }), "source tab can be picked up")
local moved, source_id, target_id = drag.drag_to(components[2], { screenrow = 1, screencol = 8 })
assert(moved and source_id == 11 and target_id == 22, "crossing the drag threshold identifies source and destination")
assert(drag.move_to_element(api, source_id, target_id), "drag target can be applied through BufferLine")
assert(vim.deep_equal(ids, { 22, 11, 33 }), "drag state reorders across a target tab")
assert(drag.finish_drag(), "release after a real drag is distinguishable from a click")

print("bufferline_drag_reorder_spec: OK")
