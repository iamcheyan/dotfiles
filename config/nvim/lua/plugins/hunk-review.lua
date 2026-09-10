return {
  {
    "shaunchander/hunk-review.nvim",
    cmd = { "HunkReview", "HunkReviewRefresh", "HunkReviewExport" },
    keys = {
      {
        "<leader>gH",
        "<cmd>HunkReview<cr>",
        desc = "Git Diff: review changes",
      },
    },
    dependencies = { "folke/snacks.nvim" },
    opts = {
      -- Keep the review surface wide enough for readable unified diffs while
      -- leaving the normal editor layout untouched until explicitly opened.
      layout = {
        width = 0.96,
        height = 0.92,
        explorer_width = 0.28,
      },
      diff_context = 3,
    },
  },
}
