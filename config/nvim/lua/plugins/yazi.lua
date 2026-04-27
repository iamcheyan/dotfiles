return {
  {
    "mikavilpas/yazi.nvim",
    version = "*",
    event = "VeryLazy",
    dependencies = {
      { "nvim-lua/plenary.nvim", lazy = true },
    },
    keys = {
      {
        "<leader>e",
        "<cmd>Yazi<cr>",
        mode = { "n", "v" },
        desc = "Yazi (current file)",
      },
      {
        "<leader>E",
        "<cmd>Yazi cwd<cr>",
        desc = "Yazi (cwd)",
      },
    },
    opts = {
      open_for_directories = false,
      keymaps = {
        show_help = "<f1>",
      },
    },
  },
}
