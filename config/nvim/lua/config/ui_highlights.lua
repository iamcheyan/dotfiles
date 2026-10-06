-- Theme-agnostic UI component highlights.
--
-- Plugins should consume semantic Vim highlight groups instead of reaching
-- into a particular colorscheme's private palette.  This keeps tabs and the
-- winbar readable when the colorscheme changes at runtime.

local M = {}

local function get(name)
  return vim.api.nvim_get_hl(0, { name = name, link = false })
end

local function nostalgia_palette()
  local ok, theme = pcall(require, "theme.nostalgia")
  return ok and theme.palette or nil
end
M.nostalgia_palette = nostalgia_palette
local function to_rgb(color)
  if type(color) == "string" and color:match("^#%x%x%x%x%x%x$") then
    return tonumber(color:sub(2), 16)
  end
  return color
end
M.to_rgb = to_rgb

M.fresh_normal_style = function()
  local fresh = nostalgia_palette() or {}
  return {
    fg = fresh.status_palette_fg,
    bg = fresh.status_palette_bg,
    bold = false,
  }
end

-- TabLineSel may link to StatusLine. Cache the theme's original accent before
-- this adapter changes StatusLine, so repeated apply() calls keep the same thumb.
local function get_theme_scrollbar_accent()
  return get("TabLineSel").bg or get("TitleBar").bg
end
local theme_scrollbar_accent = get_theme_scrollbar_accent()
local theme_scrollbar_fg = get("TabLineSel").fg

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

local function mix_colors(color_a, color_b, amount_b)
  if type(color_a) ~= "number" or type(color_b) ~= "number" then return nil end
  local function channel(color, shift)
    return math.floor(color / (2 ^ shift)) % 256
  end
  local r = math.floor(channel(color_a, 16) * (1 - amount_b) + channel(color_b, 16) * amount_b + 0.5)
  local g = math.floor(channel(color_a, 8) * (1 - amount_b) + channel(color_b, 8) * amount_b + 0.5)
  local b = math.floor(channel(color_a, 0) * (1 - amount_b) + channel(color_b, 0) * amount_b + 0.5)
  return r * 65536 + g * 256 + b
end

local function xterm_color(index)
  if index >= 232 then
    local level = 8 + (index - 232) * 10
    return level * 65536 + level * 257
  end
  if index >= 16 then
    local levels = { 0, 95, 135, 175, 215, 255 }
    local value = index - 16
    local r = levels[math.floor(value / 36) + 1]
    local g = levels[math.floor(value / 6) % 6 + 1]
    local b = levels[value % 6 + 1]
    return r * 65536 + g * 256 + b
  end
end

local function nearest_xterm_color(color)
  if type(color) ~= "number" then return nil end
  local best_index, best_distance = nil, math.huge
  local r, g, b = math.floor(color / 65536) % 256, math.floor(color / 256) % 256, color % 256
  for index = 16, 255 do
    local candidate = xterm_color(index)
    local dr = r - math.floor(candidate / 65536) % 256
    local dg = g - math.floor(candidate / 256) % 256
    local db = b - candidate % 256
    local distance = dr * dr + dg * dg + db * db
    if distance < best_distance then
      best_index, best_distance = index, distance
    end
  end
  return best_index
end

local function apply_cursor_guide_highlights()
  local cursor_line = get("CursorLine")
  local cursor_column = get("CursorColumn")
  local normal = get("Normal")
  if cursor_line.bg == nil or cursor_column.bg == nil or cursor_column.bg ~= cursor_line.bg then
    return
  end

  -- A shared row/column color erases the vertical axis at their crossing.
  -- Pull the column guide toward the editor surface to keep both directions
  -- visible, while preserving any theme that already chose separate colors.
  local attrs = vim.deepcopy(cursor_column)
  attrs.bg = mix_colors(cursor_column.bg, normal.bg, 0.65)
  if attrs.ctermbg then attrs.ctermbg = nearest_xterm_color(attrs.bg) end
  if attrs.bg then
    vim.api.nvim_set_hl(0, "CursorColumn", attrs)
  end
end

