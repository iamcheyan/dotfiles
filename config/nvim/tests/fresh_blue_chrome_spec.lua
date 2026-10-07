-- Bars and menus use Fresh Nostalgia; document surfaces stay Neovim Blue.
-- Run: nvim --headless -u NONE -l config/nvim/tests/fresh_blue_chrome_spec.lua
local this_file = debug.getinfo(1, "S").source:sub(2)
local nvim_root = vim.fn.fnamemodify(this_file, ":h:h")
vim.opt.runtimepath:prepend(nvim_root)
package.path = nvim_root .. "/lua/?.lua;" .. nvim_root .. "/lua/?/init.lua;" .. package.path
vim.cmd("filetype plugin indent on")
dofile(nvim_root .. "/lua/config/options.lua")

local ui = require("config.ui_highlights")
local fresh = ui.nostalgia_palette()
local function color_id(value)
  if type(value) == "string" and value:match("^#%x%x%x%x%x%x$") then
    return tonumber(value:sub(2), 16)
  end
  return value
end
local expected_fresh = {
  tab_active_fg = "#000000",
  tab_active_bg = "#aaaaaa",
  tab_inactive_fg = "#ffff55",
  tab_inactive_bg = "#000080",
  tab_separator_bg = "#0000aa",
  status_bar_fg = "#000000",
  status_bar_bg = "#00aaaa",
  status_palette_fg = "#ffffff",
  status_palette_bg = "#00aa00",
}
for key, value in pairs(expected_fresh) do
  assert(fresh[key] == value, "Fresh Nostalgia palette mismatch for " .. key)
end

local blue_groups = {
  "Normal", "NormalNC", "CursorLine", "ColorColumn", "LineNr", "LineNrAbove",
  "LineNrBelow", "CursorLineNr", "SignColumn", "FoldColumn", "Visual", "VisualNOS",
  "Search", "IncSearch", "CurSearch",
  "PmenuSbar", "PmenuThumb", "NormalFloat", "FloatBorder", "Comment", "String",
  "Function", "Type", "Identifier", "Keyword", "Operator", "DiagnosticError",
  "DiagnosticWarn", "DiagnosticInfo",
}
local blue_before = {}
for _, name in ipairs(blue_groups) do
  blue_before[name] = vim.api.nvim_get_hl(0, { name = name, link = false })
end
local blue_tab_selected = vim.api.nvim_get_hl(0, { name = "TabLineSel", link = false })
local document_bg = blue_before.Normal.bg
assert(vim.g.colors_name == "blue", "default colorscheme should remain Blue")
assert(document_bg == tonumber("000087", 16), "document background must remain #000087")

ui.apply()
for _, name in ipairs(blue_groups) do
  local current = vim.api.nvim_get_hl(0, { name = name, link = false })
  assert(vim.deep_equal(current, blue_before[name]), name .. " must remain on the built-in Blue colors")
end
assert(vim.api.nvim_get_hl(0, { name = "Normal", link = false }).bg == document_bg, "document background must remain unchanged")

