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
        width = 30, -- 增加默认宽度以显示更多内容
        max_width = { 120, 0.4 }, -- 最大宽度为120列或窗口宽度的40%
        resize_to_content = true, -- 根据内容自动调整大小
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
