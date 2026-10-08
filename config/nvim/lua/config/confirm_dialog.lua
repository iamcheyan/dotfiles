-- Presentation only: Neovim still owns the confirmation and its input keys.
local M = {}
local last_confirm

local function width()
  return math.max(1, math.min(64, vim.o.columns - 10))
end

local function append_wrapped(message, text, highlight, columns)
  for _, line in ipairs(vim.split(text, "\n", { plain = true })) do
    while vim.fn.strdisplaywidth(line) > columns do
      local count, used, boundary = 0, 0, nil
      for i = 0, vim.fn.strchars(line) - 1 do
        local char = vim.fn.strcharpart(line, i, 1)
        local cells = vim.fn.strdisplaywidth(char)
        if used + cells > columns then break end
        count, used = i + 1, used + cells
        if char == "/" or char == "\\" or char == " " then boundary = count end
      end
      count = boundary or math.max(count, 1)
      message:append(vim.fn.strcharpart(line, 0, count), highlight)
      message:newline()
      line = vim.fn.strcharpart(line, count)
    end
    message:append(line, highlight)
    message:newline()
  end
end

-- 0.11+ joins the question and button prompt on one line; older versions
-- separate them with a newline. Parse from the button tokens in either case.
local function parse(text)
  text = vim.trim(text):gsub(":%s*$", "")
  for start in text:gmatch("()[%[%(][^%]%)]+[%]%)]") do
    local buttons, valid = {}, true
    for _, token in ipairs(vim.split(text:sub(start), ", ", { plain = true })) do
      local opening, key, suffix = token:match("^([%[%(])([^%]%)]+)[%]%)](.*)$")
      if not key or suffix:find("[\n%[%]%(%)%,]") then
        valid = false
        break
      end
      buttons[#buttons + 1] = {
        key = key,
        label = key .. suffix,
        default = opening == "[",
      }
    end
    if valid and #buttons > 0 then
      return vim.trim(text:sub(1, start - 1)), buttons
    end
  end
end

local function button_signature(buttons)
  return table.concat(vim.tbl_map(function(button)
    return table.concat({ button.key, button.label, tostring(button.default) }, ":")
  end, buttons), "|")
end

