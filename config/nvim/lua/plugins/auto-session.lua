-- Persist Neo-tree / Aerial around file splits.
--
-- auto-session closes non-file windows in auto_save_session() *before*
-- pre_save_cmds. Snapshot first, keep neo-tree/aerial through that close
-- pass, then fold them ourselves so mksession cannot write ghost splits.
-- Restore is per-tab and per-file-window: a right-hand outline next to a
-- vsplit is not the same as "aerial is open".

local sidebars = require("config.sidebar_session")

local captured = nil

local function snapshot_if_visible()
  local state = sidebars.detect()
  if sidebars.has_sidebars(state) or not captured or not sidebars.has_sidebars(captured) then
    captured = sidebars.persist(state)
  end
  return captured
end

local function schedule_restore(state)
  if not state or not sidebars.has_sidebars(state) then
    return
  end
  local function run()
    sidebars.restore(state)
  end
  if vim.g.sidebar_session_very_lazy then
    vim.defer_fn(run, 250)
  else
    vim.api.nvim_create_autocmd("User", {
      pattern = "VeryLazy",
      once = true,
      callback = function()
        vim.defer_fn(run, 250)
      end,
    })
  end
end

local function find_saved_session(session_name)
  if type(session_name) ~= "string" or session_name == "" then
    return nil
  end
  local ok_auto, auto_session = pcall(require, "auto-session")
  local ok_lib, lib = pcall(require, "auto-session.lib")
  if not ok_auto or not ok_lib or not auto_session.get_root_dir then
    return nil
  end
  local root = auto_session.get_root_dir()
  local encodings = {
    lib.escape_session_name(session_name),
    lib.legacy_escape_session_name(session_name),
  }
  for _, encoded in ipairs(encodings) do
    local path = vim.fs.joinpath(root, encoded .. ".vim")
    if vim.fn.filereadable(path) == 1 then
      return path, lib
    end
  end
end

