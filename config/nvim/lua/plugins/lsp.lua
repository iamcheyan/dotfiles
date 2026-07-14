-- Standard LSP setup.
-- Replaces LazyVim's `opts.servers` convention (previously in plugins/python.lua)
-- with explicit lspconfig + mason + mason-lspconfig, and registers all LSP
-- keymaps via LspAttach. Keeps the exact same servers: lua_ls + basedpyright.
return {
  -- Mason: portable package manager for LSP servers and CLI tools.
  {
    "mason-org/mason.nvim",
    cmd = "Mason",
    keys = { { "<leader>cm", "<cmd>Mason<cr>", desc = "Mason" } },
    build = ":MasonUpdate",
    opts = {
      ensure_installed = { "stylua", "shfmt" },
    },
    config = function(_, opts)
      require("mason").setup(opts)
    end,
  },

  -- mason-lspconfig: bridge mason <-> lspconfig and install the servers below.
  -- Fully self-contained: keymaps, inlay hints, code lens and LSP folds are all
  -- wired in our on_attach (no LazyVim lsp spec needed).
  {
    "mason-org/mason-lspconfig.nvim",
    dependencies = { "mason.nvim", "neovim/nvim-lspconfig" },
    opts = {
      ensure_installed = { "basedpyright", "lua_ls" },
      automatic_enable = false,
    },
    config = function(_, opts)
      local lspconfig = require("lspconfig")

      -- on_attach: register LSP keymaps (previously from LazyVim lsp/keymaps.lua)
      -- and silence diagnostics per-buffer (consistent with prior python.lua behavior).
      local on_attach = function(client, bufnr)
        -- silence diagnostics from this client (global diagnostics already disabled)
        local ok, ns = pcall(vim.lsp.diagnostic.get_namespace, client.id)
        if ok then
          vim.diagnostic.reset(ns, bufnr)
          vim.diagnostic.enable(false, { bufnr = bufnr, ns_id = ns })
        end
        client.handlers["textDocument/publishDiagnostics"] = function() end

        -- LSP-powered 'gq' formatting (replaces LazyVim's formatexpr).
        if client.server_capabilities.documentFormattingProvider then
          vim.bo[bufnr].formatexpr = "v:lua.vim.lsp.formatexpr()"
        end

        local caps = client.server_capabilities or {}
        local set = function(lhs, rhs, desc, mode)
          vim.keymap.set(mode or "n", lhs, rhs, { buffer = bufnr, noremap = true, silent = true, desc = desc })
        end

        if caps.definitionProvider then
          set("gd", vim.lsp.buf.definition, "Goto Definition")
        end
        if caps.declarationProvider then
          set("gD", vim.lsp.buf.declaration, "Goto Declaration")
        end
        set("K", vim.lsp.buf.hover, "Hover")
        if caps.implementationProvider then
          set("gI", vim.lsp.buf.implementation, "Goto Implementation")
        end
        if caps.typeDefinitionProvider then
          set("gy", vim.lsp.buf.type_definition, "Goto Type Definition")
        end
        if caps.signatureHelpProvider then
          set("gK", vim.lsp.buf.signature_help, "Signature Help")
          set("<C-k>", vim.lsp.buf.signature_help, "Signature Help", "i")
        end
        if caps.codeActionProvider then
          set("<leader>ca", vim.lsp.buf.code_action, "Code Action", { "n", "x" })
        end
        if caps.renameProvider then
          set("<leader>cr", vim.lsp.buf.rename, "Rename")
        end

        -- Snacks-backed keymaps (snacks is retained; guarded so they never error).
        local snacks_ok, Snacks = pcall(require, "snacks")
        if snacks_ok then
          set("<leader>cl", function()
            Snacks.picker.lsp_config()
          end, "Lsp Info")
          set("<leader>cR", function()
            Snacks.rename.rename_file()
          end, "Rename File")
          if Snacks.words and Snacks.words.is_enabled() then
            set("]]", function()
              Snacks.words.jump(vim.v.count1)
            end, "Next Reference")
            set("[[", function()
              Snacks.words.jump(-vim.v.count1)
            end, "Prev Reference")
            set("<a-n>", function()
              Snacks.words.jump(vim.v.count1, true)
            end, "Next Reference")
            set("<a-p>", function()
              Snacks.words.jump(-vim.v.count1, true)
            end, "Prev Reference")
          end
        end

        -- organize imports (source action)
        set("<leader>co", function()
          vim.lsp.buf.code_action({ context = { only = { "source.organizeImports" } }, apply = true })
        end, "Organize Imports")

        -- inlay hints (LazyVim parity)
        if client.supports_method("textDocument/inlayHint", { bufnr = buf }) then
          vim.lsp.inlay_hint.enable(true, { bufnr = buf })
        end

        -- LSP folds
        if client.supports_method("textDocument/foldingRange", { bufnr = buf }) then
          local win = vim.api.nvim_get_current_win()
          if vim.wo[win].foldmethod == "manual" then
            vim.wo[win].foldmethod = "expr"
            vim.wo[win].foldexpr = "v:lua.vim.lsp.foldexpr()"
          end
        end

        -- code lens
        if client.supports_method("textDocument/codeLens", { bufnr = buf }) then
          vim.lsp.codelens.refresh()
          vim.api.nvim_create_autocmd({ "BufEnter", "CursorHold", "InsertLeave" }, {
            buffer = buf,
            callback = vim.lsp.codelens.refresh,
          })
        end

        -- NOTE: `gr` is intentionally NOT bound here. It is removed on LspAttach by
        -- plugins/lsp-keymaps.lua to avoid conflicting with substitute.nvim.
      end

      -- Register + enable servers via the native LSP API (Nvim 0.11+).
      -- The legacy `lspconfig.<srv>.setup()` path is deprecated and now throws
      -- on Neovim >= 0.11, so we use vim.lsp.config() + vim.lsp.enable().
      require("mason-lspconfig").setup(opts)

      -- lua_ls (Neovim Lua)
      vim.lsp.config("lua_ls", {
        on_attach = on_attach,
        settings = {
          Lua = {
            workspace = { checkThirdParty = false },
            codeLens = { enable = true },
            completion = { callSnippet = "Replace" },
            doc = { privateName = { "^_" } },
            hint = {
              enable = true,
              setType = false,
              paramType = true,
              paramName = "Disable",
              semicolon = "Disable",
              arrayIndex = "Disable",
            },
          },
        },
      })
      vim.lsp.enable("lua_ls")

      -- basedpyright (Python)
      vim.lsp.config("basedpyright", {
        on_attach = on_attach,
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
      vim.lsp.enable("basedpyright")
    end,
  },
}
