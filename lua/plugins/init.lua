return {

	-- Prettier Formatting
	{
		"nvimtools/none-ls.nvim",
		config = function()
			require("null-ls").setup()
		end,
		dependencies = { "nvim-lua/plenary.nvim" },
	},

	-- Obsidian
	{
		"epwalsh/obsidian.nvim",
		tag = "*",
		dependencies = {
			"nvim-lua/plenary.nvim",
		},
	},

	-- Markdown Preview
	{
		"iamcco/markdown-preview.nvim",
		build = "cd app && npm install",
		setup = function()
			vim.g.mkdp_filetypes = { "markdown" }
		end,
		ft = { "markdown" },
	},

	-- File Browser
	{
		"nvim-telescope/telescope-file-browser.nvim",
		dependencies = { "nvim-telescope/telescope.nvim", "nvim-lua/plenary.nvim" },
	},
}
