return {
  {
    "lewis6991/satellite.nvim",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      current_only = false,
      winblend = 0,
      zindex = 40,
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
        "help",
        "lazy",
        "mason",
      },
      handlers = {
        cursor = {
          enable = true,
          overlap = true,
          priority = 100,
        },
        search = {
          enable = true,
        },
        diagnostic = {
          enable = true,
        },
        gitsigns = {
          enable = true,
        },
        marks = {
          enable = true,
          show_builtins = false,
        },
      },
    },
  },
}
