return {
  {
    "rmagatti/auto-session",
    enabled = true,
    lazy = false,

    ---enables autocomplete for opts
    ---@module "auto-session"
    ---@type AutoSession.Config
    opts = {
      -- 自动保存和恢复
      enabled = true,
      auto_save = true,
      auto_restore = true,
      auto_create = true,
      auto_restore_last_session = false,

      -- 不自动保存的目录
      suppressed_dirs = { "/", "~/.cache/*" },

      -- 忽略 dashboard 等文件类型
      bypass_save_filetypes = { "alpha", "dashboard", "snacks_dashboard" },

      -- Git 支持
      git_use_branch_name = false,
      git_auto_restore_on_branch_change = false,

      -- 关闭不支持自动保存的窗口（但保留 neo-tree 和 aerial 免于提前被杀）
      close_unsupported_windows = {
        preserve_filetypes = { "neo-tree", "aerial" },
      },

      -- 空会话自动删除
      auto_delete_empty_sessions = true,

      -- session_lens 配置（会话选择器）
      session_lens = {
        picker = nil, -- 自动检测 telescope/snacks/fzf
        load_on_setup = true,
        shorten_paths = true,
        mappings = {
          delete_session = { "i", "<C-d>" },
          alternate_session = { "i", "<C-s>" },
          copy_session = { "i", "<C-y>" },
        },
      },

      -- 日志级别
      log_level = "error",

      -- 记忆侧边栏（Neo-tree 文件树、Aerial 代码结构）开启状态
      save_extra_data = function(session_name)
        local state = {}

        -- 检查 Neo-tree 是否打开
        for _, win in ipairs(vim.api.nvim_list_wins()) do
          if vim.api.nvim_win_is_valid(win) then
            local buf = vim.api.nvim_win_get_buf(win)
            if vim.bo[buf].filetype == "neo-tree" then
              state.neotree = vim.b[buf].neo_tree_source or "filesystem"
              break
            end
          end
        end

        -- 检查 Aerial（代码结构大纲）是否打开
        local aerial_ok, aerial = pcall(require, "aerial")
        if aerial_ok and type(aerial.is_open) == "function" and aerial.is_open() then
          state.aerial = true
        end

        if next(state) then
          return vim.json.encode(state)
        end
        return nil
      end,

      restore_extra_data = function(session_name, extra_data)
        if not extra_data or extra_data == "" then
          return
        end
        local ok, state = pcall(vim.json.decode, extra_data)
        if not ok or type(state) ~= "table" then
          return
        end

        vim.schedule(function()
          -- 恢复 Neo-tree
          if state.neotree then
            vim.defer_fn(function()
              pcall(function()
                require("neo-tree.command").execute({
                  source = state.neotree,
                  action = "show",
                })
              end)
            end, 50)
          end

          -- 恢复 Aerial 代码结构
          if state.aerial then
            vim.defer_fn(function()
              pcall(function()
                require("aerial").open()
              end)
            end, 100)
          end
        end)
      end,
    },
    config = function(_, opts)
      require("auto-session").setup(opts)

      -- 独立兜底：即使启动时不走 auto-session，也按工作目录（CWD）自动持久化和恢复侧边栏状态
      local state_dir = vim.fn.stdpath("data") .. "/sidebar_state/"
      pcall(vim.fn.mkdir, state_dir, "p")

      local function get_state_file()
        local cwd = vim.uv.cwd() or vim.fn.getcwd()
        local hash = vim.fn.sha256(cwd)
        return state_dir .. hash .. ".json"
      end

      -- 退出前保存侧边栏状态
      vim.api.nvim_create_autocmd("VimLeavePre", {
        group = vim.api.nvim_create_augroup("persist_sidebars_state", { clear = true }),
        callback = function()
          local state = { neotree = nil, aerial = false }
          for _, win in ipairs(vim.api.nvim_list_wins()) do
            if vim.api.nvim_win_is_valid(win) then
              local buf = vim.api.nvim_win_get_buf(win)
              local ft = vim.bo[buf].filetype
              if ft == "neo-tree" then
                state.neotree = vim.b[buf].neo_tree_source or "filesystem"
              elseif ft == "aerial" then
                state.aerial = true
              end
            end
          end

          pcall(vim.fn.writefile, { vim.json.encode(state) }, get_state_file())
        end,
      })

      -- 启动后延迟恢复侧边栏状态
      vim.api.nvim_create_autocmd("VimEnter", {
        group = vim.api.nvim_create_augroup("restore_sidebars_state", { clear = true }),
        callback = function()
          local s_file = get_state_file()
          if vim.fn.filereadable(s_file) == 1 then
            local lines = vim.fn.readfile(s_file)
            if lines and #lines > 0 then
              local ok, state = pcall(vim.json.decode, lines[1])
              if ok and type(state) == "table" then
                vim.schedule(function()
                  vim.defer_fn(function()
                    if state.neotree then
                      pcall(function()
                        require("neo-tree.command").execute({
                          source = state.neotree,
                          action = "show",
                        })
                      end)
                    end
                    if state.aerial then
                      pcall(function()
                        vim.cmd("AerialOpen")
                      end)
                    end
                  end, 100)
                end)
              end
            end
          end
        end,
      })
    end,

    -- 推荐设置 sessionoptions
    init = function()
      vim.o.sessionoptions = "blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions"
    end,

    -- 快捷键
    keys = {
      { "<leader>wr", "<cmd>AutoSession search<CR>", desc = "Session search" },
      { "<leader>ws", "<cmd>AutoSession save<CR>", desc = "Save session" },
      { "<leader>wa", "<cmd>AutoSession toggle<CR>", desc = "Toggle autosave" },
      { "<leader>wd", "<cmd>AutoSession delete<CR>", desc = "Delete session" },
    },
  },
}
