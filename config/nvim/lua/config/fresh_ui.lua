-- Fresh high-contrast-plus inspired UI palette.
-- Keep this separate from the syntax colorscheme so UI components can be
-- adjusted without changing COBOL and other language colors.

local M = {}

local colors = {
  black = "#000000",
  white = "#ffffff",
  dark = "#141414",
  panel = "#323237",
  tab_fill = "#000000",
  tab_inactive = "#000000",
  tab_active = "#ffff00",
  line = "#1e1e23",
  gray = "#7f7f7f",
  gray_light = "#8c8c8c",
  blue = "#0064c8",
  cyan = "#00ffff",
  magenta = "#ff00ff",
  yellow = "#ffff00",
  green = "#005000",
  red = "#640000",
}

local function set(group, spec)
  vim.api.nvim_set_hl(0, group, spec)
end

function M.apply()
  -- Editor and separators.
  set("Normal", { fg = colors.white, bg = colors.black })
  set("NormalFloat", { fg = colors.white, bg = colors.black })
  set("NormalNC", { fg = colors.white, bg = colors.black })
  set("CursorLine", { bg = colors.dark })
  set("CursorColumn", { bg = colors.dark })
  set("LineNr", { fg = colors.white, bg = colors.black })
  set("CursorLineNr", { fg = colors.yellow, bg = colors.dark, bold = true })
  set("SignColumn", { fg = colors.white, bg = colors.black })
  set("FoldColumn", { fg = colors.cyan, bg = colors.black })
  set("WinSeparator", { fg = colors.gray_light, bg = colors.black })
  set("VertSplit", { fg = colors.gray_light, bg = colors.black })
  set("ColorColumn", { bg = "#323200" })

  -- Fresh-like selection, menus, prompts and borders.
  set("Visual", { fg = colors.white, bg = colors.blue })
  set("Search", { fg = colors.black, bg = colors.cyan, bold = true })
  set("IncSearch", { fg = colors.black, bg = colors.yellow, bold = true })
  set("FloatBorder", { fg = colors.cyan, bg = colors.black })
  set("FloatTitle", { fg = colors.black, bg = colors.cyan, bold = true })
  set("Pmenu", { fg = colors.white, bg = colors.panel })
  set("PmenuSel", { fg = colors.white, bg = colors.blue, bold = true })
  set("PmenuBorder", { fg = colors.cyan, bg = colors.black })
  set("WildMenu", { fg = colors.black, bg = colors.yellow, bold = true })
  set("Directory", { fg = colors.cyan, bg = colors.black, bold = true })
  set("Title", { fg = colors.yellow, bg = colors.black, bold = true })

  -- Neo-tree sidebar.
  set("NeoTreeNormal", { fg = colors.white, bg = colors.black })
  set("NeoTreeNormalNC", { fg = colors.white, bg = colors.black })
  set("NeoTreeWinSeparator", { fg = colors.cyan, bg = colors.black })
  set("NeoTreeRootName", { fg = colors.cyan, bg = colors.black, bold = true })
  set("NeoTreeDirectoryName", { fg = colors.white, bg = colors.black })
  set("NeoTreeDirectoryIcon", { fg = colors.cyan, bg = colors.black })
  set("NeoTreeFileName", { fg = colors.white, bg = colors.black })
  set("NeoTreeFileNameOpened", { fg = colors.yellow, bg = colors.dark, bold = true })
  set("NeoTreeIndentMarker", { fg = colors.cyan, bg = colors.black })
  set("NeoTreeExpander", { fg = colors.cyan, bg = colors.black })
  set("NeoTreeGitModified", { fg = colors.yellow, bg = colors.black })
  set("NeoTreeGitAdded", { fg = colors.cyan, bg = colors.black })
  set("NeoTreeGitDeleted", { fg = "#ff3c3c", bg = colors.black })

  -- Bufferline: yellow active buffer, blue hover/selection accents.
  set("BufferLineFill", { fg = colors.gray, bg = colors.tab_fill })
  set("BufferLineBackground", { fg = colors.white, bg = colors.tab_inactive })
  set("BufferLineBuffer", { fg = colors.white, bg = colors.tab_inactive })
  set("BufferLineBufferVisible", { fg = colors.white, bg = colors.dark })
  set("BufferLineBufferSelected", { fg = colors.black, bg = colors.tab_active, bold = true })
  set("BufferLineTab", { fg = colors.gray, bg = colors.tab_inactive })
  set("BufferLineTabSelected", { fg = colors.black, bg = colors.tab_active, bold = true })
  set("BufferLineSeparator", { fg = colors.line, bg = colors.tab_inactive })
  set("BufferLineSeparatorVisible", { fg = colors.line, bg = colors.dark })
  set("BufferLineSeparatorSelected", { fg = colors.tab_active, bg = colors.tab_active })
  set("BufferLineModified", { fg = colors.yellow, bg = colors.tab_inactive })
  set("BufferLineModifiedVisible", { fg = colors.yellow, bg = colors.dark })
  set("BufferLineModifiedSelected", { fg = colors.black, bg = colors.tab_active, bold = true })
  set("BufferLineCloseButton", { fg = colors.gray, bg = colors.tab_inactive })
  set("BufferLineCloseButtonSelected", { fg = colors.black, bg = colors.tab_active })
  set("BufferLineIndicatorSelected", { fg = colors.tab_active, bg = colors.tab_active })
  set("BufferLineOffsetSeparator", { fg = colors.cyan, bg = colors.tab_fill })

  -- bufferline creates one DevIcon group per file type.  Its generated
  -- groups can retain the old theme background, so explicitly synchronize
  -- them with the surrounding buffer state.
  for _, group in ipairs(vim.fn.getcompletion("BufferLineDevIcon", "highlight")) do
    if group:match("Selected$") then
      set(group, { fg = colors.black, bg = colors.tab_active })
    elseif group:match("Visible$") then
      set(group, { fg = colors.white, bg = colors.tab_inactive })
    else
      set(group, { fg = colors.white, bg = colors.tab_inactive })
    end
  end

  -- nvim-scrollbar: gray track and yellow thumb, matching Fresh.
  set("ScrollbarHandle", { fg = colors.yellow, bg = colors.yellow })
  set("ScrollbarSearch", { fg = colors.black, bg = colors.cyan })
  set("ScrollbarError", { fg = colors.black, bg = "#ff3c3c" })
  set("ScrollbarWarn", { fg = colors.black, bg = colors.yellow })
  set("ScrollbarInfo", { fg = colors.black, bg = colors.blue })
  set("ScrollbarHint", { fg = colors.black, bg = colors.cyan })

  -- Heirline winbar and status-like components.
  set("WinBar", { fg = colors.white, bg = colors.black })
  set("WinBarNC", { fg = colors.gray, bg = colors.black })
  set("StatusLine", { fg = colors.white, bg = colors.panel })
  set("StatusLineNC", { fg = colors.gray, bg = colors.panel })
  set("MsgArea", { fg = colors.white, bg = colors.panel })
  set("Cmdline", { fg = colors.white, bg = colors.panel })
  set("ModeMsg", { fg = colors.cyan, bg = colors.panel, bold = true })
  set("MoreMsg", { fg = colors.cyan, bg = colors.panel, bold = true })

  if vim.bo.filetype == "cobol" then
    M.apply_cobol()
  end
