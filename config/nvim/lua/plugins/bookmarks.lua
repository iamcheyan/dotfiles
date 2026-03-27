return {
  "tomasky/bookmarks.nvim",
  event = "VimEnter",
  config = function()
    require("bookmarks").setup({
      -- 关键配置：让书签持久化保存到磁盘
      save_file = vim.fn.stdpath("data") .. "/bookmarks",
      keywords = {
        ["@t"] = "☑️ ", -- 逻辑检查点
        ["@w"] = "⚠️ ", -- 重点关注
        ["@f"] = "🔍 ", -- 关键函数
        ["@l"] = "🚀 ", -- 逻辑起点
      },
      on_attach = function(bufnr)
        if not bufnr or not vim.api.nvim_buf_is_valid(bufnr) or not vim.api.nvim_buf_is_loaded(bufnr) then
          return
        end

        local bm = require("bookmarks")
        local map = vim.keymap.set

        map("n", "mm", bm.bookmark_toggle, { buffer = bufnr, desc = "添加/删除书签" })
        map("n", "mi", bm.bookmark_ann, { buffer = bufnr, desc = "添加带备注的书签" })
        map("n", "mc", bm.bookmark_clean, { buffer = bufnr, desc = "清除当前缓冲区书签" })
        map("n", "ml", bm.bookmark_list, { buffer = bufnr, desc = "显示所有书签列表" })
        map("n", "mn", bm.bookmark_next, { buffer = bufnr, desc = "下一个书签" })
        map("n", "mp", bm.bookmark_prev, { buffer = bufnr, desc = "上一个书签" })
      end,
    })
  end,
}
