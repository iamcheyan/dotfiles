return {
  {
    "nvim-lualine/lualine.nvim",
    enabled = false,
  },
  {
    "rebelot/heirline.nvim",
    dependencies = {
      "nvim-tree/nvim-web-devicons",
    },
    opts = function()
      local gap = { provider = "  " }
      local pad = { provider = " " }

      local mode_names = {
        n = "NORMAL",
        no = "N-PENDING",
        nov = "N-PENDING",
        noV = "N-PENDING",
        ["no\22"] = "N-PENDING",
        niI = "NORMAL",
        niR = "NORMAL",
        niV = "NORMAL",
        nt = "NORMAL",
        v = "VISUAL",
        vs = "VISUAL",
        V = "V-LINE",
        Vs = "V-LINE",
        ["\22"] = "V-BLOCK",
        ["\22s"] = "V-BLOCK",
        s = "SELECT",
        S = "S-LINE",
        ["\19"] = "S-BLOCK",
        i = "INSERT",
        ic = "INSERT",
        ix = "INSERT",
        R = "REPLACE",
        Rc = "REPLACE",
        Rx = "REPLACE",
        Rv = "V-REPLACE",
        Rvc = "V-REPLACE",
        Rvx = "V-REPLACE",
        c = "COMMAND",
        cv = "EX",
        r = "PROMPT",
        rm = "MORE",
        ["r?"] = "CONFIRM",
        ["!"] = "SHELL",
        t = "TERMINAL",
      }

      local function get_venv_name()
        local venv = vim.env.VIRTUAL_ENV
        if venv and venv ~= "" then
          return vim.fn.fnamemodify(venv, ":t")
        end
        local conda = vim.env.CONDA_DEFAULT_ENV
        if conda and conda ~= "" then
          return conda
        end
        return nil
      end

      local Mode = {
        provider = function()
          local mode = vim.fn.mode(1)
          return " " .. (mode_names[mode] or mode)
        end,
        hl = { bold = true },
      }

      local GitBranch = {
        provider = function()
          local gs = vim.b.gitsigns_status_dict
          local head = gs and gs.head or ""
          if head == "" then
            return " -"
          end
          local added = gs.added or 0
          local changed = gs.changed or 0
          local removed = gs.removed or 0
          return string.format(" %s +%d ~%d -%d", head, added, changed, removed)
        end,
      }

      local FileName = {
        provider = function(self)
          local name = vim.api.nvim_buf_get_name(0)
          local path = name == "" and "[No Name]" or vim.fn.fnamemodify(name, ":p")
          self.current_path = path
          local icon = "󰈔"
          if name ~= "" then
            local devicons = require("nvim-web-devicons")
            local fname = vim.fn.fnamemodify(name, ":t")
            local ext = vim.fn.fnamemodify(name, ":e")
            icon = devicons.get_icon(fname, ext, { default = true }) or icon
          end

          local flags = {}
          if vim.bo.modified then
            table.insert(flags, "[+]")
          end
          if vim.bo.readonly or not vim.bo.modifiable then
            table.insert(flags, "[RO]")
          end
          if
            name ~= ""
            and vim.bo.buftype == ""
            and vim.fn.filereadable(name) == 0
            and vim.fn.isdirectory(name) == 0
          then
            table.insert(flags, "[New]")
          end

          local suffix = #flags > 0 and (" " .. table.concat(flags, " ")) or ""
          return string.format("%s %s%s", icon, path, suffix)
        end,
        on_click = {
          callback = function(self, _, nclicks, button)
            if button ~= "l" or nclicks < 2 then
              return
            end
            local path = self.current_path
            if not path or path == "" or path == "[No Name]" then
              return
            end
            vim.fn.setreg("+", path)
            vim.notify("已复制路径: " .. path, vim.log.levels.INFO)
          end,
          name = "heirline_copy_filepath",
        },
      }

      local LspName = {
        provider = function()
          local clients = vim.lsp.get_clients({ bufnr = 0 })
          if #clients == 0 then
            return "󰒋 None"
          end
          local name = clients[1].name or "Unknown"
          if name == "basedpyright" or name == "pyright" then
            name = "Pyright"
          end
          return "󰒋 " .. name
        end,
      }

      local Encoding = {
        provider = function()
          local enc = vim.bo.fileencoding ~= "" and vim.bo.fileencoding or vim.o.encoding
          return "󰉿 " .. string.upper(enc)
        end,
      }

      local Venv = {
        condition = function()
          return get_venv_name() ~= nil
        end,
        provider = function()
          return "󱔎 " .. get_venv_name()
        end,
      }

      local RemainingPercent = {
        provider = function()
          local total = vim.fn.line("$")
          if total <= 1 then
            return "󰦨 0%"
          end
          local current = vim.fn.line(".")
          local remain = math.floor(((total - current) / total) * 100 + 0.5)
          return "󰦨 " .. remain .. "%"
        end,
      }

      local Clock = {
        provider = function()
          return "󱑆 " .. os.date("%H:%M")
        end,
      }

      local Align = { provider = "%=" }

      return {
        statusline = {
          hl = { fg = "#000000", bg = "#50fa7b" },
          pad,
          Mode,
          gap,
          GitBranch,
          gap,
          FileName,
          gap,
          LspName,
          gap,
          Encoding,
          Align,
          Venv,
          gap,
          RemainingPercent,
          gap,
          Clock,
          pad,
        },
      }
    end,
    config = function(_, opts)
      vim.o.laststatus = 3
      require("heirline").setup(opts)
      if not vim.g.heirline_clock_timer_started then
        local timer = vim.uv.new_timer()
        if timer then
          timer:start(
            0,
            30000,
            vim.schedule_wrap(function()
              pcall(vim.cmd, "redrawstatus")
            end)
          )
          vim.g.heirline_clock_timer_started = true
        end
      end
    end,
  },
}
