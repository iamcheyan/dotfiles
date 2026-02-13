return {
  dir = vim.fn.stdpath("config") .. "/local/translator-panel.nvim",
  name = "translator-panel.nvim",
  config = function()
    require("translator_panel").setup()
  end,
}
