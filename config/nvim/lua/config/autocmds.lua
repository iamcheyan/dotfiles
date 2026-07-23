-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- Keep LazyVim default startup behavior:
-- restore session when available; otherwise show dashboard.

local function set_cmdline_highlights()
  local bg = "#2a2a2a"
  local fg = "#d6d6d6"

  vim.api.nvim_set_hl(0, "MsgArea", { bg = bg, fg = fg })
  vim.api.nvim_set_hl(0, "Cmdline", { bg = bg, fg = fg })
  vim.api.nvim_set_hl(0, "CmdLine", { bg = bg, fg = fg })
  vim.api.nvim_set_hl(0, "CmdLinePrompt", { bg = bg, fg = "#f0f0f0", bold = true })
  vim.api.nvim_set_hl(0, "WinSeparator", { fg = bg, bg = "NONE" })
  vim.api.nvim_set_hl(0, "VertSplit", { fg = bg, bg = "NONE" })
end

-- gitsigns line highlight 颜色配置
local function set_gitsigns_highlights()
  -- 整行背景高亮（linehl = true 时使用）
  vim.api.nvim_set_hl(0, "GitSignsAddLn", { bg = "#1a3a1a" })          -- 新增行：深绿色背景
  vim.api.nvim_set_hl(0, "GitSignsChangeLn", { bg = "#3a3a1a" })       -- 修改行：深黄色背景
  vim.api.nvim_set_hl(0, "GitSignsDeleteLn", { bg = "#3a1a1a" })       -- 删除行：深红色背景
  vim.api.nvim_set_hl(0, "GitSignsChangedeleteLn", { bg = "#3a2a1a" }) -- 修改+删除：深橙色背景
  vim.api.nvim_set_hl(0, "GitSignsTopdeleteLn", { bg = "#3a1a1a" })    -- 顶部删除：深红色背景
  vim.api.nvim_set_hl(0, "GitSignsUntrackedLn", { bg = "#1a3a3a" })    -- 未跟踪：深青色背景

  -- sign 列符号颜色
  vim.api.nvim_set_hl(0, "GitSignsAdd", { fg = "#00ff00", bold = true })
  vim.api.nvim_set_hl(0, "GitSignsChange", { fg = "#ffff00", bold = true })
  vim.api.nvim_set_hl(0, "GitSignsDelete", { fg = "#ff0000", bold = true })
  vim.api.nvim_set_hl(0, "GitSignsChangedelete", { fg = "#ff8800", bold = true })
  vim.api.nvim_set_hl(0, "GitSignsTopdelete", { fg = "#ff0000", bold = true })
  vim.api.nvim_set_hl(0, "GitSignsUntracked", { fg = "#00ffff", bold = true })
end

vim.api.nvim_create_autocmd("ColorScheme", {
  callback = function()
    set_cmdline_highlights()
    set_gitsigns_highlights()
  end,
})

set_cmdline_highlights()
set_gitsigns_highlights()

-- Linux で dos2unix がインストールされている場合、保存時に dos2unix を実行
if vim.fn.has("linux") == 1 and vim.fn.executable("dos2unix") == 1 then
  vim.api.nvim_create_autocmd("BufWritePost", {
    pattern = "*",
    callback = function()
      local file = vim.fn.expand("%:p")
      if file ~= "" then
        vim.fn.system({ "dos2unix", file })
      end
    end,
  })
end
