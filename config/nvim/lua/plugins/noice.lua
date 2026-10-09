-- Keep Ex command entry at the bottom, but render Neovim's blocking confirm
-- prompts (for example :q with unsaved changes) in Noice's centered popup.
return {
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    dependencies = { "MunifTanjim/nui.nvim" },
    opts = {
      cmdline = {
        enabled = true,
        view = "cmdline",
        format = {
          -- Keep the native ':' prompt instead of Noice's default '>' icon.
          cmdline = { icon = "", conceal = false },
          -- Keep vim.ui.input prompts at the bottom too.
          input = { view = "cmdline", icon = "" },
        },
      },
      messages = {
        enabled = true,
        -- Keep ordinary messages at the bottom; Noice's built-in confirm
        -- route still sends confirm dialogs to the dedicated floating view.
        view = "cmdline",
        view_error = "cmdline",
        view_warn = "cmdline",
        view_search = "cmdline",
        view_history = "messages",
      },
      views = {
        confirm = {
          position = { row = "50%", col = "50%" },
          size = { width = "auto", height = "auto", max_width = 64 },
          format = { "{dialog}" },
          align = "left",
          scrollbar = false,
          border = { style = "rounded", padding = { 1, 2 }, text = { top = " Confirm " } },
          win_options = {
            wrap = true,
            winhighlight = {
              Normal = "ConfirmDialogNormal",
              FloatBorder = "ConfirmDialogBorder",
            },
          },
        },
      },
      popupmenu = { enabled = false },
      -- Preserve the existing Snacks notification UI and LSP UI behavior.
      notify = { enabled = false },
      lsp = {
        progress = { enabled = false },
        message = { enabled = false },
        hover = { enabled = false },
        signature = { enabled = false },
      },
    },
    config = function(_, opts)
      require("config.confirm_dialog").setup()
      require("noice").setup(opts)
    end,
  },
}
