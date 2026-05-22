-- 完全禁用所有语法检查和诊断提示
return {
	-- 禁用 nvim-lspconfig 的默认诊断配置
	{
		"neovim/nvim-lspconfig",
		opts = {
			diagnostics = {
				enabled = false,
				virtual_text = false,
				signs = false,
				underline = false,
				update_in_insert = false,
				severity_sort = false,
			},
		},
		config = function(_, opts)
			-- 完全禁用 LSP 诊断处理器
			vim.lsp.handlers["textDocument/publishDiagnostics"] = function() end
			vim.lsp.handlers["textDocument/diagnostic"] = function() end

			-- 禁用所有诊断
			vim.diagnostic.config({
				enabled = false,
				virtual_text = false,
				signs = false,
				underline = false,
				update_in_insert = false,
				severity_sort = false,
				float = { enabled = false },
			})
		end,
	},

	-- 确保 LazyVim 的额外诊断也被禁用
	{
		"LazyVim/LazyVim",
		opts = {
			diagnostics = {
				enabled = false,
				virtual_text = false,
				signs = false,
				underline = false,
			},
		},
	},
}
