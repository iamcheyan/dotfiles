return {
  {
    "akinsho/bufferline.nvim",
    enabled = vim.env.WDIFF_NVIM ~= "1",
    opts = function()
      local is_ocean = vim.g.colors_name == "oceanblack" or vim.g.colors_name == "oceanblack256"
      return {
        highlights = is_ocean and require("config.fresh_ui").bufferline_highlights() or nil,
        options = {
          style_preset = nil, -- resolved in config (no_italic preset)
          mode = "buffers",
          diagnostics = false,
          themable = true,
          -- Allow colorful filetype icons when supported by the theme
          color_icons = not is_ocean,
          show_tab_indicators = false,
          offsets = {
            {
              filetype = "snacks_layout_box",
            },
          },
          -- Remove separator character between tabs for a seamless, compact layout
          separator_style = { "", "" },
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
      }
    end,
    config = function(_, opts)
      local bufferline = require("bufferline")
      if not (opts.options and opts.options.style_preset) then
        opts.options = opts.options or {}
        opts.options.style_preset = bufferline.style_preset.no_italic
      end
      bufferline.setup(opts)

      -- bufferline creates its DevIcon groups during setup.
      local is_ocean = vim.g.colors_name == "oceanblack" or vim.g.colors_name == "oceanblack256"
      if is_ocean then
        vim.defer_fn(function()
          require("config.fresh_ui").apply()
        end, 0)
      end
    end,
  },
}
