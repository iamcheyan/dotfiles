-- Detect and restore Neo-tree / Aerial around file splits.
-- One boolean "aerial is open" is not enough: a tab can have several
-- outlines, each attached to a different file window, on the left or right.

local M = {}

M.closing_for_save = false
M.restoring = false

local DEFAULT_NEOTREE_WIDTH = 28
local DEFAULT_AERIAL_WIDTH = 30
local MIN_SIDEBAR_WIDTH = 16

local function state_dir()
  return vim.fn.stdpath("data") .. "/sidebar_state/"
end

local function cwd_key()
  local cwd = vim.fs.normalize(vim.uv.cwd() or vim.fn.getcwd() or "")
  return vim.fn.sha256(cwd)
end

function M.state_file()
  return state_dir() .. cwd_key() .. ".json"
end

local function clamp_width(width, default)
  if type(width) ~= "number" then
    return default
  end
  width = math.floor(width)
  if width < MIN_SIDEBAR_WIDTH then
    return default
  end
  local max = math.max(default, math.floor((vim.o.columns or 120) * 0.5))
  if width > max then
    return default
  end
  return width
end

local function win_col(win)
  return vim.api.nvim_win_get_position(win)[2]
end

local function is_float(win)
  local cfg = vim.api.nvim_win_get_config(win)
  return cfg.relative ~= nil and cfg.relative ~= ""
end

local function is_file_win(win)
  if not vim.api.nvim_win_is_valid(win) or is_float(win) then
    return false
  end
  local buf = vim.api.nvim_win_get_buf(win)
  local ft = vim.bo[buf].filetype
  local bt = vim.bo[buf].buftype
  local name = vim.api.nvim_buf_get_name(buf)
  if ft == "neo-tree" or ft == "aerial" then
    return false
  end
  if bt ~= "" then
    return false
  end
  return name ~= ""
end

local function file_label(buf)
  local name = vim.api.nvim_buf_get_name(buf)
  if name == "" then
    return nil
  end
  return vim.fn.fnamemodify(name, ":p")
end

local function same_file(a, b)
  if not a or not b then
    return false
  end
  return vim.fn.fnamemodify(a, ":p") == vim.fn.fnamemodify(b, ":p")
end

local function detect_direction(sidebar_win, source_win)
  if source_win and vim.api.nvim_win_is_valid(source_win) then
    if win_col(sidebar_win) < win_col(source_win) then
      return "left"
    end
    return "right"
  end
  return "left"
end

local function detect_neotree_position(win, buf)
  local pos = vim.b[buf].neo_tree_position
  if pos == "left" or pos == "right" then
    return pos
  end
  local col = win_col(win)
  local width = vim.api.nvim_win_get_width(win)
  if col + width >= (vim.o.columns or 80) - 2 and col > 2 then
    return "right"
  end
  return "left"
end

local function empty_tab_state()
  return {
    neotree = nil,
    neotree_position = nil,
    neotree_width = nil,
    aerials = {},
  }
end

local function detect_tab(tabpage)
  local state = empty_tab_state()
  local wins = vim.api.nvim_tabpage_list_wins(tabpage)
  for _, win in ipairs(wins) do
    if vim.api.nvim_win_is_valid(win) and not is_float(win) then
      local buf = vim.api.nvim_win_get_buf(win)
      local ft = vim.bo[buf].filetype
      local width = vim.api.nvim_win_get_width(win)
      if ft == "neo-tree" then
        state.neotree = vim.b[buf].neo_tree_source or "filesystem"
        state.neotree_position = detect_neotree_position(win, buf)
        if width >= MIN_SIDEBAR_WIDTH then
          state.neotree_width = width
        end
      elseif ft == "aerial" then
        local source_win
        local ok, src = pcall(vim.api.nvim_win_get_var, win, "source_win")
        if ok then
          source_win = src
        end
        local file
        if source_win and vim.api.nvim_win_is_valid(source_win) then
          file = file_label(vim.api.nvim_win_get_buf(source_win))
        end
        table.insert(state.aerials, {
          file = file,
          direction = detect_direction(win, source_win),
          width = width >= MIN_SIDEBAR_WIDTH and width or nil,
        })
      end
    end
  end
  return state
end

