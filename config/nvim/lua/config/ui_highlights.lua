-- Theme-agnostic UI component highlights.
--
-- Plugins should consume semantic Vim highlight groups instead of reaching
-- into a particular colorscheme's private palette.  This keeps tabs and the
-- winbar readable when the colorscheme changes at runtime.

local M = {}

local function get(name)
  return vim.api.nvim_get_hl(0, { name = name, link = false })
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
  local surface_bg = preferred_bg("TabLine", "StatusLine", "CursorLine", "Normal")
  local fill_bg = preferred_bg("TabLineFill", "TabLine", "StatusLine", "Normal")
  local surface_fg = pick_fg("TabLine", "StatusLine", "Normal")
  local active = get("TabLineSel")
  local active_bg = active.bg or get("Visual").bg or surface_bg
  local active_fg = active.fg or get("Visual").fg or normal_fg
  local visible_bg = pick_bg("CursorLine", "TabLine", "Normal")
  local visible_fg = pick_fg("TabLine", "StatusLineNC", "NormalNC", "Normal")
  local separator_fg = pick_fg("WinSeparator", "VertSplit", "NonText", "TabLine")
  local winbar = get("WinBar")
  local winbar_bg = winbar.bg or surface_bg
  local winbar_fg = winbar.fg or surface_fg

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

  -- The path and metadata bar should read as a UI surface, not disappear
  -- into the editor background.  The colors still come from the active theme.
  set(0, "WinBar", { fg = p.winbar_fg, bg = p.winbar_bg })
  set(0, "WinBarNC", { fg = p.visible_fg, bg = p.winbar_bg })

  set(0, "BufferLineFill", { fg = p.surface_fg, bg = p.fill_bg })
  set(0, "BufferLineNewBuffer", { fg = p.normal_fg, bg = p.fill_bg, bold = true })
  set(0, "BufferLineBackground", { fg = p.surface_fg, bg = p.surface_bg })
  set(0, "BufferLineBuffer", { fg = p.surface_fg, bg = p.surface_bg })
  set(0, "BufferLineBufferVisible", { fg = p.visible_fg, bg = p.visible_bg })
  set(0, "BufferLineBufferSelected", { fg = p.active_fg, bg = p.active_bg, bold = true })
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
  set(0, "SatelliteBar", { bg = p.active_bg })

  set(0, "ScrollbarHandle", { fg = p.active_bg, bg = p.active_bg })
  set(0, "ScrollbarCursorHandle", { fg = p.active_bg, bg = p.active_bg })
  set(0, "ScrollbarMisc", { fg = p.surface_fg, bg = p.fill_bg })
  set(0, "ScrollbarMiscHandle", { fg = p.active_bg, bg = p.active_bg })
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
    set(0, "Scrollbar" .. mark .. "Handle", { fg = p.active_bg, bg = p.active_bg })
  end

  for _, group in ipairs(vim.fn.getcompletion("BufferLineDevIcon", "highlight")) do
    if group:match("Selected$") then
      set(0, group, { fg = p.active_fg, bg = p.active_bg, bold = true })
    elseif group:match("Visible$") then
      set(0, group, { fg = p.visible_fg, bg = p.visible_bg })
    else
      set(0, group, { fg = p.surface_fg, bg = p.surface_bg })
    end
  end
end

vim.api.nvim_create_autocmd("ColorScheme", {
  callback = function()
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
