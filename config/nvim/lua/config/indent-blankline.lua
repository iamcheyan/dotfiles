local is_ok, indent_blankline = pcall(require, "ibl")
if not is_ok then
	return
end

indent_blankline.setup()
