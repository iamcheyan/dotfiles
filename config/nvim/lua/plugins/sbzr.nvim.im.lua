-- sbzr.nvim.im - Neovim SBZR输入法插件配置
-- 使用方法：将此文件复制到 ~/.config/nvim/lua/plugins/sbzr.nvim.im.lua
-- 仓库地址：https://github.com/iamcheyan/sbzr.nvim.im

return {
  {
    "iamcheyan/sbzr.nvim.im",
    name = "ZFVimIM",
    lazy = false,
    dir = vim.loop.os_uname().nodename == "LH25030" and (vim.fn.stdpath("config") .. "/local/sbzr.nvim.im") or nil,
    init = function()
      if vim.loop.os_uname().nodename == "LH25030" then
        vim.g.ZFVimIM_plugin_dir = vim.fn.stdpath("config") .. "/local/sbzr.nvim.im"
      end
      vim.g.ZFVimIM_dict_path = vim.fn.expand("~/.dotfiles/rime/sbzr.chrome.extension/dicts/base.dict.yaml")
      vim.g.ZFVimIM_keymap = 1
    end,
    config = function()
      local function ensure_toggle_map(mode, fn_name)
        if vim.fn.maparg(";;", mode) ~= "" then
          return
        end
        vim.keymap.set(mode, ";;", function()
          if vim.fn.exists("*" .. fn_name) == 1 then
            vim.fn[fn_name]()
          end
          return ""
        end, { expr = true, silent = true })
      end

      ensure_toggle_map("n", "ZFVimIME_keymap_toggle_n")
      ensure_toggle_map("i", "ZFVimIME_keymap_toggle_i")
      ensure_toggle_map("v", "ZFVimIME_keymap_toggle_v")
    end,
  },
}
