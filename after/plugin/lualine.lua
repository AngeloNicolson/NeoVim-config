local status_ok_lualine, lualine = pcall(require, "lualine")

if not status_ok_lualine then
	return
end

-- Option 1:
-- local noirbuddy_lualine = require("noirbuddy.plugins.lualine")

-- local theme = noirbuddy_lualine.theme
-- optional, you can define those yourself if you need
-- local sections = noirbuddy_lualine.sections
-- local inactive_sections = noirbuddy_lualine.inactive_sections

lualine.setup({
	options = {
		icons_enabled = true,
		theme = "tokyonight",
		filetype = { colored = false },
		component_separators = { left = "", right = "" },
		section_separators = { left = "", right = "" },
		disabled_filetypes = {},
		always_divide_middle = true,
	},
	sections = sections,
	inactive_sections = inactive_sections,
})
