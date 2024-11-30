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
	{
		"folke/which-key.nvim",
		event = "VeryLazy",
		opts = {
			-- your configuration comes here
			-- or leave it empty to use the default settings
			-- refer to the configuration section below
		},
		keys = {
			{
				"<leader>k",
				function()
					require("which-key").show({ global = false })
				end,
				desc = "Buffer Local Keymaps (which-key)",
			},
		},
	},
}
