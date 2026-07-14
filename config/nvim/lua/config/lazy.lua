-- nvim/lua/lazy.lua

-- Set leader keys before lazy.nvim loads. lazy.nvim warns (and <leader>
-- mappings created by plugins would bind to the wrong key) if these aren't
-- set first. Values match LazyVim's defaults (lazyvim/config/options.lua).
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Load our options early (previously done by LazyVim's config.init()).
require("config.options")

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- Register the "LazyFile" pseudo-event so plugin specs using
-- `event = "LazyFile"` keep working. Mirrors LazyVim's original registration.
local Event = require("lazy.core.handler.event")
Event.mappings.LazyFile = { id = "LazyFile", event = { "BufReadPost", "BufNewFile", "BufWritePre" } }
Event.mappings["User LazyFile"] = Event.mappings.LazyFile

local function ensure_lockfile(path)
  local dir = vim.fn.fnamemodify(path, ":p:h")
  vim.fn.mkdir(dir, "p")
  if vim.fn.filereadable(path) == 0 then
    pcall(vim.fn.writefile, { "{}" }, path)
  end
  return path
end

local lockfile = ensure_lockfile(vim.fn.stdpath("config") .. "/lazy-lock.json")
if vim.fn.filewritable(lockfile) ~= 1 then
  lockfile = ensure_lockfile(vim.fn.stdpath("state") .. "/lazy-lock.json")
end

require("lazy").setup({
  spec = {
    -- import/override with your plugins
    { import = "plugins" },
  },
  -- Force a concrete lockfile path to avoid nil/invalid values
  lockfile = lockfile,
  -- Don't open lockfile on startup
  open = false,
  defaults = {
    -- By default, only LazyVim plugins will be lazy-loaded. Your custom plugins will load during startup.
    -- If you know what you're doing, you can set this to `true` to have all your custom plugins lazy-loaded by default.
    lazy = false,
    -- It's recommended to leave version=false for now, since a lot the plugin that support versioning,
    -- have outdated releases, which may break your Neovim install.
    version = false, -- always use the latest git commit
    -- version = "*", -- try installing the latest stable version for plugins that support semver
  },
  install = { colorscheme = { "habamax" } },
  checker = {
    enabled = true, -- check for plugin updates periodically
    notify = false, -- notify on update
  }, -- automatically check for plugin updates
  performance = {
    rtp = {
      -- disable some rtp plugins
      disabled_plugins = {
        "gzip",
        -- "matchit",
        -- "matchparen",
        -- "netrwPlugin",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
  ui = {
    border = "single",
  },
})

-- Load keymaps and autocmds (previously done by LazyVim's config.setup() at the
-- VeryLazy event). Our keymaps/autocmds have no top-level plugin requires, so
-- loading them right after setup is safe and does not depend on the UI firing.
require("config.keymaps")
require("config.autocmds")
