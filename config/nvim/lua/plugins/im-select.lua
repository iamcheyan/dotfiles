return {
  "keaising/im-select.nvim",
  event = { "InsertEnter", "InsertLeave" },
  config = function()
    require("im_select").setup({
      default_im_select = "1033",
      -- default_command = vim.env.IM_SELECT_EXE,
      async_switch_im = true,
    })
  end,
}
