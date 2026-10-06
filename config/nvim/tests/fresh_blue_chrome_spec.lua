-- Match Neovim Blue's UI chrome to Fresh 0.5.0's built-in Nostalgia theme.
-- Keep the editor's built-in Blue document background unchanged.
-- Run: nvim --headless -u NONE -l config/nvim/tests/fresh_blue_chrome_spec.lua
local this_file = debug.getinfo(1, "S").source:sub(2)
local nvim_root = vim.fn.fnamemodify(this_file, ":h:h")
vim.opt.runtimepath:prepend(nvim_root)
package.path = nvim_root .. "/lua/?.lua;" .. nvim_root .. "/lua/?/init.lua;" .. package.path
vim.cmd("filetype plugin indent on")
dofile(nvim_root .. "/lua/config/options.lua")

-- Fresh's built-in nostalgia.json in the installed Fresh v0.5.0 source.
local fresh = {
  editor_bg = "#0000aa",
  editor_fg = "#ffff55",
  cursor = "#ffffff",
  selection_bg = "#1e1ec8",
  current_line_bg = "#000080",
  line_number_fg = "#55ffff",
  line_number_bg = "#0000aa",
  whitespace_indicator_fg = "#000064",
  tab_active_fg = "#000000",
  tab_active_bg = "#aaaaaa",
  tab_inactive_fg = "#ffff55",
  tab_inactive_bg = "#000080",
  tab_separator_bg = "#0000aa",
  menu_bg = "#aaaaaa",
  menu_fg = "#000000",
  menu_highlight_bg = "#00aa00",
  menu_highlight_fg = "#ffffff",
  popup_bg = "#0000aa",
  popup_text_fg = "#ffff55",
  popup_selection_bg = "#00aa00",
  popup_border_fg = "#ffffff",
  status_bar_bg = "#00aaaa",
  status_bar_fg = "#000000",
  status_palette_bg = "#00aa00",
  status_palette_fg = "#ffffff",
  status_warning_indicator_bg = "#aa5500",
  status_warning_indicator_fg = "#ffffff",
  status_error_indicator_bg = "#aa0000",
  status_error_indicator_fg = "#ffffff",
  scrollbar_track_fg = "#000080",
  scrollbar_thumb_fg = "#aaaaaa",
  search_match_bg = "#aa5500",
  search_match_fg = "#ffffff",
  diag_error_fg = "#ff5555",
  diag_warning_fg = "#ffff55",
  diag_info_fg = "#55ffff",
  diag_hint_fg = "#aaaaaa",
  syntax_keyword = "#ffffff",
  syntax_string = "#00ffff",
  syntax_comment = "#808080",
  syntax_function = "#ffff00",
  syntax_type = "#00ff00",
  syntax_variable = "#ffff55",
  syntax_constant = "#ff00ff",
  syntax_operator = "#aaaaaa",
}
local function color_id(value)
  if type(value) == "string" and value:match("^#%x%x%x%x%x%x$") then
    return tonumber(value:sub(2), 16)
  end
  return value
end
local ui = require("config.ui_highlights")
local actual_palette = ui.nostalgia_palette()
for key, value in pairs(fresh) do
  assert(actual_palette[key] == value, "Nvim Fresh palette mismatch for " .. key)
end
ui.apply()

local normal = vim.api.nvim_get_hl(0, { name = "Normal", link = false })
assert(vim.g.colors_name == "blue", "default colorscheme should stay Blue")
assert(normal.bg == tonumber("000087", 16), "document background must remain #000087")
assert(normal.fg == color_id(fresh.editor_fg), "document text should use Fresh Nostalgia yellow")
local line_nr = vim.api.nvim_get_hl(0, { name = "LineNr", link = false })
local cursor_line = vim.api.nvim_get_hl(0, { name = "CursorLine", link = false })
local visual = vim.api.nvim_get_hl(0, { name = "Visual", link = false })
assert(line_nr.fg == color_id(fresh.line_number_fg) and line_nr.bg == color_id(fresh.line_number_bg), "gutter should use Fresh Nostalgia colors")
assert(cursor_line.bg == color_id(fresh.current_line_bg), "current line should use Fresh Nostalgia navy")
assert(visual.bg == color_id(fresh.selection_bg), "selection should use Fresh Nostalgia blue")
for group, key in pairs({ Comment = "syntax_comment", String = "syntax_string", Function = "syntax_function", Type = "syntax_type", Identifier = "syntax_variable", Keyword = "syntax_keyword", Operator = "syntax_operator" }) do
  assert(vim.api.nvim_get_hl(0, { name = group, link = false }).fg == color_id(fresh[key]), "syntax group " .. group .. " should match Fresh Nostalgia")
