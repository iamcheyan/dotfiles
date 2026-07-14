return {
  {
    "akinsho/bufferline.nvim",
    enabled = vim.env.WDIFF_NVIM ~= "1",
    opts = {
      highlights = {
        fill = {
          bg = "#2a2a2a",
          fg = "#5e5e5e",
        },
        trunc_marker = {
          bg = "#1c1c1c",
          fg = "#6a6a6a",
        },
        group_separator = {
          bg = "#1c1c1c",
          fg = "#1c1c1c",
        },
        group_label = {
          bg = "#1c1c1c",
          fg = "#8a8a8a",
        },
        tab = {
          bg = "#1c1c1c",
          fg = "#7a7a7a",
        },
        tab_selected = {
          bg = "#353535",
          fg = "#ffffff",
          bold = true,
        },
        tab_close = {
          bg = "#1c1c1c",
          fg = "#7a7a7a",
        },
        background = {
          bg = "#1c1c1c",
          fg = "#7a7a7a",
        },
        buffer = {
          bg = "#1c1c1c",
          fg = "#7a7a7a",
        },
        buffer_visible = {
          bg = "#262626",
          fg = "#a0a0a0",
        },
        buffer_selected = {
          bg = "#353535",
          fg = "#ffffff",
          bold = true,
        },
        diagnostic = {
          bg = "#1c1c1c",
          fg = "#7a7a7a",
        },
        diagnostic_visible = {
          bg = "#262626",
          fg = "#a0a0a0",
        },
        diagnostic_selected = {
          bg = "#353535",
          fg = "#ffffff",
          bold = true,
        },
        error = {
          bg = "#1c1c1c",
          fg = "#c75c6a",
        },
        error_visible = {
          bg = "#262626",
          fg = "#d46b79",
        },
        error_selected = {
          bg = "#353535",
          fg = "#c75c6a",
          bold = true,
        },
        error_diagnostic = {
          bg = "#1c1c1c",
          fg = "#c75c6a",
        },
        error_diagnostic_visible = {
          bg = "#262626",
          fg = "#d46b79",
        },
        error_diagnostic_selected = {
          bg = "#353535",
          fg = "#c75c6a",
          bold = true,
        },
        warning = {
          bg = "#1c1c1c",
          fg = "#b89a58",
        },
        warning_visible = {
          bg = "#262626",
          fg = "#c8ab68",
        },
        warning_selected = {
          bg = "#353535",
          fg = "#b89a58",
          bold = true,
        },
        warning_diagnostic = {
          bg = "#1c1c1c",
          fg = "#b89a58",
        },
        warning_diagnostic_visible = {
          bg = "#262626",
          fg = "#c8ab68",
        },
        warning_diagnostic_selected = {
          bg = "#353535",
          fg = "#b89a58",
          bold = true,
        },
        info = {
          bg = "#1c1c1c",
          fg = "#6f8fa8",
        },
        info_visible = {
          bg = "#262626",
          fg = "#80a1bb",
        },
        info_selected = {
          bg = "#353535",
          fg = "#6f8fa8",
          bold = true,
        },
        info_diagnostic = {
          bg = "#1c1c1c",
          fg = "#6f8fa8",
        },
        info_diagnostic_visible = {
          bg = "#262626",
          fg = "#80a1bb",
        },
        info_diagnostic_selected = {
          bg = "#353535",
          fg = "#6f8fa8",
          bold = true,
        },
        hint = {
          bg = "#1c1c1c",
          fg = "#6d9a7b",
        },
        hint_visible = {
          bg = "#262626",
          fg = "#7fad8d",
        },
        hint_selected = {
          bg = "#353535",
          fg = "#6d9a7b",
          bold = true,
        },
        hint_diagnostic = {
          bg = "#1c1c1c",
          fg = "#6d9a7b",
        },
        hint_diagnostic_visible = {
          bg = "#262626",
          fg = "#7fad8d",
        },
        hint_diagnostic_selected = {
          bg = "#353535",
          fg = "#6d9a7b",
          bold = true,
        },
        duplicate = {
          bg = "#1c1c1c",
          fg = "#7f7f7f",
          italic = false,
        },
        duplicate_visible = {
          bg = "#262626",
          fg = "#a0a0a0",
          italic = false,
        },
        duplicate_selected = {
          bg = "#353535",
          fg = "#7f7f7f",
          italic = false,
        },
        numbers = {
          bg = "#1c1c1c",
          fg = "#666666",
        },
        numbers_visible = {
          bg = "#262626",
          fg = "#929292",
        },
        numbers_selected = {
          bg = "#353535",
          fg = "#ffffff",
          bold = true,
        },
        close_button = {
          bg = "#1c1c1c",
          fg = "#707070",
        },
        close_button_visible = {
          bg = "#262626",
          fg = "#949494",
        },
        close_button_selected = {
          bg = "#353535",
          fg = "#ffffff",
        },
        modified = {
          bg = "#1c1c1c",
          fg = "#8e8e8e",
        },
        modified_visible = {
          bg = "#262626",
          fg = "#b3b3b3",
        },
        modified_selected = {
          bg = "#353535",
          fg = "#8e8e8e",
        },
        separator = {
          bg = "#1c1c1c",
          fg = "#1c1c1c",
        },
        separator_visible = {
          bg = "#262626",
          fg = "#262626",
        },
        separator_selected = {
          bg = "#353535",
          fg = "#2a2a2a",
        },
        tab_separator = {
          bg = "#1c1c1c",
          fg = "#1c1c1c",
        },
        tab_separator_selected = {
          bg = "#353535",
          fg = "#2a2a2a",
        },
        indicator_selected = {
          bg = "#353535",
          fg = "#353535",
        },
        indicator_visible = {
          bg = "#262626",
          fg = "#262626",
        },
        pick = {
          bg = "#1c1c1c",
          fg = "#d0d0d0",
          bold = true,
          italic = false,
        },
        pick_visible = {
          bg = "#262626",
          fg = "#dcdcdc",
          bold = true,
          italic = false,
        },
        pick_selected = {
          bg = "#353535",
          fg = "#d0d0d0",
          bold = true,
          italic = false,
        },
        offset_separator = {
          bg = "#2a2a2a",
          fg = "#2a2a2a",
        },
      },
      options = {
        style_preset = nil, -- resolved in config (no_italic preset)
        mode = "buffers",
        diagnostics = false,
        themable = false,
        color_icons = true,
        show_tab_indicators = false, -- 隐藏右侧 Tab Page 数字指示器
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
    config = function(_, opts)
      local ok, bl = pcall(require, "bufferline")
      if ok and not (opts.options and opts.options.style_preset) then
        opts.options = opts.options or {}
        opts.options.style_preset = bl.style_preset.no_italic
      end
      require("bufferline").setup(opts)
    end,
  },
}
