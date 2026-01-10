local function read_gemini_env()
  local api_key = os.getenv("GEMINI_API_KEY")
  local model = os.getenv("GEMINI_MODEL") or "gemini-1.5-flash" -- 默认值

  -- 尝试从 .env 文件读取配置 (如果没有在环境变量中设置)
  if not api_key or not os.getenv("GEMINI_MODEL") then
    local env_file = vim.fn.expand("~/.dotfiles/plugins/avante/.env")
    local file = io.open(env_file, "r")
    if file then
      for line in file:lines() do
        -- 读取 API Key
        if not api_key and line:match("^GEMINI_API_KEY") then
          local key = line:match("GEMINI_API_KEY%s*=%s*(.+)")
          if key then api_key = key:gsub("^['\"]", ""):gsub("['\"]$", "") end
        end
        -- 读取 Model
        if line:match("^GEMINI_MODEL") then
          local m = line:match("GEMINI_MODEL%s*=%s*(.+)")
          if m then model = m:gsub("^['\"]", ""):gsub("['\"]$", "") end
        end
      end
      file:close()
    end
  end

  return api_key, model
end

return {
  -- 1. 确保 dressing.nvim 独立安装并立即加载
  {
    "stevearc/dressing.nvim",
    lazy = false,
    opts = {
      input = { enabled = true },
      select = { enabled = true },
    },
  },

  -- 2. Avante.nvim 配置
  {
    "yetone/avante.nvim",
    event = "VeryLazy",
    lazy = false,
    version = false, 
    build = "make",
    enabled = function()
      local api_key = read_gemini_env()
      return api_key ~= nil and api_key ~= ""
    end,
    dependencies = {
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      "nvim-tree/nvim-web-devicons",
      "nvim-telescope/telescope.nvim",
    },
    opts = function()
      -- 初始化变量
      local api_key, model = read_gemini_env()

      -- 注入环境变量
      if api_key then vim.env.GEMINI_API_KEY = api_key end
      -- 也可以注入 Model 变量，方便调试，虽然后面是直接使用的 local 变量
      if model then vim.env.GEMINI_MODEL = model end

      return {
        provider = "gemini",
        providers = {
          gemini = {
            model = model, -- 使用动态读取的模型
            max_tokens = 4096,
            temperature = 0.7,
          },
        },
        behaviour = {
          auto_suggestions = false,
          auto_set_highlight_group = true,
          auto_set_keymaps = true,
          auto_apply_diff_after_generation = false,
          support_paste_from_clipboard = false,
        },
      }
    end,
    -- 强制切换 Provider 的 Hack
    init = function()
      vim.api.nvim_create_autocmd("VimEnter", {
        callback = function()
          if vim.fn.exists(":AvanteSwitchProvider") == 2 then
            vim.cmd("AvanteSwitchProvider gemini")
          end
        end,
      })
    end,
    keys = {
      { "<leader>aa", "<cmd>AvanteAsk<cr>", desc = "Avante: Ask" },
      { "<leader>ac", "<cmd>AvanteChat<cr>", desc = "Avante: Chat" },
      { "<leader>ar", "<cmd>AvanteReview<cr>", desc = "Avante: Review" },
      { "<leader>af", "<cmd>AvanteFix<cr>", desc = "Avante: Fix" },
    },
    config = function(_, opts)
      require("avante").setup(opts)
    end,
  },
}
