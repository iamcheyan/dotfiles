return {
  {
    "stevearc/aerial.nvim",
    keys = {
      { "<leader>cs", "<cmd>AerialToggle!<cr>", desc = "Aerial (Symbols)" },
    },
    opts = {
      layout = {
        default_direction = "left",
        placement = "window",
        width = 30,
      },
      show_guides = true,
      manage_folds = true,
      link_tree_to_folds = true,
      link_tree_to_window = true,
    },
  },
  {
    "folke/trouble.nvim",
    optional = true,
    keys = {
      { "<leader>cs", false },
    },
  },
}
