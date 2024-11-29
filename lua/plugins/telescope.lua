return {
	-- Telescope plugin
	{
		"nvim-telescope/telescope.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim", -- Required dependency
			"nvim-telescope/telescope-ui-select.nvim", -- Add this line
		},
		config = function()
			local builtin = require("telescope.builtin")
			local telescope = require("telescope")

			-- Set up Telescope with your key mappings
			vim.keymap.set("n", "<leader>pf", builtin.find_files, {})
			vim.keymap.set("n", "<c-p>", builtin.git_files, {})
			vim.keymap.set("n", "<leader>ps", function()
				builtin.grep_string({ search = vim.fn.input("Grep > ") })
			end)

			-- Telescope setup with extensions and floating window configuration
			telescope.setup({})
		end,
	},

	-- Optional: Add any other extensions or configurations below as needed.
}
