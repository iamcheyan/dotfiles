-- Self-contained Treesitter configuration.
-- Replaces LazyVim's core `lazyvim/plugins/treesitter.lua` so highlighting,
-- indentation, folds and text-objects no longer depend on LazyVim.treesitter
-- helpers. Behavior is kept equivalent to the previous setup.

local ensure_installed = {
  "bash",
  "c",
  "diff",
  "go",
  "html",
  "javascript",
  "java",
  "jsdoc",
  "json",
  "lua",
  "luadoc",
  "luap",
  "markdown",
  "markdown_inline",
  "printf",
  "python",
  "query",
  "regex",
  "ruby",
  "sql",
  "toml",
  "tsx",
  "typescript",
  "vim",
  "vimdoc",
  "xml",
  "yaml",
}

local treesitter_filetypes = {
  bash = true,
  c = true,
  diff = true,
  go = true,
  html = true,
  javascript = true,
  javascriptreact = true,
  java = true,
  jsdoc = true,
  json = true,
  lua = true,
  luadoc = true,
  markdown = true,
  python = true,
  query = true,
  regex = true,
  ruby = true,
  sh = true,
  sql = true,
  toml = true,
  tsx = true,
  typescript = true,
  typescriptreact = true,
  vim = true,
  vimdoc = true,
  xml = true,
  yaml = true,
  zsh = true,
}

local function enable_treesitter(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  local ft = vim.bo[bufnr].filetype
  if not treesitter_filetypes[ft] then
    return
  end

  if pcall(vim.treesitter.start, bufnr) then
    vim.wo[0][0].foldexpr = "v:lua.vim.treesitter.foldexpr()"
    vim.wo[0][0].foldmethod = "expr"
    vim.bo[bufnr].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
  end
end

return {
  {
    "nvim-treesitter/nvim-treesitter",
    -- `main` is the supported branch (master is archived). It requires Neovim
    -- 0.11+ and ABI-15 parsers, so the oldest supported runtime for this public
    -- config is 0.11.
    branch = "main",
    version = false, -- last release is way too old and doesn't work on Windows
    -- Keep parsers in sync when the plugin is installed or updated: fetch the
    -- ones that are missing and rebuild grammars that predate the revisions
    -- `main` pins. Stale grammars are not cosmetic -- the queries shipped with
    -- the plugin use fields that older revisions lack, which aborts highlighting
    -- with "Invalid field name" query errors.
    -- The install/update calls are async, so wait for them: this build step runs
    -- in a Neovim that exits as soon as it returns.
    build = function()
      local ok, TS = pcall(require, "nvim-treesitter")
      if not (ok and TS.get_installed) then
        return
      end
      -- Only parsers count here: `get_installed()` also reports languages that
      -- merely have a query directory.
      local ok2, installed = pcall(TS.get_installed, "parsers")
      if not ok2 then
        return
      end
      local missing = vim.tbl_filter(function(lang)
        return not vim.tbl_contains(installed, lang)
      end, ensure_installed)

      local tasks = {}
      if #missing > 0 then
        -- `force` is needed because `install()` skips any language listed by
        -- `get_installed()`, query directory included.
        tasks[#tasks + 1] = TS.install(missing, { force = true })
      end
      tasks[#tasks + 1] = TS.update()
      for _, task in ipairs(tasks) do
        pcall(function()
          task:wait()
        end)
      end
    end,
    event = { "LazyFile", "VeryLazy" },
    cmd = { "TSUpdate", "TSInstall", "TSLog", "TSUninstall" },
    opts = {
      -- `main` already defaults to this directory; keeping it explicit documents
      -- that parsers stay out of the plugin directory, where `:Lazy` operations
      -- could wipe them. It is also the directory the install/update commands
      -- consult when deciding whether a parser is installed.
      install_dir = vim.fn.stdpath("data") .. "/site",
    },
    config = function(_, opts)
      -- Highlighting, indentation and folds are set up natively below, so
      -- `main` only needs the install directory here.
      require("nvim-treesitter").setup(opts)
      -- `main` does not register filetype aliases (master's parsers.lua mapped
      -- `javascriptreact` for us), and `sh`/`zsh` used to depend on aerial being
      -- loaded first. Register them here so highlighting works from the start
      -- of the session instead of silently doing nothing.
      for lang, filetypes in pairs({
        bash = { "sh", "zsh" },
        javascript = { "javascriptreact" },
        tsx = { "typescriptreact" },
      }) do
        pcall(vim.treesitter.language.register, lang, filetypes)
      end
      vim.api.nvim_create_autocmd("FileType", {
        pattern = vim.tbl_keys(treesitter_filetypes),
        callback = function(args)
          enable_treesitter(args.buf)
        end,
      })
      enable_treesitter()
    end,
  },

  -- Treesitter text-objects (function/class/parameter navigation).
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    branch = "main",
    event = "VeryLazy",
    opts = {
      move = {
        enable = true,
        set_jumps = true, -- whether to set jumps in the jumplist
        keys = {
          goto_next_start = { ["]f"] = "@function.outer", ["]c"] = "@class.outer", ["]a"] = "@parameter.inner" },
          goto_next_end = { ["]F"] = "@function.outer", ["]C"] = "@class.outer", ["]A"] = "@parameter.inner" },
          goto_previous_start = { ["[f"] = "@function.outer", ["[c"] = "@class.outer", ["[a"] = "@parameter.inner" },
          goto_previous_end = { ["[F"] = "@function.outer", ["[C"] = "@class.outer", ["[A"] = "@parameter.inner" },
        },
      },
    },
    config = function(_, opts)
      require("nvim-treesitter-textobjects").setup(opts)
    end,
  },
}
