return {
  {
    "akinsho/bufferline.nvim",
    enabled = vim.env.WDIFF_NVIM ~= "1",
    opts = function()
      -- Neovim's tabline click protocol only resolves global functions.
      _G.__bufferline_new_buffer = function(_, _, button)
        if button == "l" then
          require("config.bar_feedback").press("__bufferline_new_buffer", 0)
          vim.defer_fn(function() vim.cmd("enew") end, 100)
        end
      end

      -- The sidebar's title shows the tree's current root instead of a static
      -- label. neo-tree hides its own root node (`hide_root_node`), so this is
      -- where the path is displayed -- bufferline truncates it to the offset
      -- width when it does not fit.
      local function neo_tree_root_text()
        local ok, manager = pcall(require, "neo-tree.sources.manager")
        if ok then
          for _, win in ipairs(vim.api.nvim_list_wins()) do
            local buf = vim.api.nvim_win_get_buf(win)
            if vim.bo[buf].filetype == "neo-tree" then
              local source = vim.b[buf].neo_tree_source or "filesystem"
              local state = manager.get_state(source)
              if state and state.path and state.path ~= "" then
                return vim.fn.fnamemodify(state.path, ":~")
              end
            end
          end
        end
        return "Neo-tree"
      end

      -- The native PopUp menu is installed by config.context_menu.
      return {
        highlights = require("config.ui_highlights").bufferline_highlights(),
        options = {
          style_preset = nil, -- resolved in config (no_italic preset)
          mode = "buffers",
          diagnostics = false,
          themable = true,
          -- Icons inherit the active/inactive tab text color. Keeping the
          -- filetype glyph while disabling per-filetype icon colors prevents
          -- selected icons from turning white or retaining stale colors.
          color_icons = false,
          show_tab_indicators = false,
          offsets = {
            {
              filetype = "neo-tree",
              text = neo_tree_root_text,
              highlight = "Directory",
              text_align = "left",
              -- Window width excludes the split separator; reserve that cell
              -- so the first tab starts above the editor's winbar.
              padding = 1,
            },
            {
              filetype = "snacks_layout_box",
            },
          },
          -- Remove separator character between tabs for a seamless, compact layout
          separator_style = { "", "" },
          indicator = {
            style = "none",
          },
          show_buffer_close_icons = true,
          show_close_icon = false,
          buffer_padding = 1,
          hover = {
            enabled = true,
            reveal = { "close" },
          },
          enforce_regular_tabs = false,
          buffer_close_icon = "",
          modified_icon = "",
          close_command = "bdelete! %d",
          middle_mouse_command = "bdelete! %d",
          right_mouse_command = function(buffer_id)
            require("config.context_menu").open_buffer(buffer_id)
          end,
          left_mouse_command = "buffer %d",
          custom_areas = {
            right = function()
              return {
                {
                  -- Keep the click marker inside the highlighted plus area.
                  text = "%@v:lua.__bufferline_new_buffer@ + %T",
                  link = "BufferLineNewBuffer",
                },
              }
            end,
          },
        },
      }
    end,
    config = function(_, opts)
      local bufferline = require("bufferline")
      if not (opts.options and opts.options.style_preset) then
        opts.options = opts.options or {}
        opts.options.style_preset = bufferline.style_preset.no_italic
      end
      bufferline.setup(opts)

      -- Guard handle_close against right-clicks: right-click on close icon should
      -- open the context menu instead of closing the buffer.
      local orig_handle_close = _G.___bufferline_private and _G.___bufferline_private.handle_close
      if orig_handle_close then
        _G.___bufferline_private.handle_close = function(id, clicks, button, mod)
          require("config.bar_feedback").press("___bufferline_private.handle_close", id)
          if button == "r" then
            require("config.context_menu").open_buffer(id)
            return
          end
          vim.defer_fn(function()
            if vim.api.nvim_buf_is_valid(id) then orig_handle_close(id, clicks, button, mod) end
          end, 100)
        end
      end

      local original_click = _G.___bufferline_private.handle_click
      _G.___bufferline_private.handle_click = function(id, clicks, button, mods)
        require("config.bar_feedback").press("___bufferline_private.handle_click", id)
        return original_click(id, clicks, button, mods)
      end
      local original_render = _G.nvim_bufferline
      _G.nvim_bufferline = function()
        local line = original_render()
        line = line:gsub("(%%%d+@v:lua%.___bufferline_private%.handle_close@)(.-)(%%X)", "%1 %2 %3")
        return require("config.bar_feedback").paint(line)
      end

      -- bufferline creates its DevIcon groups during setup.
      vim.defer_fn(function()
        require("config.ui_highlights").apply()
      end, 0)
    end,
  },
}
