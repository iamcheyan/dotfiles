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

  -- NOTE: gitsigns is already included by LazyVim. Keep explicit opts here for clarity.
  {
    "lewis6991/gitsigns.nvim",
    opts = {
      signcolumn = true,
      current_line_blame = false,
    },
  },

  {
    "airblade/vim-gitgutter",
    event = { "BufReadPre", "BufNewFile" },
    init = function()
      -- Avoid duplicate git signs with gitsigns by default.
      vim.g.gitgutter_enabled = 0
      vim.g.gitgutter_map_keys = 0
    end,
    keys = {
      { "<leader>uG", "<cmd>GitGutterToggle<cr>", desc = "Toggle GitGutter" },
      { "]h", "<cmd>GitGutterNextHunk<cr>", desc = "GitGutter Next Hunk" },
      { "[h", "<cmd>GitGutterPrevHunk<cr>", desc = "GitGutter Prev Hunk" },
      { "<leader>hp", "<cmd>GitGutterPreviewHunk<cr>", desc = "GitGutter Preview Hunk" },
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
    "ellisonleao/glow.nvim",
    cmd = "Glow",
    opts = {
      border = "single",
      style = "dark",
      width = 120,
    },
    keys = {
      { "<leader>mg", "<cmd>Glow<cr>", desc = "Markdown Preview (Glow)" },
    },
  },

  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    event = "VeryLazy",
    opts = {
      indent = { char = "│" },
      scope = { enabled = true },
      exclude = {
        filetypes = { "help", "dashboard", "neo-tree", "NvimTree", "lazy", "mason", "Trouble" },
      },
    },
  },
}
