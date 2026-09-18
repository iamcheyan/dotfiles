return {
  {
    "akinsho/bufferline.nvim",
    enabled = vim.env.WDIFF_NVIM ~= "1",
    opts = {
      -- Colors are centralized in config.fresh_ui.lua before Bufferline
      -- creates its per-filetype icon highlight groups.
      highlights = require("config.fresh_ui").bufferline_highlights(),
      options = {
        style_preset = nil, -- resolved in config (no_italic preset)
        mode = "buffers",
        diagnostics = false,
        themable = false,
        -- Let the active buffer highlight control the icon as well.
        color_icons = false,
        show_tab_indicators = false,
        offsets = {
          {
            filetype = "snacks_layout_box",
          },
        },
        separator_style = "thin",
        indicator = {
          style = "none",
        },
        show_buffer_close_icons = true,
        show_close_icon = false,
        hover = {
          enabled = true,
          reveal = { "close" },
        },
        enforce_regular_tabs = false,
        buffer_close_icon = "",
        modified_icon = "",
        close_command = "bdelete! %d",
        right_mouse_command = "bdelete! %d",
        left_mouse_command = "buffer %d",
      },
    },
    config = function(_, opts)
      local bufferline = require("bufferline")
      if not (opts.options and opts.options.style_preset) then
        opts.options = opts.options or {}
        opts.options.style_preset = bufferline.style_preset.no_italic
      end
      bufferline.setup(opts)

      -- bufferline creates its DevIcon groups during setup.
      vim.defer_fn(function()
        require("config.fresh_ui").apply()
      end, 0)
    end,
  },
}
