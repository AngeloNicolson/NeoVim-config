local builtin = require("telescope.builtin")

-- Set up Telescope with your key mappings
vim.keymap.set("n", "<leader>pf", builtin.find_files, {})
vim.keymap.set("n", "<c-p>", builtin.git_files, {})
vim.keymap.set("n", "<leader>ps", function()
	builtin.grep_string({ search = vim.fn.input("Grep > ") })
end)

-- Import and set up the Telescope plugin
local telescope = require("telescope")
local themes = require("telescope.themes")

telescope.setup({
	extensions = {
		["ui-select"] = {
			require("telescope.themes").get_dropdown({}),
		},
	},
	floating = {
		border = {},
	},
})

telescope.load_extension("ui-select")
