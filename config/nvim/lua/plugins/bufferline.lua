return {
  {
    "akinsho/bufferline.nvim",
    opts = {
      highlights = {
        fill = {
          bg = "#111111",
          fg = "#4a4a4a",
        },
        background = {
          bg = "#1b1b1b",
          fg = "#707070",
        },
        buffer = {
          bg = "#1b1b1b",
          fg = "#707070",
        },
        buffer_visible = {
          bg = "#242424",
          fg = "#9a9a9a",
        },
        buffer_selected = {
          bg = "#3a3a3a",
          fg = "#e2e2e2",
          bold = true,
        },
        numbers = {
          bg = "#1b1b1b",
          fg = "#5f5f5f",
        },
        numbers_visible = {
          bg = "#242424",
          fg = "#8a8a8a",
        },
        numbers_selected = {
          bg = "#3a3a3a",
          fg = "#d8d8d8",
          bold = true,
        },
        close_button = {
          bg = "#1b1b1b",
          fg = "#666666",
        },
        close_button_visible = {
          bg = "#242424",
          fg = "#8a8a8a",
        },
        close_button_selected = {
          bg = "#3a3a3a",
          fg = "#cfcfcf",
        },
        modified = {
          bg = "#1b1b1b",
          fg = "#8a8a8a",
        },
        modified_visible = {
          bg = "#242424",
          fg = "#adadad",
        },
        modified_selected = {
          bg = "#3a3a3a",
          fg = "#f0f0f0",
        },
        separator = {
          bg = "#111111",
          fg = "#111111",
        },
        separator_visible = {
          bg = "#111111",
          fg = "#111111",
        },
        separator_selected = {
          bg = "#111111",
          fg = "#111111",
        },
        indicator_selected = {
          bg = "#3a3a3a",
          fg = "#3a3a3a",
        },
      },
      options = {
        mode = "buffers",
        diagnostics = false,
        themable = false,
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
        buffer_close_icon = "",
        modified_icon = "",
        close_command = "bdelete! %d",
        right_mouse_command = "bdelete! %d",
        left_mouse_command = "buffer %d",
      },
    },
  },
}
