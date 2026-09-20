return {
  {
    "folke/todo-comments.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      signs = true,
      keywords = {
        FIX  = { icon = " ", color = "error",   alt = { "FIXME", "BUG", "ISSUE" } },
        TODO = { icon = " ", color = "info" },
        HACK = { icon = " ", color = "warning" },
        WARN = { icon = " ", color = "warning", alt = { "WARNING", "XXX" } },
        PERF = { icon = "󰅒 ", color = "default", alt = { "OPTIM", "PERFORMANCE", "OPTIMIZE" } },
        NOTE = { icon = "󰎞 ", color = "hint",    alt = { "INFO" } },
        REVIEW = { icon = "󰈈 ", color = "test",  alt = { "CHECK" } },
        TEST = { icon = "⏲ ", color = "test",   alt = { "TESTING", "PASSED", "FAILED" } },
      },
    },
    keys = {
      { "]t",         function() require("todo-comments").jump_next() end, desc = "Todo: Next" },
      { "[t",         function() require("todo-comments").jump_prev() end, desc = "Todo: Prev" },
      { "<leader>st", "<cmd>TodoPicker<cr>",                               desc = "Todo: Search All" },
      { "<leader>sT", "<cmd>TodoPicker keywords=TODO,FIX,FIXME<cr>",      desc = "Todo: Search TODO/FIX" },
    },
  },
}
