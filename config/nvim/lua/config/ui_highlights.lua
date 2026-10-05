-- Theme-agnostic UI component highlights.
--
-- Plugins should consume semantic Vim highlight groups instead of reaching
-- into a particular colorscheme's private palette.  This keeps tabs and the
-- winbar readable when the colorscheme changes at runtime.

local M = {}

local function get(name)
  return vim.api.nvim_get_hl(0, { name = name, link = false })
end

-- TabLineSel may link to StatusLine. Cache the theme's original accent before
-- this adapter changes StatusLine, so repeated apply() calls keep the same thumb.
local function get_theme_scrollbar_accent()
  return get("TabLineSel").bg or get("TitleBar").bg
end
local theme_scrollbar_accent = get_theme_scrollbar_accent()

local minimum_text_contrast = 4.5

local function relative_luminance(color)
  if type(color) ~= "number" then return nil end
  local function linear(channel)
    channel = channel / 255
    return channel <= 0.04045 and channel / 12.92 or ((channel + 0.055) / 1.055) ^ 2.4
  end
  local r = math.floor(color / 65536) % 256
  local g = math.floor(color / 256) % 256
  local b = color % 256
  return 0.2126 * linear(r) + 0.7152 * linear(g) + 0.0722 * linear(b)
end

local function contrast_ratio(fg, bg)
  local fg_luminance, bg_luminance = relative_luminance(fg), relative_luminance(bg)
  if not fg_luminance or not bg_luminance then return 0 end
  if fg_luminance < bg_luminance then fg_luminance, bg_luminance = bg_luminance, fg_luminance end
  return (fg_luminance + 0.05) / (bg_luminance + 0.05)
end

local function readable_foreground(bg, ...)
  local best_fg, best_ratio, count = nil, -1, select("#", ...)
  for i = 1, count do
    local fg = select(i, ...)
    if fg then
      local ratio = contrast_ratio(fg, bg)
      if ratio > best_ratio then best_fg, best_ratio = fg, ratio end
      if ratio >= minimum_text_contrast then return fg, ratio end
    end
  end
  return best_fg, best_ratio
end

local function readable_pair(fg, bg, normal)
  local chosen_fg, ratio = readable_foreground(
    bg,
    fg,
    normal.fg,
    normal.bg,
    get("Pmenu").fg,
    get("StatusLine").fg,
    get("LineNr").fg
  )
  if ratio >= minimum_text_contrast then return chosen_fg, bg end
  if normal.fg and normal.bg and contrast_ratio(normal.fg, normal.bg) >= minimum_text_contrast then
    return normal.fg, normal.bg
  end
  return fg, bg
end

-- Keep Blue's bar hue but scale its theme-provided title surfaces to deep navy.
-- The bottom bar is intentionally a little lighter than the top bar.
local top_active_scale = 0.18
local top_inactive_scale = 0.16
local bottom_active_scale = 0.26
local bottom_inactive_scale = 0.23
local function darken_surface(color, scale)
  if type(color) ~= "number" then return color end
  local function scale_channel(channel)
    return math.floor(channel * scale + 0.5)
  end
  local r = scale_channel(math.floor(color / 65536) % 256)
  local g = scale_channel(math.floor(color / 256) % 256)
  local b = scale_channel(color % 256)
  return r * 65536 + g * 256 + b
end

local function title_bar_surfaces()
  local active = get("TitleBar")
  local inactive = get("TitleBarNC")
  return {
    active_fg = active.fg,
    active_bg = darken_surface(active.bg, top_active_scale),
    inactive_fg = inactive.fg,
    inactive_bg = darken_surface(inactive.bg, top_inactive_scale),
    status_active_fg = active.fg,
    status_active_bg = darken_surface(active.bg, bottom_active_scale),
    status_inactive_fg = inactive.fg,
    status_inactive_bg = darken_surface(inactive.bg, bottom_inactive_scale),
    scrollbar_bg = theme_scrollbar_accent or get("TabLineSel").bg or active.bg,
  }
end

