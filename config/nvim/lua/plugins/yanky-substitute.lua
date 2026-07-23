return {
  -- yanky.nvim: 增强的剪贴板管理
  {
    "gbprod/yanky.nvim",
    dependencies = {
      "kkharji/sqlite.lua", -- 可选：用于持久化历史记录
    },
    opts = {
      ring = {
        history_length = 100,
        storage = "sqlite", -- 使用 sqlite 持久化，或改为 "shada"
        sync_with_numbered_registers = true,
        cancel_event = "update",
      },
      picker = {
        select = {
          action = nil, -- 默认动作
        },
        telescope = {
          use_default_mappings = true,
          mappings = nil,
        },
      },
      system_clipboard = {
        sync_with_ring = true,
      },
      highlight = {
        on_put = true,
        on_yank = true,
        timer = 500,
      },
      preserve_cursor_position = {
        enabled = true,
      },
      textobj = {
        enabled = true,
      },
    },
    keys = {
      -- 基本 yank 和 put（增强版）
      { "y", "<Plug>(YankyYank)", mode = { "n", "x" }, desc = "Yank" },
      { "p", "<Plug>(YankyPutAfter)", mode = { "n", "x" }, desc = "Put after" },
      { "P", "<Plug>(YankyPutBefore)", mode = { "n", "x" }, desc = "Put before" },
      { "gp", "<Plug>(YankyGPutAfter)", mode = { "n", "x" }, desc = "Put after (cursor after)" },
      { "gP", "<Plug>(YankyGPutBefore)", mode = { "n", "x" }, desc = "Put before (cursor after)" },

      -- 主要快捷键：[p 下一个粘贴历史，]p 上一个粘贴历史
      { "[p", "<Plug>(YankyCycleForward)", desc = "Cycle forward through yank history (next)" },
      { "]p", "<Plug>(YankyCycleBackward)", desc = "Cycle backward through yank history (previous)" },

      -- 使用 Telescope 浏览历史
      { "<leader>fy", "<cmd>Telescope yank_history<cr>", desc = "Yank History (Telescope)" },

    },
  }
}
