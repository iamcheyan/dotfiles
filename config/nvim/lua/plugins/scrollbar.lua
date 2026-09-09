return {
  {
    "petertriho/nvim-scrollbar",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      show_in_active_only = false,
      handlers = {
        diagnostic = true,
        gitsigns = true,
      },
    },
  },
}
