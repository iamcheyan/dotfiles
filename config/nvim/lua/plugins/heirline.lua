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

      local function trigger_press(self)
        self._pressed = true
        pcall(vim.cmd, "redrawstatus")
        vim.defer_fn(function()
          self._pressed = false
          pcall(vim.cmd, "redrawstatus")
        end, 180)
      end

      local function open_statusline_menu(title, items, preferred_col)
        if _G._statusline_menu_win and vim.api.nvim_win_is_valid(_G._statusline_menu_win) then
          pcall(vim.api.nvim_win_close, _G._statusline_menu_win, true)
          _G._statusline_menu_win = nil
          _G._statusline_menu_buf = nil
        end

        local display_lines = {}
        local actions = {}
        local max_len = vim.fn.strdisplaywidth(title) + 6

        for _, item in ipairs(items) do
          if item.separator then
            table.insert(display_lines, "  ──────────────────────────────")
            table.insert(actions, false)
          else
            local line = string.format("  %s  %-26s", item.icon or "•", item.label)
            local len = vim.fn.strdisplaywidth(line)
            if len > max_len then
              max_len = len
            end
            table.insert(display_lines, line)
            table.insert(actions, item.action)
          end
        end

        local buf = vim.api.nvim_create_buf(false, true)
        vim.api.nvim_buf_set_lines(buf, 0, -1, false, display_lines)
        vim.bo[buf].buftype = "nofile"
        vim.bo[buf].filetype = "contextline_menu"
        vim.bo[buf].bufhidden = "wipe"
        vim.bo[buf].modifiable = false

        local win_width = math.min(max_len + 3, vim.o.columns - 4)
        local win_height = #display_lines

        local mouse_pos = vim.fn.getmousepos()
        local col = preferred_col or (mouse_pos and mouse_pos.screencol) or 10
        col = math.max(0, math.min(col - math.floor(win_width / 2), vim.o.columns - win_width - 2))
        local row = math.max(0, vim.o.lines - win_height - 2)

        local win = vim.api.nvim_open_win(buf, true, {
          relative = "editor",
          row = row,
          col = col,
          width = win_width,
          height = win_height,
          style = "minimal",
          border = "single",
          title = " " .. title .. " ",
          title_pos = "center",
          zindex = 300,
        })

        vim.wo[win].cursorline = true
        vim.wo[win].winhighlight = "NormalFloat:Pmenu,FloatBorder:Pmenu,CursorLine:PmenuSel,FloatTitle:Title"

        _G._statusline_menu_win = win
        _G._statusline_menu_buf = buf

        local function close()
          if win and vim.api.nvim_win_is_valid(win) then
            pcall(vim.api.nvim_win_close, win, true)
          end
          _G._statusline_menu_win = nil
          _G._statusline_menu_buf = nil
        end

        local function execute_current()
          local ok, cur = pcall(vim.api.nvim_win_get_cursor, win)
          local line_idx = (ok and cur) and cur[1] or 1
          close()
          local act = actions[line_idx]
          if type(act) == "function" then
            vim.schedule(act)
          end
        end

        local kmopts = { buffer = buf, nowait = true, silent = true }
        vim.keymap.set("n", "<CR>", execute_current, kmopts)
        vim.keymap.set("n", "<Space>", execute_current, kmopts)
        vim.keymap.set("n", "<LeftMouse>", function()
          local mp = vim.fn.getmousepos()
          if mp and mp.winid == win then
            if mp.line >= 1 and mp.line <= #display_lines then
              pcall(vim.api.nvim_win_set_cursor, win, { mp.line, 0 })
              execute_current()
            end
          else
            close()
          end
        end, kmopts)
        vim.keymap.set("n", "q", close, kmopts)
        vim.keymap.set("n", "<Esc>", close, kmopts)

        vim.api.nvim_create_autocmd({ "BufLeave", "WinLeave" }, {
          buffer = buf,
          once = true,
          callback = close,
        })
      end

      local Mode = {
        init = function(self)
          self.mode = vim.fn.mode(1)
        end,
        on_click = {
          callback = function(self, _, _, button)
            if button ~= "l" then return end
            trigger_press(self)
            open_statusline_menu("Quick Commands", {
              {
                icon = "⌨️",
                label = "Show All Keymaps (:WhichKey)",
                action = function()
                  pcall(function() require("which-key").show() end)
                end,
              },
              {
                icon = "🔍",
                label = "Find Files (<leader><space>)",
                action = function()
                  pcall(function() require("snacks").picker.files() end)
                end,
              },
              {
                icon = "🔎",
                label = "Search Text in Project (<leader>sg)",
                action = function()
                  pcall(function() require("snacks").picker.grep() end)
                end,
              },
              {
                icon = "📁",
                label = "Project Explorer (<leader>e)",
                action = function()
                  pcall(function() require("neo-tree.command").execute({ toggle = true }) end)
                end,
              },
              {
                icon = "⚡",
                label = "Plugin Manager (:Lazy)",
                action = function()
                  vim.cmd("Lazy")
                end,
              },
            })
          end,
          name = "heirline_mode_menu",
        },
        hl = function(self)
          if self._pressed then
            return { bg = "#0064c8" }
          end
        end,
        {
          provider = " ",
          hl = function(self)
            if self._pressed then return { fg = "#ffffff", bold = true } end
            local c = mode_colors[self.mode] or mode_colors[self.mode:sub(1, 1)] or "#ffffff"
            return { fg = c, bold = true }
          end,
        },
        {
          provider = function(self)
            return (mode_names[self.mode] or self.mode)
          end,
          hl = function(self)
            if self._pressed then return { fg = "#ffffff", bold = true } end
            local c = mode_colors[self.mode] or mode_colors[self.mode:sub(1, 1)] or "#ffffff"
            return { fg = c, bold = true }
          end,
        },
      }

      local GitBranch = {
        init = function(self)
          self.gs = vim.b.gitsigns_status_dict
        end,
        on_click = {
          callback = function(self, _, _, button)
            if button ~= "l" then return end
            trigger_press(self)
            open_statusline_menu("Git Operations", {
              {
                icon = "",
                label = "Open Diffview Workspace (<leader>gd)",
                action = function()
                  vim.cmd("DiffviewOpen")
                end,
              },
              {
                icon = "",
                label = "Current File Diff History (<leader>gD)",
                action = function()
                  vim.cmd("DiffviewFileHistory %")
                end,
              },
              {
                icon = "",
                label = "Branch Commit History (<leader>gV)",
                action = function()
                  vim.cmd("DiffviewFileHistory")
                end,
              },
              {
                icon = "🚀",
                label = "Open Lazygit Terminal (<leader>gg)",
                action = function()
                  pcall(function() require("snacks").lazygit() end)
                end,
              },
              { separator = true },
              {
                icon = "👁️",
                label = "Toggle Line Blame (<leader>ub)",
                action = function()
                  pcall(function() require("gitsigns").toggle_current_line_blame() end)
                end,
              },
              {
                icon = "🔍",
                label = "Preview Hunk at Cursor (<leader>gp)",
                action = function()
                  pcall(function() require("gitsigns").preview_hunk() end)
                end,
              },
              {
                icon = "↩️",
                label = "Reset Hunk at Cursor (<leader>gr)",
                action = function()
                  pcall(function() require("gitsigns").reset_hunk() end)
                end,
              },
            })
          end,
          name = "heirline_git_menu",
        },
        hl = function(self)
          if self._pressed then
            return { bg = "#0064c8" }
          end
        end,
        {
          provider = function(self)
            local head = self.gs and self.gs.head or ""
            return " " .. (head == "" and "-" or head)
          end,
          hl = function(self)
            if self._pressed then return { fg = "#ffffff", bold = true } end
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
          hl = function(self)
            if self._pressed then return { fg = "#ffffff" } end
            return { fg = "#50fa7b" }
          end,
        },
        {
          provider = function(self)
            local count = (self.gs and self.gs.changed) or 0
            return " ~" .. count
          end,
          hl = function(self)
            if self._pressed then return { fg = "#ffffff" } end
            return { fg = "#ffff00" }
          end,
        },
        {
          provider = function(self)
            local count = (self.gs and self.gs.removed) or 0
            return " -" .. count
          end,
          hl = function(self)
            if self._pressed then return { fg = "#ffffff" } end
            return { fg = "#ff5555" }
          end,
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
            if button ~= "l" then return end
            trigger_press(self)
            local path = self.current_path
            if not path or path == "" or path == "[No Name]" then return end
            local fname = self.file or vim.fn.fnamemodify(path, ":t")
            local rel_path = vim.fn.fnamemodify(path, ":.")

            if nclicks and nclicks >= 2 then
              vim.fn.setreg("+", path)
              vim.notify("Copied full path: " .. path, vim.log.levels.INFO)
              return
            end

            open_statusline_menu("File Actions", {
              {
                icon = "📋",
                label = "Copy Relative Path",
                action = function()
                  vim.fn.setreg("+", rel_path)
                  vim.notify("Copied: " .. rel_path, vim.log.levels.INFO)
                end,
              },
              {
                icon = "📋",
                label = "Copy Absolute Path",
                action = function()
                  vim.fn.setreg("+", path)
                  vim.notify("Copied: " .. path, vim.log.levels.INFO)
                end,
              },
              {
                icon = "📋",
                label = "Copy Filename Only",
                action = function()
                  vim.fn.setreg("+", fname)
                  vim.notify("Copied: " .. fname, vim.log.levels.INFO)
                end,
              },
              { separator = true },
              {
                icon = "📂",
                label = "Open Directory in Oil (-)",
                action = function()
                  vim.cmd("Oil")
                end,
              },
              {
                icon = "🌳",
                label = "Reveal in Neo-tree (<leader>e)",
                action = function()
                  pcall(function()
                    require("neo-tree.command").execute({ toggle = false, reveal = true })
                  end)
                end,
              },
              {
                icon = "📜",
                label = "View File History (Diffview)",
                action = function()
                  vim.cmd("DiffviewFileHistory %")
                end,
              },
              {
                icon = "✏️",
                label = "Rename File (Snacks)",
                action = function()
                  pcall(function()
                    require("snacks").rename.rename_file()
                  end)
                end,
              },
            })
          end,
          name = "heirline_file_actions",
        },
        hl = function(self)
          if self._pressed then
            return { bg = "#0064c8" }
          end
        end,
        {
          provider = function(self)
            return self.icon .. " "
          end,
          hl = function(self)
            if self._pressed then return { fg = "#ffffff", bold = true } end
            return { fg = self.icon_color }
          end,
        },
        {
          provider = function(self)
            return self.dir
          end,
          hl = function(self)
            if self._pressed then return { fg = "#ffffff" } end
            return { fg = "#a0a0a0" }
          end,
        },
        {
          provider = function(self)
            return self.file
          end,
          hl = function(self)
            if self._pressed then return { fg = "#ffffff", bold = true } end
            return { fg = "#ffffff", bold = true }
          end,
        },
        {
          condition = function(self)
            return self.is_modified
          end,
          provider = " [+]",
          hl = function(self)
            if self._pressed then return { fg = "#ffff00", bold = true } end
            return { fg = "#ffff00", bold = true }
          end,
        },
        {
          condition = function(self)
            return self.is_readonly
          end,
          provider = " [RO]",
          hl = function(self)
            if self._pressed then return { fg = "#ff5555", bold = true } end
            return { fg = "#ff5555", bold = true }
          end,
        },
        {
          condition = function(self)
            return self.is_new
          end,
          provider = " [New]",
          hl = function(self)
            if self._pressed then return { fg = "#50fa7b", bold = true } end
            return { fg = "#50fa7b", bold = true }
          end,
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
        on_click = {
          callback = function(self, _, _, button)
            if button ~= "l" then return end
            trigger_press(self)
            open_statusline_menu("LSP & Dev Tools", {
              {
                icon = "󰒋",
                label = "LSP Information (:LspInfo)",
                action = function()
                  vim.cmd("LspInfo")
                end,
              },
              {
                icon = "📦",
                label = "Package Manager (:Mason)",
                action = function()
                  vim.cmd("Mason")
                end,
              },
              {
                icon = "📑",
                label = "Document Symbols (<leader>cs)",
                action = function()
                  vim.cmd("AerialToggle!")
                end,
              },
              { separator = true },
              {
                icon = "💡",
                label = "Code Actions (<leader>ca)",
                action = function()
                  pcall(vim.lsp.buf.code_action)
                end,
              },
              {
                icon = "✨",
                label = "Format Buffer (<leader>F)",
                action = function()
                  pcall(function()
                    require("conform").format({ async = true, lsp_fallback = true })
                  end)
                end,
              },
              {
                icon = "🔄",
                label = "Restart LSP Server (:LspRestart)",
                action = function()
                  vim.cmd("LspRestart")
                end,
              },
            })
          end,
          name = "heirline_lsp_menu",
        },
        hl = function(self)
          if self._pressed then
            return { bg = "#0064c8" }
          end
        end,
        {
          provider = "󰒋 ",
          hl = function(self)
            if self._pressed then return { fg = "#ffffff" } end
            return { fg = self.active and "#50fa7b" or "#7f7f7f" }
          end,
        },
        {
          provider = function(self)
            return self.lsp_name
          end,
          hl = function(self)
            if self._pressed then return { fg = "#ffffff", bold = true } end
            return { fg = self.active and "#50fa7b" or "#7f7f7f", bold = self.active }
          end,
        },
      }

      local Encoding = {
        on_click = {
          callback = function(self, _, _, button)
            if button ~= "l" then return end
            trigger_press(self)
            open_statusline_menu("Encoding & Line Format", {
              {
                icon = "󰉿",
                label = "Set Encoding: UTF-8",
                action = function()
                  vim.bo.fileencoding = "utf-8"
                  vim.notify("File encoding set to UTF-8", vim.log.levels.INFO)
                end,
              },
              {
                icon = "󰉿",
                label = "Set Encoding: GB18030 / GBK",
                action = function()
                  vim.bo.fileencoding = "gb18030"
                  vim.notify("File encoding set to GB18030", vim.log.levels.INFO)
                end,
              },
              {
                icon = "󰉿",
                label = "Set Encoding: Shift-JIS (CP932)",
                action = function()
                  vim.bo.fileencoding = "cp932"
                  vim.notify("File encoding set to CP932", vim.log.levels.INFO)
                end,
              },
              {
                icon = "󰉿",
                label = "Set Encoding: EUC-JP",
                action = function()
                  vim.bo.fileencoding = "euc-jp"
                  vim.notify("File encoding set to EUC-JP", vim.log.levels.INFO)
                end,
              },
              {
                icon = "󰉿",
                label = "Set Encoding: Latin-1 (ISO-8859-1)",
                action = function()
                  vim.bo.fileencoding = "latin1"
                  vim.notify("File encoding set to Latin-1", vim.log.levels.INFO)
                end,
              },
              {
                icon = "󰉿",
                label = "Set Encoding: UTF-16LE",
                action = function()
                  vim.bo.fileencoding = "utf-16le"
                  vim.notify("File encoding set to UTF-16LE", vim.log.levels.INFO)
                end,
              },
              { separator = true },
              {
                icon = "󰑓",
                label = "Reload as: UTF-8 (:e ++enc=utf-8)",
                action = function()
                  vim.cmd("edit ++enc=utf-8")
                end,
              },
              {
                icon = "󰑓",
                label = "Reload as: Shift-JIS (:e ++enc=cp932)",
                action = function()
                  vim.cmd("edit ++enc=cp932")
                end,
              },
              {
                icon = "󰑓",
                label = "Reload as: GB18030 (:e ++enc=gb18030)",
                action = function()
                  vim.cmd("edit ++enc=gb18030")
                end,
              },
              {
                icon = "󰑓",
                label = "Reload as: EUC-JP (:e ++enc=euc-jp)",
                action = function()
                  vim.cmd("edit ++enc=euc-jp")
                end,
              },
              { separator = true },
              {
                icon = "󰌒",
                label = "Line Format: Unix (LF)",
                action = function()
                  vim.bo.fileformat = "unix"
                  vim.notify("Line format set to Unix (LF)", vim.log.levels.INFO)
                end,
              },
              {
                icon = "󰌒",
                label = "Line Format: Windows (CRLF)",
                action = function()
                  vim.bo.fileformat = "dos"
                  vim.notify("Line format set to Windows (CRLF)", vim.log.levels.INFO)
                end,
              },
              {
                icon = "󰌒",
                label = "Line Format: Mac Classic (CR)",
                action = function()
                  vim.bo.fileformat = "mac"
                  vim.notify("Line format set to Mac Classic (CR)", vim.log.levels.INFO)
                end,
              },
            })
          end,
          name = "heirline_encoding_menu",
        },
        hl = function(self)
          if self._pressed then
            return { bg = "#0064c8" }
          end
        end,
        {
          provider = "󰉿 ",
          hl = function(self)
            if self._pressed then return { fg = "#ffffff" } end
            return { fg = "#8be9fd" }
          end,
        },
        {
          provider = function()
            local enc = vim.bo.fileencoding ~= "" and vim.bo.fileencoding or vim.o.encoding
            local fmt = vim.bo.fileformat == "dos" and " [CRLF]" or (vim.bo.fileformat == "mac" and " [CR]" or "")
            return string.upper(enc) .. fmt
          end,
          hl = function(self)
            if self._pressed then return { fg = "#ffffff", bold = true } end
            return { fg = "#8be9fd", bold = true }
          end,
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
        on_click = {
          callback = function(self, _, _, button)
            if button ~= "l" then return end
            trigger_press(self)
            open_statusline_menu("Navigation & Position", {
              {
                icon = "🔢",
                label = "Go to Line Number...",
                action = function()
                  vim.ui.input({ prompt = "Enter line number: " }, function(input)
                    if input and tonumber(input) then
                      vim.cmd("normal! " .. input .. "G")
                    end
                  end)
                end,
              },
              {
                icon = "⬆️",
                label = "Jump to Top of File (gg)",
                action = function()
                  vim.cmd("normal! gg")
                end,
              },
              {
                icon = "⬇️",
                label = "Jump to Bottom of File (G)",
                action = function()
                  vim.cmd("normal! G")
                end,
              },
              {
                icon = "🎯",
                label = "Center Screen on Cursor (zz)",
                action = function()
                  vim.cmd("normal! zz")
                end,
              },
            })
          end,
          name = "heirline_nav_menu",
        },
        hl = function(self)
          if self._pressed then
            return { bg = "#0064c8" }
          end
        end,
        {
          provider = "󰦨 ",
          hl = function(self)
            if self._pressed then return { fg = "#ffffff" } end
            return { fg = "#bd93f9" }
          end,
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
          hl = function(self)
            if self._pressed then return { fg = "#ffffff", bold = true } end
            return { fg = "#bd93f9", bold = true }
          end,
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
