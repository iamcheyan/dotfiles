-- context_menu.lua
-- Right-click context menu using Neovim's native :popup PopUp mechanism.
--
-- Three contexts are supported:
--   • bufferline tab  → buffer_entries  (called by bufferline right_mouse_command)
--   • neo-tree node   → neo_entries     (called by neo-tree <RightMouse> mapping)
--   • editor area     → editor_entries  (fired by MenuPopup autocmd on bare right-click)

local M = {}

-- ---------------------------------------------------------------------------
-- Context state
-- The context must survive from the time the plugin calls open_buffer()/open_neo()
-- until MenuPopup fires (synchronously inside :popup) AND until M.run() executes
-- the selected action.  It is cleared only after M.run() completes.
-- ---------------------------------------------------------------------------
local _ctx = {}  -- { kind = "buffer"|"neo"|"editor", buffer_id = ?, neo_state = ? }

-- ---------------------------------------------------------------------------
-- Helpers
-- ---------------------------------------------------------------------------

local function notify(msg, level)
  vim.notify(msg, level or vim.log.levels.INFO)
end

local function target_buffer(ctx)
  ctx = ctx or _ctx
  return ctx.buffer_id or ctx.target_buf or vim.api.nvim_get_current_buf()
end

local function target_path(ctx)
  ctx = ctx or _ctx
  if ctx.target_path and ctx.target_path ~= "" then
    return ctx.target_path
  end
  if ctx.neo_state then
    local node = ctx.neo_state.tree:get_node()
    return node and node.path or ""
  end
  return vim.api.nvim_buf_get_name(target_buffer(ctx))
end

local function copy(value, message)
  if value == "" then
    notify("No path is available for this item", vim.log.levels.INFO)
    return
  end
  vim.fn.setreg("+", value)
  notify(message)
end

local function buffer_elements()
  local ok, bufferline = pcall(require, "bufferline")
  if not ok then return {} end
  return bufferline.get_elements().elements or {}
end

local function delete_buffers(ids)
  for _, id in ipairs(ids) do
    if vim.api.nvim_buf_is_valid(id) then
      pcall(vim.api.nvim_buf_delete, id, { force = false })
    end
  end
end

-- ---------------------------------------------------------------------------
-- Action dispatch
-- ---------------------------------------------------------------------------

