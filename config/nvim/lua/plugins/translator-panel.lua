return {
  dir = vim.fn.stdpath("config") .. "/local/translator-panel.nvim",
  name = "translator-panel.nvim",
  keys = {
    {
      "tj",
      function()
        require("translator_panel.panel").toggle()
      end,
      desc = "Toggle translator panel",
    },
  },
  config = function()
    require("translator_panel").setup()
  end,
}
