-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- LazyVimのデフォルトのダッシュボードautocmdを無効化（存在する場合のみ）
local function safe_del_augroup(name)
	local ok, _ = pcall(vim.api.nvim_del_augroup_by_name, name)
	if not ok then
		-- グループが存在しない場合は無視
	end
end

safe_del_augroup("lazyvim_dashboard")

-- 起動時に空白の新規ファイルを開く
vim.api.nvim_create_autocmd("VimEnter", {
	callback = function()
		-- 引数なしで起動した場合、空白の新規ファイルを開く
		if vim.fn.argc() == 0 then
			vim.cmd("enew")
		end
	end,
	once = true,
})