function M.apply_completion_highlights()
  local menu = get("Pmenu")
  local normal = get("Normal")
  local doc_bg = normal.bg or menu.bg
  local doc_fg = readable_foreground(
    doc_bg,
    menu.fg,
    normal.fg,
    get("StatusLine").fg,
    get("LineNr").fg
  ) or menu.fg or normal.fg
  if not doc_bg or not doc_fg then return end

  -- Keep completion docs distinct from the list surface and readable on every
  -- colorscheme; the menu itself continues to use Pmenu/PmenuSel.
  vim.api.nvim_set_hl(0, "BlinkCmpMenuBorder", { fg = menu.fg or doc_fg, bg = menu.bg })
  vim.api.nvim_set_hl(0, "BlinkCmpDoc", { fg = doc_fg, bg = doc_bg })
  vim.api.nvim_set_hl(0, "BlinkCmpDocBorder", { fg = doc_fg, bg = doc_bg })
  vim.api.nvim_set_hl(0, "BlinkCmpDocSeparator", { fg = doc_fg, bg = doc_bg })
end

local function title_bar_surfaces()
  local active = get("TitleBar")
  local inactive = get("TitleBarNC")
  local tab_accent = theme_scrollbar_accent or get("TabLineSel").bg or active.bg
  local is_blue = vim.g.colors_name == "blue"
  return {
    active_fg = is_blue and (get("TabLineSel").fg or active.fg) or active.fg,
    -- Keep the original bright blue on the active top tab.  The darkened
    -- title-bar blue made the whole top edge read nearly black.
    active_bg = is_blue and tab_accent or darken_surface(active.bg, top_active_scale),
    inactive_fg = inactive.fg,
    inactive_bg = darken_surface(inactive.bg, top_inactive_scale),
    status_active_fg = is_blue and (get("TabLineSel").fg or active.fg) or darken_surface(active.fg, 1.0),
    status_active_bg = is_blue and tab_accent or darken_surface(active.bg, top_active_scale),
    status_inactive_fg = inactive.fg,
    status_inactive_bg = inactive.bg,
    scrollbar_bg = tab_accent,
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
  local fresh = vim.g.colors_name == "blue" and nostalgia_palette()
  if fresh then
    local surface_bg = to_rgb(fresh.tab_inactive_bg)
    local surface_fg = to_rgb(fresh.tab_inactive_fg)
    local separator_bg = to_rgb(fresh.tab_separator_bg)
    local active_bg = to_rgb(fresh.tab_active_bg)
    local active_fg = to_rgb(fresh.tab_active_fg)
    return {
      normal_fg = to_rgb(fresh.editor_fg),
      normal_bg = normal_bg,
      fill_bg = separator_bg,
      surface_fg = surface_fg,
      surface_bg = surface_bg,
      active_fg = active_fg,
      active_bg = active_bg,
      visible_fg = surface_fg,
      visible_bg = surface_bg,
      separator_fg = to_rgb(fresh.split_separator_fg),
      scrollbar_bg = theme_scrollbar_accent,
      scrollbar_misc_fg = normal_fg,
      scrollbar_misc_bg = normal_bg,
      winbar_fg = active_fg,
      winbar_bg = active_bg,
      winbar_nc_fg = surface_fg,
      winbar_nc_bg = surface_bg,
      top_bold = false,
    }
  end

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
    top_bold = true,
  }
end

