return {
  {
    "akinsho/bufferline.nvim",
    enabled = vim.env.WDIFF_NVIM ~= "1",
    opts = function()
      -- Neovim's tabline click protocol only resolves global functions.
      _G.__bufferline_new_buffer = function(_, _, button)
        if button == "l" then
          vim.cmd("enew")
        end
      end

      return {
        highlights = require("config.ui_highlights").bufferline_highlights(),
        options = {
          style_preset = nil, -- resolved in config (no_italic preset)
          mode = "buffers",
          diagnostics = false,
          themable = true,
          -- Icons inherit the active/inactive tab text color. Keeping the
          -- filetype glyph while disabling per-filetype icon colors prevents
          -- selected icons from turning white or retaining stale colors.
          color_icons = false,
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
          custom_areas = {
            right = function()
              return {
                {
                  -- Keep the click marker inside the highlighted plus area.
                  text = " %@v:lua.__bufferline_new_buffer@+%T ",
                  link = "BufferLineNewBuffer",
                },
              }
            end,
          },
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
      vim.defer_fn(function()
        require("config.ui_highlights").apply()
      end, 0)
    end,
  },
}
