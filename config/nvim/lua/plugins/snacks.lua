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
      styles = {
        float = { border = "single" },
        notification = { border = "single" },
        input = { border = "single" },
        confirm = { border = "single" },
      },
      picker = {
        layout = {
          layout = {
            box = "horizontal",
            width = 0.85,
            min_width = 120,
            height = 0.8,
            border = "single",
            footer = {
              { " Alt+h ", "Special" },
              { "Toggle Hidden", "Comment" },
              { "  │  ", "NonText" },
              { " Alt+i ", "Special" },
              { "Toggle Ignored", "Comment" },
              { "  │  ", "NonText" },
              { " Enter ", "Special" },
              { "Open", "Comment" },
              { "  │  ", "NonText" },
              { " Esc ", "Special" },
              { "Close", "Comment" },
            },
            footer_pos = "center",
            {
              box = "vertical",
              border = "none",
              { win = "input", height = 1, border = "bottom" },
              { win = "list", border = "none" },
            },
            { win = "preview", border = "left", width = 0.55 },
          },
        },
        win = {
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