function M.bufferline_highlights()
  local p = tab_palette()
  return {
    fill = { fg = p.surface_fg, bg = p.fill_bg },
    background = { fg = p.surface_fg, bg = p.surface_bg },
    buffer = { fg = p.surface_fg, bg = p.surface_bg },
    buffer_visible = { fg = p.visible_fg, bg = p.visible_bg },
    buffer_selected = { fg = p.active_fg, bg = p.active_bg, bold = p.top_bold },
    tab = { fg = p.visible_fg, bg = p.surface_bg },
    tab_selected = { fg = p.active_fg, bg = p.active_bg, bold = p.top_bold },
    separator = { fg = p.separator_fg, bg = p.surface_bg },
    separator_visible = { fg = p.separator_fg, bg = p.visible_bg },
    separator_selected = { fg = p.active_bg, bg = p.active_bg },
    modified = { fg = p.active_fg, bg = p.surface_bg },
    modified_visible = { fg = p.active_fg, bg = p.visible_bg },
    modified_selected = { fg = p.active_fg, bg = p.active_bg, bold = p.top_bold },
    close_button = { fg = p.visible_fg, bg = p.surface_bg },
    close_button_visible = { fg = p.visible_fg, bg = p.visible_bg },
    close_button_selected = { fg = p.active_fg, bg = p.active_bg },
    numbers = { fg = p.surface_fg, bg = p.surface_bg },
    numbers_visible = { fg = p.visible_fg, bg = p.visible_bg },
    numbers_selected = { fg = p.active_fg, bg = p.active_bg, bold = p.top_bold },
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

-- Snacks links the focused list row to Visual by default. Visual may have
-- exactly the same surface as NormalFloat, making the selection disappear.
function M.apply_picker_highlights()
  local normal = get("Normal")
  local menu = get("Pmenu")
  local selected = get("PmenuSel")
  local separator = get("WinSeparator")
  local float_bg = menu.bg or get("NormalFloat").bg or normal.bg
  local float_fg = menu.fg or get("NormalFloat").fg or normal.fg
  local document_bg = normal.bg or float_bg
  local preview_fg = normal.fg or float_fg
  if not float_bg then return end

  -- Keep all left-pane sections and preview on the document-blue surface.
  -- Preserve the Blue theme's popup foreground on picker borders.
  vim.api.nvim_set_hl(0, "SnacksPickerInput", { fg = float_fg, bg = document_bg })
  vim.api.nvim_set_hl(0, "SnacksPickerList", { fg = float_fg, bg = document_bg })
  for _, group in ipairs({ "SnacksPickerFooter", "SnacksPickerListFooter" }) do
    vim.api.nvim_set_hl(0, group, { fg = float_fg, bg = document_bg })
  end
  for _, group in ipairs({ "SnacksPickerFooterKey", "SnacksPickerFooterText", "SnacksPickerFooterSeparator" }) do
    vim.api.nvim_set_hl(0, group, { fg = float_fg, bg = document_bg })
  end
  vim.api.nvim_set_hl(0, "SnacksPickerPreview", { fg = preview_fg, bg = document_bg })
  local border_fg = float_fg or separator.fg or get("FloatBorder").fg
  for _, group in ipairs({
    "SnacksPickerBorder", "SnacksPickerInputBorder", "SnacksPickerListBorder",
    "SnacksPickerPreviewBorder", "SnacksPickerFooterBorder",
  }) do
    vim.api.nvim_set_hl(0, group, { fg = border_fg, bg = document_bg })
  end

  for _, group in ipairs({
    "SnacksPickerCursorLine", "SnacksPickerInputCursorLine",
    "SnacksPickerPreviewCursorLine", "SnacksPickerBoxCursorLine",
  }) do
    local row = vim.api.nvim_get_hl(0, { name = group, link = false })
    row.bg = document_bg
    row.ctermbg = normal.ctermbg or nearest_xterm_color(document_bg)
    vim.api.nvim_set_hl(0, group, row)
  end

  -- Use the same theme-derived blue accent as the active tab so the current result
  -- remains obvious without restoring Snacks' mismatched green/white PmenuSel.
  local title_surfaces = title_bar_surfaces()
  local cursor_line = get("CursorLine")
  local selected_bg = title_surfaces.active_bg
    or (cursor_line.bg ~= document_bg and cursor_line.bg)
    or selected.bg or document_bg
  local selected_fg = (vim.g.colors_name == "blue" and nostalgia_palette())
      and theme_scrollbar_fg
      or title_surfaces.active_fg or cursor_line.fg or selected.fg or normal.fg
  selected_fg, selected_bg = readable_pair(selected_fg, selected_bg, normal)
  vim.api.nvim_set_hl(0, "SnacksPickerListCursorLine", {
    bg = selected_bg,
    fg = selected_fg,
    ctermbg = nearest_xterm_color(selected_bg),
    ctermfg = nearest_xterm_color(selected_fg),
    bold = true,
  })
end

function M.apply()
  local nostalgia = vim.g.colors_name == "blue" and nostalgia_palette()
  local winbar_before = get("WinBar")
  local winbar_nc_before = get("WinBarNC")
  local p = tab_palette()
  local set = vim.api.nvim_set_hl
  local normal = get("Normal")
  if nostalgia then
    set(0, "TabLine", { fg = nostalgia.tab_inactive_fg, bg = nostalgia.tab_separator_bg, bold = false })
    set(0, "TabLineFill", { fg = nostalgia.tab_inactive_fg, bg = nostalgia.tab_separator_bg, bold = false })
    set(0, "TabLineSel", { fg = nostalgia.tab_active_fg, bg = nostalgia.tab_active_bg, bold = false })
    set(0, "FreshStatusLineNormal", M.fresh_normal_style())
    set(0, "FreshStatusLineAccent", {
      fg = nostalgia.status_palette_fg,
      bg = nostalgia.status_palette_bg,
      bold = false,
    })
    set(0, "FreshStatusLineWarning", {
      fg = nostalgia.status_warning_indicator_fg,
      bg = nostalgia.status_warning_indicator_bg,
      bold = false,
    })
    set(0, "FreshStatusLineError", {
      fg = nostalgia.status_error_indicator_fg,
      bg = nostalgia.status_error_indicator_bg,
      bold = false,
    })
  end
  local title_surfaces = title_bar_surfaces()
  apply_cursor_guide_highlights()
  M.apply_completion_highlights()
  M.apply_picker_highlights()
  local active_status = get("StatusLine")
  local inactive_status = get("StatusLineNC")
  local status_fg, status_bg
  local status_nc_fg, status_nc_bg
  if nostalgia then
    status_fg, status_bg = nostalgia.status_bar_fg, nostalgia.status_bar_bg
    status_nc_fg, status_nc_bg = nostalgia.status_bar_fg, nostalgia.status_bar_bg
  else
    status_fg, status_bg = readable_pair(
      title_surfaces.status_active_fg or active_status.fg or normal.fg,
      title_surfaces.status_active_bg or active_status.bg or normal.bg,
      normal
    )
    status_nc_fg, status_nc_bg = readable_pair(
      title_surfaces.status_inactive_fg or inactive_status.fg or status_fg,
      title_surfaces.status_inactive_bg or inactive_status.bg or status_bg,
      normal
    )
  end
  set(0, "StatusLine", { fg = status_fg, bg = status_bg, bold = false })
  set(0, "StatusLineNC", { fg = status_nc_fg, bg = status_nc_bg, bold = false })

  -- The path and metadata bar should read as a UI surface, not disappear
  -- into the editor background.  The colors still come from the active theme.
  if not nostalgia then
    set(0, "WinBar", { fg = p.winbar_fg, bg = p.winbar_bg })
    set(0, "WinBarNC", { fg = p.winbar_nc_fg or p.visible_fg, bg = p.winbar_nc_bg or p.visible_bg })
  end

  set(0, "BufferLineFill", { fg = p.surface_fg, bg = p.fill_bg })
  set(0, "BufferLineNewBuffer", { fg = p.normal_fg, bg = p.fill_bg, bold = p.top_bold })
  set(0, "BufferLineBackground", { fg = p.surface_fg, bg = p.surface_bg })
  set(0, "BufferLineBuffer", { fg = p.surface_fg, bg = p.surface_bg })
  set(0, "BufferLineBufferVisible", { fg = p.visible_fg, bg = p.visible_bg })
  set(0, "BufferLineBufferSelected", { fg = p.active_fg, bg = p.active_bg, bold = p.top_bold })
  -- Bufferline keeps a one-cell indicator slot before every icon. Copy the
  -- final tab backgrounds here so that slot cannot retain a stale/different
  -- color after a theme change or delayed bufferline highlight generation.
  local visible_tab_bg = get("BufferLineBufferVisible").bg or p.visible_bg
  local selected_tab_bg = get("BufferLineBufferSelected").bg or p.active_bg
  set(0, "BufferLineIndicatorVisible", { fg = visible_tab_bg, bg = visible_tab_bg })
  set(0, "BufferLineIndicatorSelected", { fg = selected_tab_bg, bg = selected_tab_bg })
  set(0, "BufferLineTab", { fg = p.visible_fg, bg = p.surface_bg })
  set(0, "BufferLineTabSelected", { fg = p.active_fg, bg = p.active_bg, bold = p.top_bold })
  set(0, "BufferLineSeparator", { fg = p.separator_fg, bg = p.surface_bg })
  set(0, "BufferLineSeparatorVisible", { fg = p.separator_fg, bg = p.visible_bg })
  set(0, "BufferLineSeparatorSelected", { fg = p.active_bg, bg = p.active_bg })
  set(0, "BufferLineModified", { fg = p.active_fg, bg = p.surface_bg })
  set(0, "BufferLineModifiedVisible", { fg = p.active_fg, bg = p.visible_bg })
  set(0, "BufferLineModifiedSelected", { fg = p.active_fg, bg = p.active_bg, bold = p.top_bold })
  set(0, "BufferLineCloseButton", { fg = p.visible_fg, bg = p.surface_bg })
  set(0, "BufferLineCloseButtonVisible", { fg = p.visible_fg, bg = p.visible_bg })
  set(0, "BufferLineCloseButtonSelected", { fg = p.active_fg, bg = p.active_bg, bold = p.top_bold })
  set(0, "BufferLineOffsetSeparator", { fg = p.separator_fg, bg = p.surface_bg })
  -- Duplicate prefix: directory shown in tab when two buffers share the same
  -- filename.  bufferline's default bg is Normal.bg (black); override it so
  -- the prefix blends with its surrounding tab surface.
  set(0, "BufferLineDuplicateSelected", { fg = p.active_fg,  bg = p.active_bg,  italic = true })
  set(0, "BufferLineDuplicateVisible",  { fg = p.visible_fg, bg = p.visible_bg, italic = true })
  set(0, "BufferLineDuplicate",         { fg = p.surface_fg, bg = p.surface_bg, italic = true })

  -- Scrollbar (Satellite & nvim-scrollbar):
  set(0, "SatelliteBackground", { bg = p.scrollbar_track_bg or "#25252a" })
  set(0, "SatelliteBar", { bg = p.scrollbar_bg })

  set(0, "ScrollbarHandle", { fg = p.scrollbar_bg, bg = p.scrollbar_bg })
  set(0, "ScrollbarCursorHandle", { fg = p.scrollbar_bg, bg = p.scrollbar_bg })
  set(0, "ScrollbarMisc", { fg = p.scrollbar_misc_fg or p.surface_fg, bg = p.scrollbar_misc_bg or p.fill_bg })
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
    set(0, "Scrollbar" .. mark, { fg = h.fg or p.scrollbar_misc_fg or p.surface_fg, bg = h.bg or p.scrollbar_misc_bg or p.fill_bg })
    set(0, "Scrollbar" .. mark .. "Handle", { fg = p.scrollbar_bg, bg = p.scrollbar_bg })
  end

  for _, group in ipairs(vim.fn.getcompletion("BufferLineDevIcon", "highlight")) do
    if group:match("Selected$") then
      set(0, group, { fg = p.active_fg, bg = p.active_bg, bold = p.top_bold })
    elseif group:match("Visible$") or group:match("Inactive$") then
      set(0, group, { fg = p.visible_fg, bg = p.visible_bg })
    else
      set(0, group, { fg = p.surface_fg, bg = p.surface_bg })
    end
  end

  -- Heirline caches both component strings and generated RGB highlight
  -- groups. Invalidate them after the delayed adapter changes the bar palette,
  -- so the first visible frame uses the new foreground and background together.
  if not vim.deep_equal(winbar_before, get("WinBar"))
      or not vim.deep_equal(winbar_nc_before, get("WinBarNC")) then
    if package.loaded["heirline"] then
      require("heirline.utils").on_colorscheme()
    end
    vim.schedule(function() pcall(vim.cmd, "redrawstatus") end)
  end
end

local ui_group = vim.api.nvim_create_augroup("ThemeUiHighlights", { clear = true })
vim.api.nvim_create_autocmd("ColorScheme", {
  group = ui_group,
  callback = function()
    theme_scrollbar_accent = get_theme_scrollbar_accent()
    theme_scrollbar_fg = get("TabLineSel").fg
    vim.schedule(M.apply)
  end,
})

-- bufferline dynamically creates BufferLineDevIcon* groups the first time a
-- new filetype is opened in a tab.  Those groups are built from bufferline's
-- internally-stored highlight table (frozen at setup time), so their bg may
-- not match the current theme.  Re-applying 100 ms after BufEnter gives
-- bufferline time to create the group before we overwrite it.
vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter", "TabEnter" }, {
  group = ui_group,
  callback = function()
    vim.defer_fn(M.apply, 100)
  end,
})

return M
