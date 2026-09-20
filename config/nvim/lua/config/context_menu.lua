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

local function target_buffer()
  return _ctx.buffer_id or vim.api.nvim_get_current_buf()
end

local function target_path()
  if _ctx.neo_state then
    local node = _ctx.neo_state.tree:get_node()
    return node and node.path or ""
  end
  return vim.api.nvim_buf_get_name(target_buffer())
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

local function run_buffer(action)
  local id       = target_buffer()
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
    copy(vim.fn.fnamemodify(target_path(), ":."), "Copied relative path")
  elseif action == "copy_absolute" then
    copy(target_path(), "Copied absolute path")
  elseif action == "copy_filename" then
    copy(vim.fn.fnamemodify(target_path(), ":t"), "Copied filename")
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
    local path = target_path()
    if path == "" then
      notify("This buffer has no file path", vim.log.levels.INFO)
    elseif vim.fn.has("mac") == 1 then
      vim.fn.jobstart({ "open", "-R", path }, { detach = true })
    elseif vim.fn.executable("xdg-open") == 1 then
      vim.fn.jobstart({ "xdg-open", vim.fn.fnamemodify(path, ":h") }, { detach = true })
    end
  elseif action == "history" then
    local path = target_path()
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

local function run_neo(action)
  local state = _ctx.neo_state
  local node  = state and state.tree:get_node()
  local path  = node and node.path or ""
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

-- Public dispatch – called by every menu item command.
function M.run(action)
  local kind = _ctx.kind
  -- Clear context BEFORE running the action so stale state is never reused
  -- even if the action opens another menu.
  _ctx = {}
  if kind == "neo" then
    run_neo(action)
  elseif kind == "buffer" then
    run_buffer(action)
  end
  -- "editor" entries embed raw key sequences; they never reach M.run().
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

-- Editor entries use raw key sequences rather than M.run() because they
-- must operate on the buffer that was under the cursor when right-clicked,
-- not a saved buffer id.
local editor_entries = {
  { "󰆍  Open in web browser",        "<Cmd>normal! gx<CR>" },
  { "󰊕  Go to definition",           "<Cmd>lua vim.lsp.buf.definition()<CR>" },
  { "󰒡  Show Diagnostics",           "<Cmd>lua vim.diagnostic.open_float()<CR>" },
  { "󰒡  Show All Diagnostics",       "<Cmd>lua vim.diagnostic.setqflist()<CR>" },
  { "󰘥  Configure Diagnostics",      "<Cmd>help vim.diagnostic.config()<CR>" },
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
      vim.cmd(("amenu PopUp.-sep%d- <Nop>"):format(sep_idx))
    else
      local label   = menu_name(entry[1])
      local rhs     = entry[2]
      -- Raw key sequences start with "<" (e.g. "<Cmd>...").
      -- Action strings are dispatched through M.run().
      local command = rhs:sub(1, 1) == "<"
          and rhs
          or (":lua require('config.context_menu').run(" .. string.format("%q", rhs) .. ")<CR>")
      vim.cmd(("amenu PopUp.%s %s"):format(label, command))
    end
  end
end

-- ---------------------------------------------------------------------------
-- Public entry points (called by plugins before :popup fires)
-- ---------------------------------------------------------------------------

-- Called by bufferline's right_mouse_command.
-- The callback fires inside a tabline mouse-click handler where Neovim's
-- window context may not yet be settled.  Defer popup PopUp via schedule()
-- so it runs after the event loop returns to normal, guaranteeing the menu
-- appears at the correct position.
function M.open_buffer(id)
  _ctx = { kind = "buffer", buffer_id = id }
  install_popup(buffer_entries)
  vim.schedule(function()
    local ok, err = pcall(vim.cmd, "popup PopUp")
    if not ok then notify(tostring(err), vim.log.levels.ERROR) end
  end)
end

-- Called by neo-tree's <RightMouse> mapping.
function M.open_neo(state)
  _ctx = { kind = "neo", neo_state = state }
  install_popup(neo_entries)
  vim.schedule(function()
    local ok, err = pcall(vim.cmd, "popup PopUp")
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
      if _ctx.kind == "neo" then
        install_popup(neo_entries)
      elseif _ctx.kind == "buffer" then
        install_popup(buffer_entries)
      else
        -- Bare editor right-click: reset any stale context and show editor menu.
        _ctx = {}
        install_popup(editor_entries)
      end
    end,
  })

  -- Seed PopUp with editor entries so there is always something visible
  -- even if MenuPopup fires before any install_popup() call.
  install_popup(editor_entries)
end

return M
