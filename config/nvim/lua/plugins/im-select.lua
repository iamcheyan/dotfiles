return {
  "keaising/im-select.nvim",
  event = { "InsertEnter", "InsertLeave" },
  config = function()
    require("im_select").setup({
      default_im_select = "1033",
      default_command = "${WIN_HOME}/Applications/im-select.exe",
      async_switch_im = true,
    })
  end,
}
