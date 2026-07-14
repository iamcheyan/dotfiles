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

      -- 在插入模式下粘贴（使用 <C-y> 避免与 Oil 的 <C-p> 冲突）
      { "<C-y>", "<Plug>(YankyPutBefore)", mode = "i", desc = "Put before cursor" },

      -- 循环浏览历史（使用 [p/]p 更符合语义：p = put/paste）
      -- 注意：[p = 下一个(next)，]p = 上一个(previous)
      { "<leader>pp", "<Plug>(YankyCycleBackward)", desc = "Cycle backward through yank history (previous)" },
      { "<leader>pn", "<Plug>(YankyCycleForward)", desc = "Cycle forward through yank history (next)" },
      -- 主要快捷键：[p 下一个粘贴历史，]p 上一个粘贴历史
      { "[p", "<Plug>(YankyCycleForward)", desc = "Cycle forward through yank history (next)" },
      { "]p", "<Plug>(YankyCycleBackward)", desc = "Cycle backward through yank history (previous)" },

      -- 使用 Telescope 浏览历史
      { "<leader>fy", "<cmd>Telescope yank_history<cr>", desc = "Yank History (Telescope)" },

      -- 文本对象
      { "iy", "<Plug>(YankyYankiere)", mode = { "o", "x" }, desc = "Inside yank" },
      { "ay", "<Plug>(YankyYankerea)", mode = { "o", "x" }, desc = "Around yank" },
    },
  },
}
