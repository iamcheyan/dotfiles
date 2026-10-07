-- Backdrops are inactive windows: map NormalNC too, or Blue leaks through.
local black_backdrop = {
  bg = "#000000",
  blend = 80,
  win = {
    wo = { winhighlight = "Normal:SnacksBackdrop_000000,NormalNC:SnacksBackdrop_000000" },
  },
}

return {
  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    keys = {
      { "<leader>fe", false },
      { "<leader>fE", false },
      { "<leader>e", false },
      { "<leader>E", false },
    },
    config = function(_, opts)
      require("snacks").setup(opts)

      -- Work around an upstream grep transform crash when rg outputs a non-NUL line.
      local proc = require("snacks.picker.source.proc")
      local raw_proc = proc.proc
      proc.proc = function(picker_opts, ctx)
        if picker_opts and picker_opts.cmd == "rg" and type(picker_opts.transform) == "function" then
          local original_transform = picker_opts.transform
          picker_opts = vim.tbl_extend("force", {}, picker_opts)
          picker_opts.transform = function(item, transform_ctx)
            local ok, ret = pcall(original_transform, item, transform_ctx)
            if ok then
              return ret
            end
            local err = tostring(ret)
            if err:find("file_sep", 1, true) then
              return false
            end
            return false
          end
        end
        return raw_proc(picker_opts, ctx)
      end
    end,
    opts = {
      explorer = { enabled = false },
      scroll = { enabled = false },
      statuscolumn = {
        enabled = true,
        left = { "mark", "sign" },
        right = { "fold", "git" },
        folds = {
          open = true, -- 显示已展开的代码折叠三角图标 
          git_hl = false,
        },
      },
      notifier = {
        icons = {
          error = "",
          warn = "",
          info = "",
          debug = "",
          trace = "",
        },
      },
      -- 1. 全局基础窗口配置
      win = { border = "single" },
      -- 2. 覆盖 Snacks 内置的所有标准样式
      lazygit = {
        configure = true,
        theme = {
          activeBorderColor = { fg = "UnifiedFloatBorder" },
          inactiveBorderColor = { fg = "UnifiedFloatBorder" },
          defaultFgColor = { fg = "Normal" },
          selectedLineBgColor = { bg = "SnacksPickerListCursorLine" },
        },
      },
      styles = {
        float = { border = "single", backdrop = black_backdrop },
        notification = { border = "single" },
        input = { border = "single", backdrop = black_backdrop },
        confirm = { border = "single", backdrop = black_backdrop },
        lazygit = { border = "single", backdrop = black_backdrop },
      },
      picker = {
        on_show = function(picker)
          -- The picker floats over the editor; hide its context winbar while
          -- open so the old buffer breadcrumb does not look like a stray bar.
          local win = picker.main
          if win and vim.api.nvim_win_is_valid(win) then
            picker._saved_main_winbar = vim.wo[win].winbar
            vim.wo[win].winbar = ""
          end
          -- Snacks maps NormalFloat for the preview, but blank filler lines
          -- use Normal. Map that too so scrolling past document text never
          -- exposes the editor's blue background inside the picker.
          vim.defer_fn(function()
            if picker.closed then return end
            local preview = picker.preview and picker.preview.win and picker.preview.win.win
            if preview and vim.api.nvim_win_is_valid(preview) then
              local winhl = vim.wo[preview].winhighlight
              if not winhl:find("Normal:", 1, true) then
                vim.wo[preview].winhighlight = (winhl ~= "" and (winhl .. ",") or "")
                  .. "Normal:SnacksPickerPreview"
              end
            end
          end, 50)
        end,
        on_close = function(picker)
          local win = picker.main
          if win and vim.api.nvim_win_is_valid(win) and picker._saved_main_winbar ~= nil then
            vim.wo[win].winbar = picker._saved_main_winbar
            picker._saved_main_winbar = nil
          end
        end,
        layout = {
          layout = {
            -- Keep background text visible at 20% brightness behind the dialog.
            backdrop = black_backdrop,
            box = "horizontal",
            width = 0.85,
            min_width = 120,
            height = 0.8,
            border = "single",
            footer = {
              { " Alt+h ", "SnacksPickerFooterKey" },
              { "Toggle Hidden", "SnacksPickerFooterText" },
              { "  │  ", "SnacksPickerFooterSeparator" },
              { " Alt+i ", "SnacksPickerFooterKey" },
              { "Toggle Ignored", "SnacksPickerFooterText" },
              { "  │  ", "SnacksPickerFooterSeparator" },
              { " Enter ", "SnacksPickerFooterKey" },
              { "Open", "SnacksPickerFooterText" },
              { "  │  ", "SnacksPickerFooterSeparator" },
              { " Esc ", "SnacksPickerFooterKey" },
              { "Close", "SnacksPickerFooterText" },
            },
            footer_pos = "center",
            {
              box = "vertical",
              border = "none",
              { win = "input", height = 1, border = "single" },
              { win = "list", border = "none" },
            },
            { win = "preview", border = "left", width = 0.55 },
          },
        },
        win = {
          preview = {
            wo = { cursorcolumn = false },
          },
          input = {
            keys = {
              ["<a-h>"] = { "toggle_hidden", mode = { "i", "n" } },
              ["<c-h>"] = { "toggle_hidden", mode = { "i", "n" } },
              ["<a-i>"] = { "toggle_ignored", mode = { "i", "n" } },
            },
          },
        },
        sources = {
          files = {
            hidden = false,
          },
          grep = {
            args = { "--no-messages" },
          },
          git_grep = {
            args = { "--no-messages" },
          },
        },
      },
    },
  },
}
