return {
  {
    "petertriho/nvim-scrollbar",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      show_in_active_only = false,
      -- Use semantic theme groups instead of deriving a low-contrast color
      -- from CursorColumn. ui_highlights owns the actual colors.
      set_highlights = false,
      excluded_buftypes = {
        "terminal",
        "nofile",
        "quickfix",
        "prompt",
      },
      excluded_filetypes = {
        "contextline_menu",
        "dropbar_menu",
        "dropbar_menu_fzf",
        "DressingInput",
        "cmp_docs",
        "cmp_menu",
        "blink-cmp-menu",
        "noice",
        "prompt",
        "TelescopePrompt",
        "neo-tree",
        "aerial",
      },
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