local function run_buffer(action, ctx)
  local id       = target_buffer(ctx)
  local elements = buffer_elements()
  local index
  for i, e in ipairs(elements) do
    if e.id == id then index = i; break end
  end

  if action == "close" then
    delete_buffers({ id })
  elseif action == "close_left" and index then
    delete_buffers(vim.tbl_map(function(e) return e.id end, vim.list_slice(elements, 1, index - 1)))
  elseif action == "close_right" and index then
    delete_buffers(vim.tbl_map(function(e) return e.id end, vim.list_slice(elements, index + 1)))
  elseif action == "close_others" and index then
    local ids = {}
    for i, e in ipairs(elements) do if i ~= index then ids[#ids + 1] = e.id end end
    delete_buffers(ids)
  elseif action == "close_all" then
    delete_buffers(vim.tbl_map(function(e) return e.id end, elements))
  elseif action == "copy_relative" then
    copy(vim.fn.fnamemodify(target_path(ctx), ":."), "Copied relative path")
  elseif action == "copy_absolute" then
    copy(target_path(ctx), "Copied absolute path")
  elseif action == "copy_filename" then
    copy(vim.fn.fnamemodify(target_path(ctx), ":t"), "Copied filename")
  elseif action == "split_vertical" or action == "split_horizontal" then
    if vim.api.nvim_buf_is_valid(id) then
      vim.api.nvim_set_current_buf(id)
      vim.cmd(action == "split_vertical" and "vsplit" or "split")
    end
  elseif action == "new_tab" and vim.api.nvim_buf_is_valid(id) then
    vim.cmd("tab sbuffer " .. id)
  elseif action == "toggle_pin" and vim.api.nvim_buf_is_valid(id) then
    vim.api.nvim_set_current_buf(id)
    require("bufferline.groups").toggle_pin()
  elseif action == "checktime" and vim.api.nvim_buf_is_valid(id) then
    vim.api.nvim_set_current_buf(id)
    vim.cmd("checktime")
  elseif action == "reveal" then
    local path = target_path(ctx)
    if path == "" then
      notify("This buffer has no file path", vim.log.levels.INFO)
    elseif vim.fn.has("mac") == 1 then
      vim.fn.jobstart({ "open", "-R", path }, { detach = true })
    elseif vim.fn.executable("xdg-open") == 1 then
      vim.fn.jobstart({ "xdg-open", vim.fn.fnamemodify(path, ":h") }, { detach = true })
    end
  elseif action == "history" then
    local path = target_path(ctx)
    if path == "" then notify("This buffer has no file path", vim.log.levels.INFO); return end
    vim.api.nvim_set_current_buf(id)
    local ok, snacks = pcall(require, "snacks.picker")
    if ok and snacks.git_log_file then
      snacks.git_log_file()
    else
      notify("Snacks git history is unavailable", vim.log.levels.WARN)
    end
  end
end

local function run_neo(action, ctx)
  local state = ctx.neo_state
  if ctx.target_win and vim.api.nvim_win_is_valid(ctx.target_win) then
    vim.api.nvim_set_current_win(ctx.target_win)
    if ctx.target_line and ctx.target_line > 0 then
      pcall(vim.api.nvim_win_set_cursor, ctx.target_win, { ctx.target_line, 0 })
    end
  end
  local node = state and state.tree:get_node()
  local path = (node and node.path) or ctx.target_path or ""
  if not state or path == "" then return end
  local fs = require("neo-tree.sources.filesystem.commands")
  local commands = {
    open             = fs.open,
    split_vertical   = fs.open_vsplit,
    split_horizontal = fs.open_split,
    new_tab          = fs.open_tabnew,
    new_file         = fs.add,
    new_folder       = fs.add_directory,
    rename           = fs.rename,
    copy             = fs.copy_to_clipboard,
    cut              = fs.cut_to_clipboard,
    paste            = fs.paste_from_clipboard,
    delete           = fs.delete,
  }
  if commands[action] then
    local ok, err = pcall(commands[action], state)
    if not ok then notify(tostring(err), vim.log.levels.ERROR) end
  elseif action == "copy_relative" then
    copy(vim.fn.fnamemodify(path, ":."), "Copied relative path")
  elseif action == "copy_absolute" then
    copy(path, "Copied absolute path")
  elseif action == "copy_filename" then
    copy(vim.fn.fnamemodify(path, ":t"), "Copied filename")
  elseif action == "open_oil" then
    pcall(vim.cmd, "Oil " .. vim.fn.fnameescape(vim.fn.fnamemodify(path, ":h")))
  elseif action == "reveal" then
    local dir = vim.fn.isdirectory(path) == 1 and path or vim.fn.fnamemodify(path, ":h")
    if vim.fn.has("mac") == 1 then
      vim.fn.jobstart({ "open", dir }, { detach = true })
    elseif vim.fn.executable("xdg-open") == 1 then
      vim.fn.jobstart({ "xdg-open", dir }, { detach = true })
    end
  elseif action == "history" then
    pcall(vim.cmd, "DiffviewFileHistory " .. vim.fn.fnameescape(path))
  end
end

local function run_editor(action, ctx)
  if ctx.target_win and vim.api.nvim_win_is_valid(ctx.target_win) then
    pcall(vim.api.nvim_set_current_win, ctx.target_win)
  end
  local buf  = target_buffer(ctx)
  local path = target_path(ctx)

  if action == "definition" then
    local ok, snacks = pcall(require, "snacks.picker")
    if ok and snacks.lsp_definitions then
      snacks.lsp_definitions()
    else
      vim.lsp.buf.definition()
    end
  elseif action == "references" then
    local ok, snacks = pcall(require, "snacks.picker")
    if ok and snacks.lsp_references then
      snacks.lsp_references()
    else
      vim.lsp.buf.references()
    end
  elseif action == "implementation" then
    local ok, snacks = pcall(require, "snacks.picker")
    if ok and snacks.lsp_implementations then
      snacks.lsp_implementations()
    else
      vim.lsp.buf.implementation()
    end
  elseif action == "code_action" then
    vim.lsp.buf.code_action()
  elseif action == "rename" then
    vim.lsp.buf.rename()
  elseif action == "format" then
    local ok, conform = pcall(require, "conform")
    if ok then
      conform.format({ async = true, lsp_fallback = true })
    else
      vim.lsp.buf.format({ async = true })
    end
  elseif action == "diagnostic" then
    vim.diagnostic.open_float()
  elseif action == "open_browser" then
    pcall(vim.cmd, "normal! gx")
  elseif action == "copy_relative" then
    copy(vim.fn.fnamemodify(path, ":."), "Copied relative path")
  elseif action == "copy_absolute" then
    copy(path, "Copied absolute path")
  elseif action == "select_all" then
    vim.cmd("normal! ggVG")
  elseif action == "copy_all" then
    local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
    local text = table.concat(lines, "\n") .. "\n"
    vim.fn.setreg("+", text)
    notify(string.format("Copied entire document (%d lines)", #lines))
  elseif action == "cut_all" then
    local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
    local text = table.concat(lines, "\n") .. "\n"
    vim.fn.setreg("+", text)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, { "" })
    notify(string.format("Cut entire document (%d lines)", #lines))
  elseif action == "paste_all" then
    local content = vim.fn.getreg("+")
    if content == "" then
      notify("Clipboard is empty", vim.log.levels.WARN)
      return
    end
    local lines = vim.split(content, "\n", { plain = true })
    if #lines > 0 and lines[#lines] == "" then
      table.remove(lines, #lines)
    end
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    notify(string.format("Replaced document with clipboard (%d lines)", #lines))
  elseif action == "reveal" then
    if path ~= "" then
      local ok, neotree = pcall(require, "neo-tree.command")
      if ok then
        neotree.execute({ action = "focus", reveal_file = path })
      end
    end
  elseif action == "history" then
    if path == "" then
      notify("This buffer has no file path", vim.log.levels.INFO)
      return
    end
    local ok, snacks = pcall(require, "snacks.picker")
    if ok and snacks.git_log_file then
      snacks.git_log_file()
    else
      pcall(vim.cmd, "DiffviewFileHistory " .. vim.fn.fnameescape(path))
    end
  end
end

-- Public dispatch – called by every menu item command.
function M.run(action)
  local ctx = _ctx
  _ctx = {}
  if ctx.kind == "neo" then
    run_neo(action, ctx)
  elseif ctx.kind == "buffer" then
    run_buffer(action, ctx)
  elseif ctx.kind == "editor" then
    run_editor(action, ctx)
  end
end

-- ---------------------------------------------------------------------------
-- Menu entry tables
-- ---------------------------------------------------------------------------

local buffer_entries = {
  { "󰅖  Close",                      "close" },
  { "󰁍  Close Left",                 "close_left" },
  { "󰁔  Close Right",                "close_right" },
  { "󰘓  Close Others",               "close_others" },
  { "󰅖  Close All",                  "close_all" },
  { separator = true },
  { "󰆏  Copy Relative Path",         "copy_relative" },
  { "󰅎  Copy Absolute Path",         "copy_absolute" },
  { "󰈤  Copy Filename",              "copy_filename" },
  { separator = true },
  { "󰤼  Open Vertical Split",        "split_vertical" },
  { "󰤻  Open Horizontal Split",      "split_horizontal" },
  { "󰐕  Open in New Tab",            "new_tab" },
  { separator = true },
  { "󰐃  Toggle Pin",                 "toggle_pin" },
  { "󰑐  Check for External Changes", "checktime" },
  { "󰀼  Reveal in File Manager",     "reveal" },
  { "󰋚  Git: View File History",     "history" },
}

local neo_entries = {
  { "󰉖  Open",                       "open" },
  { "󰤼  Open Vertical Split",        "split_vertical" },
  { "󰤻  Open Horizontal Split",      "split_horizontal" },
  { "󰐕  Open in New Tab",            "new_tab" },
  { separator = true },
  { "󰆏  Copy Relative Path",         "copy_relative" },
  { "󰅎  Copy Absolute Path",         "copy_absolute" },
  { "󰈤  Copy Filename",              "copy_filename" },
  { separator = true },
  { "󰝰  New File",                   "new_file" },
  { "󰉖  New Folder",                 "new_folder" },
  { "󰑕  Rename",                     "rename" },
  { "󰆴  Copy",                       "copy" },
  { "󰆐  Cut",                        "cut" },
  { "󰆒  Paste",                      "paste" },
  { "󰩹  Delete",                     "delete" },
  { separator = true },
  { "󰉖  Open Directory in Oil",      "open_oil" },
  { "󰀼  Reveal in File Manager",     "reveal" },
  { "󰋚  Git: View File History",     "history" },
}

local editor_entries = {
  { "󰆒  Select All & Paste",         "paste_all" },
  { "󰅍  Select All & Copy",          "copy_all" },
  { "󰆐  Select All & Cut",           "cut_all" },
  { "󰒅  Select All",                 "select_all" },
  { separator = true },
  { "󰊕  Go to Definition",           "definition" },
  { "󰌹  Go to References",           "references" },
  { "󰈔  Go to Implementation",       "implementation" },
  { "󰌵  Code Action",                "code_action" },
  { "󰏫  Rename Symbol",              "rename" },
  { separator = true },
  { "󰉦  Format Document",            "format" },
  { "󰒡  Line Diagnostics",           "diagnostic" },
  { "󰆍  Open URL in Browser",        "open_browser" },
  { separator = true },
  { "󰆴  Copy",                       '"+yy', mode = "n", raw = true },
  { "󰆴  Copy",                       '"+y',  mode = "v", raw = true },
  { "󰆐  Cut",                        '"+dd', mode = "n", raw = true },
  { "󰆐  Cut",                        '"+d',  mode = "v", raw = true },
  { "󰆒  Paste",                      '"+p',  mode = "a", raw = true },
  { separator = true },
  { "󰆏  Copy Relative Path",         "copy_relative" },
  { "󰅎  Copy Absolute Path",         "copy_absolute" },
  { "󰀼  Reveal in File Tree",        "reveal" },
  { "󰋚  Git: View File History",     "history" },
}

-- ---------------------------------------------------------------------------
-- PopUp menu builder
-- ---------------------------------------------------------------------------

-- Escape spaces and backslashes so Vim's :menu parser accepts the label.
local function menu_name(label)
  return vim.fn.escape(label, " \\")
end

-- Replace every entry in the PopUp menu with the given list.
local function install_popup(entries)
  vim.cmd("silent! aunmenu PopUp")
  local sep_idx = 0
  for _, entry in ipairs(entries) do
    if entry.separator then
      sep_idx = sep_idx + 1
      vim.cmd(("anoremenu PopUp.-sep%d- <Nop>"):format(sep_idx))
    elseif entry.raw then
      local label = menu_name(entry[1])
      local mode  = entry.mode or "a"
      vim.cmd(("%snoremenu PopUp.%s %s"):format(mode, label, entry[2]))
    else
      local label   = menu_name(entry[1])
      local rhs     = entry[2]
      -- Raw key sequences start with "<" (e.g. "<Cmd>...").
      -- Action strings are dispatched through M.run().
      local command = rhs:sub(1, 1) == "<"
          and rhs
          or ("<Cmd>lua require('config.context_menu').run(" .. string.format("%q", rhs) .. ")<CR>")
      vim.cmd(("anoremenu PopUp.%s %s"):format(label, command))
    end
  end
end

-- ---------------------------------------------------------------------------
-- Public entry points (called by plugins before :popup fires)
-- ---------------------------------------------------------------------------

-- Resolve which buffer corresponds to a given screen column on row 1.
local function resolve_buffer_at_col(screencol)
  local ok, s = pcall(require, "bufferline.state")
  if not ok or not s.visible_components or #s.visible_components == 0 then
    return vim.api.nvim_get_current_buf(), "tab"
  end
  local offset = s.left_offset_size or 0
  if screencol <= offset then
    return nil, "offset"
  end
  local pos = offset
  for _, item in ipairs(s.visible_components) do
    local next_pos = pos + item.length
    if screencol > pos and screencol <= next_pos then
      if item.id and vim.api.nvim_buf_is_valid(item.id) then
        return item.id, "tab"
      end
    end
    pos = next_pos
  end
  -- Past all tabs (empty tabline space)
  return vim.api.nvim_get_current_buf(), "empty"
end
M.resolve_buffer_at_col = resolve_buffer_at_col

-- Called by bufferline's right_mouse_command.
-- The callback fires inside a tabline mouse-click handler where Neovim's
-- window context may not yet be settled.  Defer popup PopUp via schedule()
-- so it runs after the event loop returns to normal, guaranteeing the menu
-- appears at the correct position.
function M.open_buffer(id)
  _ctx = { kind = "buffer", buffer_id = id }
  install_popup(buffer_entries)
  vim.schedule(function()
    local ok, err = pcall(vim.cmd, "popup! PopUp")
    if not ok then notify(tostring(err), vim.log.levels.ERROR) end
  end)
end

-- Called by neo-tree's context action or tests.
function M.open_neo(state, line)
  line = line or (state and state.winid and vim.api.nvim_win_is_valid(state.winid) and vim.api.nvim_win_get_cursor(state.winid)[1]) or 1
  local node = state and state.tree and state.tree:get_node(line)
  if not node or node.type == "message" or not node.path or node.path == "" then
    return
  end
  _ctx = {
    kind        = "neo",
    neo_state   = state,
    target_win  = state.winid,
    target_line = line,
    target_path = node.path,
  }
  install_popup(neo_entries)
  vim.schedule(function()
    local ok, err = pcall(vim.cmd, "popup! PopUp")
    if not ok then notify(tostring(err), vim.log.levels.ERROR) end
  end)
end

-- ---------------------------------------------------------------------------
-- Setup
-- ---------------------------------------------------------------------------

function M.setup()
  -- mousemodel=popup_setpos makes Neovim open PopUp on right-click in the
  -- editor area and moves the cursor to the click position first.
  vim.opt.mousemodel = "popup_setpos"

  -- Neovim ≥ 0.9 ships with "nvim.popupmenu" that pre-fills PopUp with
  -- generic items on every right-click.  We replace it with our own handler
  -- that shows context-sensitive items.
  pcall(vim.api.nvim_del_augroup_by_name, "nvim.popupmenu")

  local group = vim.api.nvim_create_augroup("context_menu_popup", { clear = true })

  -- MenuPopup fires just before the PopUp is displayed.
  -- • When triggered by M.open_buffer() / M.open_neo(): _ctx is already set
  --   and install_popup() has already been called, so we just refresh.
  -- • When triggered by a bare right-click in the editor area: _ctx is empty,
  --   so we install the generic editor entries.
  vim.api.nvim_create_autocmd("MenuPopup", {
    group    = group,
    callback = function()
      local mouse = vim.fn.getmousepos()
      local mouse_win = mouse.winid
      local mouse_buf = (mouse_win and mouse_win > 0 and vim.api.nvim_win_is_valid(mouse_win))
          and vim.api.nvim_win_get_buf(mouse_win)
          or 0
      local ft = mouse_buf > 0 and vim.bo[mouse_buf].filetype or ""

      -- 1. Top tabline area (screenrow 1)
      if mouse.screenrow == 1 then
        local buf_id, area_type = resolve_buffer_at_col(mouse.screencol)
        if area_type == "offset" then
          -- Click on the offset area (the sidebar's root path in the tabline): no menu
          vim.cmd("silent! aunmenu PopUp")
          _ctx = {}
          return
        end
        local target_id = (_ctx.kind == "buffer" and _ctx.buffer_id) or buf_id
        _ctx = {
          kind = "buffer",
          buffer_id = target_id,
        }
        install_popup(buffer_entries)
        return
      end

      -- If an explicit buffer tab click was scheduled but screenrow is not 1 (fallback)
      if _ctx.kind == "buffer" and mouse_win == 0 then
        install_popup(buffer_entries)
        return
      end

      local ok_nt, nt_sources = pcall(require, "neo-tree.sources.manager")
      local nt_state = ok_nt and (
        (mouse_win > 0 and nt_sources.get_state_for_window(mouse_win))
        or (ft == "neo-tree" and nt_sources.get_state("filesystem"))
      ) or nil

      -- 2. Neo-tree sidebar area (screenrow > 1)
      if ft == "neo-tree" or nt_state ~= nil then
        local line_count = mouse_buf > 0 and vim.api.nvim_buf_line_count(mouse_buf) or 0
        local line = mouse.line
        if line < 1 or line > line_count then
          -- Blank space below tree items: do not show menu
          vim.cmd("silent! aunmenu PopUp")
          _ctx = {}
          return
        end
        local node = nt_state and nt_state.tree and nt_state.tree:get_node(line)
        if not node or node.type == "message" or not node.path or node.path == "" then
          -- Non-actionable node (e.g. '(8 hidden items)' message): do not show menu
          vim.cmd("silent! aunmenu PopUp")
          _ctx = {}
          return
        end

        if mouse_win > 0 and line > 0 then
          pcall(vim.api.nvim_win_set_cursor, mouse_win, { line, 0 })
          pcall(vim.api.nvim_set_current_win, mouse_win)
        end
        _ctx = {
          kind        = "neo",
          neo_state   = nt_state,
          target_win  = mouse_win,
          target_line = line,
          target_path = node.path,
        }
        install_popup(neo_entries)
        return
      end

      -- 3. Regular editor window
      _ctx = {
        kind       = "editor",
        target_win = mouse_win,
        target_buf = mouse_buf,
      }
      install_popup(editor_entries)
    end,
  })

  -- Seed PopUp with editor entries so there is always something visible
  -- even if MenuPopup fires before any install_popup() call.
  install_popup(editor_entries)
end

return M
