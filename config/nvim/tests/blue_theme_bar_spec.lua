-- Verify the default colorscheme and readable bar colors using real theme groups.
-- Run: nvim --headless -u NONE -l config/nvim/tests/blue_theme_bar_spec.lua
local this_file = debug.getinfo(1, "S").source:sub(2)
local nvim_root = vim.fn.fnamemodify(this_file, ":h:h")
vim.opt.runtimepath:prepend(nvim_root)
package.path = nvim_root .. "/lua/?.lua;" .. nvim_root .. "/lua/?/init.lua;" .. package.path
vim.cmd("filetype plugin indent on")
dofile(nvim_root .. "/lua/config/options.lua")
assert(vim.g.colors_name == "blue", "Neovim should start with the built-in blue colorscheme")

local ui = require("config.ui_highlights")
ui.apply()

local function luminance(color)
  local function channel(v)
    v = v / 255
    return v <= 0.04045 and v / 12.92 or ((v + 0.055) / 1.055) ^ 2.4
  end
  local r = math.floor(color / 65536) % 256
  local g = math.floor(color / 256) % 256
  local b = color % 256
  return 0.2126 * channel(r) + 0.7152 * channel(g) + 0.0722 * channel(b)
end

local function contrast(fg, bg)
  local l1, l2 = luminance(fg), luminance(bg)
  if l1 < l2 then l1, l2 = l2, l1 end
  return (l1 + 0.05) / (l2 + 0.05)
end

local function readable(name, fg, bg)
  assert(fg and bg and contrast(fg, bg) >= 4.5, name .. " bar text lacks contrast")
end

local tabs = ui.bufferline_highlights()
local title_active = vim.api.nvim_get_hl(0, { name = "TitleBar", link = false })
local title_inactive = vim.api.nvim_get_hl(0, { name = "TitleBarNC", link = false })
local normal = vim.api.nvim_get_hl(0, { name = "Normal", link = false })
assert(luminance(tabs.fill.bg) < luminance(title_inactive.bg), "top-bar fill should be darker than the blue theme's inactive title surface")
assert(luminance(tabs.buffer_selected.bg) < luminance(title_active.bg), "selected tab should be darker than the blue theme's active title surface")
assert(tabs.fill.bg ~= normal.bg, "top-bar fill should remain distinct from the document background")
for _, name in ipairs({ "fill", "buffer", "buffer_visible", "buffer_selected" }) do
  readable("BufferLine " .. name, tabs[name].fg, tabs[name].bg)
end
for _, name in ipairs({ "WinBar", "WinBarNC", "StatusLine", "StatusLineNC" }) do
  local hl = vim.api.nvim_get_hl(0, { name = name, link = false })
  readable(name, hl.fg, hl.bg)
end
local status_active = vim.api.nvim_get_hl(0, { name = "StatusLine", link = false })
local status_inactive = vim.api.nvim_get_hl(0, { name = "StatusLineNC", link = false })
local winbar_active = vim.api.nvim_get_hl(0, { name = "WinBar", link = false })
local winbar_inactive = vim.api.nvim_get_hl(0, { name = "WinBarNC", link = false })
assert(luminance(status_active.bg) < luminance(title_active.bg), "bottom statusline should be darker than the blue theme's active title surface")
assert(luminance(status_inactive.bg) < luminance(title_inactive.bg), "inactive statusline should be darker than the blue theme's inactive title surface")
assert(status_active.bg ~= normal.bg and status_inactive.bg ~= normal.bg, "bottom bars should be distinct from the document background")
assert(luminance(winbar_active.bg) < luminance(title_active.bg) and luminance(winbar_inactive.bg) < luminance(title_inactive.bg), "window bars should be darker than the title surfaces")

-- Runtime theme switching should keep the existing high-contrast theme legible too.
vim.cmd.colorscheme("high-contrast-plus")
ui.apply()
tabs = ui.bufferline_highlights()
for _, name in ipairs({ "fill", "buffer", "buffer_visible", "buffer_selected" }) do
  readable("High Contrast BufferLine " .. name, tabs[name].fg, tabs[name].bg)
end
for _, name in ipairs({ "WinBar", "WinBarNC", "StatusLine", "StatusLineNC" }) do
  local hl = vim.api.nvim_get_hl(0, { name = name, link = false })
  readable("High Contrast " .. name, hl.fg, hl.bg)
end

print("blue_theme_bar_spec: OK")
