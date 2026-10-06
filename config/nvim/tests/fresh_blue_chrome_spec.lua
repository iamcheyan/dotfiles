-- Headless check that Blue keeps the document surface while Fresh styles the UI chrome.
-- Run: nvim --headless -u NONE -l config/nvim/tests/fresh_blue_chrome_spec.lua
local this_file = debug.getinfo(1, "S").source:sub(2)
local nvim_root = vim.fn.fnamemodify(this_file, ":h:h")
vim.opt.runtimepath:prepend(nvim_root)
package.path = nvim_root .. "/lua/?.lua;" .. nvim_root .. "/lua/?/init.lua;" .. package.path
vim.cmd("filetype plugin indent on")
dofile(nvim_root .. "/lua/config/options.lua")

local fresh = require("theme.high-contrast-plus").palette
local ui = require("config.ui_highlights")
local function color_id(value)
  if type(value) == "string" and value:match("^#%x%x%x%x%x%x$") then
    return tonumber(value:sub(2), 16)
  end
  return value
end
ui.apply()
local normal = vim.api.nvim_get_hl(0, { name = "Normal", link = false })
assert(vim.g.colors_name == "blue", "default colorscheme should stay Blue")
assert(normal.bg == tonumber("000087", 16), "the editor document background must remain #000087")

local tabs = ui.bufferline_highlights()
assert(tabs.fill.bg == color_id(fresh.tab_separator_bg), "topbar fill should use Fresh's separator background")
assert(tabs.buffer_selected.bold == false, "topbar selected tab should not be bold")
ui.apply()
local actual_tabline = vim.api.nvim_get_hl(0, { name = "TabLine", link = false })
local actual_tabline_fill = vim.api.nvim_get_hl(0, { name = "TabLineFill", link = false })
local actual_tabline_selected = vim.api.nvim_get_hl(0, { name = "TabLineSel", link = false })
assert(actual_tabline.bg == color_id(fresh.tab_separator_bg), "Neovim topbar inactive surface should use Fresh separator gray")
assert(actual_tabline_fill.bg == color_id(fresh.tab_separator_bg), "Neovim topbar fill should use Fresh separator gray")
assert(actual_tabline_selected.bg == color_id(fresh.tab_active_bg), "Neovim active tab should use Fresh yellow")
assert(actual_tabline_selected.fg == color_id(fresh.tab_active_fg), "Neovim active tab text should use Fresh black")
assert(actual_tabline_selected.bold ~= true, "Neovim active tab should not be bold")

local status = vim.api.nvim_get_hl(0, { name = "StatusLine", link = false })
assert(status.bg == color_id(fresh.menu_highlight_bg), "bottom bar should use Fresh's blue surface")
assert(status.fg == color_id(fresh.menu_highlight_fg), "bottom bar text should use Fresh's white foreground")
assert(status.bold ~= true, "bottom bar must not be bold")

local popup = vim.api.nvim_get_hl(0, { name = "Pmenu", link = false })
local popup_selected = vim.api.nvim_get_hl(0, { name = "PmenuSel", link = false })
local popup_border = vim.api.nvim_get_hl(0, { name = "PmenuBorder", link = false })
local scrollbar_track = vim.api.nvim_get_hl(0, { name = "SatelliteBackground", link = false })
local scrollbar_thumb = vim.api.nvim_get_hl(0, { name = "SatelliteBar", link = false })
assert(popup.bg == color_id(fresh.menu_dropdown_bg) and popup.fg == color_id(fresh.menu_dropdown_fg), "dropdown should use Fresh's menu surface")
assert(scrollbar_track.bg == color_id(fresh.scrollbar_track_fg), "scrollbar track should use Fresh gray")
assert(scrollbar_thumb.bg == color_id(fresh.scrollbar_thumb_fg), "scrollbar thumb should use Fresh yellow")
assert(popup_selected.bg == color_id(fresh.menu_highlight_bg) and popup_selected.fg == color_id(fresh.menu_highlight_fg), "dropdown selection should use Fresh's blue highlight")
assert(popup_border.fg == color_id(fresh.menu_border_fg), "dropdown border should use Fresh's border accent")

local normal_mode = ui.fresh_normal_style()
assert(normal_mode.bg == fresh.diff_add_bg, "NORMAL mode should use Fresh's green background")
assert(normal_mode.fg == "#ffffff", "NORMAL mode should use white text")
assert(normal_mode.bold == false, "NORMAL mode should not be bold")
local insert_mode = ui.fresh_mode_style("i")
assert(insert_mode.bg == fresh.menu_highlight_bg and insert_mode.fg == fresh.menu_highlight_fg, "other modes should use Fresh's blue status surface")
assert(insert_mode.bold == false, "other status modes should not be bold")

local heirline_spec = dofile(nvim_root .. "/lua/plugins/heirline.lua")[1]
local heirline_opts = heirline_spec.opts()
local statusline_opts = heirline_opts.statusline
local statusline_style = statusline_opts.hl()
assert(color_id(statusline_style.bg) == color_id(fresh.menu_highlight_bg), "Heirline bottom bar must actually use Fresh blue")
assert(statusline_style.bold ~= true, "Heirline bottom bar must not be bold")
local mode_component
for _, component in ipairs(statusline_opts) do
  if type(component) == "table" and component.on_click and component.on_click.name == "heirline_mode_menu" then
    mode_component = component
    break
  end
end
assert(mode_component, "Heirline mode segment should be present")
local mode_state = { mode = "n", _pressed = false }
local actual_normal = mode_component.hl(mode_state)
assert(actual_normal == "FreshStatusLineNormal", "Heirline NORMAL segment should use Fresh's green highlight group")
local normal_hl = vim.api.nvim_get_hl(0, { name = actual_normal, link = false })
assert(normal_hl.bg == color_id(normal_mode.bg) and normal_hl.fg == color_id(normal_mode.fg), "Heirline NORMAL segment must use Fresh green/white")
for _, child in ipairs(mode_component) do
  if type(child) == "table" and type(child.hl) == "function" then
    assert(child.hl(mode_state) == "FreshStatusLineNormal", "NORMAL icon/text should use the same green/white highlight")
  end
end

print("fresh_blue_chrome_spec: OK")
