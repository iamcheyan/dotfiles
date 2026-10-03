-- Diagnostics are disabled across the board.
--
-- vim.diagnostic.config() is applied in config/options.lua at startup; what
-- remains here is the part that only makes sense once the LSP client is loaded:
-- suppressing the diagnostic handlers so servers cannot push them at all.
--
-- The previous `opts = { diagnostics = {...} }` table on nvim-lspconfig was
-- inert: current nvim-lspconfig never reads that key (it is a leftover from the
-- pre-0.11 lspconfig.default_config API).
return {
  {
    "neovim/nvim-lspconfig",
    config = function()
      vim.lsp.handlers["textDocument/publishDiagnostics"] = function() end
      vim.lsp.handlers["textDocument/diagnostic"] = function() end
    end,
  },
}
