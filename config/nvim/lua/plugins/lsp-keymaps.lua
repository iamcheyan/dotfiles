return {
  -- 禁用 LSP 默认的 gr 快捷键，避免与 substitute.nvim 冲突
  {
    "neovim/nvim-lspconfig",
    init = function()
      -- 在 LSP attach 时禁用 gr 映射
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          local bufnr = args.buf
          -- 禁用 gr (go to references)
          pcall(vim.keymap.del, "n", "gr", { buffer = bufnr })
        end,
      })
    end,
  },
}
