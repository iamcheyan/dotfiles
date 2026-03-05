return {
  "coffebar/neovim-project",
  opts = {
    projects = {
      "~/projects/*",
      "~/.config/*",
    },
    picker = {
      type = "telescope",
    },
  },
  init = function()
    vim.opt.sessionoptions:append("globals")
  end,
  dependencies = {
    { "nvim-lua/plenary.nvim" },
    { "nvim-telescope/telescope.nvim" },
    { "Shatur/neovim-session-manager" },
  },
  lazy = false,
  priority = 100,
}
