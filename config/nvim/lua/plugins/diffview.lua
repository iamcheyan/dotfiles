return {
  {
    "sindrets/diffview.nvim",
    cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewToggleFiles", "DiffviewFocusFiles", "DiffviewFileHistory", "DiffviewRefresh" },
    keys = {
      { "<leader>gd", "<cmd>DiffviewOpen<cr>", desc = "Diffview Open" },
      { "<leader>gv", "<cmd>DiffviewOpen<cr>", desc = "Diffview Open" },
      { "<leader>gD", "<cmd>DiffviewFileHistory %<cr>", desc = "Diffview File History (Current File)" },
      { "<leader>gV", "<cmd>DiffviewFileHistory<cr>", desc = "Diffview Branch History" },
      { "<leader>gq", "<cmd>DiffviewClose<cr>", desc = "Diffview Close" },
    },
    opts = {
      enhanced_diff_hl = true,
      view = {
        default = {
          layout = "diff2_horizontal",
        },
      },
      hooks = {
        diff_buf_read = function(bufnr)
          vim.opt_local.swapfile = false
        end,
        diff_buf_win_enter = function(bufnr, winid, ctx)
          vim.opt_local.swapfile = false
        end,
      },
    },
  },
}
