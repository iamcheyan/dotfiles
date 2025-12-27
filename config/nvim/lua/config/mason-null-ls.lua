local mason_ok, mason = pcall(require, "mason")
if not mason_ok then
	return
end

mason.setup()

local null_ls_ok, null_ls = pcall(require, "null-ls")
if not null_ls_ok then
	return
end

local sources = {
	null_ls.builtins.formatting.black.with({ extra_args = { "--target-version", "py310" } }),
	null_ls.builtins.formatting.stylua,
}

null_ls.setup({
	debug = false,
	log_level = "warn",
	update_in_insert = false,
	sources = sources,
})

local mason_null_ls_ok, mason_null_ls = pcall(require, "mason-null-ls")
if not mason_null_ls_ok then
	return
end

mason_null_ls.setup({
	-- A list of sources to install if they're not already installed.
	-- This setting has no relation with the `automatic_installation` setting.
	ensure_installed = {
		"black",
		"stylua",
	},
	automatic_installation = false,
	-- Sources found installed in mason will automatically be setup for null-ls.
	automatic_setup = true,
	handlers = {},
})
