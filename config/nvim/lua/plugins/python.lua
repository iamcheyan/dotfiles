-- 1️⃣ basedpyright LSP 配置
require("lspconfig").basedpyright.setup({
  on_attach = function(client, bufnr)
    -- Keep LSP features (jump/symbol/completion), but silence diagnostics from basedpyright.
    local ok, ns = pcall(vim.lsp.diagnostic.get_namespace, client.id)
    if ok then
      vim.diagnostic.reset(ns, bufnr)
      vim.diagnostic.enable(false, { bufnr = bufnr, ns_id = ns })
    end
    client.handlers["textDocument/publishDiagnostics"] = function() end
  end,
  settings = {
    python = {
      analysis = {
        exclude = { "**/venv/**", "**/__pycache__/**", "**/.pytest_cache/**" },
        typeCheckingMode = "off",
        diagnosticMode = "workspace",
        autoSearchPaths = true,
        useLibraryCodeForTypes = true,
        reportMissingImports = false,
      },
    },
  },
})

-- 2️⃣ 全局 diagnostic 配置（不显示行内文本，只显示左边图标）
vim.diagnostic.config({
  virtual_text = false, -- 不显示行内错误文本
  virtual_lines = false,
  signs = true, -- 左侧显示图标
  underline = false, -- 不显示下划线
  severity_sort = true,
  update_in_insert = false,
  float = {
    border = "rounded",
    source = "if_many",
  },
})

-- 统一左侧诊断图标为 "!"，降低界面噪音
local diagnostic_sign = "!"
for _, name in ipairs({ "Error", "Warn", "Info", "Hint" }) do
  vim.fn.sign_define("DiagnosticSign" .. name, {
    text = diagnostic_sign,
    texthl = "DiagnosticSign" .. name,
    numhl = "",
    linehl = "",
  })
end
