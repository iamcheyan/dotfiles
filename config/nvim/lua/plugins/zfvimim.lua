--- config/nvim/lua/plugins/zfvimim.lua 

-- ZFVimIM 词库配置
-- 方法1：使用绝对路径（推荐，如果词库在插件目录外）
-- vim.g.zfvimim_dict_path = "/Users/tetsuya/.local/share/nvim/lazy/ZFVimIM/dict/sbzr.yaml"

-- 方法2：使用插件目录下的词库（推荐，如果词库在插件 dict/ 目录下）
vim.g.zfvimim_default_dict_name = "sbzr"
vim.g.ZFVimIM_settings = { 'sbzr' }
return {
  {
    "iamcheyan/ZFVimIM",
    lazy = false,
  },
}
