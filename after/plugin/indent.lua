vim.opt.termguicolors = true
vim.cmd [[highlight IndentBlanklineIndent1 guifg=#307700 gui=nocombine]]

vim.opt.list = true
-- vim.opt.listchars:append "space:⋅"
vim.opt.listchars:append "eol:↴"

require("indent_blankline").setup {
    show_end_of_line = true,
--    show_current_context = true,
    show_current_context_start = true,
 --   space_char_blankline = " ",
    char_highlight_list = {
        "IndentBlanklineIndent1",
    },
}
