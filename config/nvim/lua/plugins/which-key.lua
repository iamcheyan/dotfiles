return {
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts_extend = { "spec" },
    opts = {
      preset = "helix",
      show_keys = false,
      win = {
        border = "single",
        title = false,
      },
      icons = {
        breadcrumb = "»",
        group = "",
        keys = {
          Space = "SPC ",
        },
      },
      defaults = {},
      spec = {
        {
          mode = { "n", "x" },
          { "<leader>", group = "Leader" },
          { "<leader><tab>", group = "tabs" },
          { "<leader>c", group = "code" },
          { "<leader>d", group = "debug" },
          { "<leader>dp", group = "profiler" },
          { "<leader>f", group = "file/find" },
          { "<leader>g", group = "git" },
          { "<leader>gh", group = "hunks" },
          { "<leader>q", group = "quit/session" },
          { "<leader>m", group = "bookmarks" },
          { "<leader>s", group = "search" },
          { "<leader>u", group = "ui" },
          { "<leader>x", group = "diagnostics/quickfix" },
          -- { "[", group = "prev" },
          -- { "]", group = "next" },
          { "g", group = "goto" },
          { "gs", group = "surround" },
          { "z", group = "fold" },
          {
            "<leader>b",
            group = "buffer",
            expand = function()
              return require("which-key.extras").expand.buf()
            end,
          },
          {
            "<leader>w",
            group = "windows",
            proxy = "<c-w>",
            expand = function()
              return require("which-key.extras").expand.win()
            end,
          },
          { "<c-w>", group = "windows" },
          { "gx", desc = "Open with system app" },
        },
      },
    },
    keys = {
      {
        "<leader>?",
        function()
          require("which-key").show({ global = false })
        end,
        desc = "Buffer Keymaps (which-key)",
      },
      {
        "<c-w><space>",
        function()
          require("which-key").show({ keys = "<c-w>", loop = true })
        end,
        desc = "Window Hydra Mode (which-key)",
      },
    },
    config = function(_, opts)
      vim.api.nvim_set_hl(0, "WhichKeyTitle", { default = true, fg = "#eed49f", bold = true, bg = "NONE" })
      local wk = require("which-key")
      wk.setup(opts)
      if not vim.tbl_isempty(opts.defaults) then
        wk.register(opts.defaults)
      end

      local View = require("which-key.view")
      local State = require("which-key.state")
      local orig_show = View.show
      View.show = function()
        orig_show()
        if View.view and View.view.win and vim.api.nvim_win_is_valid(View.view.win) then
          local vcfg = vim.api.nvim_win_get_config(View.view.win)
          vcfg.height = vcfg.height + 1
          vcfg.row = vcfg.row - 1
          vim.api.nvim_win_set_config(View.view.win, vcfg)

          local cur_winhl = vim.wo[View.view.win].winhighlight
          if not cur_winhl:find("WinBar:") then
            vim.wo[View.view.win].winhighlight = (cur_winhl ~= "" and (cur_winhl .. ",") or "")
              .. "WinBar:NormalFloat,WinBarNC:NormalFloat"
          end

          local node = State.state and State.state.node
          local trail = View.trail(node)
          local title_parts = {}
          if trail then
            for _, seg in ipairs(trail) do
              local t = seg[1]:gsub("^%s+", ""):gsub("%s+$", "")
              if t ~= "" then
                table.insert(title_parts, t)
              end
            end
          end
          local title_str = table.concat(title_parts, " ")
          if title_str == "" then
            title_str = "Leader"
          end
          vim.wo[View.view.win].winbar = "%#WhichKeyTitle#%=" .. title_str .. "%="

          if View.footer and View.footer.win and vim.api.nvim_win_is_valid(View.footer.win) then
            local fcfg = vim.api.nvim_win_get_config(View.footer.win)
            fcfg.row = vcfg.height - 2
            vim.api.nvim_win_set_config(View.footer.win, fcfg)
          end
          vim.cmd("redraw")
        end
      end
    end,
  },
}
