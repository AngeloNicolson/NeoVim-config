local M = {}

--------------------------------------------------------------------------------
----------------------------- WINDOW CREATION ----------------------------------
--------------------------------------------------------------------------------
function M.get_window_options()
	local width = 80 -- Set a fixed width (you can adjust this value)
	local height = 27 -- Set a fixed height (you can adjust this value)
	local row = math.floor((vim.o.lines - height) / 2)
	local col = math.floor((vim.o.columns - width) / 2)

	local cursor = vim.api.nvim_win_get_cursor(0)
	local new_win_width = vim.api.nvim_win_get_width(0)
	local win_height = vim.api.nvim_win_get_height(0)

	local middle_row = win_height / 2

	local new_win_height = math.floor(win_height / 2)
	local new_win_row
	if cursor[1] <= middle_row then
		new_win_row = 5
	else
		new_win_row = -5 - new_win_height
	end

	return {
		relative = "cursor",
		width = width,
		height = height,
		row = new_win_row,
		col = 0,
		style = "minimal",
		border = "single",
	}
end

-- Function to create a window based on the display mode
function M.create_window(opts)
	-- Delete existing buffer if it exists
	if opts.result_buffer and vim.api.nvim_buf_is_valid(opts.result_buffer) then
		vim.api.nvim_buf_delete(opts.result_buffer, { force = true })
	end

	-- Create a new buffer for the result with filetype set to markdown
	opts.result_buffer = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_option(opts.result_buffer, "filetype", "markdown")

	-- Delete existing window if it exists
	if opts.float_win and vim.api.nvim_win_is_valid(opts.float_win) then
		vim.api.nvim_win_close(opts.float_win, true)
	end

	-- Get window options and extend them with user-provided options
	local win_opts = vim.tbl_deep_extend("force", M.get_window_options(), opts.win_config)

	-- Open a new window with the result buffer
	opts.float_win = vim.api.nvim_open_win(opts.result_buffer, true, win_opts)

	-- Set options for the result buffer
	vim.api.nvim_buf_set_option(opts.result_buffer, "filetype", "markdown")
	vim.api.nvim_win_set_option(opts.float_win, "wrap", true)
	vim.api.nvim_win_set_option(opts.float_win, "linebreak", true)
	-- Return the buffer and window IDs
	return opts.result_buffer, opts.float_win
end
return M
