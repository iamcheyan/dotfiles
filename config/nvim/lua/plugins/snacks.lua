return {
  {
    "folke/snacks.nvim",
    opts = {
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
          explorer = {
            layout = { preset = "sidebar", preview = false },
            focus = "input", 
          },
        },
      },
    },
  },
}
