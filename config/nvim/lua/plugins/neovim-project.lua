return {
  "coffebar/neovim-project",
  opts = {
    projects = {
      "~/Dotfiles",
      "~/.dotfiles",
      "~/Development/*",
      "~/Dotfiles/*",
    },
    picker = {
      type = "telescope",
    },
    -- ... 其他配置
    session_manager_opts = {
      autosave_last_session = true, -- 退出时自动保存
      autosave_ignore_not_normal = true, -- 忽略特殊的 buffer（如插件窗口）
      last_session = true, -- 启动时自动加载最后一次使用的 session
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