end
local search = vim.api.nvim_get_hl(0, { name = "Search", link = false })
assert(search.bg == color_id(fresh.search_match_bg) and search.fg == color_id(fresh.search_match_fg), "search should use Fresh Nostalgia colors")

local tabs = ui.bufferline_highlights()
assert(tabs.fill.bg == color_id(fresh.tab_separator_bg), "topbar fill should use Fresh Nostalgia's blue")
assert(tabs.buffer.bg == color_id(fresh.tab_inactive_bg), "inactive tab should use Fresh Nostalgia blue")
assert(tabs.buffer.fg == color_id(fresh.tab_inactive_fg), "inactive tab text should use Fresh Nostalgia yellow")
assert(tabs.buffer_selected.bg == color_id(fresh.tab_active_bg), "active tab should use Fresh Nostalgia gray")
assert(tabs.buffer_selected.fg == color_id(fresh.tab_active_fg), "active tab text should use Fresh Nostalgia black")
assert(tabs.buffer_selected.bold == false, "active tab should not be bold")

local tabline = vim.api.nvim_get_hl(0, { name = "TabLine", link = false })
local tabline_fill = vim.api.nvim_get_hl(0, { name = "TabLineFill", link = false })
local tabline_selected = vim.api.nvim_get_hl(0, { name = "TabLineSel", link = false })
assert(tabline.bg == color_id(fresh.tab_separator_bg), "Neovim tabline should use Fresh Nostalgia blue")
assert(tabline_fill.bg == color_id(fresh.tab_separator_bg), "Neovim tabline fill should use Fresh Nostalgia blue")
assert(tabline_selected.bg == color_id(fresh.tab_active_bg) and tabline_selected.fg == color_id(fresh.tab_active_fg), "active tabline should use Fresh Nostalgia gray/black")
local bufferline_selected = vim.api.nvim_get_hl(0, { name = "BufferLineBufferSelected", link = false })
local bufferline_fill = vim.api.nvim_get_hl(0, { name = "BufferLineFill", link = false })
assert(bufferline_selected.bg == color_id(fresh.tab_active_bg) and bufferline_selected.fg == color_id(fresh.tab_active_fg), "bufferline active tab should use Fresh Nostalgia gray/black")
assert(bufferline_selected.bold ~= true, "bufferline active tab should not be bold")
assert(bufferline_fill.bg == color_id(fresh.tab_separator_bg), "bufferline fill should use Fresh Nostalgia blue")
local winbar = vim.api.nvim_get_hl(0, { name = "WinBar", link = false })
local winbar_nc = vim.api.nvim_get_hl(0, { name = "WinBarNC", link = false })
assert(winbar.bg == color_id(fresh.tab_active_bg) and winbar.fg == color_id(fresh.tab_active_fg), "active winbar should use Fresh Nostalgia active-tab colors")
assert(winbar_nc.bg == color_id(fresh.tab_inactive_bg) and winbar_nc.fg == color_id(fresh.tab_inactive_fg), "inactive winbar should use Fresh Nostalgia inactive-tab colors")

