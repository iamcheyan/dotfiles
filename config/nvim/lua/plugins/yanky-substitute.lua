return {
  -- yanky.nvim: 增强的剪贴板管理
  {
    "gbprod/yanky.nvim",
    opts = {
      ring = {
        history_length = 100,
        -- "sqlite" needs libsqlite3 through sqlite.lua's FFI binding, which only
        -- probes Debian/RedHat paths (/usr/lib/.../libsqlite3.so). On NixOS that
        -- lookup fails, yanky.history.setup() throws, and setup() aborts before
        -- configuring highlight/preserve_cursor/system_clipboard -- so yank and
        -- put raise "attempt to call a nil value". "shada" is dependency-free
        -- and persists the ring across sessions.
        storage = "shada",
        sync_with_numbered_registers = true,
        cancel_event = "update",
      },
      picker = {
        select = {
          action = nil, -- 默认动作
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

      -- 使用 Snacks Picker 浏览剪贴板历史
      {
        "<leader>fy",
        function()
          require("yanky.sources.snacks").pick()
        end,
        desc = "Yank History (Snacks Picker)",
      },
    },
  }
}