local tabs = ui.bufferline_highlights()
assert(tabs.fill.bg == color_id(fresh.tab_separator_bg), "topbar fill should use Fresh Nostalgia")
assert(tabs.buffer.bg == color_id(fresh.tab_inactive_bg) and tabs.buffer.fg == color_id(fresh.tab_inactive_fg), "inactive tabs should use Fresh Nostalgia")
assert(tabs.buffer_selected.bg == color_id(fresh.tab_active_bg) and tabs.buffer_selected.fg == color_id(fresh.tab_active_fg), "active tab should use Fresh Nostalgia")
assert(tabs.buffer_selected.bold == false, "active tab should not be bold")
local tabline = vim.api.nvim_get_hl(0, { name = "TabLine", link = false })
local tabline_fill = vim.api.nvim_get_hl(0, { name = "TabLineFill", link = false })
local tabline_selected = vim.api.nvim_get_hl(0, { name = "TabLineSel", link = false })
assert(tabline.bg == color_id(fresh.tab_separator_bg) and tabline_fill.bg == color_id(fresh.tab_separator_bg), "native topbar should use Fresh Nostalgia")
assert(tabline_selected.bg == color_id(fresh.tab_active_bg) and tabline_selected.fg == color_id(fresh.tab_active_fg), "active native tab should use Fresh Nostalgia")
local winbar = vim.api.nvim_get_hl(0, { name = "WinBar", link = false })
local winbar_nc = vim.api.nvim_get_hl(0, { name = "WinBarNC", link = false })
assert(winbar.bg == color_id(fresh.tab_active_bg) and winbar.fg == color_id(fresh.tab_active_fg), "context WinBar should match the active tab")
assert(winbar_nc.bg == color_id(fresh.tab_inactive_bg) and winbar_nc.fg == color_id(fresh.tab_inactive_fg), "inactive context WinBar should match the inactive tab")
local bufferline_selected = vim.api.nvim_get_hl(0, { name = "BufferLineBufferSelected", link = false })
assert(bufferline_selected.bg == color_id(fresh.tab_active_bg) and bufferline_selected.fg == color_id(fresh.tab_active_fg), "bufferline active tab should use Fresh Nostalgia")
assert(bufferline_selected.bold ~= true, "bufferline active tab should not be bold")

local status = vim.api.nvim_get_hl(0, { name = "StatusLine", link = false })
local status_nc = vim.api.nvim_get_hl(0, { name = "StatusLineNC", link = false })
assert(status.bg == color_id(fresh.status_bar_bg) and status.fg == color_id(fresh.status_bar_fg), "bottom bar should use Fresh Nostalgia")
assert(status_nc.bg == color_id(fresh.status_bar_bg) and status_nc.fg == color_id(fresh.status_bar_fg), "inactive bottom bar should use Fresh Nostalgia")
assert(status.bold ~= true and status_nc.bold ~= true, "bottom bars should not be bold")
local status_accent = vim.api.nvim_get_hl(0, { name = "FreshStatusLineAccent", link = false })
assert(status_accent.bg == color_id(fresh.status_palette_bg) and status_accent.fg == color_id(fresh.status_palette_fg), "bottom-bar accent should use Fresh Nostalgia green/white")
local status_warning = vim.api.nvim_get_hl(0, { name = "FreshStatusLineWarning", link = false })
assert(status_warning.bg == color_id(fresh.status_warning_indicator_bg) and status_warning.fg == color_id(fresh.status_warning_indicator_fg), "bottom-bar warning should use Fresh Nostalgia")

assert(vim.api.nvim_get_hl(0, { name = "SatelliteBackground", link = false }).bg == tonumber("25252a", 16), "scrollbar track should remain Blue")
assert(vim.api.nvim_get_hl(0, { name = "SatelliteBar", link = false }).bg == blue_tab_selected.bg, "scrollbar thumb should remain Blue")

local heirline_spec = dofile(nvim_root .. "/lua/plugins/heirline.lua")[1]
local statusline_opts = heirline_spec.opts().statusline
local statusline_style = statusline_opts.hl()
assert(color_id(statusline_style.bg) == color_id(fresh.status_bar_bg), "Heirline bottom bar should use Fresh Nostalgia")
assert(color_id(statusline_style.fg) == color_id(fresh.status_bar_fg), "Heirline bottom-bar text should use Fresh Nostalgia")
assert(statusline_style.bold == false, "Heirline bottom bar should not be bold")
local right_info
local function find_right_info(components)
  for _, component in ipairs(components) do
    if type(component) == "table" then
      if component.hl == "FreshStatusLineAccent" and #component > 0 then
        right_info = component
        return
      end
      find_right_info(component)
      if right_info then return end
    end
  end
end
find_right_info(statusline_opts)
assert(right_info, "right status information should share one Fresh green group")
assert(right_info[1].provider == " " and right_info[#right_info].provider == " ", "right status block should have green padding on both edges")
local mode_component = right_info[9]
assert(mode_component and mode_component.on_click.name == "heirline_mode_menu", "mode segment should remain in the right status block")
assert(mode_component.hl({ mode = "n", _pressed = false }) == "FreshStatusLineAccent", "mode segment should share Fresh green")

print("fresh_blue_chrome_spec: OK")
