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
      auto_create = true,
      auto_restore_last_session = false,

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
