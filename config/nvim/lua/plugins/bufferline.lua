return {
  {
    "akinsho/bufferline.nvim",
    opts = {
      options = {
        diagnostics = false,
        offsets = {
          {
            filetype = "snacks_layout_box",
          },
        },
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
        close_command = "bdelete! %d", -- 关闭buffer
        right_mouse_command = "bdelete! %d", -- 右键关闭
        left_mouse_command = "buffer %d", -- 左键单击切换
      },
    },
  },
}
