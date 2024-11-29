return {
	-- Status Line
	{

		"nvim-lualine/lualine.nvim",

		dependencies = { "nvim-tree/nvim-web-devicons" },

		config = function()
			local status_ok_lualine, lualine = pcall(require, "lualine")

			if not status_ok_lualine then
				return
			end

			-- Optionally, you can define your sections if needed
			-- local noirbuddy_lualine = require("noirbuddy.plugins.lualine")
			-- local theme = noirbuddy_lualine.theme
			-- local sections = noirbuddy_lualine.sections
			-- local inactive_sections = noirbuddy_lualine.inactive_sections

			lualine.setup({
				options = {
					icons_enabled = true, -- Enable icons
					theme = "gruvbox-material", -- Set theme
					filetype = { colored = false }, -- Disable filetype colored
					component_separators = { left = "", right = "" }, -- Remove component separators
					section_separators = { left = "", right = "" }, -- Remove section separators
					disabled_filetypes = {}, -- No filetypes disabled
					always_divide_middle = true, -- Always divide the middle
				},
				sections = sections, -- Customize sections as needed
				inactive_sections = inactive_sections, -- Customize inactive sections
			})
		end,
	},
}
