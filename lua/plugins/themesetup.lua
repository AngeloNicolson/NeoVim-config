return {
	-- Gruvbox themes
	"sainnhe/gruvbox-material",

	-- Vim-Tmux Navigator
	"christoomey/vim-tmux-navigator",

	-- Configuration for termguicolors and Gruvbox Material options
	config = function()
		-- Enable termguicolors for true color support
		vim.o.termguicolors = true

		-- Gruvbox Material settings
		vim.g.gruvbox_material_background = "hard" -- Contrast: hard, medium, soft
		vim.g.gruvbox_material_foreground = "original" -- Original bright colors
		vim.gruvbox_material_transparent_background = 0 -- Disable transparent background

		-- Enable bold and italics
		vim.cmd("highlight Comment cterm=bold gui=bold")
		vim.cmd("highlight Function cterm=italic gui=italic")

		-- Load Gruvbox Material color scheme
		vim.cmd("colorscheme gruvbox-material")

		-- Function to apply the color settings
		ColorMyPencils()
	end,
}
