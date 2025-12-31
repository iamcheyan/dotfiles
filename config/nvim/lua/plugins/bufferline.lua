return {
  {
    "akinsho/bufferline.nvim",
    opts = {
      options = {
        indicator = { style = "none" },
        separator_style = { "", "" },
        show_buffer_close_icons = true,
        show_close_icon = false,
        hover = {
          enabled = true,
          reveal = { "close" },
        },
        enforce_regular_tabs = false,
        tab_size = 0,
        buffer_close_icon = "", -- 带前置空格，增加选中态的呼吸感
        modified_icon = "", -- 保持为空，确保未选中标签极致紧凑
      },

      highlights = {
        indicator_selected = {
          fg = "#000000",
          bg = "#3fb950",
        },
        -- 背景填充（非 tab 区域）
        fill = {
          bg = "#1e1e1e",
        },

        -- 非当前 tab
        background = {
          fg = "#9aa0a6",
          bg = "#1e1e1e",
        },
        buffer_visible = {
          fg = "#9aa0a6",
          bg = "#1e1e1e",
        },
        duplicate = {
          fg = "#9aa0a6",
          bg = "#1e1e1e",
          italic = false,
        },
        duplicate_visible = {
          fg = "#9aa0a6",
          bg = "#1e1e1e",
          italic = false,
        },

        -- 当前 tab：绿色背景
        buffer_selected = {
          fg = "#000000",
          bg = "#3fb950", -- 绿色（GitHub green）
          bold = true,
          italic = false,
        },
        duplicate_selected = {
          fg = "#000000",
          bg = "#3fb950",
          italic = false,
        },
        close_button_selected = {
          fg = "#000000",
          bg = "#3fb950",
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
