return {
	"lukas-reineke/indent-blankline.nvim",
	main = "ibl",
	opts = {},

	config = function()
		-- Enable true color support
		vim.opt.termguicolors = true
		vim.opt.list = true
		vim.opt.listchars:append("eol:↴")

		-- Custom highlight for indentation lines
		vim.api.nvim_set_hl(0, "IndentBlanklineIndent2", { fg = "#262626" })

		-- Setup indent-blankline plugin
		require("ibl").setup({
			indent = {
				highlight = { "IndentBlanklineIndent2" },
			},
			-- Optional: Exclude specific file types or buffer types
			exclude = {
				filetypes = { "help", "dashboard", "NvimTree", "lazy" },
				buftypes = { "terminal" },
			},
		})
	end,
}