local status = vim.api.nvim_get_hl(0, { name = "StatusLine", link = false })
local status_nc = vim.api.nvim_get_hl(0, { name = "StatusLineNC", link = false })
assert(status.bg == color_id(fresh.status_bar_bg) and status.fg == color_id(fresh.status_bar_fg), "bottom bar should use Fresh Nostalgia cyan/black")
assert(status_nc.bg == color_id(fresh.status_bar_bg) and status_nc.fg == color_id(fresh.status_bar_fg), "inactive bottom bar should match Fresh Nostalgia status colors")
assert(status.bold ~= true and status_nc.bold ~= true, "bottom bars should not be bold")
local status_accent = vim.api.nvim_get_hl(0, { name = "FreshStatusLineAccent", link = false })
local status_warning = vim.api.nvim_get_hl(0, { name = "FreshStatusLineWarning", link = false })
local status_error = vim.api.nvim_get_hl(0, { name = "FreshStatusLineError", link = false })
assert(status_accent.bg == color_id(fresh.status_palette_bg) and status_accent.fg == color_id(fresh.status_palette_fg), "status accent should use Fresh Nostalgia green/white")
assert(status_warning.bg == color_id(fresh.status_warning_indicator_bg) and status_warning.fg == color_id(fresh.status_warning_indicator_fg), "status warning should use Fresh Nostalgia warning colors")
assert(status_error.bg == color_id(fresh.status_error_indicator_bg) and status_error.fg == color_id(fresh.status_error_indicator_fg), "status error should use Fresh Nostalgia error colors")

local popup = vim.api.nvim_get_hl(0, { name = "Pmenu", link = false })
local popup_selected = vim.api.nvim_get_hl(0, { name = "PmenuSel", link = false })
local popup_border = vim.api.nvim_get_hl(0, { name = "PmenuBorder", link = false })
assert(popup.bg == color_id(fresh.popup_bg) and popup.fg == color_id(fresh.popup_text_fg), "popup should use Fresh Nostalgia blue/yellow")
assert(popup_selected.bg == color_id(fresh.popup_selection_bg) and popup_selected.fg == color_id(fresh.status_palette_fg), "popup selection should use Fresh Nostalgia green/white")
assert(popup_border.bg == color_id(fresh.popup_bg) and popup_border.fg == color_id(fresh.popup_border_fg), "popup border should use Fresh Nostalgia popup colors")
local scrollbar_track = vim.api.nvim_get_hl(0, { name = "SatelliteBackground", link = false })
local scrollbar_thumb = vim.api.nvim_get_hl(0, { name = "SatelliteBar", link = false })
assert(scrollbar_track.bg == color_id(fresh.scrollbar_track_fg), "scrollbar track should use Fresh Nostalgia blue")
assert(scrollbar_thumb.bg == color_id(fresh.scrollbar_thumb_fg), "scrollbar thumb should use Fresh Nostalgia gray")

local normal_mode = ui.fresh_normal_style()
assert(color_id(normal_mode.bg) == color_id(fresh.status_palette_bg), "NORMAL mode should use Fresh Nostalgia green")
assert(color_id(normal_mode.fg) == color_id(fresh.status_palette_fg), "NORMAL mode should use Fresh Nostalgia white")
assert(normal_mode.bold == false, "NORMAL mode should not be bold")

local heirline_spec = dofile(nvim_root .. "/lua/plugins/heirline.lua")[1]
local statusline_opts = heirline_spec.opts().statusline
local statusline_style = statusline_opts.hl()
assert(color_id(statusline_style.bg) == color_id(fresh.status_bar_bg), "Heirline must actually use Fresh Nostalgia status background")
assert(color_id(statusline_style.fg) == color_id(fresh.status_bar_fg), "Heirline must actually use Fresh Nostalgia status foreground")
assert(statusline_style.bold == false, "Heirline statusline must not be bold")
local mode_component
for _, component in ipairs(statusline_opts) do
  if type(component) == "table" and component.on_click and component.on_click.name == "heirline_mode_menu" then
    mode_component = component
    break
  end
end
assert(mode_component and mode_component.hl({ mode = "n", _pressed = false }) == "FreshStatusLineNormal", "Heirline NORMAL segment should use Fresh Nostalgia's green highlight")

print("fresh_blue_chrome_spec: OK")
