return {
  dir = vim.fn.stdpath("config"),
  name = "VimQuest.nvim",
  cmd = { "VimQuestStart", "VimQuestStop", "VimQuestNext", "VimQuestPrev", "VimQuestNextRound" },
  config = function()
    require("vimquest").setup()
  end,
}
