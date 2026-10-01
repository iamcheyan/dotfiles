return {
  {
    "OXY2DEV/markview.nvim",
    -- Markview manages its own preview attachment; keep it available after the
    -- colorscheme has initialized so Markdown opens with rendered elements.
    lazy = false,
    ft = { "markdown", "markdown.mdx", "quarto", "rmd" },
    opts = {
      preview = {
        enable = true,
        icon_provider = "internal",
        filetypes = { "markdown", "markdown.mdx", "quarto", "rmd" },
      },
    },
    keys = {
      {
        "<leader>um",
        "<cmd>Markview<cr>",
        ft = { "markdown", "markdown.mdx", "quarto", "rmd" },
        desc = "Toggle Markdown preview",
      },
    },
  },
}
