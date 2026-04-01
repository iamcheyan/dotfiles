return {
  {
    "folke/snacks.nvim",
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
        -- 3. 针对 Picker 的每一个子窗进行硬拦截
        win = {
          input = { border = "single" },
          list = { border = "single" },
          preview = { border = "single" },
        },
        sources = {
          files = {
            hidden = true,
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
