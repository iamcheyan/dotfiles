-- ~/Dotfiles/config/nvim/lua/plugins/translator-panel.lu

return {
	dir = vim.fn.expand("~/.local/share/nvim/lazy/translator-panel.nvim"),
	name = "translator-panel.nvim",
	config = function()
		require("translator_panel").setup()
	end,
}
