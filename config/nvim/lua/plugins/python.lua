return {
  {
    "neovim/nvim-lspconfig",
    init = function()
      vim.diagnostic.config({
        virtual_text = false,
        virtual_lines = false,
        signs = true,
        underline = false,
        severity_sort = true,
        update_in_insert = false,
        float = {
          border = "rounded",
          source = "if_many",
        },
      })

      local diagnostic_sign = "!"
      for _, name in ipairs({ "Error", "Warn", "Info", "Hint" }) do
        vim.fn.sign_define("DiagnosticSign" .. name, {
          text = diagnostic_sign,
          texthl = "DiagnosticSign" .. name,
          numhl = "",
          linehl = "",
        })
      end
    end,
    opts = function(_, opts)
      opts.servers = opts.servers or {}

      local existing = opts.servers.basedpyright or {}
      local existing_on_attach = existing.on_attach

      opts.servers.basedpyright = vim.tbl_deep_extend("force", existing, {
        on_attach = function(client, bufnr)
          if type(existing_on_attach) == "function" then
            existing_on_attach(client, bufnr)
          end

          -- Keep LSP features (jump/symbol/completion), but silence diagnostics from basedpyright.
          local ok, ns = pcall(vim.lsp.diagnostic.get_namespace, client.id)
          if ok then
            vim.diagnostic.reset(ns, bufnr)
            vim.diagnostic.enable(false, { bufnr = bufnr, ns_id = ns })
          end
          client.handlers["textDocument/publishDiagnostics"] = function() end
        end,
        settings = {
          basedpyright = {
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
    end,
  },
}
