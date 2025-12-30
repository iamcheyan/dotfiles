return {
  {
    "akinsho/bufferline.nvim",
    opts = {
      options = {
        indicator = { style = "none" },
        separator_style = { "", "" },
        show_buffer_close_icons = false,
        show_close_icon = false,
      },

      highlights = {
        -- 非当前 tab
        background = {
          fg = "#9aa0a6",
          bg = "#1e1e1e",
        },

        -- 当前 tab：绿色背景
        buffer_selected = {
          fg = "#000000",
          bg = "#3fb950", -- 绿色（GitHub green）
          bold = true,
        },

        -- 分隔符全部“隐形”
        separator = {
          fg = "#1e1e1e",
          bg = "#1e1e1e",
        },
        separator_selected = {
          fg = "#3fb950",
          bg = "#3fb950",
        },
      },
    },
  },
}
