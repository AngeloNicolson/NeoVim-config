-- ~/.config/nvim/lua/angelo/floating_style.lua

local M = {}

function M.style_floating_window()
	local win_config = {
		relative = "cursor",
		row = 1,
		col = 1,
		width = 40,
		height = 10,
		style = "minimal",
		border = "single",
		focusable = false,
		anchor = "NE",
	}

	local opts = {
		title = "Gen Output",
	}

	require("gen").open_win_config(win_config, opts)

	-- Use autocmd to apply styling after the window is opened
	vim.cmd([[autocmd WinEnter * ++once lua require('angelo.floating_style').apply_custom_styling()]])
end

function M.apply_custom_styling()
	-- Adjust highlighting or other styling options here
	vim.cmd([[highlight! link GenOutput NormalNC]])
end

return M
