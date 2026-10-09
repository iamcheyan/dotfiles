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
  Array = "",
  Boolean = "󰨙",
  Class = "",
  Codeium = "󰘦",
  Color = "",
  Control = "",
  Collapsed = "",
  Constant = "󰏿",
  Constructor = "",
  Copilot = "",
  Enum = "",
  EnumMember = "",
  Event = "",
  Field = "",
  File = "",
  Folder = "",
  Function = "󰊕",
  Interface = "",
  Key = "",
  Keyword = "",
  Method = "󰊕",
  Module = "",
  Namespace = "󰦮",
  Null = "",
  Number = "󰎠",
  Object = "",
  Operator = "",
  Package = "",
  Property = "",
  Reference = "",
  Snippet = "󱄽",
  String = "",
  Struct = "󰆼",
  Supermaven = "",
  TabNine = "󰏚",
  Text = "",
  TypeParameter = "",
  Unit = "",
  Value = "",
  Variable = "󰀫",
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

      completion = {
        trigger = {
          -- COBOL periods terminate words/sentences; suppress LSP trigger popups only there.
          show_on_blocked_trigger_characters = function()
            local blocked = { " ", "\n", "\t" }
            if vim.tbl_contains({ "cobol", "cbl", "cob" }, vim.bo.filetype) then
              blocked[#blocked + 1] = "."
            end
            return blocked
          end,
        },
        accept = {
          -- experimental auto-brackets support
          auto_brackets = {
            enabled = true,
            -- COBOL PERFORM calls use bare paragraph names; keep auto brackets in other languages.
            blocked_filetypes = { "cobol", "cbl", "cob" },
          },
        },
        menu = {
          border = "rounded",
          draw = {
            align_to = "label",
            padding = 1,
            gap = 1,
            treesitter = { "lsp" },
          },
        },
        documentation = {
          auto_show = true,
          auto_show_delay_ms = 200,
          window = {
            border = "rounded",
            max_width = 60,
            max_height = 16,
          },
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
        ["<CR>"] = { "select_and_accept", "fallback" },
        ["<Up>"] = { "select_prev", "fallback" },
        ["<Down>"] = { "select_next", "fallback" },
        ["<BS>"] = {
          function()
            if not vim.tbl_contains({ "cobol", "cbl", "cob" }, vim.bo.filetype) then return end
            local cobol = require("cobol")
            if cobol.detect_format(0) ~= "fixed" then return end

            local buf = vim.api.nvim_get_current_buf()
            local win = vim.api.nvim_get_current_win()
            local row, cursor_byte = unpack(vim.api.nvim_win_get_cursor(win))
            local line = vim.api.nvim_get_current_line()
            local prefix = line:sub(1, math.min(cursor_byte + 1, #line))
            local target_prefix

            if #prefix >= 7 and prefix:sub(1, 7):match("^%s*$") then
              local code = prefix:sub(8)
              local data_name = code:match("^(%d%d%s+[%w_%-]+)%s+$")
              local level = code:match("^(%d%d)%s+$")
              if data_name then
                target_prefix = prefix:sub(1, 7 + #data_name)
              elseif level then
                target_prefix = prefix:sub(1, 7 + #level)
              end
            end

            if not target_prefix and prefix:match("^ *$") then
              local col = vim.fn.strdisplaywidth(prefix) + 1
              local sw = vim.bo[buf].shiftwidth > 0 and vim.bo[buf].shiftwidth or 4
              local target = col <= 7 and 1 or col == 8 and 7 or col <= 12 and 8 or math.max(12, col - sw)
              target_prefix = string.rep(" ", target - 1)
            end
            if not target_prefix or #target_prefix >= #prefix then return end

            vim.schedule(function()
              if not vim.api.nvim_buf_is_valid(buf) or not vim.api.nvim_buf_is_loaded(buf) then return end
              local current = vim.api.nvim_buf_get_lines(buf, row - 1, row, false)[1] or ""
              if current:sub(1, #prefix) ~= prefix then return end
              vim.api.nvim_buf_set_text(buf, row - 1, 0, row - 1, #prefix, { target_prefix })
            end)
            return true
          end,
          "fallback",
        },
        ["<Tab>"] = {
          function(cmp)
            if vim.tbl_contains({ "cobol", "cbl", "cob" }, vim.bo.filetype) then
              local aligned = require("cobol").smart_tab()
              if aligned then return aligned end
            end
            return cmp.snippet_forward()
          end,
          "fallback",
        },
        ["<S-Tab>"] = {
          function(cmp)
            if vim.tbl_contains({ "cobol", "cbl", "cob" }, vim.bo.filetype) then
              local aligned = require("cobol").smart_backtab()
              if aligned then return vim.api.nvim_replace_termcodes(aligned, true, false, true) end
            end
            return cmp.snippet_backward()
          end,
          "fallback",
        },
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
      require("config.blink_menu").setup()
      require("config.ui_highlights").apply_completion_highlights()
    end,
  },
}
