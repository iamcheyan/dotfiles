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
