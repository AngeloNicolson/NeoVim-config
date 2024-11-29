require("config.settings")
require("config.remaps")
require("config.lazy")
-- vim.nnoremap <silent> <leader>c} V}:call nerdcommenter#Comment('x', 'toggle')<CR>
-- vim.nnoremap <silent> <leader>c{ V{:call nerdcommenter#Comment('x', 'toggle')<CR>

-- This function tries to detect react code (html tags) in javascript files
-- it will then set the file to either javascript or javascriptreact for formatting.
--_G.detectReact = function()
--	local file_extension = vim.fn.expand("%:e")
--	if file_extension == "js" and vim.fn.search("<[A-Z]", "W") > 0 then
--		vim.bo.filetype = "javascriptreact"
--	else
--		vim.bo.filetype = "javascript"
--	end
--end

--vim.cmd([[
--  augroup SelectiveFiletype
--    autocmd!
--    autocmd BufNewFile,BufRead *.js lua detectReact()
--  augroup END
--]])
