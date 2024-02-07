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
--function M.create_window(opts)
--	-- Delete existing buffer if it exists
--	if opts.result_buffer and vim.api.nvim_buf_is_valid(opts.result_buffer) then
--		vim.api.nvim_buf_delete(opts.result_buffer, { force = true })
--	end
--
--	-- Create a new buffer for the result with filetype set to markdown
--	opts.result_buffer = vim.api.nvim_create_buf(false, true)
--	vim.api.nvim_buf_set_option(opts.result_buffer, "filetype", "markdown")
--
--	-- Delete existing window if it exists
--	if opts.float_win and vim.api.nvim_win_is_valid(opts.float_win) then
--		vim.api.nvim_win_close(opts.float_win, true)
--	end
--
--	-- Get window options and extend them with user-provided options
--	local win_opts = vim.tbl_deep_extend("force", M.get_window_options(), opts.win_config)
--
--	-- Open a new window with the result buffer
--	opts.float_win = vim.api.nvim_open_win(opts.result_buffer, true, win_opts)
--
--	-- Set options for the result buffer
--	vim.api.nvim_buf_set_option(opts.result_buffer, "filetype", "markdown")
--	vim.api.nvim_win_set_option(opts.float_win, "wrap", true)
--	vim.api.nvim_win_set_option(opts.float_win, "linebreak", true)
--	-- Return the buffer and window IDs
--	return opts.result_buffer, opts.float_win
--end

-- Function to create a window based on the display mode
-- Function to create a window based on the display mode
local Popup = require("nui.popup")

function M.create_window(opts)
	-- Delete existing popup if it exists
	if opts.float_win and opts.float_win:is_valid() then
		opts.float_win:close()
		vim.api.nvim_buf_delete(opts.result_buffer, { force = true })
	end

	-- Create a new Nui popup
	local float_win = Popup({
		position = "50%",
		size = {
			width = 80,
			height = 20,
		},
		border = "rounded",
	})

	-- Mount the popup to make it visible
	float_win:mount()

	-- Set options for the result buffer (you can customize this based on your requirements)
	vim.api.nvim_buf_set_option(float_win.bufnr, "filetype", "markdown")

	-- Return both the Nui popup and the associated buffer
	return { float_win = float_win, result_buffer = float_win.bufnr }
end

return M
--------------------------------------------------------------------------------
---------------------------- V.I.R.G.I.L INTERFACE -----------------------------
--------------------------------------------------------------------------------
local function initiateVirgil()
	-- Define the first popup window with color settings
	local virgilPopup = Popup({
		focusable = false,
		border = {
			style = "rounded",
			highlight = "Normal", -- Border color
			text = {
				fg = "Blue", -- Text color
			},
		},
		text = {
			fg = "VirgilPopupText", -- Color group for text
		},
		position = "50%",
		size = {
			width = "80%",
			height = "60%",
		},
	
	-- Define a method to update the content of the popup
	function virgilPopup:update_content(value)
		vim.api.nvim_buf_set_lines(self.bufnr, -1, -1, false, { value })
	end

	--------------------------------------------------------------------------------
	------------------------------------ INPUT -------------------------------------
	--------------------------------------------------------------------------------

	-- Define the input popup window
	local inputPopup = Popup({
		enter = true,
		focusable = true,
		border = {
			style = "rounded",
			highlight = "Normal", -- Border color
			text = {
				fg = "Blue", -- Text color
			},
		},
		text = {
			fg = "VirgilPopupText", -- Color group for text
		},
		position = "50%",
		size = {
			width = "50%",
			height = "30%",
		},
	})

	-- Set the content of the input popup
	local inputBuffer = "Test "
	vim.api.nvim_buf_set_lines(inputPopup.bufnr, 0, -1, false, { inputBuffer })

	-- Set up autocommand to handle Enter key press in input popup buffer
	vim.cmd([[
augroup inputPopupEnter
  autocmd!
  autocmd BufEnter <buffer> nnoremap <CR> :lua insert_value()<CR>
augroup END
]])

	-- Define the function to insert user input and trigger AI processing
	function insert_value()
		-- Retrieve the user input from the inputPopup buffer
		local input_value = vim.api.nvim_buf_get_lines(inputPopup.bufnr, 0, -1, false)[1]

		-- Check if input_value is not nil before triggering AI processing
		if input_value then
			-- Trigger the AI processing with the user input
			M.exec({ prompt_name = "Ask" })
		else
			print("Error: No input value found.")
		end
	end

	-- Set the layout
	local layout = Layout({
		position = "50%",
		size = {
			width = "80%",
			height = "60%",
		},
	}, {
		Layout.Box(virgilPopup, { size = "90%" }),
		Layout.Box(inputPopup, { size = "10%" }),
	})

	-- Mount the layout to display the popups
	layout:mount()
end


