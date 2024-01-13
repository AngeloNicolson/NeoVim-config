-- Enable termguicolors for true color support
if vim.fn.has("termguicolors") == 1 then
	vim.o.termguicolors = true
end

-- Enable transparent background
vim.gruvbox_material_transparent_background = 0

-- Enable bold and italics
vim.cmd("highlight Comment cterm=bold gui=bold")
vim.cmd("highlight Function cterm=italic gui=italic")

-- Set contrast (available values: 'hard', 'medium', 'soft')
vim.g.gruvbox_material_background = "hard"

-- Set gruvbox-material foreground color to 'original' for bright colors
vim.g.gruvbox_material_foreground = "original"

-- Load Gruvbox Material color scheme
vim.cmd("colorscheme gruvbox-material")
