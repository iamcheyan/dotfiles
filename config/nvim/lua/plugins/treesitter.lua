-- Self-contained Treesitter configuration.
-- Replaces LazyVim's core `lazyvim/plugins/treesitter.lua` so highlighting,
-- indentation, folds and text-objects no longer depend on LazyVim.treesitter
-- helpers. Behavior is kept equivalent to the previous setup.

-- nvim-treesitter main currently uses vim.list.unique, introduced after
-- Neovim 0.10. Keep the public config usable on the installed 0.10 series
-- while allowing newer Neovim versions to use their native implementation.
if vim.list == nil then
  vim.list = {}
end
if vim.list.unique == nil then
  vim.list.unique = function(values)
    local seen, result = {}, {}
    for _, value in ipairs(values) do
      if not seen[value] then
        seen[value] = true
        table.insert(result, value)
      end
    end
    return result
  end
end

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
    -- Neovim 0.10 supports the stable master branch. The newer main branch
    -- requires Neovim 0.11 and downloads ABI-15 parsers, which do not load on
    -- the 0.10 runtime used by this public configuration.
    branch = "master",
    build = ":TSUpdate",
    event = { "LazyFile", "VeryLazy" },
    cmd = { "TSUpdate", "TSInstall", "TSLog", "TSUninstall" },
    opts = {
      ensure_installed = ensure_installed,
      install_dir = vim.fn.stdpath("data") .. "/site",
    },
    config = function(_, opts)
      local treesitter = require("nvim-treesitter")
      if treesitter.setup then
        treesitter.setup(opts)
      else
        require("nvim-treesitter.configs").setup({
          ensure_installed = opts.ensure_installed,
          highlight = { enable = false },
          indent = { enable = false },
        })
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
