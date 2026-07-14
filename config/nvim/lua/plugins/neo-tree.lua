local function project_root()
  local buf = vim.api.nvim_get_current_buf()
  local clients = vim.lsp.get_clients({ bufnr = buf })
  for _, c in ipairs(clients) do
    if c.config.root_dir then
      return c.config.root_dir
    end
  end
  return vim.fs.root(buf, { ".git", "lua" }) or vim.uv.cwd()
end

return {
  -- 配置 neo-tree
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    cmd = "Neotree",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
    },
    keys = {
      {
        "<leader>fe",
        function()
          require("neo-tree.command").execute({ toggle = true, dir = project_root() })
        end,
        desc = "Explorer NeoTree (Root Dir)",
      },
      {
        "<leader>fE",
        function()
          require("neo-tree.command").execute({ toggle = true, dir = vim.uv.cwd() })
        end,
        desc = "Explorer NeoTree (cwd)",
      },
      { "<leader>e", "<leader>fE", desc = "Explorer NeoTree (cwd)", remap = true },
      {
        "<leader>ge",
        function()
          require("neo-tree.command").execute({ source = "git_status", toggle = true })
        end,
        desc = "Git Explorer",
      },
      {
        "<leader>be",
        function()
          require("neo-tree.command").execute({ source = "buffers", toggle = true })
        end,
        desc = "Buffer Explorer",
      },
    },
    deactivate = function()
      vim.cmd([[Neotree close]])
    end,
    opts = {
      sources = { "filesystem", "buffers", "git_status" },
      open_files_do_not_replace_types = { "terminal", "Trouble", "trouble", "qf", "Outline" },
      -- 全局默认缩进配置（用于 filesystem）
      default_component_configs = {
        indent = {
          indent_size = 2,
          padding = 0,
          with_markers = true,
          indent_marker = "│",
          last_indent_marker = "└",
          highlight = "NeoTreeIndentMarker",
          with_expanders = true,
          expander_collapsed = "",
          expander_expanded = "",
          expander_highlight = "NeoTreeExpander",
        },
        git_status = {
          symbols = {
            unstaged = "",
            staged = "",
          },
        },
      },
      filesystem = {
        bind_to_cwd = false,
        follow_current_file = { enabled = true },
        use_libuv_file_watcher = true,
      },
      git_status = {
        window = {
          position = "left",
          width = 30,
          mappings = {
            ["A"] = "git_add_all",
            ["gu"] = "git_unstage_file",
            ["ga"] = "git_add_file",
            ["gr"] = "git_revert_file",
            ["gc"] = "git_commit",
            ["gp"] = "git_push",
            ["gg"] = "git_commit_and_push",
          },
        },
        -- 使用自定义渲染器，覆盖缩进配置
        renderers = {
          root = {
            { "text", { "  ", highlight = "NeoTreeRootName" } },
            { "name", zindex = 10 },
          },
          directory = {
            { "indent", with_markers = false, indent_size = 0 },
            { "icon" },
            { "current_filter" },
            { "name" },
            { "symlink_target" },
          },
          file = {
            { "indent", with_markers = false, indent_size = 0 },
            { "icon" },
            { "name", use_git_status_colors = true },
            { "symlink_target" },
          },
        },
      },
      buffers = {
        window = {
          position = "left",
          width = 28,
        },
        -- 使用自定义渲染器，覆盖缩进配置
        renderers = {
          root = {
            { "text", { "  ", highlight = "NeoTreeRootName" } },
            { "name", zindex = 10 },
          },
          directory = {
            { "indent", with_markers = false, indent_size = 0 },
            { "icon" },
            { "name" },
          },
          file = {
            { "indent", with_markers = false, indent_size = 0 },
            { "icon" },
            { "name", use_git_status_colors = true },
          },
        },
      },
      window = {
        position = "left",
        width = 28,
        mappings = {
          ["l"] = "open",
          ["h"] = "close_node",
          ["<space>"] = "none",
        },
      },
    },
  },
}