end

function M.apply_cobol()
  -- Neovim ships COBOL syntax recognition, but most colorschemes do not style
  -- its cobol* groups.  Keep these colors local to COBOL buffers.
  set("cobolDivisionName", { fg = colors.yellow, bg = colors.black, bold = true })
  set("cobolSectionName", { fg = colors.cyan, bg = colors.black, bold = true })
  set("cobolParagraphName", { fg = colors.yellow, bg = colors.black, bold = true })
  set("cobolReserved", { fg = colors.cyan, bg = colors.black })
  set("cobolConstant", { fg = colors.blue, bg = colors.black })
  set("cobolNumber", { fg = colors.green, bg = colors.black })
  set("cobolPic", { fg = colors.blue, bg = colors.black })
  set("cobolComment", { fg = colors.gray_light, bg = colors.black, italic = true })
  set("cobolInlineComment", { fg = colors.gray_light, bg = colors.black, italic = true })
  set("cobolTodo", { fg = colors.black, bg = colors.yellow, bold = true })
  set("cobolCopy", { fg = colors.magenta, bg = colors.black, bold = true })
  set("cobolCopyName", { fg = colors.magenta, bg = colors.black })
  set("cobolGoTo", { fg = colors.red, bg = colors.black, bold = true })
  set("cobolGoToPara", { fg = colors.red, bg = colors.black })
  set("cobolBAD", { fg = colors.black, bg = colors.red, bold = true })
  set("cobolBadLine", { fg = colors.black, bg = colors.red, bold = true })
end

-- These values are supplied to bufferline before it creates its dynamic
-- BufferLineDevIcon* groups.  Keeping them here avoids a second palette.
function M.bufferline_highlights()
  return {
    fill = { fg = colors.gray, bg = colors.tab_fill },
    background = { fg = colors.white, bg = colors.tab_inactive },
    buffer = { fg = colors.white, bg = colors.tab_inactive },
    buffer_visible = { fg = colors.white, bg = colors.dark },
    buffer_selected = { fg = colors.black, bg = colors.tab_active, bold = true },
    tab = { fg = colors.white, bg = colors.tab_inactive },
    tab_selected = { fg = colors.black, bg = colors.tab_active, bold = true },
    separator = { fg = colors.black, bg = colors.tab_inactive },
    separator_visible = { fg = colors.dark, bg = colors.dark },
    separator_selected = { fg = colors.tab_active, bg = colors.tab_active },
    modified = { fg = colors.yellow, bg = colors.tab_inactive },
    modified_visible = { fg = colors.yellow, bg = colors.dark },
    modified_selected = { fg = colors.black, bg = colors.tab_active },
    close_button = { fg = colors.white, bg = colors.tab_inactive },
    close_button_visible = { fg = colors.white, bg = colors.dark },
    close_button_selected = { fg = colors.black, bg = colors.tab_active },
    numbers = { fg = colors.white, bg = colors.tab_inactive },
    numbers_visible = { fg = colors.white, bg = colors.dark },
    numbers_selected = { fg = colors.black, bg = colors.tab_active, bold = true },
    indicator_selected = { fg = colors.tab_active, bg = colors.tab_active },
    indicator_visible = { fg = colors.dark, bg = colors.dark },
  }
end

vim.api.nvim_create_autocmd("ColorScheme", {
  callback = function()
    vim.schedule(M.apply)
  end,
})

vim.api.nvim_create_autocmd("User", {
  pattern = "VeryLazy",
  callback = M.apply,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "cobol", "cbl", "cob" },
  callback = M.apply_cobol,
})

M.apply()

-- bufferline/neo-tree may apply their own highlight tables after VeryLazy.
-- Re-apply once after those plugin configs have finished.
vim.defer_fn(M.apply, 500)
vim.defer_fn(M.apply, 1500)

vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter", "TabEnter" }, {
  callback = function()
    vim.defer_fn(M.apply, 100)
  end,
})

return M
