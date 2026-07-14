-- Self-contained blink.cmp configuration.
-- Replaces LazyVim's `coding.blink` extra so that the completion engine no
-- longer depends on LazyVim's cmp helpers (LazyVim.cmp.expand / LazyVim.cmp.map)
-- or LazyVim.config.icons.kinds. Behavior is kept identical to the previous setup.

-- Mirror of LazyVim.cmp.expand: native vim.snippet with a nested-placeholder fix
-- and top-level session restoration.
---@param snippet string
local function snippet_expand(snippet)
  -- Native sessions don't support nested snippet sessions.
  -- Always use the top-level session.
  local session = vim.snippet.active() and vim.snippet._session or nil

  local function snippet_preview(s)
    local ok, parsed = pcall(function()
      return vim.lsp._snippet_grammar.parse(s)
    end)
    if ok then
      return tostring(parsed)
    end
    return (s:gsub("%$%b{}", function(m)
      local n, name = m:match("^%${(%d+):(.+)}$")
      return n and snippet_preview(name) or m
    end):gsub("%$0", ""))
  end

  local ok, err = pcall(vim.snippet.expand, snippet)
  if not ok then
    local fixed = snippet:gsub("%$%b{}", function(m)
      local n, name = m:match("^%${(%d+):(.+)}$")
      return n and ("${" .. n .. ":" .. snippet_preview(name) .. "}") or m
    end)
    ok = pcall(vim.snippet.expand, fixed)

    local msg = ok and "Failed to parse snippet,\nbut was able to fix it automatically."
      or ("Failed to parse snippet.\n" .. err)
    vim.notify(
      string.format("%s\n```%s\n%s\n```", msg, vim.bo.filetype, snippet),
      ok and vim.log.levels.WARN or vim.log.levels.ERROR,
      { title = "vim.snippet" }
    )
  end

  -- Restore top-level session when needed
  if session then
    vim.snippet._session = session
  end
end

-- Kind icons (copied from LazyVim's config so blink is not tied to LazyVim.config.icons)
local kind_icons = {
  Array = " ",
  Boolean = "󰨙 ",
  Class = " ",
  Codeium = "󰘦 ",
  Color = " ",
  Control = " ",
  Collapsed = " ",
  Constant = "󰏿 ",
  Constructor = " ",
  Copilot = " ",
  Enum = " ",
  EnumMember = " ",
  Event = " ",
  Field = " ",
  File = " ",
  Folder = " ",
  Function = "󰊕 ",
  Interface = " ",
  Key = " ",
  Keyword = " ",
  Method = "󰊕 ",
  Module = " ",
  Namespace = "󰦮 ",
  Null = " ",
  Number = "󰎠 ",
  Object = " ",
  Operator = " ",
  Package = " ",
  Property = " ",
  Reference = " ",
  Snippet = "󱄽 ",
  String = " ",
  Struct = "󰆼 ",
  Supermaven = " ",
  TabNine = "󰏚 ",
  Text = " ",
  TypeParameter = " ",
  Unit = " ",
  Value = " ",
  Variable = "󰀫 ",
}

return {
  {
    "saghen/blink.cmp",
    version = "*",
    event = { "InsertEnter", "CmdlineEnter" },

    ---@type blink.cmp.Config
    opts = {
      snippets = {
        preset = "default",
      },

      appearance = {
        -- sets the fallback highlight groups to nvim-cmp's highlight groups
        use_nvim_cmp_as_default = false,
        -- set to 'mono' for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
        nerd_font_variant = "mono",
        kind_icons = kind_icons,
      },

      window = {
        border = "single",
      },

      completion = {
        accept = {
          -- experimental auto-brackets support
          auto_brackets = {
            enabled = true,
          },
        },
        menu = {
          draw = {
            treesitter = { "lsp" },
          },
        },
        documentation = {
          auto_show = true,
          auto_show_delay_ms = 200,
        },
        ghost_text = {
          enabled = vim.g.ai_cmp,
        },
      },

      sources = {
        -- adding any nvim-cmp sources here will enable them with blink.compat
        compat = {},
        default = { "lsp", "path", "snippets", "buffer" },
        per_filetype = {
          lua = { inherit_defaults = true, "lazydev" },
        },
        providers = {
          lazydev = {
            name = "LazyDev",
            module = "lazydev.integrations.blink",
            score_offset = 100, -- show at a higher priority than lsp
          },
        },
      },

      cmdline = {
        enabled = true,
        keymap = {
          preset = "cmdline",
          ["<Right>"] = false,
          ["<Left>"] = false,
        },
        completion = {
          list = { selection = { preselect = false } },
          menu = {
            auto_show = function(ctx)
              return vim.fn.getcmdtype() == ":"
            end,
          },
          ghost_text = { enabled = true },
        },
      },

      keymap = {
        preset = "enter",
        ["<C-y>"] = { "select_and_accept" },
        -- snippet_forward first, otherwise fall back (e.g. to indentation)
        ["<Tab>"] = { "snippet_forward", "fallback" },
      },
    },

    config = function(_, opts)
      if opts.snippets and opts.snippets.preset == "default" then
        opts.snippets.expand = snippet_expand
      end

      -- Normalize sources.default (LazyVim's extra extends it via opts_extend)
      opts.sources.default = { "lsp", "path", "snippets", "buffer" }

      -- Unset custom prop to pass blink.cmp validation
      opts.sources.compat = nil

      -- Only enable the lazydev source when lazydev.nvim is actually available
      -- (it can be disabled, e.g. via plugins/disable-lazydev.lua).
      local has_lazydev = pcall(require, "lazydev")
      if not has_lazydev then
        if opts.sources.per_filetype then
          opts.sources.per_filetype.lua = nil
        end
        if opts.sources.providers then
          opts.sources.providers.lazydev = nil
        end
      end

      require("blink.cmp").setup(opts)
    end,
  },
}
