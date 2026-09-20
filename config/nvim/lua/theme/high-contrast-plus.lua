-- lua/theme/high-contrast-plus.lua
-- Exact port of Fresh's `high-contrast-plus` theme for Neovim.
-- Source of truth: ~/.config/fresh/themes/high-contrast-plus.json

local M = {}

M.palette = {
  -- Editor
  bg                      = "#000000", -- editor.bg: [0, 0, 0]
  fg                      = "#ffffff", -- editor.fg: [255, 255, 255]
  cursor                  = "#ffffff", -- editor.cursor: [255, 255, 255]
  inactive_cursor         = "#7f7f7f", -- editor.inactive_cursor: [127, 127, 127]
  selection_bg            = "#0064c8", -- ui.menu_highlight_bg / prompt_selection_bg: [0, 100, 200]
  selection_editor_bg     = "#323c5a", -- editor.selection_bg: [50, 60, 90]
  current_line_bg         = "#141414", -- editor.current_line_bg: [20, 20, 20]
  line_number_fg          = "#ffffff", -- editor.line_number_fg: [255, 255, 255]
  line_number_bg          = "#000000", -- editor.line_number_bg: [0, 0, 0]
  whitespace              = "#505050", -- editor.whitespace_indicator_fg: [80, 80, 80]

  -- Diff
  diff_add_bg             = "#005000", -- editor.diff_add_bg: [0, 80, 0]
  diff_remove_bg          = "#640000", -- editor.diff_remove_bg: [100, 0, 0]
  diff_modify_bg          = "#3c3700", -- editor.diff_modify_bg: [60, 55, 0]
  diff_add_hl_bg          = "#006e00", -- editor.diff_add_highlight_bg: [0, 110, 0]
  diff_remove_hl_bg       = "#8c0000", -- editor.diff_remove_highlight_bg: [140, 0, 0]

  -- UI Tabs
  tab_active_fg           = "#000000", -- ui.tab_active_fg: [0, 0, 0]
  tab_active_bg           = "#ffff00", -- ui.tab_active_bg: [255, 255, 0]
  tab_inactive_fg         = "#ffffff", -- ui.tab_inactive_fg: [255, 255, 255]
  -- Keep inactive buffer tabs on a visible UI surface instead of the editor's
  -- black background.  The old value leaked black strips around bufferline.
  tab_inactive_bg         = "#242424", -- dedicated inactive-tab surface
  tab_inactive_surface_bg = "#242424", -- dedicated inactive-tab surface
  tab_separator_bg        = "#1e1e23", -- ui.tab_separator_bg: [30, 30, 35]
  tab_close_hover_fg      = "#f92672", -- ui.tab_close_hover_fg: [249, 38, 114]
  tab_hover_bg            = "#323237", -- ui.tab_hover_bg: [50, 50, 55]

  -- UI Menu / Dropdown / Popups
  menu_bg                 = "#323237", -- ui.menu_bg: [50, 50, 55]
  menu_fg                 = "#ffffff", -- ui.menu_fg: [255, 255, 255]
  menu_active_bg          = "#ffff00", -- ui.menu_active_bg: [255, 255, 0]
  menu_active_fg          = "#000000", -- ui.menu_active_fg: [0, 0, 0]
  menu_dropdown_bg        = "#141414", -- ui.menu_dropdown_bg: [20, 20, 20]
  menu_dropdown_fg        = "#ffffff", -- ui.menu_dropdown_fg: [255, 255, 255]
  menu_highlight_bg       = "#0064c8", -- ui.menu_highlight_bg: [0, 100, 200]
  menu_highlight_fg       = "#ffffff", -- ui.menu_highlight_fg: [255, 255, 255]
  menu_border_fg          = "#ffff00", -- ui.menu_border_fg: [255, 255, 0]
  menu_separator_fg       = "#ffffff", -- ui.menu_separator_fg: [255, 255, 255]
  menu_hover_bg           = "#323232", -- ui.menu_hover_bg: [50, 50, 50]
  menu_hover_fg           = "#ffff00", -- ui.menu_hover_fg: [255, 255, 0]
  menu_disabled_fg        = "#7f7f7f", -- ui.menu_disabled_fg: [127, 127, 127]
  menu_disabled_bg        = "#141414", -- ui.menu_disabled_bg: [20, 20, 20]

  -- Status Bar & Header
  status_bar_fg           = "#ffffff", -- ui.status_bar_fg: [255, 255, 255]
  status_bar_bg           = "#2a2a2a", -- ui.status_bar_bg: [42, 42, 42]
  status_palette_fg       = "#000000", -- ui.status_palette_fg: [0, 0, 0]
  status_palette_bg       = "#00ffff", -- ui.status_palette_bg: [0, 255, 255]
  status_warn_bg          = "#ffff00", -- ui.status_warning_indicator_bg: [255, 255, 0]
  status_warn_fg          = "#000000", -- ui.status_warning_indicator_fg: [0, 0, 0]
  status_err_bg           = "#ff3c3c", -- ui.status_error_indicator_bg: [255, 60, 60]
  status_err_fg           = "#ffffff", -- ui.status_error_indicator_fg: [255, 255, 255]

  -- Prompt & Popups
  prompt_fg               = "#ffffff", -- ui.prompt_fg: [255, 255, 255]
  prompt_bg               = "#0a0a0a", -- ui.prompt_bg: [10, 10, 10]
  prompt_selection_fg     = "#ffffff", -- ui.prompt_selection_fg: [255, 255, 255]
  prompt_selection_bg     = "#0064c8", -- ui.prompt_selection_bg: [0, 100, 200]
  popup_border_fg         = "#00ffff", -- ui.popup_border_fg: [0, 255, 255]
  popup_bg                = "#000000", -- ui.popup_bg: [0, 0, 0]
  popup_selection_bg      = "#0064c8", -- ui.popup_selection_bg: [0, 100, 200]
  popup_text_fg           = "#ffffff", -- ui.popup_text_fg: [255, 255, 255]

  -- Separators & Scrollbar
  split_separator_fg      = "#8c8c8c", -- ui.split_separator_fg: [140, 140, 140]
  win_separator_fg        = "#333338", -- 窗口与侧边栏垂直分割线调暗淡，柔和低调不抢眼
  split_separator_hover   = "#ffff00", -- ui.split_separator_hover_fg: [255, 255, 0]
  scrollbar_track_fg      = "#505050", -- ui.scrollbar_track_fg: [80, 80, 80]
  scrollbar_thumb_fg      = "#ffff00", -- ui.scrollbar_thumb_fg: [255, 255, 0]
  scrollbar_track_hover   = "#8c8c8c", -- ui.scrollbar_track_hover_fg: [140, 140, 140]
  scrollbar_thumb_hover   = "#00ffff", -- ui.scrollbar_thumb_hover_fg: [0, 255, 255]

  -- Search
  search_match_bg         = "#0064c8", -- search.match_bg: [0, 100, 200]
  search_match_fg         = "#ffffff", -- search.match_fg: [255, 255, 255]

  -- Diagnostics
  diag_error_fg           = "#ff5050", -- diagnostic.error_fg: [255, 80, 80]
  diag_error_bg           = "#320000", -- diagnostic.error_bg: [50, 0, 0]
  diag_warning_fg         = "#ffff00", -- diagnostic.warning_fg: [255, 255, 0]
  diag_warning_bg         = "#231e00", -- diagnostic.warning_bg: [35, 30, 0]
  diag_info_fg            = "#00ffff", -- diagnostic.info_fg: [0, 255, 255]
  diag_info_bg            = "#001937", -- diagnostic.info_bg: [0, 25, 55]
  diag_hint_fg            = "#ffffff", -- diagnostic.hint_fg: [255, 255, 255]
  diag_hint_bg            = "#1e1e1e", -- diagnostic.hint_bg: [30, 30, 30]

  -- Syntax (Fresh exact)
  keyword                 = "#00ffff", -- syntax.keyword: [0, 255, 255] (Cyan)
  string                  = "#00cd00", -- syntax.string: [0, 205, 0] (Green)
  comment                 = "#e5e5e5", -- syntax.comment: [229, 229, 229] (Light gray)
  func                    = "#ffff00", -- syntax.function: [255, 255, 0] (Yellow)
  type                    = "#ff55ff", -- syntax.type: [255, 85, 255] (Magenta)
  variable                = "#ffffff", -- syntax.variable: [255, 255, 255] (White)
  constant                = "#7882ff", -- syntax.constant: [120, 130, 255] (Periwinkle Blue)
  operator                = "#ffffff", -- syntax.operator: [255, 255, 255] (White)
}

