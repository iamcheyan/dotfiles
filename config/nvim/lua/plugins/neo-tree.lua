return {
  {
    "nvim-tree/nvim-tree.lua",
    enabled = false,
  },
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
    },
    keys = {
      { "<leader>e", "<cmd>Neotree toggle reveal_force_cwd<cr>", desc = "Explorer (Neo-tree)" },
    },
    opts = {
      source_selector = {
        winbar = false,
        statusline = false,
      },
      event_handlers = {
        {
          event = "neo_tree_buffer_enter",
          handler = function()
            vim.opt_local.winbar = nil
          end,
        },
      },
      filesystem = {
        follow_current_file = {
          enabled = true,
        },
      },
      window = {
        width = 32,
      },
    },
  },
}