local function restore_missing_session_paths(session_name)
  local session_path, lib = find_saved_session(session_name)
  if not session_path then
    return true
  end
  local ok, summary = pcall(lib.create_session_summary, session_path)
  if not ok or type(summary) ~= "table" then
    return true
  end

  local session_cwd = summary.cwd
  if (not session_cwd or session_cwd == "") and session_name:sub(1, 1) == "/" then
    session_cwd = session_name
  end
  local missing, seen = {}, {}
  local function add_missing(path, kind)
    if type(path) ~= "string" or path == "" or path:match("^[%w+.-]+://") then
      return
    end
    if kind == "file" then
      path = lib.resolve_filename_path(path, session_cwd)
    else
      path = vim.fn.fnamemodify(path, ":p")
    end
    local exists = kind == "directory" and vim.fn.isdirectory(path) == 1 or vim.fn.filereadable(path) == 1
    if not exists and not seen[path] then
      seen[path] = true
      table.insert(missing, { path = path, kind = kind })
    end
  end

  add_missing(session_cwd, "directory")
  for _, buffer in ipairs(summary.buffers or {}) do
    add_missing(buffer.path, "file")
  end
  add_missing(summary.current_buffer, "file")
  if #missing == 0 then
    return true
  end
  if #vim.api.nvim_list_uis() == 0 then
    return false
  end

  local example = vim.fn.fnamemodify(missing[1].path, ":t")
  local choice = vim.fn.confirm(
    string.format("Saved session has %d missing path(s), e.g. %s. Recreate the missing path(s)?", #missing, example),
    "&Create\n&Skip session",
    2
  )
  if choice ~= 1 then
    return false
  end

  for _, item in ipairs(missing) do
    if item.kind == "directory" then
      vim.fn.mkdir(item.path, "p")
      if vim.fn.isdirectory(item.path) ~= 1 then
        return false
      end
    else
      local parent = vim.fs.dirname(item.path)
      if parent and vim.fn.isdirectory(parent) ~= 1 then
        vim.fn.mkdir(parent, "p")
      end
      if vim.fn.filereadable(item.path) ~= 1 and vim.fn.writefile({}, item.path) ~= 0 then
        return false
      end
    end
  end
  return true
end

local function confirm_auto_create_session()
  local ok, auto_session = pcall(require, "auto-session")
  if not ok or type(auto_session.session_exists_for_cwd) ~= "function" or auto_session.session_exists_for_cwd() then
    return true
  end
  if #vim.api.nvim_list_uis() == 0 then
    return false
  end
  return vim.fn.confirm(
    "No saved session exists for this directory. Create one when exiting?",
    "&Create\n&Skip",
    2
  ) == 1
end

local function handle_missing_restore_error(error_msg)
  local message = tostring(error_msg or "")
  if message:find("E344: Can't find directory", 1, true)
    or message:find("E484: Can't open file", 1, true)
    or message:find("ENOENT", 1, true) then
    if #vim.api.nvim_list_uis() == 0 then
      return true
    end
    return vim.fn.confirm(
      "Session restore encountered a missing path. Continue and refresh the session on exit?",
      "&Continue\n&Disable autosave",
      1
    ) == 1
  end
  local auto_session = require("auto-session")
  return auto_session.default_restore_error_handler(error_msg)
end

return {
  {
    "rmagatti/auto-session",
    enabled = true,
    lazy = false,

    ---enables autocomplete for opts
    ---@module "auto-session"
    ---@type AutoSession.Config
    opts = {
      enabled = true,
      auto_save = true,
      auto_restore = true,
      auto_create = confirm_auto_create_session,
      auto_restore_last_session = false,
      args_allow_files_auto_save = true,

      pre_restore_cmds = { restore_missing_session_paths },
      restore_error_handler = handle_missing_restore_error,

      suppressed_dirs = { "/", "~/.cache/*" },
      bypass_save_filetypes = { "alpha", "dashboard", "snacks_dashboard" },

      git_use_branch_name = false,
      git_auto_restore_on_branch_change = false,

      close_unsupported_windows = {
        preserve_filetypes = { "neo-tree", "aerial" },
      },

      auto_delete_empty_sessions = true,

      session_lens = {
        picker = nil,
        load_on_setup = true,
        shorten_paths = true,
        mappings = {
          delete_session = { "i", "<C-d>" },
          alternate_session = { "i", "<C-s>" },
          copy_session = { "i", "<C-y>" },
        },
      },

      log_level = "error",

      pre_save_cmds = {
        function()
          sidebars.closing_for_save = true
          snapshot_if_visible()
          sidebars.close_sidebars()
        end,
      },

      post_save_cmds = {
        function()
          sidebars.closing_for_save = false
        end,
      },

      save_extra_data = function()
        if not captured or not sidebars.has_sidebars(captured) then
          return nil
        end
        return vim.json.encode(captured)
      end,

      restore_extra_data = function(_, extra_data)
        if not extra_data or extra_data == "" then
          return
        end
        local ok, state = pcall(vim.json.decode, extra_data)
        if ok and type(state) == "table" then
          captured = sidebars.normalize(state)
        end
      end,

      post_restore_cmds = {
        function()
          vim.o.equalalways = false
          vim.o.winwidth = 1
          vim.o.winminwidth = 1
          local state = (captured and sidebars.has_sidebars(captured)) and captured or sidebars.read()
          schedule_restore(state)
        end,
      },

      no_restore_cmds = {
        function()
          schedule_restore(sidebars.read())
        end,
      },
    },
    config = function(_, opts)
      require("auto-session").setup(opts)

      vim.api.nvim_create_autocmd("User", {
        pattern = "VeryLazy",
        group = vim.api.nvim_create_augroup("sidebar_state_very_lazy", { clear = true }),
        callback = function()
          vim.g.sidebar_session_very_lazy = true
        end,
      })

      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "neo-tree", "aerial" },
        group = vim.api.nvim_create_augroup("persist_sidebars_on_open", { clear = true }),
        callback = function()
          if sidebars.closing_for_save or sidebars.restoring then
            return
          end
          vim.schedule(function()
            if not sidebars.closing_for_save and not sidebars.restoring then
              captured = sidebars.persist(sidebars.detect())
            end
          end)
        end,
      })

      vim.api.nvim_create_autocmd("WinClosed", {
        group = vim.api.nvim_create_augroup("persist_sidebars_on_close", { clear = true }),
        callback = function(args)
          if sidebars.closing_for_save or sidebars.restoring then
            return
          end
          local win = tonumber(args.match)
          if not win then
            return
          end
          local ok, buf = pcall(vim.api.nvim_win_get_buf, win)
          if not ok then
            return
          end
          local ft = vim.bo[buf].filetype
          if ft ~= "neo-tree" and ft ~= "aerial" then
            return
          end
          vim.schedule(function()
            if not sidebars.closing_for_save and not sidebars.restoring then
              captured = sidebars.persist(sidebars.detect())
            end
          end)
        end,
      })
    end,

    init = function()
      vim.o.sessionoptions = "buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions"
      vim.api.nvim_create_autocmd("VimLeavePre", {
        group = vim.api.nvim_create_augroup("persist_sidebars_before_session_save", { clear = true }),
        callback = function()
          captured = sidebars.persist(sidebars.detect())
          sidebars.closing_for_save = true
        end,
      })
    end,

    keys = {
      { "<leader>wr", "<cmd>AutoSession search<CR>", desc = "Session search" },
      { "<leader>ws", "<cmd>AutoSession save<CR>", desc = "Save session" },
      { "<leader>wa", "<cmd>AutoSession toggle<CR>", desc = "Toggle autosave" },
      { "<leader>wd", "<cmd>AutoSession delete<CR>", desc = "Delete session" },
    },
  },
}
