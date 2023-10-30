vim.opt.termguicolors = true
vim.cmd([[highlight IndentBlanklineIndent1 guifg=#307700 gui=nocombine]])

vim.opt.list = true
-- vim.opt.listchars:append "space:⋅"
vim.opt.listchars:append("eol:↴")

require("ibl").setup({ indent = { highlight = highlight } })
