-- Formatter plugin. Provides <leader>F to format the current buffer.
-- Auto-format on save is OFF by default (vim.g.autoformat = false).
return {
  "stevearc/conform.nvim",
  event = { "BufWritePre" },
  cmd = { "ConformInfo" },
  keys = {
    {
      "<leader>F",
      function()
        require("conform").format({ async = true, lsp_fallback = true })
      end,
      mode = { "n", "x" },
      desc = "Format (conform)",
    },
  },
  opts = {
    formatters_by_ft = {
      lua = { "stylua" },
      sh = { "shfmt" },
      bash = { "shfmt" },
      zsh = { "shfmt" },
      python = { "ruff_fix", "ruff_format" },
      javascript = { "prettierd", "prettier", stop_after_first = true },
      typescript = { "prettierd", "prettier", stop_after_first = true },
      javascriptreact = { "prettierd", "prettier", stop_after_first = true },
      typescriptreact = { "prettierd", "prettier", stop_after_first = true },
      css = { "prettierd", "prettier", stop_after_first = true },
      html = { "prettierd", "prettier", stop_after_first = true },
      json = { "prettierd", "prettier", stop_after_first = true },
      yaml = { "prettierd", "prettier", stop_after_first = true },
      markdown = { "prettierd", "prettier", stop_after_first = true },
      rust = { "rustfmt" },
      go = { "gofumpt", "goimports" },
      c = { "clang_format" },
      cpp = { "clang_format" },
    },
    -- Honour the Auto Format toggle (<leader>uf / <leader>uF). LazyVim wired
    -- this flag itself; without a consumer here the toggle was inert. The
    -- function form is evaluated on each save, so toggling takes effect
    -- immediately instead of being frozen at startup.
    format_on_save = function(bufnr)
      if vim.g.autoformat == false then
        return nil
      end
      return { timeout_ms = 500, lsp_fallback = true }
    end,
  },
  init = function()
    vim.g.autoformat = false
  end,
}
