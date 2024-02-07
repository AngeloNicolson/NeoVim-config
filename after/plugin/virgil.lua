-- ~/.config/nvim/lua/personal_plugins/virgil/init.lua

local virgil = require("personal_plugins.virgil")

-- Define a keybinding to open the window
vim.api.nvim_set_keymap(
	"n",
	"<Leader>]",
	':lua require("personal_plugins.virgil").showWindow()<CR>',
	{ noremap = true, silent = true }
)
