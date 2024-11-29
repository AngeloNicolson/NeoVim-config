return {
	"sainnhe/gruvbox-material",
	-- Making sure the cholor scheme is loaded first.
	-- Lazy can load this last which is why occationally it would cause indent.lua to error.
	lazy = false,
	priority = 1000,
	config = function()
		-- Load Gruvbox Material color scheme first
		vim.cmd("colorscheme gruvbox-material")

		-- Apply specific highlight settings after the theme is loaded
		vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
		vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
	end,
}