local function pick_bg(...)
  for _, group in ipairs({ ... }) do
    local bg = get(group).bg
    if bg and bg ~= 0 then
      return bg
    end
  end
  return get("Normal").bg
end

local function preferred_bg(name, ...)
  local bg = get(name).bg
  -- In Neovim, color index 0 is a valid explicit black, not “unset”.
  if bg ~= nil then
    return bg
  end
  return pick_bg(...)
end

local function pick_fg(...)
  for _, group in ipairs({ ... }) do
    local fg = get(group).fg
    if fg then
      return fg
    end
  end
  return get("Normal").fg
end

local function tab_palette()
  local normal = get("Normal")
  local normal_fg = normal.fg
  local normal_bg = normal.bg
  local title_surfaces = title_bar_surfaces()
  local surface_bg = title_surfaces.inactive_bg or preferred_bg("TabLine", "StatusLine", "CursorLine", "Normal")
  local surface_fg = title_surfaces.inactive_fg or pick_fg("TabLine", "StatusLine", "Normal")
  surface_fg, surface_bg = readable_pair(surface_fg, surface_bg, normal)

  local fill_bg = title_surfaces.inactive_bg or preferred_bg("TabLineFill", "TabLine", "StatusLine", "Normal")
  if contrast_ratio(surface_fg, fill_bg) < minimum_text_contrast then
    fill_bg = surface_bg
  end

  local active = get("TabLineSel")
  local active_bg = title_surfaces.active_bg or active.bg or get("Visual").bg or surface_bg
  local active_fg = title_surfaces.active_fg or active.fg or get("Visual").fg or normal_fg
  active_fg, active_bg = readable_pair(active_fg, active_bg, normal)

  local visible_bg = title_surfaces.inactive_bg or pick_bg("CursorLine", "TabLine", "Normal")
  local visible_fg = title_surfaces.inactive_fg or pick_fg("TabLine", "StatusLineNC", "NormalNC", "Normal")
  visible_fg, visible_bg = readable_pair(visible_fg, visible_bg, normal)

  local separator_fg = pick_fg("WinSeparator", "VertSplit", "NonText", "TabLine")
  local readable_separator, separator_ratio = readable_foreground(
    surface_bg,
    separator_fg,
    normal_fg,
    normal_bg,
    get("Pmenu").fg
  )
  if separator_ratio >= minimum_text_contrast then separator_fg = readable_separator else separator_fg = surface_fg end

  local winbar = get("WinBar")
  local winbar_bg = winbar.bg or title_surfaces.active_bg or surface_bg
  local winbar_fg = winbar.fg or title_surfaces.active_fg or surface_fg
  winbar_fg, winbar_bg = readable_pair(winbar_fg, winbar_bg, normal)

  return {
    normal_fg = normal_fg,
    normal_bg = normal_bg,
    fill_bg = fill_bg,
    surface_fg = surface_fg,
    surface_bg = surface_bg,
    active_fg = active_fg,
    active_bg = active_bg,
    visible_fg = visible_fg,
    visible_bg = visible_bg,
    separator_fg = separator_fg,
    scrollbar_bg = title_surfaces.scrollbar_bg or active_bg,
    winbar_fg = winbar_fg,
    winbar_bg = winbar_bg,
  }
end

