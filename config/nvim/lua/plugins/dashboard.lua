return {
  {
    "nvimdev/dashboard-nvim",
    event = "VimEnter",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      theme = "hyper",
      change_to_vcs_root = true,
      config = {
        header = {
          "███╗   ██╗██╗   ██╗██╗███╗   ███╗",
          "████╗  ██║██║   ██║██║████╗ ████║",
          "██╔██╗ ██║██║   ██║██║██╔████╔██║",
          "██║╚██╗██║╚██╗ ██╔╝██║██║╚██╔╝██║",
          "██║ ╚████║ ╚████╔╝ ██║██║ ╚═╝ ██║",
          "╚═╝  ╚═══╝  ╚═══╝  ╚═╝╚═╝     ╚═╝",
        },
        project = {
          enable = true,
          limit = 8,
          label = " Projects",
          action = function(path)
            require("snacks").picker.files({ cwd = path })
          end,
        },
        mru = {
          enable = true,
          limit = 10,
          label = " Recent files",
          cwd_only = false,
        },
        shortcut = {
          { desc = " Find file", group = "Label", key = "f", action = "lua Snacks.picker.files()" },
          { desc = " Search text", group = "Label", key = "s", action = "lua Snacks.picker.grep()" },
          { desc = " Lazy", group = "Label", key = "l", action = "Lazy" },
        },
      },
    },
  },
  {
    "folke/snacks.nvim",
    opts = {
      dashboard = { enabled = false },
    },
  },
}
