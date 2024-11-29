return {
	-- Gruvbox Material theme
	"sainnhe/gruvbox-material",
	lazy = false,
	priority = 1000,

	-- Configuration for termguicolors and Gruvbox Material options
	config = function()
		-- Enable termguicolors for true color support
		vim.o.termguicolors = true

		-- Gruvbox Material settings
		vim.g.gruvbox_material_background = "hard" -- Contrast: hard, medium, soft
		vim.g.gruvbox_material_foreground = "original" -- Use original bright colors
		vim.g.gruvbox_material_transparent_background = 1 -- Enable transparent background
		vim.g.gruvbox_material_dim_inactive_windows = 0 -- Ensure inactive windows are not dimmed
		vim.g.gruvbox_material_show_eob = 0 -- Hide end of buffer filler characters

		-- Load Gruvbox Material color scheme
		vim.cmd("colorscheme gruvbox-material")

		-- Apply specific highlight settings after the theme is loaded
		vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
		vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
		vim.api.nvim_set_hl(0, "EndOfBuffer", { bg = "none" }) -- Ensure EOB filler matches transparency

		-- Enable bold and italics
		vim.cmd("highlight Comment cterm=bold gui=bold")
		vim.cmd("highlight Function cterm=italic gui=italic")
	end,
}
