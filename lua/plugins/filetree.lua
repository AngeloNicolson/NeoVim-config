	-- Neo-tree
return {
	-- Neo-tree
	{
		"nvim-neo-tree/neo-tree.nvim",
		branch = "v3.x",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-tree/nvim-web-devicons",
			"MunifTanjim/nui.nvim",
		},
		config = function()
			-- Neo-tree setup
			require("neo-tree").setup({
				window = {
					position = "right", -- Set the default position to the right side
					width = 30,        -- Adjust the width of the Neo-tree window
				},
			})

		end,
	},
}

