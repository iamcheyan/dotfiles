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
        -- A blank cell with an opaque background becomes a wide-looking block
        -- when a buffer line is hard-wrapped. Use a narrow glyph instead.
        text = "▏",
        highlight = "ScrollbarHandle",
        blend = 0,
      },
      handlers = {
        diagnostic = true,
        gitsigns = true,
      },
    },
  },
}
