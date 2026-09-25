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

      local function get_active_editor_win()
        local id = tonumber(vim.g.statusline_winid)
        if id and id > 0 and vim.api.nvim_win_is_valid(id) and id ~= _G._statusline_menu_win then
          return id
        end
        local cur = vim.api.nvim_get_current_win()
        if cur ~= _G._statusline_menu_win then
          return cur
        end
        for _, w in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
          if w ~= _G._statusline_menu_win and vim.api.nvim_win_is_valid(w) then
            local b = vim.api.nvim_win_get_buf(w)
            if vim.bo[b].buftype == "" then
              return w
            end
          end
        end
        return cur
      end

      local function get_comp_col(click_name)
        if not click_name then return nil end
        local ok, heirline = pcall(require, "heirline")
        if not ok or not heirline.eval_statusline then return nil end
        local raw_str = heirline.eval_statusline()
        local needle = "%@v:lua." .. click_name .. "@"
        local p = raw_str:find(needle, 1, true)
        if not p then return nil end
        local marker = "|||TARGET|||"
        local marker_str = raw_str:sub(1, p - 1) .. marker .. raw_str:sub(p + #needle)
        local ev = vim.api.nvim_eval_statusline(marker_str, { highlights = false })
        local idx = ev.str:find(marker, 1, true)
        if idx then
          return vim.fn.strdisplaywidth(ev.str:sub(1, idx - 1))
        end
        return nil
      end

      local function open_statusline_menu(menu_id, items, click_name)
        if _G._active_statusline_menu == menu_id and _G._statusline_menu_win and vim.api.nvim_win_is_valid(_G._statusline_menu_win) then
          pcall(vim.api.nvim_win_close, _G._statusline_menu_win, true)
          _G._statusline_menu_win = nil
          _G._statusline_menu_buf = nil
          _G._active_statusline_menu = nil
          pcall(vim.cmd, "redrawstatus")
          return
        end

        if _G._statusline_menu_win and vim.api.nvim_win_is_valid(_G._statusline_menu_win) then
          pcall(vim.api.nvim_win_close, _G._statusline_menu_win, true)
          _G._statusline_menu_win = nil
          _G._statusline_menu_buf = nil
          _G._active_statusline_menu = nil
        end

        local comp_col = get_comp_col(click_name)
        if not comp_col then
          if click_name == "heirline_git_menu" then
            comp_col = 1
          elseif click_name == "heirline_file_actions" then
            comp_col = 15
          else
            local mouse_pos = vim.fn.getmousepos()
            comp_col = (mouse_pos and mouse_pos.screencol and mouse_pos.screencol > 0) and mouse_pos.screencol or 10
          end
        end

        _G._active_statusline_menu = menu_id
        pcall(vim.cmd, "redrawstatus")

        local display_lines = {}
        local actions = {}
        local max_len = 24

        for _, item in ipairs(items) do
          if item.separator then
            table.insert(display_lines, "  ──────────────────────────────")
            table.insert(actions, false)
          else
            local line = string.format("  %s  %s", item.icon or "•", item.label)
            local len = vim.fn.strdisplaywidth(line)
            if len > max_len then
              max_len = len
            end
            table.insert(display_lines, line)
            table.insert(actions, item.action)
          end
        end

        local win_width = math.min(max_len + 4, vim.o.columns - 2)

        local final_lines = {}
        for _, text in ipairs(display_lines) do
          local visual_len = vim.fn.strdisplaywidth(text)
          local pad_len = math.max(0, win_width - visual_len)
          table.insert(final_lines, text .. string.rep(" ", pad_len))
        end

        local buf = vim.api.nvim_create_buf(false, true)
        vim.api.nvim_buf_set_lines(buf, 0, -1, false, final_lines)
        vim.bo[buf].buftype = "nofile"
        vim.bo[buf].filetype = "contextline_menu"
        vim.bo[buf].bufhidden = "wipe"
        vim.bo[buf].modifiable = false

        local ns = vim.api.nvim_create_namespace("statusline_menu")
        for i, act in ipairs(actions) do
          if act == false then
            vim.api.nvim_buf_add_highlight(buf, ns, "Comment", i - 1, 0, -1)
          end
        end

        local col = comp_col
        if col + win_width > vim.o.columns - 1 then
          col = math.max(0, vim.o.columns - win_width - 1)
        end

        local statusline_row = vim.o.lines - vim.o.cmdheight - 1
        local win_height = math.min(#final_lines, math.max(1, statusline_row))
        local row = math.max(0, statusline_row - win_height)

        local win = vim.api.nvim_open_win(buf, true, {
          relative = "editor",
          row = row,
          col = col,
          width = win_width,
          height = win_height,
          style = "minimal",
          border = "none",
          zindex = 250,
        })

        vim.wo[win].cursorline = true
        vim.wo[win].winhighlight = "NormalFloat:Pmenu,FloatBorder:Pmenu,CursorLine:PmenuSel"

        _G._statusline_menu_win = win
        _G._statusline_menu_buf = buf

        local function close()
          if win and vim.api.nvim_win_is_valid(win) then
            pcall(vim.api.nvim_win_close, win, true)
          end
          _G._statusline_menu_win = nil
          _G._statusline_menu_buf = nil
          _G._active_statusline_menu = nil
          pcall(vim.cmd, "redrawstatus")
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
            if mp.line >= 1 and mp.line <= #final_lines then
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
            open_statusline_menu("mode", {
              {
                icon = "󰌌",
                label = "Show All Keymaps (:WhichKey)",
                action = function()
                  pcall(function() require("which-key").show() end)
                end,
              },
              {
                icon = "󰍉",
                label = "Find Files (<leader><space>)",
                action = function()
                  pcall(function() require("snacks").picker.files() end)
                end,
              },
              {
                icon = "󰊄",
                label = "Search Text in Project (<leader>sg)",
                action = function()
                  pcall(function() require("snacks").picker.grep() end)
                end,
              },
              {
                icon = "󰙅",
                label = "Project Explorer (<leader>e)",
                action = function()
                  pcall(function() require("neo-tree.command").execute({ toggle = true }) end)
                end,
              },
              {
                icon = "󱐋",
                label = "Plugin Manager (:Lazy)",
                action = function()
                  vim.cmd("Lazy")
                end,
              },
            }, "heirline_mode_menu")
          end,
          name = "heirline_mode_menu",
        },
        hl = function(self)
          if _G._active_statusline_menu == "mode" then
            return "Pmenu"
          end
          if self._pressed then
            return { bg = "#0064c8" }
          end
        end,
        {
          provider = " ",
          hl = function(self)
            if _G._active_statusline_menu == "mode" or self._pressed then return { fg = "#ffffff", bold = true } end
            local c = mode_colors[self.mode] or mode_colors[self.mode:sub(1, 1)] or "#ffffff"
            return { fg = c, bold = true }
          end,
        },
        {
          provider = function(self)
            return (mode_names[self.mode] or self.mode)
          end,
          hl = function(self)
            if _G._active_statusline_menu == "mode" or self._pressed then return { fg = "#ffffff", bold = true } end
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
            open_statusline_menu("git", {
              {
                icon = "󰊢",
                label = "Open Diffview Workspace (<leader>gd)",
                action = function()
                  vim.cmd("DiffviewOpen")
                end,
              },
              {
                icon = "󰋚",
                label = "Current File Diff History (<leader>gD)",
                action = function()
                  vim.cmd("DiffviewFileHistory %")
                end,
              },
              {
                icon = "󰜘",
                label = "Branch Commit History (<leader>gV)",
                action = function()
                  vim.cmd("DiffviewFileHistory")
                end,
              },
              {
                icon = "",
                label = "Open Lazygit Terminal (<leader>gg)",
                action = function()
                  pcall(function() require("snacks").lazygit() end)
                end,
              },
              { separator = true },
              {
                icon = "󰈈",
                label = "Toggle Line Blame (<leader>ub)",
                action = function()
                  pcall(function() require("gitsigns").toggle_current_line_blame() end)
                end,
              },
              {
                icon = "󰍉",
                label = "Preview Hunk at Cursor (<leader>gp)",
                action = function()
                  pcall(function() require("gitsigns").preview_hunk() end)
                end,
              },
              {
                icon = "󰜺",
                label = "Reset Hunk at Cursor (<leader>gr)",
                action = function()
                  pcall(function() require("gitsigns").reset_hunk() end)
                end,
              },
            }, "heirline_git_menu")
          end,
          name = "heirline_git_menu",
        },
        hl = function(self)
          if _G._active_statusline_menu == "git" then
            return "Pmenu"
          end
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
            if _G._active_statusline_menu == "git" or self._pressed then return { fg = "#ffffff", bold = true } end
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
            if _G._active_statusline_menu == "git" or self._pressed then return { fg = "#ffffff" } end
            return { fg = "#50fa7b" }
          end,
        },
        {
          provider = function(self)
            local count = (self.gs and self.gs.changed) or 0
            return " ~" .. count
          end,
          hl = function(self)
            if _G._active_statusline_menu == "git" or self._pressed then return { fg = "#ffffff" } end
            return { fg = "#ffff00" }
          end,
        },
        {
          provider = function(self)
            local count = (self.gs and self.gs.removed) or 0
            return " -" .. count
          end,
          hl = function(self)
            if _G._active_statusline_menu == "git" or self._pressed then return { fg = "#ffffff" } end
            return { fg = "#ff5555" }
          end,
        },
      }

      local FileName = {
        init = function(self)
          local winid = get_active_editor_win()
          local bufnr = vim.api.nvim_win_get_buf(winid)
          local name = vim.api.nvim_buf_get_name(bufnr)
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

          self.is_modified = vim.bo[bufnr].modified
          self.is_readonly = vim.bo[bufnr].readonly or not vim.bo[bufnr].modifiable
          self.is_new = (
            name ~= ""
            and vim.bo[bufnr].buftype == ""
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

            open_statusline_menu("file", {
              {
                icon = "󰅍",
                label = "Copy Relative Path",
                action = function()
                  vim.fn.setreg("+", rel_path)
                  vim.notify("Copied: " .. rel_path, vim.log.levels.INFO)
                end,
              },
              {
                icon = "󰅎",
                label = "Copy Absolute Path",
                action = function()
                  vim.fn.setreg("+", path)
                  vim.notify("Copied: " .. path, vim.log.levels.INFO)
                end,
              },
              {
                icon = "󰈤",
                label = "Copy Filename Only",
                action = function()
                  vim.fn.setreg("+", fname)
                  vim.notify("Copied: " .. fname, vim.log.levels.INFO)
                end,
              },
              { separator = true },
              {
                icon = "󰉖",
                label = "Open Directory in Oil (-)",
                action = function()
                  vim.cmd("Oil")
                end,
              },
              {
                icon = "󰙅",
                label = "Reveal in Neo-tree (<leader>e)",
                action = function()
                  pcall(function()
                    require("neo-tree.command").execute({ toggle = false, reveal = true })
                  end)
                end,
              },
              {
                icon = "󰋚",
                label = "View File History (Diffview)",
                action = function()
                  vim.cmd("DiffviewFileHistory %")
                end,
              },
              {
                icon = "󰑕",
                label = "Rename File (Snacks)",
                action = function()
                  pcall(function()
                    require("snacks").rename.rename_file()
                  end)
                end,
              },
            }, "heirline_file_actions")
          end,
          name = "heirline_file_actions",
        },
        hl = function(self)
          if _G._active_statusline_menu == "file" then
            return "Pmenu"
          end
          if self._pressed then
            return { bg = "#0064c8" }
          end
        end,
        {
          provider = function(self)
            return self.icon .. " "
          end,
          hl = function(self)
            if _G._active_statusline_menu == "file" or self._pressed then return { fg = "#ffffff", bold = true } end
            return { fg = self.icon_color }
          end,
        },
        {
          provider = function(self)
            return self.dir
          end,
          hl = function(self)
            if _G._active_statusline_menu == "file" or self._pressed then return { fg = "#ffffff" } end
            return { fg = "#a0a0a0" }
          end,
        },
        {
          provider = function(self)
            return self.file
          end,
          hl = function(self)
            if _G._active_statusline_menu == "file" or self._pressed then return { fg = "#ffffff", bold = true } end
            return { fg = "#ffffff", bold = true }
          end,
        },
        {
          condition = function(self)
            return self.is_modified
          end,
          provider = " [+]",
          hl = function(self)
            if _G._active_statusline_menu == "file" or self._pressed then return { fg = "#ffff00", bold = true } end
            return { fg = "#ffff00", bold = true }
          end,
        },
        {
          condition = function(self)
            return self.is_readonly
          end,
          provider = " [RO]",
          hl = function(self)
            if _G._active_statusline_menu == "file" or self._pressed then return { fg = "#ff5555", bold = true } end
            return { fg = "#ff5555", bold = true }
          end,
        },
        {
          condition = function(self)
            return self.is_new
          end,
          provider = " [New]",
          hl = function(self)
            if _G._active_statusline_menu == "file" or self._pressed then return { fg = "#50fa7b", bold = true } end
            return { fg = "#50fa7b", bold = true }
          end,
        },
      }

      local LspName = {
        init = function(self)
          local winid = get_active_editor_win()
          local bufnr = vim.api.nvim_win_get_buf(winid)
          local clients = vim.lsp.get_clients({ bufnr = bufnr })
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
            open_statusline_menu("lsp", {
              {
                icon = "󰒋",
                label = "LSP Information (:LspInfo)",
                action = function()
                  vim.cmd("LspInfo")
                end,
              },
              {
                icon = "󰏓",
                label = "Package Manager (:Mason)",
                action = function()
                  vim.cmd("Mason")
                end,
              },
              {
                icon = "󰘦",
                label = "Document Symbols (<leader>cs)",
                action = function()
                  vim.cmd("AerialToggle!")
                end,
              },
              { separator = true },
              {
                icon = "󰌵",
                label = "Code Actions (<leader>ca)",
                action = function()
                  pcall(vim.lsp.buf.code_action)
                end,
              },
              {
                icon = "󰉿",
                label = "Format Buffer (<leader>F)",
                action = function()
                  pcall(function()
                    require("conform").format({ async = true, lsp_fallback = true })
                  end)
                end,
              },
              {
                icon = "󰑓",
                label = "Restart LSP Server (:LspRestart)",
                action = function()
                  vim.cmd("LspRestart")
                end,
              },
            }, "heirline_lsp_menu")
          end,
          name = "heirline_lsp_menu",
        },
        hl = function(self)
          if _G._active_statusline_menu == "lsp" then
            return "Pmenu"
          end
          if self._pressed then
            return { bg = "#0064c8" }
          end
        end,
        {
          provider = "󰒋 ",
          hl = function(self)
            if _G._active_statusline_menu == "lsp" or self._pressed then return { fg = "#ffffff" } end
            return { fg = self.active and "#50fa7b" or "#7f7f7f" }
          end,
        },
        {
          provider = function(self)
            return self.lsp_name
          end,
          hl = function(self)
            if _G._active_statusline_menu == "lsp" or self._pressed then return { fg = "#ffffff", bold = true } end
            return { fg = self.active and "#50fa7b" or "#7f7f7f", bold = self.active }
          end,
        },
      }

      local Encoding = {
        on_click = {
          callback = function(self, _, _, button)
            if button ~= "l" then return end
            trigger_press(self)
            open_statusline_menu("encoding", {
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
            }, "heirline_encoding_menu")
          end,
          name = "heirline_encoding_menu",
        },
        hl = function(self)
          if _G._active_statusline_menu == "encoding" then
            return "Pmenu"
          end
          if self._pressed then
            return { bg = "#0064c8" }
          end
        end,
        {
          provider = "󰉿 ",
          hl = function(self)
            if _G._active_statusline_menu == "encoding" or self._pressed then return { fg = "#ffffff" } end
            return { fg = "#8be9fd" }
          end,
        },
        {
          provider = function()
            local winid = get_active_editor_win()
            local bufnr = vim.api.nvim_win_get_buf(winid)
            local enc = vim.bo[bufnr].fileencoding ~= "" and vim.bo[bufnr].fileencoding or vim.o.encoding
            local fmt = vim.bo[bufnr].fileformat == "dos" and " [CRLF]" or (vim.bo[bufnr].fileformat == "mac" and " [CR]" or "")
            return string.upper(enc) .. fmt
          end,
          hl = function(self)
            if _G._active_statusline_menu == "encoding" or self._pressed then return { fg = "#ffffff", bold = true } end
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
            open_statusline_menu("nav", {
              {
                icon = "󰎤",
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
                icon = "󰜲",
                label = "Jump to Top of File (gg)",
                action = function()
                  vim.cmd("normal! gg")
                end,
              },
              {
                icon = "󰜮",
                label = "Jump to Bottom of File (G)",
                action = function()
                  vim.cmd("normal! G")
                end,
              },
              {
                icon = "󰆤",
                label = "Center Screen on Cursor (zz)",
                action = function()
                  vim.cmd("normal! zz")
                end,
              },
            }, "heirline_nav_menu")
          end,
          name = "heirline_nav_menu",
        },
        hl = function(self)
          if _G._active_statusline_menu == "nav" then
            return "Pmenu"
          end
          if self._pressed then
            return { bg = "#0064c8" }
          end
        end,
        {
          provider = "󰦨 ",
          hl = function(self)
            if _G._active_statusline_menu == "nav" or self._pressed then return { fg = "#ffffff" } end
            return { fg = "#bd93f9" }
          end,
        },
        {
          provider = function()
            local winid = get_active_editor_win()
            local bufnr = vim.api.nvim_win_get_buf(winid)
            local total = vim.api.nvim_buf_line_count(bufnr)
            if total <= 1 then
              return "0%"
            end
            local current = vim.api.nvim_win_get_cursor(winid)[1]
            local remain = math.floor(((total - current) / total) * 100 + 0.5)
            return remain .. "%"
          end,
          hl = function(self)
            if _G._active_statusline_menu == "nav" or self._pressed then return { fg = "#ffffff", bold = true } end
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
          on_click = {
            callback = function()
              vim.schedule(function()
                pcall(vim.cmd, "ContextlineMenu")
              end)
            end,
            name = "contextline_menu",
          },
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
            -- Heirline can keep the winbar row allocated even when the
            -- context component's condition returns false.  Disable the
            -- entire winbar when there is no actual context to display.
            local ok, cl = pcall(require, "contextline")
            if not ok or cl.get_info({ bufnr = buf, winid = args.win or 0 }) == nil then
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

      -- Heirline's built-in winbar setup listens to FileType, but a window
      -- can retain the previous buffer's local winbar across BufEnter. Keep
      -- the context winbar synchronized when switching between buffers.
      local heirline_winbar = "%{%v:lua.require'heirline'.eval_winbar()%}"
      vim.api.nvim_create_autocmd({ "BufEnter", "WinEnter" }, {
        group = vim.api.nvim_create_augroup("HeirlineContextWinbarSync", { clear = true }),
        callback = function(args)
          local win = vim.api.nvim_get_current_win()
          local buf = args.buf or vim.api.nvim_win_get_buf(win)
          local ft = vim.bo[buf].filetype
          local bt = vim.bo[buf].buftype
          local hidden = {
            ["neo-tree"] = true, ["NvimTree"] = true, ["aerial"] = true,
            ["help"] = true, ["lazy"] = true, ["mason"] = true,
            ["Trouble"] = true, ["snacks_layout_box"] = true, ["qf"] = true,
            ["csv"] = true, ["tsv"] = true, ["text"] = true, ["txt"] = true,
            ["plaintex"] = true, ["log"] = true, ["gitcommit"] = true,
            ["gitrebase"] = true, ["diff"] = true, ["checkhealth"] = true,
            ["man"] = true,
          }
          local ok, cl = pcall(require, "contextline")
          local has_context = bt == "" and ft ~= "" and not hidden[ft]
            and ok and cl.get_info({ bufnr = buf, winid = win }) ~= nil
          local current = vim.wo[win].winbar
          if has_context then
            if current == nil or current == "" or current == heirline_winbar then
              vim.wo[win].winbar = heirline_winbar
            end
          elseif current == heirline_winbar then
            vim.wo[win].winbar = ""
          end
        end,
        desc = "Sync context winbar when changing buffers",
      })

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
