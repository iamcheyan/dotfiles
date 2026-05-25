return {
  {
    "stevearc/oil.nvim",
    lazy = true,
    event = "VeryLazy",
    dependencies = {
      "nvim-tree/nvim-web-devicons",
    },
    keys = {
      {
        "-",
        "<cmd>Oil<cr>",
        desc = "Open parent directory (Oil)",
      },
      -- {
      --   "<leader>o",
      --   "<cmd>Oil<cr>",
      --   desc = "Open Oil",
      -- },
      {
        "<leader>o",
        function()
          require("oil").toggle_float()
        end,
        desc = "Toggle Oil (float)",
      },
    },
    opts = {
      default_file_explorer = true,
      columns = {
        "icon",
      },
      delete_to_trash = false,
      skip_confirm_for_simple_edits = false,
      constrain_cursor = "editable",
      view_options = {
        show_hidden = false,
        natural_order = true,
      },
      float = {
        padding = 2,
        max_width = 0.8,
        max_height = 0.8,
        border = "rounded",
        win_options = {
          winblend = 0,
        },
      },
      keymaps = {
        ["g?"] = { "actions.show_help", mode = "n" },
        ["<CR>"] = "actions.select",
        ["<C-s>"] = { "actions.select", opts = { vertical = true } },
        ["<C-h>"] = { "actions.select", opts = { horizontal = true } },
        ["<C-t>"] = { "actions.select", opts = { tab = true } },
        ["<C-p>"] = "actions.preview",
        ["<C-c>"] = { "actions.close", mode = "n" },
        ["<C-l>"] = "actions.refresh",
        ["-"] = { "actions.parent", mode = "n" },
        ["_"] = { "actions.open_cwd", mode = "n" },
        ["`"] = { "actions.cd", mode = "n" },
        ["~"] = { "actions.tcd", mode = "n" },
        ["gs"] = { "actions.change_sort", mode = "n" },
        ["gx"] = "actions.open_external",
        ["g."] = { "actions.toggle_hidden", mode = "n" },
      },
      use_default_keymaps = false,
    },
  },
}
