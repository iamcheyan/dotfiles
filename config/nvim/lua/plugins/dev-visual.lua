return {
  {
    "j-hui/fidget.nvim",
    event = "LspAttach",
    opts = {
      notification = {
        window = {
          border = "single",
        },
      },
    },
  },

  -- diffview.nvim: 强大的 Git diff 查看器
  {
    "sindrets/diffview.nvim",
    cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewToggleFiles", "DiffviewFocusFiles" },
    keys = {
      { "<leader>gdv", function()
        local view = require("diffview.lib").get_current_view()
        if view then
          vim.cmd("DiffviewClose")
        else
          vim.cmd("DiffviewOpen")
        end
      end, desc = "Toggle Diffview" },
      { "<leader>gdc", "<cmd>DiffviewClose<cr>", desc = "Close Diffview" },
      { "<leader>gdf", "<cmd>DiffviewFocusFiles<cr>", desc = "Focus Diffview Files" },
      { "<leader>gdt", "<cmd>DiffviewToggleFiles<cr>", desc = "Toggle Diffview Files" },
      { "<leader>gdh", "<cmd>DiffviewFileHistory<cr>", desc = "File History" },
    },
    opts = {
      diff_binaries = false,
      enhanced_diff_hl = true,
      git_cmd = { "git" },
      use_icons = true,
      show_help_hints = true,
      watch_indexed_git_files = true,
      icons = {
        folder_closed = "",
        folder_open = "",
      },
      signs = {
        fold_closed = "",
        fold_open = "",
        done = "✓",
      },
      view = {
        default = {
          -- 默认布局：左侧文件列表，右侧 diff
          layout = "diff2_horizontal",
        },
        merge_tool = {
          layout = "diff3_horizontal",
          disable_diagnostics = true,
        },
        file_history = {
          layout = "diff2_horizontal",
        },
      },
      file_panel = {
        listing_style = "tree",
        tree_options = {
          flatten_dirs = true,
          folder_statuses = "only_folded",
        },
        win_config = {
          position = "left",
          width = 35,
          win_opts = {},
        },
      },
      file_history_panel = {
        log_options = {
          git = {
            single_file = {
              diff_merges = "combined",
            },
            multi_file = {
              diff_merges = "first-parent",
            },
          },
        },
        win_config = {
          position = "bottom",
          height = 16,
          win_opts = {},
        },
      },
      commit_log_panel = {
        win_config = {},
      },
      default_args = {
        DiffviewOpen = {},
        DiffviewFileHistory = {},
      },
      hooks = {
        diff_buf_read = function(bufnr)
          -- 在 diff 缓冲区中禁用行号（可选）
          vim.opt_local.number = false
          vim.opt_local.relativenumber = false
        end,
      },
      keymaps = {
        disable_defaults = false,
        view = {
          { "n", "<tab>", "<cmd>DiffviewFocusFiles<cr>", { desc = "Focus Files Panel" } },
          { "n", "q", "<cmd>DiffviewClose<cr>", { desc = "Close Diffview" } },
        },
        file_panel = {
          { "n", "j", "<cmd>lua require('diffview.actions').next_entry()<cr>", { desc = "Next Entry" } },
          { "n", "k", "<cmd>lua require('diffview.actions').prev_entry()<cr>", { desc = "Previous Entry" } },
          { "n", "o", "<cmd>lua require('diffview.actions').select_entry()<cr>", { desc = "Open File" } },
          { "n", "<cr>", "<cmd>lua require('diffview.actions').select_entry()<cr>", { desc = "Open File" } },
          { "n", "s", "<cmd>lua require('diffview.actions').toggle_stage_entry()<cr>", { desc = "Stage/Unstage" } },
          { "n", "S", "<cmd>lua require('diffview.actions').stage_all()<cr>", { desc = "Stage All" } },
          { "n", "U", "<cmd>lua require('diffview.actions').unstage_all()<cr>", { desc = "Unstage All" } },
          { "n", "X", "<cmd>lua require('diffview.actions').restore_entry()<cr>", { desc = "Restore Entry" } },
          { "n", "R", "<cmd>lua require('diffview.actions').refresh_files()<cr>", { desc = "Refresh" } },
          { "n", "<tab>", "<cmd>lua require('diffview.actions').select_next_entry()<cr>", { desc = "Open Next" } },
          { "n", "<s-tab>", "<cmd>lua require('diffview.actions').select_prev_entry()<cr>", { desc = "Open Previous" } },
          { "n", "gf", "<cmd>lua require('diffview.actions').goto_file()<cr>", { desc = "Go to File" } },
          { "n", "q", "<cmd>DiffviewClose<cr>", { desc = "Close" } },
        },
        file_history_panel = {
          { "n", "j", "<cmd>lua require('diffview.actions').next_entry()<cr>", { desc = "Next Entry" } },
          { "n", "k", "<cmd>lua require('diffview.actions').prev_entry()<cr>", { desc = "Previous Entry" } },
          { "n", "o", "<cmd>lua require('diffview.actions').select_entry()<cr>", { desc = "Open File" } },
          { "n", "<cr>", "<cmd>lua require('diffview.actions').select_entry()<cr>", { desc = "Open File" } },
          { "n", "q", "<cmd>DiffviewClose<cr>", { desc = "Close" } },
        },
      },
    },
  },

  -- gitsigns: 完整的 Git 集成配置，包括行高亮和快捷键
  {
    "lewis6991/gitsigns.nvim",
    opts = {
      signs = {
        add = { text = "│" },
        change = { text = "│" },
        delete = { text = "_" },
        topdelete = { text = "‾" },
        changedelete = { text = "~" },
        untracked = { text = "┆" },
      },
      signcolumn = true,
      numhl = false,
      linehl = true,  -- 开启整行背景高亮
      word_diff = false,
      current_line_blame = false,
      on_attach = function(bufnr)
        local gitsigns = require("gitsigns")
        local function map(mode, l, r, opts)
          opts = opts or {}
          opts.buffer = bufnr
          vim.keymap.set(mode, l, r, opts)
        end

        -- 导航
        map("n", "]g", gitsigns.next_hunk, { desc = "Next Git hunk" })
        map("n", "[g", gitsigns.prev_hunk, { desc = "Previous Git hunk" })

        -- 操作
        map("n", "<leader>gp", gitsigns.preview_hunk, { desc = "Preview Git hunk" })
        map("n", "<leader>gd", gitsigns.diffthis, { desc = "Git diff this file" })
        map("n", "<leader>gs", gitsigns.stage_hunk, { desc = "Stage Git hunk" })
        map("n", "<leader>gu", gitsigns.undo_stage_hunk, { desc = "Undo stage Git hunk" })
        map("n", "<leader>gr", gitsigns.reset_hunk, { desc = "Reset Git hunk" })
        map("n", "<leader>gb", function() gitsigns.blame_line({ full = true }) end, { desc = "Git blame line" })

        -- 开关
        map("n", "<leader>gt", gitsigns.toggle_signs, { desc = "Toggle Git signs" })
        map("n", "<leader>gl", gitsigns.toggle_current_line_blame, { desc = "Toggle Git line blame" })
        map("n", "<leader>gL", gitsigns.toggle_linehl, { desc = "Toggle Git line highlight" })
      end,
    },
  },

  {
    "kevinhwang91/nvim-hlslens",
    event = "VeryLazy",
    opts = {},
    keys = {
      {
        "n",
        function()
          vim.cmd("normal! n")
          require("hlslens").start()
        end,
        desc = "Next Search Result",
      },
      {
        "N",
        function()
          vim.cmd("normal! N")
          require("hlslens").start()
        end,
        desc = "Prev Search Result",
      },
      {
        "*",
        function()
          vim.cmd("normal! *")
          require("hlslens").start()
        end,
        desc = "Search Word Forward",
      },
      {
        "#",
        function()
          vim.cmd("normal! #")
          require("hlslens").start()
        end,
        desc = "Search Word Backward",
      },
      {
        "g*",
        function()
          vim.cmd("normal! g*")
          require("hlslens").start()
        end,
        desc = "Search Partial Word Forward",
      },
      {
        "g#",
        function()
          vim.cmd("normal! g#")
          require("hlslens").start()
        end,
        desc = "Search Partial Word Backward",
      },
    },
  },

  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    event = "VeryLazy",
    opts = {
      indent = { char = "│" },
      scope = { enabled = false },
      exclude = {
        filetypes = { "help", "dashboard", "neo-tree", "NvimTree", "lazy", "mason", "Trouble" },
      },
    },
  },
}
