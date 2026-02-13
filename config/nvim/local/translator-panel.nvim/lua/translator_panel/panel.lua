local config = require("translator_panel.config")
local translator = require("translator_panel.translator")

local M = {}

local state = {
  buf = nil,
  win = nil,
  ns = vim.api.nvim_create_namespace("translator_panel"),
  timer = nil,
  last_text = nil,
  last_translation_lines = nil,
  request_id = 0,
  autocmd_id = nil,
  input_height = 0,
}

local function is_open()
  return state.win and vim.api.nvim_win_is_valid(state.win)
end

local function normalize_text(lines)
  local text = table.concat(lines, "\n")
  text = text:gsub("^%s+", ""):gsub("%s+$", "")
  return text
end

local function split_lines(text)
  if text == "" then
    return {}
  end
  return vim.split(text, "\n", { plain = true })
end

local function render_virtual(lines, is_error)
  if not state.buf or not vim.api.nvim_buf_is_valid(state.buf) then
    return
  end

  vim.api.nvim_buf_clear_namespace(state.buf, state.ns, 0, -1)

  local width = config.options.window.width
  local separator = string.rep("-", math.max(width - 2, 1))
  local virt = {
    { { separator, "NonText" } },
    { { is_error and "Error:" or "JA:", is_error and "ErrorMsg" or "Comment" } },
  }

  for _, line in ipairs(lines) do
    table.insert(virt, { { line, is_error and "ErrorMsg" or "Normal" } })
  end

  local line_count = vim.api.nvim_buf_line_count(state.buf)
  if line_count == 0 then
    return
  end

  local anchor_line = math.min(state.input_height - 1, line_count - 1)
  if anchor_line < 0 then
    return
  end

  vim.api.nvim_buf_set_extmark(state.buf, state.ns, anchor_line, 0, {
    virt_lines = virt,
    virt_lines_above = false,
  })
end

local function copy_translation()
  if not state.last_translation_lines or #state.last_translation_lines == 0 then
    vim.notify("No translation to copy", vim.log.levels.WARN)
    return
  end

  local text = table.concat(state.last_translation_lines, "\n")
  vim.fn.setreg('"', text)
  vim.fn.setreg("+", text)
  vim.notify("Translation copied", vim.log.levels.INFO)
end

local function copy_source()
  if not state.buf or not vim.api.nvim_buf_is_valid(state.buf) then
    return
  end

  local lines = vim.api.nvim_buf_get_lines(state.buf, 0, state.input_height, false)
  local text = normalize_text(lines)
  if text == "" then
    vim.notify("No source text to copy", vim.log.levels.WARN)
    return
  end

  vim.fn.setreg('"', text)
  vim.fn.setreg("+", text)
  vim.notify("Source copied", vim.log.levels.INFO)
end

local function update_translation(text)
  local current_id = state.request_id + 1
  state.request_id = current_id

  translator.translate(text, config.options, function(result, err)
    if current_id ~= state.request_id then
      return
    end

    if err then
      state.last_translation_lines = nil
      render_virtual(split_lines(err), true)
      vim.notify(err, vim.log.levels.ERROR)
      return
    end

    local lines = split_lines(result)
    state.last_translation_lines = lines
    render_virtual(lines, false)
  end)
end

local function schedule_translate()
  if not state.timer then
    state.timer = vim.loop.new_timer()
  end

  state.timer:stop()
  state.timer:start(config.options.debounce_ms, 0, vim.schedule_wrap(function()
    if not state.buf or not vim.api.nvim_buf_is_valid(state.buf) then
      return
    end

    local lines = vim.api.nvim_buf_get_lines(state.buf, 0, state.input_height, false)
    local text = normalize_text(lines)

    if text == "" then
      state.last_text = nil
      state.last_translation_lines = nil
      render_virtual({}, false)
      return
    end

    if text == state.last_text then
      return
    end

    state.last_text = text
    update_translation(text)
  end))
end

local function apply_autocmd()
  if state.autocmd_id then
    pcall(vim.api.nvim_del_autocmd, state.autocmd_id)
    state.autocmd_id = nil
  end

  state.autocmd_id = vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI" }, {
    buffer = state.buf,
    callback = schedule_translate,
  })
end

local function open_panel()
  local width = config.options.window.width
  local height = config.options.window.height
  local input_height = math.max(math.floor((height - 1) / 2), 3)
  state.input_height = input_height

  local buf = state.buf
  if not buf or not vim.api.nvim_buf_is_valid(buf) then
    buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_option(buf, "buftype", "nofile")
    vim.api.nvim_buf_set_option(buf, "bufhidden", "hide")
    vim.api.nvim_buf_set_option(buf, "swapfile", false)
    vim.api.nvim_buf_set_option(buf, "modifiable", true)
  end

  local line_count = vim.api.nvim_buf_line_count(buf)
  if line_count < input_height then
    local lines = {}
    for _ = 1, input_height - line_count do
      table.insert(lines, "")
    end
    vim.api.nvim_buf_set_lines(buf, line_count, line_count, false, lines)
  end

  local row = math.floor((vim.o.lines - height) / 2)
  local col = math.floor((vim.o.columns - width) / 2)

  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    row = row,
    col = col,
    width = width,
    height = height,
    style = "minimal",
    border = "rounded",
  })

  vim.api.nvim_buf_set_option(buf, "filetype", "translator_panel")
  vim.api.nvim_win_set_option(win, "wrap", true)
  vim.api.nvim_win_set_option(win, "cursorline", true)
  vim.keymap.set("n", config.options.copy_key, copy_translation, {
    buffer = buf,
    desc = "Copy translation",
  })
  vim.keymap.set("n", config.options.copy_source_key, copy_source, {
    buffer = buf,
    desc = "Copy source",
  })

  state.buf = buf
  state.win = win

  if state.last_translation_lines and #state.last_translation_lines > 0 then
    render_virtual(state.last_translation_lines, false)
  else
    render_virtual({}, false)
  end
  apply_autocmd()
end

local function close_panel()
  if state.timer then
    state.timer:stop()
    state.timer:close()
    state.timer = nil
  end

  if state.autocmd_id then
    pcall(vim.api.nvim_del_autocmd, state.autocmd_id)
    state.autocmd_id = nil
  end

  if state.win and vim.api.nvim_win_is_valid(state.win) then
    vim.api.nvim_win_close(state.win, true)
  end

  state.win = nil
end

function M.toggle()
  if is_open() then
    close_panel()
  else
    open_panel()
  end
end

function M.refresh()
  if not state.buf or not vim.api.nvim_buf_is_valid(state.buf) then
    return
  end

  local lines = vim.api.nvim_buf_get_lines(state.buf, 0, state.input_height, false)
  local text = normalize_text(lines)

  if text == "" then
    state.last_text = nil
    state.last_translation_lines = nil
    render_virtual({}, false)
    return
  end

  state.last_text = nil
  update_translation(text)
end

return M
