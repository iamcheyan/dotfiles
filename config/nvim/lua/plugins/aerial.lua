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
        max_width = { 120, 0.4 },
        resize_to_content = true,
      },
      show_guides = true,
      manage_folds = true,
      link_tree_to_folds = true,
      link_tree_to_window = true,
    },
  },
}
