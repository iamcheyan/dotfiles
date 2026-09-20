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

      -- 关闭不支持自动保存的窗口，防止产生空白幽灵窗口
      close_unsupported_windows = true,

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

      -- 保存会话前：记录侧边栏真实状态，并安全收起侧边栏，防止 mksession 保存损坏的无名空白分屏
      pre_save_cmds = {
        function()
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

          local state_dir = vim.fn.stdpath("data") .. "/sidebar_state/"
          pcall(vim.fn.mkdir, state_dir, "p")
          local cwd = vim.uv.cwd() or vim.fn.getcwd()
          local hash = vim.fn.sha256(cwd)
          pcall(vim.fn.writefile, { vim.json.encode(state) }, state_dir .. hash .. ".json")

          -- 在写入 .vim 会话文件前，先干净地关闭侧边栏，避免生成未初始化的空 buffer 窗口
          if state.neotree then
            pcall(vim.cmd, "Neotree close")
          end
          if state.aerial then
            pcall(vim.cmd, "AerialClose")
          end
        end,
      },
    },
    config = function(_, opts)
      require("auto-session").setup(opts)

      local state_dir = vim.fn.stdpath("data") .. "/sidebar_state/"
      local function get_state_file()
        local cwd = vim.uv.cwd() or vim.fn.getcwd()
        local hash = vim.fn.sha256(cwd)
        return state_dir .. hash .. ".json"
      end

      -- 启动恢复会话后：平滑重新唤醒原有的侧边栏
      local function restore_sidebars()
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
                end, 80)
              end)
            end
          end
        end
      end

      vim.api.nvim_create_autocmd("User", {
        pattern = "AutoSessionRestorePost",
        group = vim.api.nvim_create_augroup("restore_sidebars_post_session", { clear = true }),
        callback = restore_sidebars,
      })

      vim.api.nvim_create_autocmd("VimEnter", {
        group = vim.api.nvim_create_augroup("restore_sidebars_on_vimenter", { clear = true }),
        callback = function()
          vim.defer_fn(restore_sidebars, 120)
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