function M.detect()
  local tabs = {}
  local tabpages = vim.api.nvim_list_tabpages()
  local current = vim.api.nvim_get_current_tabpage()
  local current_state = empty_tab_state()
  for i, tab in ipairs(tabpages) do
    local s = detect_tab(tab)
    s.tab_index = i
    tabs[#tabs + 1] = s
    if tab == current then
      current_state = vim.deepcopy(s)
    end
  end
  current_state.tabs = tabs
  current_state.aerial = #current_state.aerials > 0
  if current_state.aerials[1] then
    current_state.aerial_width = current_state.aerials[1].width
  end
  return current_state
end

function M.normalize(state)
  if type(state) ~= "table" then
    return empty_tab_state()
  end
  local out = empty_tab_state()
  out.neotree = state.neotree
  out.neotree_position = state.neotree_position
  if out.neotree and not out.neotree_position then
    out.neotree_position = "left"
  end
  out.neotree_width = state.neotree_width
  if type(state.aerials) == "table" and #state.aerials > 0 then
    out.aerials = vim.deepcopy(state.aerials)
  elseif state.aerial then
    out.aerials = {
      {
        file = nil,
        direction = "left",
        width = state.aerial_width,
      },
    }
  end
  if type(state.tabs) == "table" then
    out.tabs = {}
    for _, tab in ipairs(state.tabs) do
      table.insert(out.tabs, M.normalize(vim.tbl_extend("force", {}, tab, { tabs = nil })))
    end
  end
  out.tab_index = state.tab_index
  return out
end

function M.restore_plan(state)
  state = M.normalize(state)
  local plan = {}
  if state.neotree then
    table.insert(plan, {
      kind = "neotree",
      source = state.neotree == true and "filesystem" or state.neotree,
      position = state.neotree_position or "left",
      width = clamp_width(state.neotree_width, DEFAULT_NEOTREE_WIDTH),
    })
  end
  for _, aerial in ipairs(state.aerials or {}) do
    table.insert(plan, {
      kind = "aerial",
      file = aerial.file,
      direction = aerial.direction == "right" and "right" or "left",
      width = clamp_width(aerial.width, DEFAULT_AERIAL_WIDTH),
    })
  end
  return plan
end

function M.persist(state)
  state = M.normalize(state or M.detect())
  pcall(vim.fn.mkdir, state_dir(), "p")
  pcall(vim.fn.writefile, { vim.json.encode(state) }, M.state_file())
  return state
end

function M.read()
  local file = M.state_file()
  if vim.fn.filereadable(file) ~= 1 then
    return nil
  end
  local lines = vim.fn.readfile(file)
  if not lines or not lines[1] then
    return nil
  end
  local ok, state = pcall(vim.json.decode, lines[1])
  if ok and type(state) == "table" then
    return M.normalize(state)
  end
  return nil
end

local function file_wins_in_tab()
  local wins = {}
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if is_file_win(win) then
      table.insert(wins, win)
    end
  end
  table.sort(wins, function(a, b)
    local pa = vim.api.nvim_win_get_position(a)
    local pb = vim.api.nvim_win_get_position(b)
    if pa[1] ~= pb[1] then
      return pa[1] < pb[1]
    end
    return pa[2] < pb[2]
  end)
  return wins
end

function M.find_file_win(file, used)
  used = used or {}
  local wins = file_wins_in_tab()
  if not file or file == "" then
    for _, win in ipairs(wins) do
      if not used[win] then
        used[win] = true
        return win
      end
    end
    return nil
  end
  local want = vim.fn.fnamemodify(file, ":p")
  for _, win in ipairs(wins) do
    if not used[win] then
      local name = file_label(vim.api.nvim_win_get_buf(win))
      if name and same_file(name, want) then
        used[win] = true
        return win
      end
    end
  end
  local base = vim.fn.fnamemodify(file, ":t")
  for _, win in ipairs(wins) do
    if not used[win] then
      local name = vim.api.nvim_buf_get_name(vim.api.nvim_win_get_buf(win))
      if vim.fn.fnamemodify(name, ":t") == base then
        used[win] = true
        return win
      end
    end
  end
  return nil
end

function M.close_sidebars()
  if package.loaded["neo-tree"] or package.loaded["neo-tree.command"] then
    pcall(vim.cmd, "Neotree close")
  end
  if package.loaded.aerial then
    pcall(function()
      require("aerial").close_all()
    end)
  end
  local to_close = {}
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if vim.api.nvim_win_is_valid(win) then
      local buf = vim.api.nvim_win_get_buf(win)
      local ft = vim.bo[buf].filetype
      local name = vim.api.nvim_buf_get_name(buf)
      if ft == "neo-tree" or ft == "aerial" or name:match("neo%-tree") then
        table.insert(to_close, win)
      end
    end
  end
  for _, win in ipairs(to_close) do
    if vim.api.nvim_win_is_valid(win) and vim.fn.winnr("$") > 1 then
      pcall(vim.api.nvim_win_close, win, true)
    end
  end
end

local function set_win_width(win, width)
  if not win or not vim.api.nvim_win_is_valid(win) or type(width) ~= "number" then
    return
  end
  pcall(vim.api.nvim_set_option_value, "winfixwidth", true, { scope = "local", win = win })
  pcall(vim.api.nvim_win_set_width, win, width)
  pcall(vim.api.nvim_set_option_value, "winfixwidth", true, { scope = "local", win = win })
end

local function sidebar_win(ft)
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if vim.api.nvim_win_is_valid(win) then
      if vim.bo[vim.api.nvim_win_get_buf(win)].filetype == ft then
        return win
      end
    end
  end
end

function M.apply_widths(state)
  state = M.normalize(state)
  if state.neotree then
    set_win_width(sidebar_win("neo-tree"), clamp_width(state.neotree_width, DEFAULT_NEOTREE_WIDTH))
  end
  local used = {}
  for _, aerial in ipairs(state.aerials or {}) do
    local src = M.find_file_win(aerial.file, used)
    if src then
      local aer
      local ok, w = pcall(vim.api.nvim_win_get_var, src, "aerial_win")
      if ok then
        aer = w
      end
      if not (aer and vim.api.nvim_win_is_valid(aer)) then
        for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
          local aok, source = pcall(vim.api.nvim_win_get_var, win, "source_win")
          if aok and source == src then
            aer = win
            break
          end
        end
      end
      set_win_width(aer, clamp_width(aerial.width, DEFAULT_AERIAL_WIDTH))
    end
  end
end

local function wait_until(pred, cb)
  local tries = 0
  local function check()
    tries = tries + 1
    if pred() or tries >= 40 then
      cb()
      return
    end
    vim.defer_fn(check, 25)
  end
  check()
end

local function open_neotree(step, cb)
  pcall(require, "nvim-web-devicons")
  pcall(function()
    local nt = require("neo-tree")
    if nt.ensure_config then
      nt.ensure_config()
    end
    if nt.config and nt.config.window then
      nt.config.window.width = step.width
      nt.config.window.position = step.position
    end
    require("neo-tree.command").execute({
      source = step.source,
      action = "show",
      position = step.position,
      dir = vim.uv.cwd(),
    })
  end)
  wait_until(function()
    return sidebar_win("neo-tree") ~= nil
  end, cb)
end

local function open_aerial(step, used, cb)
  local win = M.find_file_win(step.file, used)
  if not win then
    cb()
    return
  end
  pcall(vim.api.nvim_set_current_win, win)
  pcall(function()
    require("aerial").open({
      focus = false,
      direction = step.direction,
    })
  end)
  wait_until(function()
    local ok, aer = pcall(vim.api.nvim_win_get_var, win, "aerial_win")
    return ok and aer and vim.api.nvim_win_is_valid(aer)
  end, cb)
end

local function restore_tab(state, done)
  state = M.normalize(state)
  local plan = M.restore_plan(state)
  if #plan == 0 then
    done()
    return
  end
  local used = {}
  local i = 0
  local function next_step()
    i = i + 1
    local step = plan[i]
    if not step then
      M.apply_widths(state)
      vim.defer_fn(function()
        M.apply_widths(state)
        done()
      end, 300)
      return
    end
    if step.kind == "neotree" then
      open_neotree(step, next_step)
    else
      open_aerial(step, used, next_step)
    end
  end
  next_step()
end

function M.restore(state)
  state = M.normalize(state)
  local has = state.neotree or #(state.aerials or {}) > 0
  if state.tabs then
    for _, tab in ipairs(state.tabs) do
      if tab.neotree or #(tab.aerials or {}) > 0 then
        has = true
        break
      end
    end
  end
  if not has then
    return
  end

  M.restoring = true
  M.close_sidebars()
  vim.o.equalalways = false
  vim.o.winwidth = 1
  vim.o.winminwidth = 1

  local jobs
  if state.tabs and #state.tabs > 0 then
    jobs = state.tabs
  else
    jobs = { state }
  end

  local tabpages = vim.api.nvim_list_tabpages()
  local idx = 0
  local function next_tab()
    idx = idx + 1
    local job = jobs[idx]
    if not job then
      vim.defer_fn(function()
        M.restoring = false
      end, 800)
      return
    end
    local tab = tabpages[job.tab_index or idx]
    if tab and vim.api.nvim_tabpage_is_valid(tab) then
      pcall(vim.api.nvim_set_current_tabpage, tab)
    end
    restore_tab(job, next_tab)
  end
  next_tab()
end

function M.has_sidebars(state)
  state = M.normalize(state)
  if state.neotree or #(state.aerials or {}) > 0 then
    return true
  end
  if state.tabs then
    for _, tab in ipairs(state.tabs) do
      if tab.neotree or #(tab.aerials or {}) > 0 then
        return true
      end
    end
  end
  return false
end

return M
