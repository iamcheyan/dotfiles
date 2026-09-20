return {
  {
    "rebelot/heirline.nvim",
    lazy = true,
    event = "VeryLazy",
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

      local mode_colors = {
        n = "#50fa7b",       -- Normal: Green
        no = "#50fa7b",
        nov = "#50fa7b",
        noV = "#50fa7b",
        ["no\22"] = "#50fa7b",
        niI = "#50fa7b",
        niR = "#50fa7b",
        niV = "#50fa7b",
        nt = "#50fa7b",
        i = "#8be9fd",       -- Insert: Cyan
        ic = "#8be9fd",
        ix = "#8be9fd",
        v = "#ff79c6",       -- Visual: Pink
        vs = "#ff79c6",
        V = "#ff79c6",       -- V-Line: Pink
        Vs = "#ff79c6",
        ["\22"] = "#bd93f9", -- V-Block: Purple
        ["\22s"] = "#bd93f9",
        s = "#ffb86c",       -- Select: Orange
        S = "#ffb86c",
        ["\19"] = "#ffb86c",
        R = "#ff5555",       -- Replace: Red
        Rc = "#ff5555",
        Rx = "#ff5555",
        Rv = "#ff5555",
        Rvc = "#ff5555",
        Rvx = "#ff5555",
        c = "#ffff00",       -- Command: Yellow
        cv = "#ffff00",
        r = "#ff5555",
        rm = "#ff5555",
        ["r?"] = "#ffff00",
        ["!"] = "#ff5555",
        t = "#50fa7b",
      }

      local Mode = {
        init = function(self)
          self.mode = vim.fn.mode(1)
        end,
        {
          provider = " ",
          hl = function(self)
            local c = mode_colors[self.mode] or mode_colors[self.mode:sub(1, 1)] or "#ffffff"
            return { fg = c, bold = true }
          end,
        },
        {
          provider = function(self)
            return (mode_names[self.mode] or self.mode)
          end,
          hl = function(self)
            local c = mode_colors[self.mode] or mode_colors[self.mode:sub(1, 1)] or "#ffffff"
            return { fg = c, bold = true }
          end,
        },
      }

      local GitBranch = {
        init = function(self)
          self.gs = vim.b.gitsigns_status_dict
        end,
        {
          provider = function(self)
            local head = self.gs and self.gs.head or ""
            return " " .. (head == "" and "-" or head)
          end,
          hl = function(self)
            local head = self.gs and self.gs.head or ""
            if head ~= "" then
              return { fg = "#ff79c6", bold = true }
            end
            return { fg = "#7f7f7f" }
          end,
        },
        {
          provider = function(self)
            local count = (self.gs and self.gs.added) or 0
            return " +" .. count
          end,
          hl = { fg = "#50fa7b" },
        },
        {
          provider = function(self)
            local count = (self.gs and self.gs.changed) or 0
            return " ~" .. count
          end,
          hl = { fg = "#ffff00" },
        },
        {
          provider = function(self)
            local count = (self.gs and self.gs.removed) or 0
            return " -" .. count
          end,
          hl = { fg = "#ff5555" },
        },
      }

      local FileName = {
        init = function(self)
          local name = vim.api.nvim_buf_get_name(0)
          local path = name == "" and "[No Name]" or vim.fn.fnamemodify(name, ":p")
          self.current_path = path

          local icon = "󰈔"
          local icon_color = "#8be9fd"
          if name ~= "" then
            local devicons = require("nvim-web-devicons")
            local fname = vim.fn.fnamemodify(name, ":t")
            local ext = vim.fn.fnamemodify(name, ":e")
            local ic, col = devicons.get_icon_color(fname, ext, { default = true })
            if ic then
              icon = ic
            end
            if col then
              icon_color = col
            end
            self.dir = vim.fn.fnamemodify(path, ":h") .. "/"
            self.file = fname
          else
            self.dir = ""
            self.file = "[No Name]"
          end
          self.icon = icon
          self.icon_color = icon_color

          self.is_modified = vim.bo.modified
          self.is_readonly = vim.bo.readonly or not vim.bo.modifiable
          self.is_new = (
            name ~= ""
            and vim.bo.buftype == ""
            and vim.fn.filereadable(name) == 0
            and vim.fn.isdirectory(name) == 0
          )
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
            vim.notify("Copied path: " .. path, vim.log.levels.INFO)
          end,
          name = "heirline_copy_filepath",
        },
        {
          provider = function(self)
            return self.icon .. " "
          end,
          hl = function(self)
            return { fg = self.icon_color }
          end,
        },
        {
          provider = function(self)
            return self.dir
          end,
          hl = { fg = "#a0a0a0" },
        },
        {
          provider = function(self)
            return self.file
          end,
          hl = { fg = "#ffffff", bold = true },
        },
        {
          condition = function(self)
            return self.is_modified
          end,
          provider = " [+]",
          hl = { fg = "#ffff00", bold = true },
        },
        {
          condition = function(self)
            return self.is_readonly
          end,
          provider = " [RO]",
          hl = { fg = "#ff5555", bold = true },
        },
        {
          condition = function(self)
            return self.is_new
          end,
          provider = " [New]",
          hl = { fg = "#50fa7b", bold = true },
        },
      }

      local LspName = {
        init = function(self)
          local clients = vim.lsp.get_clients({ bufnr = 0 })
          if #clients == 0 then
            self.lsp_name = "None"
            self.active = false
          else
            local name = clients[1].name or "Unknown"
            if name == "basedpyright" or name == "pyright" then
              name = "Pyright"
            end
            self.lsp_name = name
            self.active = true
          end
        end,
        {
          provider = "󰒋 ",
          hl = function(self)
            return { fg = self.active and "#50fa7b" or "#7f7f7f" }
          end,
        },
        {
          provider = function(self)
            return self.lsp_name
          end,
          hl = function(self)
            return { fg = self.active and "#50fa7b" or "#7f7f7f", bold = self.active }
          end,
        },
      }

      local Encoding = {
        {
          provider = "󰉿 ",
          hl = { fg = "#8be9fd" },
        },
        {
          provider = function()
            local enc = vim.bo.fileencoding ~= "" and vim.bo.fileencoding or vim.o.encoding
            return string.upper(enc)
          end,
          hl = { fg = "#8be9fd", bold = true },
        },
      }

      local Venv = {
        condition = function()
          return get_venv_name() ~= nil
        end,
        {
          provider = "󱔎 ",
          hl = { fg = "#ffff00" },
        },
        {
          provider = function()
            return get_venv_name()
          end,
          hl = { fg = "#50fa7b", bold = true },
        },
      }

      local RemainingPercent = {
        {
          provider = "󰦨 ",
          hl = { fg = "#bd93f9" },
        },
        {
          provider = function()
            local total = vim.fn.line("$")
            if total <= 1 then
              return "0%"
            end
            local current = vim.fn.line(".")
            local remain = math.floor(((total - current) / total) * 100 + 0.5)
            return remain .. "%"
          end,
          hl = { fg = "#bd93f9", bold = true },
        },
      }

      local Clock = {
        provider = function()
          return "󱑆 " .. os.date("%H:%M")
        end,
      }

      local Align = { provider = "%=" }
      local hidden_filetypes = {
        ["neo-tree"] = true,
        ["NvimTree"] = true,
        ["aerial"] = true,
        ["help"] = true,
        ["lazy"] = true,
        ["mason"] = true,
        ["Trouble"] = true,
        ["snacks_layout_box"] = true,
        ["qf"] = true,
        ["csv"] = true,
        ["tsv"] = true,
        ["text"] = true,
        ["txt"] = true,
        ["plaintex"] = true,
        ["log"] = true,
        ["gitcommit"] = true,
        ["gitrebase"] = true,
        ["diff"] = true,
        ["checkhealth"] = true,
        ["man"] = true,
      }


      local ContextlineWinbar = {
        condition = function()
          if vim.bo.buftype ~= "" or vim.bo.filetype == "" or hidden_filetypes[vim.bo.filetype] then
            return false
          end
          local ok, cl = pcall(require, "contextline")
          if not ok then
            return false
          end
          return cl.get_info() ~= nil
        end,
        pad,
        {
          provider = function()
            local ok, cl = pcall(require, "contextline")
            return ok and cl.get({ separator = "  " }) or ""
          end,
        },
        -- Do not cache only on CursorMoved: opening the hierarchy menu must
        -- redraw the active chip on the first click, before any cursor move.
        update = { "CursorMoved", "CursorMovedI", "BufEnter", "WinEnter", "WinLeave" },
      }

      return {
        opts = {
          disable_winbar_cb = function(args)
            local buf = args.buf or 0
            local ft = vim.bo[buf].filetype
            local bt = vim.bo[buf].buftype
            if bt ~= "" or ft == "" or hidden_filetypes[ft] then
              return true
            end
            return false
          end,
        },
        winbar = ContextlineWinbar,
        statusline = {
          hl = "StatusLine",
          pad,
          GitBranch,
          gap,
          FileName,
          Align,
          Venv,
          gap,
          Encoding, 
          gap,
          LspName,
          gap,
          RemainingPercent,
          gap,
          Mode,
          pad,
        },
      }
    end,
    config = function(_, opts)
      vim.o.laststatus = 3
      require("heirline").setup(opts)

      -- 解决切换主题后状态栏失去颜色的问题：
      -- 当执行 :colorscheme 时，Vim 会清空所有高亮组 (hi clear)。
      -- 监听 ColorScheme 事件，自动调用 heirline.utils.on_colorscheme 重建高亮并重绘状态栏。
      vim.api.nvim_create_autocmd("ColorScheme", {
        group = vim.api.nvim_create_augroup("HeirlineReloadOnColorscheme", { clear = true }),
        callback = function()
          local ok, utils = pcall(require, "heirline.utils")
          if ok and utils.on_colorscheme then
            utils.on_colorscheme()
          end
          pcall(vim.cmd, "redrawstatus")
        end,
      })

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
