-- Self-contained Treesitter configuration.
-- Replaces LazyVim's core `lazyvim/plugins/treesitter.lua` so highlighting,
-- indentation, folds and text-objects no longer depend on LazyVim.treesitter
-- helpers. Behavior is kept equivalent to the previous setup.

local ensure_installed = {
  "bash",
  "c",
  "diff",
  "html",
  "javascript",
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
  html = true,
  javascript = true,
  javascriptreact = true,
  jsdoc = true,
  json = true,
  lua = true,
  luadoc = true,
  markdown = true,
  python = true,
  query = true,
  regex = true,
  sh = true,
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
    branch = "main",
    version = false, -- last release is way too old and doesn't work on Windows
    -- Install any missing parsers on build (safe: never fails the build).
    build = function()
      local ok, TS = pcall(require, "nvim-treesitter")
      if not (ok and TS.get_installed) then
        return
      end
      local ok2, installed = pcall(TS.get_installed)
      if not ok2 then
        return
      end
      local missing = vim.tbl_filter(function(lang)
        return not vim.tbl_contains(installed, lang)
      end, ensure_installed)
      if #missing > 0 then
        pcall(TS.install, missing)
      end
    end,
    event = { "LazyFile", "VeryLazy" },
    cmd = { "TSUpdate", "TSInstall", "TSLog", "TSUninstall" },
    opts = {
      install_dir = vim.fn.stdpath("data") .. "/site",
    },
    config = function(_, opts)
      require("nvim-treesitter").setup(opts)
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
