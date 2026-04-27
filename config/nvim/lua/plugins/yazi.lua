return {
  {
    "mikavilpas/yazi.nvim",
    version = "*",
    -- NOTE: Do NOT use event = "VeryLazy" together with keys.
    -- In lazy.nvim, "keys" already enables lazy-loading. Adding "event"
    -- causes the keymaps to be registered incorrectly, so <leader>e / <leader>E
    -- silently fail to bind. This is the general fix for yazi.nvim not opening.
    dependencies = {
      { "nvim-lua/plenary.nvim", lazy = true },
    },
    keys = {
      {
        "<leader>e",
        function()
          require("yazi").yazi(nil, vim.fn.expand("%:p"))
        end,
        mode = { "n", "v" },
        desc = "Yazi (current file)",
      },
      {
        "<leader>E",
        function()
          require("yazi").yazi(nil, vim.fn.getcwd())
        end,
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