function M.bufferline_highlights()
  local p = tab_palette()
  return {
    fill = { fg = p.surface_fg, bg = p.surface_bg },
    background = { fg = p.surface_fg, bg = p.surface_bg },
    buffer = { fg = p.surface_fg, bg = p.surface_bg },
    buffer_visible = { fg = p.visible_fg, bg = p.visible_bg },
    buffer_selected = { fg = p.active_fg, bg = p.active_bg, bold = true },
    tab = { fg = p.visible_fg, bg = p.surface_bg },
    tab_selected = { fg = p.active_fg, bg = p.active_bg, bold = true },
    separator = { fg = p.separator_fg, bg = p.surface_bg },
    separator_visible = { fg = p.separator_fg, bg = p.visible_bg },
    separator_selected = { fg = p.active_bg, bg = p.active_bg },
    modified = { fg = p.active_fg, bg = p.surface_bg },
    modified_visible = { fg = p.active_fg, bg = p.visible_bg },
    modified_selected = { fg = p.active_fg, bg = p.active_bg, bold = true },
    close_button = { fg = p.visible_fg, bg = p.surface_bg },
    close_button_visible = { fg = p.visible_fg, bg = p.visible_bg },
    close_button_selected = { fg = p.active_fg, bg = p.active_bg },
    numbers = { fg = p.surface_fg, bg = p.surface_bg },
    numbers_visible = { fg = p.visible_fg, bg = p.visible_bg },
    numbers_selected = { fg = p.active_fg, bg = p.active_bg, bold = true },
    indicator_selected = { fg = p.active_bg, bg = p.active_bg },
    indicator_visible = { fg = p.visible_bg, bg = p.visible_bg },
    offset_separator = { fg = p.separator_fg, bg = p.surface_bg },
    -- Duplicate prefix (directory shown when two files share the same name).
    -- bufferline defaults bg to Normal.bg (black), which leaks as a dark
    -- strip inside the active tab.  Match the surrounding tab surface.
    duplicate_selected = { fg = p.active_fg, bg = p.active_bg, italic = true },
    duplicate_visible  = { fg = p.visible_fg, bg = p.visible_bg, italic = true },
    duplicate          = { fg = p.surface_fg, bg = p.surface_bg, italic = true },
  }
end

