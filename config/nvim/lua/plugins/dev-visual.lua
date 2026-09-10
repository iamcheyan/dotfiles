return {
  {
    "j-hui/fidget.nvim",
    event = "LspAttach",
    opts = {
      notification = {
        window = {
          border = "single",
        },
      },
    },
  },

  {
    "kevinhwang91/nvim-hlslens",
    event = "VeryLazy",
    opts = {},
    keys = {
      {
        "n",
        function()
          pcall(vim.cmd, "normal! n")
          require("hlslens").start()
        end,
        desc = "Next Search Result",
      },
      {
        "N",
        function()
          pcall(vim.cmd, "normal! N")
          require("hlslens").start()
        end,
        desc = "Prev Search Result",
      },
      {
        "*",
        function()
          pcall(vim.cmd, "normal! *")
          require("hlslens").start()
        end,
        desc = "Search Word Forward",
      },
      {
        "#",
        function()
          pcall(vim.cmd, "normal! #")
          require("hlslens").start()
        end,
        desc = "Search Word Backward",
      },
      {
        "g*",
        function()
          pcall(vim.cmd, "normal! g*")
          require("hlslens").start()
        end,
        desc = "Search Partial Word Forward",
      },
      {
        "g#",
        function()
          pcall(vim.cmd, "normal! g#")
          require("hlslens").start()
        end,
        desc = "Search Partial Word Backward",
      },
    },
  },
}