function M.load()
  vim.cmd("hi clear")
  if vim.fn.exists("syntax_on") == 1 then
    vim.cmd("syntax reset")
  end
  vim.o.termguicolors = true
  vim.g.colors_name = "high-contrast-plus"

  local p = M.palette
  local set = function(group, spec)
    vim.api.nvim_set_hl(0, group, spec)
  end

  -----------------------------------------------------------------------------
  -- 1. Core Editor
  -----------------------------------------------------------------------------
  set("Normal", { fg = p.fg, bg = p.bg })
  set("NormalNC", { fg = p.fg, bg = p.bg })
  set("NormalFloat", { fg = p.fg, bg = p.popup_bg })
  set("FloatBorder", { fg = p.split_separator_fg, bg = p.popup_bg })
  set("FloatTitle", { fg = p.status_palette_fg, bg = p.status_palette_bg, bold = true })
  set("FloatFooter", { fg = p.menu_disabled_fg, bg = p.popup_bg })

  set("Cursor", { fg = p.bg, bg = p.cursor })
  set("lCursor", { fg = p.bg, bg = p.cursor })
  set("CursorIM", { fg = p.bg, bg = p.cursor })
  set("TermCursor", { fg = p.bg, bg = p.cursor })
  set("TermCursorNC", { fg = p.bg, bg = p.inactive_cursor })

  set("CursorLine", { bg = p.current_line_bg })
  set("CursorColumn", { bg = p.current_line_bg })
  set("ColorColumn", { bg = p.current_line_bg })

  set("LineNr", { fg = p.line_number_fg, bg = p.line_number_bg })
  set("LineNrAbove", { fg = p.inactive_cursor, bg = p.line_number_bg })
  set("LineNrBelow", { fg = p.inactive_cursor, bg = p.line_number_bg })
  set("CursorLineNr", { fg = p.tab_active_bg, bg = p.current_line_bg, bold = true })

  set("SignColumn", { fg = p.fg, bg = p.bg })
  set("FoldColumn", { fg = p.keyword, bg = p.bg })
  set("Folded", { fg = p.comment, bg = p.current_line_bg, italic = true })

  set("Visual", { fg = p.menu_highlight_fg, bg = p.selection_bg, bold = true })
  set("VisualNOS", { fg = p.menu_highlight_fg, bg = p.selection_editor_bg })

  set("Search", { fg = p.search_match_fg, bg = p.search_match_bg, bold = true })
  set("IncSearch", { fg = p.tab_active_fg, bg = p.tab_active_bg, bold = true })
  set("CurSearch", { fg = p.tab_active_fg, bg = p.tab_active_bg, bold = true })

  set("WinSeparator", { fg = p.win_separator_fg, bg = p.bg })
  set("VertSplit", { fg = p.win_separator_fg, bg = p.bg })

  set("Whitespace", { fg = p.whitespace })
  set("NonText", { fg = p.whitespace })
  set("SpecialKey", { fg = p.whitespace })
  set("EndOfBuffer", { fg = p.bg })
  set("Conceal", { fg = p.inactive_cursor })

  set("MatchParen", { fg = p.tab_active_fg, bg = p.tab_active_bg, bold = true })

  -----------------------------------------------------------------------------
  -- 2. Menus & Floating Prompts
  -----------------------------------------------------------------------------
  set("Pmenu", { fg = p.menu_dropdown_fg, bg = p.menu_dropdown_bg })
  set("PmenuSel", { fg = p.menu_highlight_fg, bg = p.menu_highlight_bg, bold = true })
  set("PmenuBorder", { fg = p.split_separator_fg, bg = p.menu_dropdown_bg })
  set("PmenuSbar", { bg = p.scrollbar_track_fg })
  set("PmenuThumb", { bg = p.scrollbar_thumb_fg })
  set("WildMenu", { fg = p.menu_active_fg, bg = p.menu_active_bg, bold = true })

  set("Question", { fg = p.keyword, bold = true })
  set("MoreMsg", { fg = p.keyword, bold = true })
  set("ModeMsg", { fg = p.status_palette_fg, bg = p.status_palette_bg, bold = true })
  set("WarningMsg", { fg = p.diag_warning_fg, bold = true })
  set("ErrorMsg", { fg = p.diag_error_fg, bold = true })
  set("Directory", { fg = p.keyword, bold = true })
  set("Title", { fg = p.func, bold = true })

  -----------------------------------------------------------------------------
  -- 3. Diff & Version Control
  -----------------------------------------------------------------------------
  set("DiffAdd", { fg = p.fg, bg = p.diff_add_bg })
  set("DiffDelete", { fg = p.fg, bg = p.diff_remove_bg })
  set("DiffChange", { fg = p.fg, bg = p.diff_modify_bg })
  set("DiffText", { fg = p.fg, bg = p.diff_add_hl_bg, bold = true })

  -- Standard Vim diff syntax & generic VCS diff tokens
  set("diffAdded", { fg = p.string })
  set("diffRemoved", { fg = p.diag_error_fg })
  set("diffChanged", { fg = p.func })
  set("diffFile", { fg = p.keyword, bold = true })
  set("diffNewFile", { fg = p.string, bold = true })
  set("diffOldFile", { fg = p.diag_error_fg, bold = true })
  set("diffLine", { fg = p.constant, bold = true })
  set("diffSubname", { fg = p.comment })
  set("diffIndexLine", { fg = p.keyword })

  -- Neovim 0.10+ standard diff groups
  set("Added", { fg = p.string })
  set("Removed", { fg = p.diag_error_fg })
  set("Changed", { fg = p.func })

  set("GitSignsAdd", { fg = p.string })
  set("GitSignsChange", { fg = p.func })
  set("GitSignsDelete", { fg = p.diag_error_fg })
  set("GitSignsCurrentLineBlame", { fg = "#5a5a64", italic = true })

  -----------------------------------------------------------------------------
  -- 4. Diagnostics & Spell
  -----------------------------------------------------------------------------
  set("DiagnosticError", { fg = p.diag_error_fg })
  set("DiagnosticWarn", { fg = p.diag_warning_fg })
  set("DiagnosticInfo", { fg = p.diag_info_fg })
  set("DiagnosticHint", { fg = p.diag_hint_fg })
  set("DiagnosticOk", { fg = p.string })

  set("DiagnosticUnderlineError", { undercurl = true, sp = p.diag_error_fg })
  set("DiagnosticUnderlineWarn", { undercurl = true, sp = p.diag_warning_fg })
  set("DiagnosticUnderlineInfo", { undercurl = true, sp = p.diag_info_fg })
  set("DiagnosticUnderlineHint", { undercurl = true, sp = p.diag_hint_fg })

  set("DiagnosticVirtualTextError", { fg = p.diag_error_fg, bg = p.diag_error_bg })
  set("DiagnosticVirtualTextWarn", { fg = p.diag_warning_fg, bg = p.diag_warning_bg })
  set("DiagnosticVirtualTextInfo", { fg = p.diag_info_fg, bg = p.diag_info_bg })
  set("DiagnosticVirtualTextHint", { fg = p.diag_hint_fg, bg = p.diag_hint_bg })

  set("DiagnosticFloatingError", { fg = p.diag_error_fg, bg = p.popup_bg })
  set("DiagnosticFloatingWarn", { fg = p.diag_warning_fg, bg = p.popup_bg })
  set("DiagnosticFloatingInfo", { fg = p.diag_info_fg, bg = p.popup_bg })
  set("DiagnosticFloatingHint", { fg = p.diag_hint_fg, bg = p.popup_bg })

  set("SpellBad", { undercurl = true, sp = p.diag_error_fg })
  set("SpellCap", { undercurl = true, sp = p.diag_warning_fg })
  set("SpellLocal", { undercurl = true, sp = p.diag_info_fg })
  set("SpellRare", { undercurl = true, sp = p.constant })

  -----------------------------------------------------------------------------
  -- 5. Standard Syntax (1:1 with Fresh)
  -----------------------------------------------------------------------------
  set("Comment", { fg = p.comment, italic = true })
  set("SpecialComment", { fg = p.comment, italic = true, bold = true })

  set("Constant", { fg = p.constant })
  set("String", { fg = p.string })
  set("Character", { fg = p.string })
  set("Number", { fg = p.constant })
  set("Boolean", { fg = p.constant, bold = true })
  set("Float", { fg = p.constant })

  set("Identifier", { fg = p.variable })
  set("Function", { fg = p.func, bold = true })

  set("Statement", { fg = p.keyword, bold = true })
  set("Conditional", { fg = p.keyword, bold = true })
  set("Repeat", { fg = p.keyword, bold = true })
  set("Label", { fg = p.func, bold = true })
  set("Operator", { fg = p.operator })
  set("Keyword", { fg = p.keyword, bold = true })
  set("Exception", { fg = p.diag_error_fg, bold = true })

  set("PreProc", { fg = p.type })
  set("Include", { fg = p.type })
  set("Define", { fg = p.type })
  set("Macro", { fg = p.type })
  set("PreCondit", { fg = p.type })

  set("Type", { fg = p.type, bold = true })
  set("StorageClass", { fg = p.keyword })
  set("Structure", { fg = p.type, bold = true })
  set("Typedef", { fg = p.type, bold = true })

  set("Special", { fg = p.keyword })
  set("SpecialChar", { fg = p.constant })
  set("Tag", { fg = p.keyword })
  set("Delimiter", { fg = p.operator })
  set("Debug", { fg = p.diag_warning_fg })

  set("Underlined", { underline = true })
  set("Ignore", { fg = p.inactive_cursor })
  set("Error", { fg = p.fg, bg = p.diff_remove_bg, bold = true })
  set("Todo", { fg = p.tab_active_fg, bg = p.tab_active_bg, bold = true })

  -----------------------------------------------------------------------------
  -- 6. Treesitter
  -----------------------------------------------------------------------------
  set("@comment", { link = "Comment" })
  set("@comment.documentation", { fg = p.comment, italic = true })
  set("@comment.error", { fg = p.diag_error_fg, bold = true })
  set("@comment.warning", { fg = p.diag_warning_fg, bold = true })
  set("@comment.todo", { link = "Todo" })
  set("@comment.note", { fg = p.keyword, bold = true })

  set("@constant", { link = "Constant" })
  set("@constant.builtin", { fg = p.constant, bold = true })
  set("@constant.macro", { fg = p.constant, bold = true })

  set("@string", { link = "String" })
  set("@string.documentation", { fg = p.string, italic = true })
  set("@string.regex", { fg = p.constant })
  set("@string.escape", { fg = p.constant, bold = true })
  set("@string.special", { fg = p.constant })
  set("@character", { link = "Character" })
  set("@character.special", { fg = p.constant })

  set("@number", { link = "Number" })
  set("@number.float", { link = "Float" })
  set("@boolean", { link = "Boolean" })

  set("@function", { link = "Function" })
  set("@function.builtin", { fg = p.func, bold = true })
  set("@function.call", { fg = p.func })
  set("@function.macro", { fg = p.type, bold = true })
  set("@function.method", { fg = p.func })
  set("@function.method.call", { fg = p.func })
  set("@method", { fg = p.func })
  set("@method.call", { fg = p.func })
  set("@constructor", { fg = p.type, bold = true })

  set("@keyword", { link = "Keyword" })
  set("@keyword.function", { fg = p.keyword, bold = true })
  set("@keyword.operator", { fg = p.keyword })
  set("@keyword.return", { fg = p.keyword, bold = true })
  set("@keyword.coroutine", { fg = p.keyword, bold = true })
  set("@keyword.exception", { fg = p.diag_error_fg, bold = true })
  set("@keyword.import", { fg = p.type, bold = true })
  set("@keyword.conditional", { fg = p.keyword, bold = true })
  set("@keyword.repeat", { fg = p.keyword, bold = true })
  set("@keyword.type", { fg = p.type, bold = true })

  set("@operator", { link = "Operator" })
  set("@variable", { link = "Identifier" })
  set("@variable.builtin", { fg = p.constant, bold = true })
  set("@variable.parameter", { fg = p.variable })
  set("@variable.member", { fg = p.variable })
  set("@property", { fg = p.variable })
  set("@field", { fg = p.variable })

  set("@type", { link = "Type" })
  set("@type.builtin", { fg = p.type, bold = true })
  set("@type.definition", { fg = p.type, bold = true })
  set("@type.qualifier", { fg = p.keyword })
  set("@storageclass", { fg = p.keyword })
  set("@structure", { fg = p.type, bold = true })
  set("@namespace", { fg = p.type, bold = true })
  set("@module", { fg = p.type, bold = true })

  set("@punctuation.delimiter", { fg = p.operator })
  set("@punctuation.bracket", { fg = p.operator })
  set("@punctuation.special", { fg = p.operator })

  set("@tag", { fg = p.keyword, bold = true })
  set("@tag.attribute", { fg = p.func })
  set("@tag.delimiter", { fg = p.operator })

  set("@markup.heading", { fg = p.func, bold = true })
  set("@markup.heading.1", { fg = p.tab_active_bg, bold = true })
  set("@markup.heading.2", { fg = p.keyword, bold = true })
  set("@markup.heading.3", { fg = p.type, bold = true })
  set("@markup.heading.4", { fg = p.constant, bold = true })
  set("@markup.strong", { bold = true })
  set("@markup.italic", { italic = true })
  set("@markup.link", { fg = p.keyword, underline = true })
  set("@markup.link.url", { fg = p.constant, underline = true })
  set("@markup.raw", { fg = p.string })
  set("@markup.list", { fg = p.keyword })

  -----------------------------------------------------------------------------
  -- 7. Standard tab surfaces
  --
  -- Components such as bufferline consume these standard groups through the
  -- theme-agnostic UI adapter.  The theme owns the semantic colors; it does
  -- not own any plugin-specific BufferLine* groups.
  -----------------------------------------------------------------------------
  -- Standard surfaces consumed by the theme-agnostic UI adapter:
  -- inactive tabs, the bufferline fill, the path bar, and the active tab
  -- remain visually distinct without exposing BufferLine-specific groups.
  set("TabLine", { fg = p.inactive_cursor, bg = p.tab_inactive_surface_bg })
  set("TabLineFill", { fg = p.inactive_cursor, bg = p.tab_inactive_surface_bg })
  set("TabLineSel", { fg = p.tab_active_fg, bg = p.tab_active_bg, bold = true })

  -----------------------------------------------------------------------------
  -- 8. Heirline / Statusline / WinBar
  -----------------------------------------------------------------------------
  set("StatusLine", { fg = p.status_bar_fg, bg = p.status_bar_bg })
  set("StatusLineNC", { fg = p.inactive_cursor, bg = p.status_bar_bg })
  set("WinBar", { fg = p.fg, bg = p.tab_hover_bg })
  set("WinBarNC", { fg = p.inactive_cursor, bg = p.tab_hover_bg })
  set("MsgArea", { fg = p.fg, bg = p.menu_dropdown_bg })
  set("Cmdline", { fg = p.fg, bg = p.menu_dropdown_bg })

  -----------------------------------------------------------------------------
  -- 9. Neo-tree
  -----------------------------------------------------------------------------
  set("NeoTreeNormal", { fg = p.fg, bg = p.bg })
  set("NeoTreeNormalNC", { fg = p.fg, bg = p.bg })
  set("NeoTreeWinSeparator", { fg = p.win_separator_fg, bg = p.bg })
  set("NeoTreeRootName", { fg = p.popup_border_fg, bg = p.bg, bold = true })
  set("NeoTreeDirectoryName", { fg = p.fg, bg = p.bg })
  set("NeoTreeDirectoryIcon", { fg = p.popup_border_fg, bg = p.bg })
  set("NeoTreeFileName", { fg = p.fg, bg = p.bg })
  set("NeoTreeFileNameOpened", { fg = p.func, bg = p.current_line_bg, bold = true })
  set("NeoTreeIndentMarker", { fg = p.split_separator_fg, bg = p.bg })
  set("NeoTreeExpander", { fg = p.popup_border_fg, bg = p.bg })
  set("NeoTreeGitModified", { fg = p.func, bg = p.bg })
  set("NeoTreeGitAdded", { fg = p.string, bg = p.bg })
  set("NeoTreeGitDeleted", { fg = p.diag_error_fg, bg = p.bg })
  set("NeoTreeCursorLine", { bg = p.current_line_bg })

  -----------------------------------------------------------------------------
  -- 11. Snacks Picker & Telescope & WhichKey
  -----------------------------------------------------------------------------
  set("SnacksPicker", { fg = p.fg, bg = p.popup_bg })
  set("SnacksPickerBorder", { fg = p.split_separator_fg, bg = p.popup_bg })
  set("SnacksPickerMatch", { fg = p.func, bold = true })
  set("SnacksPickerSelected", { fg = p.menu_highlight_fg, bg = p.menu_highlight_bg, bold = true })
  set("SnacksPickerTitle", { fg = p.status_palette_fg, bg = p.status_palette_bg, bold = true })

  set("TelescopeNormal", { fg = p.fg, bg = p.popup_bg })
  set("TelescopeBorder", { fg = p.split_separator_fg, bg = p.popup_bg })
  set("TelescopePromptNormal", { fg = p.prompt_fg, bg = p.prompt_bg })
  set("TelescopePromptBorder", { fg = p.split_separator_fg, bg = p.prompt_bg })
  set("TelescopeSelection", { fg = p.menu_highlight_fg, bg = p.menu_highlight_bg, bold = true })
  set("TelescopeMatching", { fg = p.func, bold = true })
  set("TelescopeTitle", { fg = p.status_palette_fg, bg = p.status_palette_bg, bold = true })

  set("WhichKey", { fg = p.func, bold = true })
  set("WhichKeyGroup", { fg = p.keyword })
  set("WhichKeyDesc", { fg = p.fg })
  set("WhichKeySeparator", { fg = p.split_separator_fg })
  set("WhichKeyBorder", { fg = p.split_separator_fg, bg = p.popup_bg })
  set("WhichKeyTitle", { fg = p.func, bold = true, bg = "NONE" })

  set("LazyNormal", { fg = p.fg, bg = p.popup_bg })
  set("LazyBorder", { fg = p.split_separator_fg, bg = p.popup_bg })
  set("MasonNormal", { fg = p.fg, bg = p.popup_bg })
  set("MasonBorder", { fg = p.split_separator_fg, bg = p.popup_bg })

  -----------------------------------------------------------------------------
  -- 12. Completion (Blink.cmp & Nvim-cmp)
  -----------------------------------------------------------------------------
  set("BlinkCmpMenu", { fg = p.menu_dropdown_fg, bg = p.menu_dropdown_bg })
  set("BlinkCmpMenuBorder", { fg = p.split_separator_fg, bg = p.menu_dropdown_bg })
  set("BlinkCmpMenuSelection", { fg = p.menu_highlight_fg, bg = p.menu_highlight_bg, bold = true })
  set("BlinkCmpLabel", { fg = p.menu_dropdown_fg })
  set("BlinkCmpLabelMatch", { fg = p.func, bold = true })
  set("BlinkCmpDoc", { fg = p.fg, bg = p.popup_bg })
  set("BlinkCmpDocBorder", { fg = p.split_separator_fg, bg = p.popup_bg })

  set("CmpItemAbbr", { fg = p.menu_dropdown_fg })
  set("CmpItemAbbrMatch", { fg = p.func, bold = true })
  set("CmpItemKindFunction", { fg = p.func })
  set("CmpItemKindMethod", { fg = p.func })
  set("CmpItemKindVariable", { fg = p.variable })
  set("CmpItemKindKeyword", { fg = p.keyword })
  set("CmpItemKindType", { fg = p.type })

  -----------------------------------------------------------------------------
  -- 13. COBOL Syntax & cobol.nvim Integration
  -----------------------------------------------------------------------------
  set("cobolDivisionName", { fg = p.func, bg = p.bg, bold = true })
  set("cobolSectionName", { fg = p.keyword, bg = p.bg, bold = true })
  set("cobolParagraphName", { fg = p.func, bg = p.bg, bold = true })
  set("cobolReserved", { fg = p.keyword, bg = p.bg })
  set("cobolConstant", { fg = p.constant, bg = p.bg })
  set("cobolNumber", { fg = p.constant, bg = p.bg })
  set("cobolPic", { fg = p.type, bg = p.bg })
  set("cobolComment", { fg = p.comment, bg = p.bg, italic = true })
  set("cobolInlineComment", { fg = p.comment, bg = p.bg, italic = true })
  set("cobolTodo", { fg = p.tab_active_fg, bg = p.tab_active_bg, bold = true })
  set("cobolCopy", { fg = p.type, bg = p.bg, bold = true })
  set("cobolCopyName", { fg = p.type, bg = p.bg })
  set("cobolGoTo", { fg = p.diag_error_fg, bg = p.bg, bold = true })
  set("cobolGoToPara", { fg = p.diag_error_fg, bg = p.bg })
  set("cobolBAD", { fg = p.fg, bg = p.diff_remove_bg, bold = true })
  set("cobolBadLine", { fg = p.fg, bg = p.diff_remove_bg, bold = true })

  -- cobol.nvim custom groups
  set("CobolRulerLine", { fg = "#3b638c", bg = "NONE" })
  set("CobolRulerLineInd", { fg = "#4c78a8", bg = "NONE" })
  set("CobolRulerBase", { fg = p.inactive_cursor, bg = p.current_line_bg })
  set("CobolRulerSeq", { fg = p.inactive_cursor, bg = p.current_line_bg })
  set("CobolRulerInd", { fg = p.tab_active_fg, bg = p.tab_active_bg, bold = true })
  set("CobolRulerAreaA", { fg = p.status_palette_fg, bg = p.status_palette_bg, bold = true })
  set("CobolRulerAreaB", { fg = p.string, bg = p.current_line_bg })
  set("CobolRulerIdent", { fg = p.diag_error_fg, bg = p.current_line_bg })

  set("CobolBreadcrumbProc", { fg = p.func, bg = "NONE", bold = true })
  set("CobolBreadcrumbData", { fg = p.type, bg = "NONE", bold = true })
  set("CobolBreadcrumbEnv", { fg = p.keyword, bg = "NONE", bold = true })
  set("CobolBreadcrumbId", { fg = p.constant, bg = "NONE", bold = true })

  set("CobolLevel88", { fg = p.type, bold = true })
  set("CobolConditionName", { fg = p.func, bold = true })
  set("CobolLevel01", { fg = p.keyword, bold = true })
  set("CobolHierarchyHint", { fg = p.inactive_cursor, italic = true })

  set("CobolColumnOverflow", {
    fg = p.diag_error_fg,
    bg = p.diag_error_bg,
    undercurl = true,
    sp = p.diag_error_fg,
    bold = true,
  })

  -----------------------------------------------------------------------------
  -- 14. Satellite Scrollbar
  -----------------------------------------------------------------------------
  set("SatelliteBackground", { bg = "#25252a" }) -- 传统 UI 滚动条淡灰色背景轨道
  set("SatelliteBar", { bg = p.tab_active_bg })  -- 滚动条滑块（高亮黄色）
  set("SatelliteCursor", { fg = p.fg })

  -----------------------------------------------------------------------------
  -- 15. Rainbow Delimiters
  -----------------------------------------------------------------------------
  set("RainbowDelimiterYellow", { fg = p.func })
  set("RainbowDelimiterCyan",   { fg = p.keyword })
  set("RainbowDelimiterBlue",   { fg = "#569cd6" })
  set("RainbowDelimiterOrange", { fg = p.type })
  set("RainbowDelimiterGreen",  { fg = p.string })
  set("RainbowDelimiterViolet", { fg = "#c586c0" })
  set("RainbowDelimiterRed",    { fg = p.diag_error_fg })

  -----------------------------------------------------------------------------
  -- 16. Diffview
  -----------------------------------------------------------------------------
  set("DiffviewNormal",              { fg = p.fg, bg = p.bg })
  set("DiffviewPrimary",             { fg = p.keyword })
  set("DiffviewSecondary",           { fg = p.comment })
  set("DiffviewFilePanelTitle",      { fg = p.keyword, bold = true })
  set("DiffviewFilePanelCounter",    { fg = p.func, bold = true })
  set("DiffviewFilePanelFileName",   { fg = p.fg })
  set("DiffviewFilePanelPath",       { fg = p.comment })
  set("DiffviewFilePanelRootPath",   { fg = p.keyword, bold = true })
  set("DiffviewFilePanelSelected",   { fg = p.fg, bg = p.selection_editor_bg, bold = true })
  set("DiffviewFilePanelInsertions", { fg = p.string })
  set("DiffviewFilePanelDeletions",  { fg = p.diag_error_fg })
  set("DiffviewFilePanelConflicts",  { fg = p.diag_warning_fg, bold = true })
  set("DiffviewFolderName",          { fg = p.keyword, bold = true })
  set("DiffviewFolderSign",          { fg = p.constant })
  set("DiffviewHash",                { fg = p.constant })
  set("DiffviewReference",           { fg = p.keyword })
  set("DiffviewReflogSelector",      { fg = p.type })
  set("DiffviewStatusAdded",         { fg = p.string, bold = true })
  set("DiffviewStatusUntracked",     { fg = p.string })
  set("DiffviewStatusModified",      { fg = p.func, bold = true })
  set("DiffviewStatusRenamed",       { fg = p.func })
  set("DiffviewStatusCopied",        { fg = p.func })
  set("DiffviewStatusTypeChanged",   { fg = p.func })
  set("DiffviewStatusUnmerged",      { fg = p.diag_warning_fg, bold = true })
  set("DiffviewStatusDeleted",       { fg = p.diag_error_fg, bold = true })
  set("DiffviewStatusBroken",        { fg = p.diag_error_fg })
  set("DiffviewStatusUnknown",       { fg = p.diag_error_fg })
  set("DiffviewStatusIgnored",       { fg = p.comment })
  set("DiffviewDim1",                { fg = p.comment })

  -----------------------------------------------------------------------------
  -- 17. nvim-ufo (Code Folding)
  -----------------------------------------------------------------------------
  set("UfoFoldedEllipsis", { fg = p.func, bold = true })
  set("UfoPreviewThumb",   { bg = p.tab_active_bg })
  set("UfoPreviewWinSpec", { bg = p.current_line_bg })

end

return M
