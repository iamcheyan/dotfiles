return {
  {
    "petertriho/nvim-scrollbar",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      show_in_active_only = false,
      -- Use semantic theme groups instead of deriving a low-contrast color
      -- from CursorColumn. ui_highlights owns the actual colors.
      set_highlights = false,
      handle = {
        highlight = "TabLineSel",
        blend = 0,
      },
      handlers = {
        diagnostic = true,
        gitsigns = true,
      },
    },
  },
}
