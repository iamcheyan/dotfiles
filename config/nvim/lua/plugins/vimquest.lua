return {
  dir = vim.fn.stdpath("config"),
  name = "VimQuest.nvim",
  lazy = false,
  config = function()
    require("vimquest").setup()
  end,
}
