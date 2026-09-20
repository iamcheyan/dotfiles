return {
  {
    "uga-rosa/ccc.nvim",
    cmd = { "CccPick", "CccConvert" },
    keys = {
      { "<leader>cp", "<cmd>CccPick<cr>", desc = "Color Picker (ccc)" },
      { "<leader>cC", "<cmd>CccConvert<cr>", desc = "Color Convert (ccc)" },
    },
    opts = {
      highlighter = {
        auto_enable = false, -- 禁用自带的 buffer 高亮，避免与极速的 mini.hipatterns 争抢高亮组
        lsp = false,
      },
    },
  },
}