function M.format(message, _opts, input)
  if input.kind ~= "confirm" then
    return message:append(input)
  end
  local question, buttons = parse(input:content())
  if buttons then
    -- Neovim may suppress an identical msg_show.confirm event on a repeated
    -- confirm(), while still sending cmdline_show with the Y/N/C prompt.
    last_confirm = { content = input:content(), buttons = button_signature(buttons) }
  end
  if not question then
    -- Unknown/localized prompt formats retain their complete original text.
    return message:append(input)
  end

  local columns = width()
  local path = question:match('^Save changes to "(.-)"%?$')
  if path then
    append_wrapped(message, "Save changes before closing?", "ConfirmDialogHeading", columns)
    message:newline()
    local directory, filename = path:match("^(.*[/\\])([^/\\]+)$")
    append_wrapped(message, filename or path, "ConfirmDialogFilename", columns)
    if directory then
      append_wrapped(message, directory, "ConfirmDialogPath", columns)
    end
  else
    append_wrapped(message, question, "ConfirmDialogHeading", columns)
  end
  message:newline()
  message:append(string.rep("─", columns), "ConfirmDialogDivider")
  message:newline()
  message:newline()

  local row, rows = {}, {}
  local row_width = 0
  for _, button in ipairs(buttons) do
    local label = button.label
    if path then
      label = ({ yes = "Save", no = "Discard", cancel = "Cancel" })[label:lower()] or label
    end
    local text = " " .. button.key .. "  " .. label .. " "
    local cells = vim.fn.strdisplaywidth(text)
    if row_width > 0 and row_width + 3 + cells > columns then
      rows[#rows + 1] = { buttons = row, width = row_width }
      row, row_width = {}, 0
    end
    row_width = row_width + (#row > 0 and 3 or 0) + cells
    row[#row + 1] = { text = text, default = button.default }
  end
  rows[#rows + 1] = { buttons = row, width = row_width }
  for _, current in ipairs(rows) do
    message:append(string.rep(" ", math.max(0, math.floor((columns - current.width) / 2))))
    for i, button in ipairs(current.buttons) do
      if i > 1 then message:append("   ") end
      local hl = button.default and "ConfirmDialogPrimary" or "ConfirmDialogButton"
      message:append(button.text, hl)
    end
    message:newline()
  end
  message:newline()
  append_wrapped(message, "Press the highlighted letter · Enter selects the default", "ConfirmDialogHint", columns)
  message:trim_empty_lines()
end

function M.highlights()
  local dark = vim.o.background ~= "light"
  local bg = dark and "#182033" or "#f3f5fa"
  local fg = dark and "#e6edf6" or "#25324b"
  local muted = dark and "#a0aec5" or "#586b85"
  local accent = dark and "#87d7e3" or "#246b83"
  local border = dark and "#536985" or "#8b9db6"
  local divider = dark and "#364760" or "#c5cfde"
  local button_bg = dark and "#2b3850" or "#e1e7f0"
  local primary_bg, primary_fg = accent, bg

  -- The built-in Blue scheme is customized elsewhere in this config to match
  -- the Nostalgia blue/cyan/yellow palette. Reuse that palette and the live
  -- Normal background so the confirmation card belongs to the editor surface.
  local palette = vim.g.colors_name == "blue" and require("config.ui_highlights").nostalgia_palette()
  if palette then
    local normal = vim.api.nvim_get_hl(0, { name = "Normal", link = false })
    bg = normal.bg or palette.editor_bg
    fg = palette.editor_fg
    muted = palette.line_number_fg
    accent = palette.syntax_string
    border = palette.popup_border_fg
    divider = palette.split_separator_fg
    button_bg = palette.current_line_bg
    primary_bg, primary_fg = palette.status_bar_bg, palette.status_bar_fg
  end
  local groups = {
    ConfirmDialogHiddenCursor = { blend = 100, nocombine = true },
    ConfirmDialogNormal = { fg = fg, bg = bg },
    ConfirmDialogBorder = { fg = border, bg = bg },
    ConfirmDialogHeading = { fg = palette and palette.syntax_function or fg, bold = true },
    ConfirmDialogFilename = { fg = accent, bold = true },
    ConfirmDialogPath = { fg = muted },
    ConfirmDialogDivider = { fg = divider },
    ConfirmDialogPrimary = { fg = primary_fg, bg = primary_bg, bold = true },
    ConfirmDialogButton = { fg = fg, bg = button_bg },
    ConfirmDialogHint = { fg = muted },
  }
  for name, values in pairs(groups) do vim.api.nvim_set_hl(0, name, values) end
end

function M.setup()
  require("noice.text.format.formatters").dialog = M.format

  -- Noice normally pairs msg_show.confirm with the following cmdline_show.
  -- For repeated identical confirmations, Neovim can send only cmdline_show;
  -- turn that prompt back into the cached dialog instead of drawing it below.
  local Cmdline = require("noice.ui.cmdline")
  local Manager = require("noice.message.manager")
  local Message = require("noice.message")
  local saved_cursor
  local function hide_cursor()
    if saved_cursor == nil then saved_cursor = vim.o.guicursor end
    vim.o.guicursor = "a:ConfirmDialogHiddenCursor"
  end
  local on_show = Cmdline.on_show
  Cmdline.on_show = function(event, content, pos, firstc, prompt, indent, level)
    -- Unlike ordinary command entry, a confirm card has no text cursor.
    -- Noice's confirm shortcut skips its normal cursor positioning, leaving
    -- the terminal cursor at the previous bottom command-line position.
    if Cmdline.confirm_message and Cmdline.confirm_message.kind == "confirm" then
      hide_cursor()
    end
    if not Cmdline.confirm_message and last_confirm then
      local _, buttons = parse(prompt or "")
      if buttons and button_signature(buttons) == last_confirm.buttons then
        hide_cursor()
        -- The router drains the pending queue after displaying a message.
        -- Visible messages remain in history until their scheduled removal;
        -- replace those synchronously before routing a repeated prompt, or
        -- the card briefly doubles in height and its centered position jumps.
        for _, previous in ipairs(Manager.get({ event = "msg_show", kind = "confirm" }, { history = true })) do
          Manager.remove(previous)
        end
        local message = Message("msg_show", "confirm", { { 0, last_confirm.content, 0 } })
        Manager.add(message)
        Cmdline._on_hide = function()
          vim.schedule(function()
            Manager.remove(message)
          end)
        end
        return
      end
    end
    return on_show(event, content, pos, firstc, prompt, indent, level)
  end
  local on_hide = Cmdline.on_hide
  Cmdline.on_hide = function(...)
    on_hide(...)
    vim.schedule(function()
      -- Invalid mouse input briefly hides and reopens the native prompt.
      -- Keep the cursor hidden through those redraws; restore on actual exit.
      if saved_cursor ~= nil and vim.fn.mode(1) ~= "r?" then
        vim.o.guicursor = saved_cursor
        saved_cursor = nil
      end
    end)
  end

  M.highlights()
  vim.api.nvim_create_autocmd("ColorScheme", {
    group = vim.api.nvim_create_augroup("ConfirmDialogStyle", { clear = true }),
    callback = M.highlights,
  })
end

return M