function M.apply()
  local p = tab_palette()
  local set = vim.api.nvim_set_hl
  local normal = get("Normal")
  local title_surfaces = title_bar_surfaces()
  local active_status = get("StatusLine")
  local inactive_status = get("StatusLineNC")
  local status_fg, status_bg = readable_pair(
    title_surfaces.status_active_fg or active_status.fg or normal.fg,
    title_surfaces.status_active_bg or active_status.bg or normal.bg,
    normal
  )
  local status_nc_fg, status_nc_bg = readable_pair(
    title_surfaces.status_inactive_fg or inactive_status.fg or status_fg,
    title_surfaces.status_inactive_bg or inactive_status.bg or status_bg,
    normal
  )
  set(0, "StatusLine", { fg = status_fg, bg = status_bg })
  set(0, "StatusLineNC", { fg = status_nc_fg, bg = status_nc_bg })

  -- The path and metadata bar should read as a UI surface, not disappear
  -- into the editor background.  The colors still come from the active theme.
  set(0, "WinBar", { fg = p.winbar_fg, bg = p.winbar_bg })
  set(0, "WinBarNC", { fg = p.visible_fg, bg = p.visible_bg })

  set(0, "BufferLineFill", { fg = p.surface_fg, bg = p.fill_bg })
  set(0, "BufferLineNewBuffer", { fg = p.normal_fg, bg = p.fill_bg, bold = true })
  set(0, "BufferLineBackground", { fg = p.surface_fg, bg = p.surface_bg })
  set(0, "BufferLineBuffer", { fg = p.surface_fg, bg = p.surface_bg })
  set(0, "BufferLineBufferVisible", { fg = p.visible_fg, bg = p.visible_bg })
  set(0, "BufferLineBufferSelected", { fg = p.active_fg, bg = p.active_bg, bold = true })
  -- Bufferline keeps a one-cell indicator slot before every icon. Copy the
  -- final tab backgrounds here so that slot cannot retain a stale/different
  -- color after a theme change or delayed bufferline highlight generation.
  local visible_tab_bg = get("BufferLineBufferVisible").bg or p.visible_bg
  local selected_tab_bg = get("BufferLineBufferSelected").bg or p.active_bg
  set(0, "BufferLineIndicatorVisible", { fg = visible_tab_bg, bg = visible_tab_bg })
  set(0, "BufferLineIndicatorSelected", { fg = selected_tab_bg, bg = selected_tab_bg })
  set(0, "BufferLineTab", { fg = p.visible_fg, bg = p.surface_bg })
  set(0, "BufferLineTabSelected", { fg = p.active_fg, bg = p.active_bg, bold = true })
  set(0, "BufferLineSeparator", { fg = p.separator_fg, bg = p.surface_bg })
  set(0, "BufferLineSeparatorVisible", { fg = p.separator_fg, bg = p.visible_bg })
  set(0, "BufferLineSeparatorSelected", { fg = p.active_bg, bg = p.active_bg })
  set(0, "BufferLineModified", { fg = p.active_fg, bg = p.surface_bg })
  set(0, "BufferLineModifiedVisible", { fg = p.active_fg, bg = p.visible_bg })
  set(0, "BufferLineModifiedSelected", { fg = p.active_fg, bg = p.active_bg, bold = true })
  set(0, "BufferLineCloseButton", { fg = p.visible_fg, bg = p.surface_bg })
  set(0, "BufferLineCloseButtonVisible", { fg = p.visible_fg, bg = p.visible_bg })
  set(0, "BufferLineCloseButtonSelected", { fg = p.active_fg, bg = p.active_bg })
  set(0, "BufferLineOffsetSeparator", { fg = p.separator_fg, bg = p.surface_bg })
  -- Duplicate prefix: directory shown in tab when two buffers share the same
  -- filename.  bufferline's default bg is Normal.bg (black); override it so
  -- the prefix blends with its surrounding tab surface.
  set(0, "BufferLineDuplicateSelected", { fg = p.active_fg,  bg = p.active_bg,  italic = true })
  set(0, "BufferLineDuplicateVisible",  { fg = p.visible_fg, bg = p.visible_bg, italic = true })
  set(0, "BufferLineDuplicate",         { fg = p.surface_fg, bg = p.surface_bg, italic = true })

  -- Scrollbar (Satellite & nvim-scrollbar):
  set(0, "SatelliteBackground", { bg = "#25252a" })
  set(0, "SatelliteBar", { bg = p.scrollbar_bg })

  set(0, "ScrollbarHandle", { fg = p.scrollbar_bg, bg = p.scrollbar_bg })
  set(0, "ScrollbarCursorHandle", { fg = p.scrollbar_bg, bg = p.scrollbar_bg })
  set(0, "ScrollbarMisc", { fg = p.surface_fg, bg = p.fill_bg })
  set(0, "ScrollbarMiscHandle", { fg = p.scrollbar_bg, bg = p.scrollbar_bg })
  local mark_groups = {
    Search = "Search",
    Error = "DiagnosticError",
    Warn = "DiagnosticWarn",
    Info = "DiagnosticInfo",
    Hint = "DiagnosticHint",
  }
  for mark, source in pairs(mark_groups) do
    local h = get(source)
    set(0, "Scrollbar" .. mark, { fg = h.fg or p.surface_fg, bg = h.bg or p.fill_bg })
    set(0, "Scrollbar" .. mark .. "Handle", { fg = p.scrollbar_bg, bg = p.scrollbar_bg })
  end

  for _, group in ipairs(vim.fn.getcompletion("BufferLineDevIcon", "highlight")) do
    if group:match("Selected$") then
      set(0, group, { fg = p.active_fg, bg = p.active_bg, bold = true })
    elseif group:match("Visible$") or group:match("Inactive$") then
      set(0, group, { fg = p.visible_fg, bg = p.visible_bg })
    else
      set(0, group, { fg = p.surface_fg, bg = p.surface_bg })
    end
  end
end

vim.api.nvim_create_autocmd("ColorScheme", {
  callback = function()
    theme_scrollbar_accent = get_theme_scrollbar_accent()
    vim.schedule(M.apply)
  end,
})

-- bufferline dynamically creates BufferLineDevIcon* groups the first time a
-- new filetype is opened in a tab.  Those groups are built from bufferline's
-- internally-stored highlight table (frozen at setup time), so their bg may
-- not match the current theme.  Re-applying 100 ms after BufEnter gives
-- bufferline time to create the group before we overwrite it.
vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter", "TabEnter" }, {
  callback = function()
    vim.defer_fn(M.apply, 100)
  end,
})

return M
