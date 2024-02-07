local Popup = require("nui.popup")
local prompts = require("personal_plugins.virgil.virgil_prompts")
local Layout = require("nui.layout")
local M = {}

local default_options = {
	model = "mistral",
	debug = false,
	show_prompt = false,
	show_model = false,
	command = "curl --silent --no-buffer -X POST http://localhost:11434/api/generate -d $body",
	json_response = true,
	no_auto_close = false,
	display_mode = "float",
	no_auto_close = false,
	init = function()
		pcall(io.popen, "ollama serve > /dev/null 2>&1 &")
	end,
	list_models = function()
		local response = vim.fn.systemlist("curl --silent --no-buffer http://localhost:11434/api/tags")
		local list = vim.fn.json_decode(response)
		local models = {}
		for key, _ in pairs(list.models) do
			table.insert(models, list.models[key].name)
		end
		table.sort(models)
		return models
	end,
}
for k, v in pairs(default_options) do
	M[k] = v
end

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
		win_options = {
			-- Set the background color to match the editor's background
			winhighlight = "Normal:Normal,VirgilPopupText:Normal,VirgilPopupBorder:Normal",
		},
	})

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
		win_options = {
			-- Set the background color to match the editor's background
			winhighlight = "Normal:Normal,VirgilPopupText:Normal,VirgilPopupBorder:Normal",
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

--------------------------------------------------------------------------------
------------------------------- AI MODEL API CALL ------------------------------
--------------------------------------------------------------------------------

local curr_buffer = nil
local start_pos = nil
local end_pos = nil

--[[ 
    This function, trim_table, trims leading and trailing empty strings or whitespace from a table of strings.
    
    Parameters:
        - tbl: A table of strings to be trimmed.

    Returns:
        - tbl: The modified table with leading and trailing empty strings or whitespace removed.
]]
local function trim_table(tbl)
	local function is_whitespace(str)
		return str:match("^%s*$") ~= nil
	end

	while #tbl > 0 and (tbl[1] == "" or is_whitespace(tbl[1])) do
		table.remove(tbl, 1)
	end

	while #tbl > 0 and (tbl[#tbl] == "" or is_whitespace(tbl[#tbl])) do
		table.remove(tbl, #tbl)
	end

	return tbl
end

--[[
    This function, M.setup, is used to set up options for the module M. It copies key-value pairs from the provided 'opts' table to the module's own table, M.

    Parameters:
        - opts: A table containing key-value pairs of options to be set.

    Behavior:
        - For each key-value pair in the 'opts' table, the function copies the value to the corresponding key in the module's table, M.

    Note:
        - If a key already exists in the module's table, its value will be overwritten by the value from 'opts'.
]]

M.setup = function(opts)
	for k, v in pairs(opts) do
		M[k] = v
	end
end

--[[
    This function, get_window_options, calculates and returns options for a new window based on the current editor's dimensions and cursor position.

    Returns:
        - A table containing window options:
            - relative: Set to "cursor" to position the window relative to the cursor.
            - width: The width of the new window, calculated as 90% of the current editor's width.
            - height: The height of the new window, calculated as half of the current editor's height.
            - row: The row position of the new window, calculated to center it vertically around the cursor.
            - col: The column position of the new window, calculated to center it horizontally around the cursor.
            - style: Set to "minimal" to use minimal window decorations.
            - border: Set to "single" to add a single-line border around the window.
]]

local function get_window_options()
	local width = math.floor(vim.o.columns * 0.9) -- 90% of the current editor's width
	local height = math.floor(vim.o.lines * 0.9)
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
		width = new_win_width,
		height = new_win_height,
		row = new_win_row,
		col = 0,
		style = "minimal",
		border = "single",
	}
end

--[[
    This function, write_to_buffer, appends lines of text to the result buffer.

    Parameters:
        - lines: A table containing lines of text to be appended to the buffer.

    Behavior:
        - If the result buffer is not valid or does not exist, the function returns early.
        - It retrieves all lines from the result buffer.
        - It calculates the position to append the new lines based on the last row and column of the buffer.
        - It concatenates the lines of text provided (or an empty table if none is provided) into a single string separated by newline characters.
        - It sets the result buffer to be modifiable, inserts the text at the calculated position, and then sets the buffer to be unmodifiable again.

    Note:
        - If the buffer is empty, the lines are appended starting from the first row.
]]

function write_to_buffer(lines)
	if not M.result_buffer or not vim.api.nvim_buf_is_valid(M.result_buffer) then
		return
	end

	local all_lines = vim.api.nvim_buf_get_lines(M.result_buffer, 0, -1, false)

	local last_row = #all_lines
	local last_row_content = all_lines[last_row]
	local last_col = string.len(last_row_content)

	local text = table.concat(lines or {}, "\n")

	vim.api.nvim_buf_set_option(M.result_buffer, "modifiable", true)
	vim.api.nvim_buf_set_text(M.result_buffer, last_row - 1, last_col, last_row - 1, last_col, vim.split(text, "\n"))
	vim.api.nvim_buf_set_option(M.result_buffer, "modifiable", false)
end

--[[
    This function, create_window, creates a new window either as a floating window or a vertical split window, based on the display mode specified in the options.

    Parameters:
        - opts: A table containing options for creating the window.

    Behavior:
        - If the display mode is set to "float":
            - If there is an existing result buffer, it is deleted.
            - Window options are fetched and merged with the provided window configuration options.
            - A new buffer is created for displaying results with the filetype set to "markdown".
            - A floating window is opened with the result buffer and the merged window options.
        - If the display mode is not "float":
            - A new vertical split window is opened with a new buffer named "gen.nvim".
            - The result buffer is set to the buffer of the currently active window.
            - The filetype of the result buffer is set to "markdown".
            - The buffer type is set to "nofile" to indicate that it is not associated with a file on disk.
            - Window options for wrapping and line breaking are set for the newly created window.

    Note:
        - If the display mode is not "float", the window is opened as a vertical split window.
]]

local function initiateVirgil(opts)
	-- Delete existing popup if it exists
	if M.float_win and vim.api.nvim_win_is_valid(M.float_win) then
		vim.api.nvim_win_close(M.float_win, true)
		vim.api.nvim_buf_delete(M.result_buffer, { force = true })
	end

	-- Call the initiateVirgil function to create a new Nui popup
	local popup_data = Popup({
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
		win_options = {
			-- Set the background color to match the editor's background
			winhighlight = "Normal:Normal,VirgilPopupText:Normal,VirgilPopupBorder:Normal",
		},
	})

	-- Mount the popup to make it visible
	popup_data:mount()

	-- Set options for the result buffer (you can customize this based on your requirements)
	vim.api.nvim_buf_set_option(popup_data.bufnr, "filetype", "markdown")

	-- Update M.float_win and M.result_buffer with the new popup and buffer
	M.float_win = popup_data.win_id
	M.result_buffer = popup_data.bufnr
end

function reset()
	M.result_buffer = nil
	M.float_win = nil
	M.result_string = ""
	M.context = nil
end

M.exec = function(options)
	--[[
    This section of code initializes options and retrieves content based on the provided options.

    Steps:
        1. Merge the default options table (M) with the provided options table, ensuring that the provided options overwrite any conflicting default options.
        2. If an 'init' function is provided in the options and it is a function, call it with the merged options table.
        3. Retrieve the current buffer number.
        4. Determine the mode (visual or normal) based on the provided options or the current editor mode.
        5. If the mode is visual ('v' or 'V'), retrieve the start and end positions of the visual selection. Adjust the end position column if the mode is 'V'.
        6. If the mode is not visual, retrieve the cursor position as the start and end positions.
        7. Get the content of the current buffer within the specified range and concatenate it into a single string.

    Variables:
        - opts: The merged options table containing default and provided options.
        - curr_buffer: The buffer number of the current buffer.
        - mode: The mode in which the operation is being performed (visual or normal).
        - start_pos: The start position (line and column) of the selection or cursor.
        - end_pos: The end position (line and column) of the selection or cursor.
        - content: The concatenated text content of the current buffer within the specified range.
]]

	local opts = vim.tbl_deep_extend("force", M, options)

	if type(opts.init) == "function" then
		opts.init(opts)
	end

	curr_buffer = vim.fn.bufnr("%")
	local mode = opts.mode or vim.fn.mode()
	if mode == "v" or mode == "V" then
		start_pos = vim.fn.getpos("'<")
		end_pos = vim.fn.getpos("'>")
		end_pos[3] = vim.fn.col("'>") -- in case of `V`, it would be maxcol instead
	else
		local cursor = vim.fn.getpos(".")
		start_pos = cursor
		end_pos = start_pos
	end

	local content = table.concat(
		vim.api.nvim_buf_get_text(curr_buffer, start_pos[2] - 1, start_pos[3] - 1, end_pos[2] - 1, end_pos[3] - 1, {}),
		"\n"
	)

	--[[
    This function, substitute_placeholders, replaces placeholder strings in the input text with actual values.

    Parameters:
        - input: The input text containing placeholders.

    Behavior:
        - If the input text is nil, the function returns nil.
        - The function iterates through each placeholder in the input text:
            - If the placeholder is "$input", it prompts the user for input and replaces the placeholder with the user's input.
            - If the placeholder is "$register", it retrieves the content of the yank register and replaces the placeholder with the register content.
            - It replaces occurrences of "%%" with "%%%%" to escape percent signs, as '%' has special meaning in Lua patterns.
            - It replaces the placeholder "$text" with the content of the current buffer within the specified range.
            - It replaces the placeholder "$filetype" with the filetype of the current buffer.
        - The function returns the modified text with replaced placeholders.

    Note:
        - If the yank register is empty and the input text contains the "$register" placeholder, the function throws an error.
]]

	local function substitute_placeholders(input)
		if not input then
			return
		end
		local text = input
		if string.find(text, "%$input") then
			local answer = vim.fn.input("Prompt: ")
			text = string.gsub(text, "%$input", answer)
		end

		if string.find(text, "%$register") then
			local register = vim.fn.getreg('"')
			if not register or register:match("^%s*$") then
				error("Prompt uses $register but yank register is empty")
			end

			text = string.gsub(text, "%$register", register)
		end

		content = string.gsub(content, "%%", "%%%%")
		text = string.gsub(text, "%$text", content)
		text = string.gsub(text, "%$filetype", vim.bo.filetype)
		return text
	end

	--[[
    This block of code prepares the prompt text, replaces placeholders, and determines the command to execute.

    Steps:
        1. Retrieve the prompt text from the options.
        2. If the prompt is a function, call it with a table containing the content of the current buffer and the filetype. Replace the prompt with the result.
        3. Substitute placeholders in the prompt text using the substitute_placeholders function.
        4. Substitute occurrences of "%%" with "%%%%" to escape percent signs.
        5. Initialize the result_string variable to an empty string.
        6. Determine the command to execute based on the type of the 'command' option:
            - If it's a function, call it with the options table and assign the result to 'cmd'.
            - If it's not a function, use the default command stored in 'M.command'.
    Variables:
        - prompt: The prompt text to be used in the generation command.
        - extractor: The text used to extract specific information from the generation result, after replacing placeholders.
        - cmd: The command to execute for text generation.
]]

	local prompt = opts.prompt

	if type(prompt) == "function" then
		prompt = prompt({ content = content, filetype = vim.bo.filetype })
	end

	prompt = substitute_placeholders(prompt)
	local extractor = substitute_placeholders(opts.extract)

	prompt = string.gsub(prompt, "%%", "%%%%")

	M.result_string = ""

	local cmd
	if type(opts.command) == "function" then
		cmd = opts.command(opts)
	else
		cmd = M.command
	end

	--[[
    This block of code replaces placeholders in the command string with corresponding values.

    Steps:
        1. If the command contains the placeholder "$prompt", escape the prompt text using the shellescape function and replace "$prompt" with the escaped prompt in the command.
        2. Replace occurrences of "$model" in the command with the model specified in the options.
        3. If the command contains the placeholder "$body":
            - Create a body table containing model, prompt, and stream attributes.
            - If there is a context in M, add it to the body table.
            - Encode the body table to JSON format and escape it using shellescape function.
            - If the shell is cmd.exe, replace '\""' with '\\\\\\"' to escape double quotes.
            - Replace "$body" in the command with the escaped JSON body.
    Variables:
        - cmd: The command string to execute for text generation.
        - prompt: The prompt text used for generation.
        - opts.model: The model specified in the options.
        - M.context: The context used for generation.
]]
	if string.find(cmd, "%$prompt") then
		local prompt_escaped = vim.fn.shellescape(prompt)
		cmd = string.gsub(cmd, "%$prompt", prompt_escaped)
	end
	cmd = string.gsub(cmd, "%$model", opts.model)
	if string.find(cmd, "%$body") then
		local body = { model = opts.model, prompt = prompt, stream = true }
		if M.context then
			body.context = M.context
		end
		local json = vim.fn.json_encode(body)
		json = vim.fn.shellescape(json)
		if vim.o.shell == "cmd.exe" then
			json = string.gsub(json, '\\""', '\\\\\\"')
		end
		cmd = string.gsub(cmd, "%$body", json)
	end

	--[[
    This block of code checks if there is a context in M, and if so, writes a separator line to the buffer.

    Steps:
        1. Check if M.context is not nil.
        2. If M.context is not nil, write an empty line followed by a separator "---" to the buffer.
        3. Initialize an empty string partial_data.
        4. If opts.debug is true, print the command.
        5. Check if M.result_buffer is nil, M.float_win is nil, or the float window is not valid:
            - If any of these conditions are true, call the create_window function to create a new window according to the options.
            - If opts.show_model is true, write a heading "# Chat with <model>" to the buffer.
    Variables:
        - M.context: The context used for generation.
        - partial_data: A string to store partial data received from the generated text.
        - opts.debug: A boolean indicating whether debug mode is enabled.
        - cmd: The command string used for text generation.
        - M.result_buffer: The buffer used for displaying generated text.
        - M.float_win: The window ID of the floating window used for displaying generated text.
        - opts.show_model: A boolean indicating whether to show the model name in the buffer.
]]

	if M.context ~= nil then
		write_to_buffer({ "", "", "---", "" })
	end

	local partial_data = ""
	if opts.debug then
		print(cmd)
	end

	if M.result_buffer == nil or M.float_win == nil or not vim.api.nvim_win_is_valid(M.float_win) then
		initiateVirgil(opts)
		if opts.show_model then
			write_to_buffer({ "# Chat with " .. opts.model, "" })
		end
	end

	--[[
    This block of code starts a job to execute the command string (cmd) and handles the output.

    Steps:
        1. Start a job using vim.fn.jobstart with the command (cmd) and options.
        2. Define the behavior on receiving standard output:
            - If the window for displaying the generated text is closed, cancel the job, delete the result buffer, and reset.
            - Otherwise, append the received data to the partial_data string.
            - Split the partial_data string into lines and process each line using the process_response function.
            - If a line ends with "}", treat it as a complete response and process it.
        3. The partial_data string accumulates partial responses until a complete one is received.

    Variables:
        - job_id: The ID of the job started for executing the command.
        - cmd: The command string used for text generation.
        - M.float_win: The window ID of the floating window used for displaying generated text.
        - M.result_buffer: The buffer used for displaying generated text.
        - partial_data: A string to accumulate partial data received from the job's output.
        - process_response: A function to process the response received from the job.
        - opts.json_response: A boolean indicating whether the response is in JSON format.
]]
	local job_id = vim.fn.jobstart(cmd, {
		-- stderr_buffered = opts.debug,
		on_stdout = function(_, data, _)
			-- window was closed, so cancel the job
			if not M.float_win or not vim.api.nvim_win_is_valid(M.float_win) then
				if job_id then
					vim.fn.jobstop(job_id)
				end
				if M.result_buffer then
					vim.api.nvim_buf_delete(M.result_buffer, { force = true })
				end
				reset()
				return
			end

			for _, line in ipairs(data) do
				partial_data = partial_data .. line
				if line:sub(-1) == "}" then
					partial_data = partial_data .. "\n"
				end
			end

			local lines = vim.split(partial_data, "\n", { trimempty = true })

			partial_data = table.remove(lines) or ""

			for _, line in ipairs(lines) do
				process_response(line, job_id, opts.json_response)
			end

			if partial_data:sub(-1) == "}" then
				process_response(partial_data, job_id, opts.json_response)
				partial_data = ""
			end
		end,
		--[[
    This block of code handles the standard error output of the job.

    Steps:
        1. Check if debugging is enabled. If not, skip the handling.
        2. If the window for displaying the generated text is closed, cancel the job.
        3. If there is no data or the data is empty, return.
        4. Append the received data to the result_string.
        5. Split the result_string into lines and write them to the buffer using the write_to_buffer function.

    Variables:
        - M.float_win: The window ID of the floating window used for displaying generated text.
        - job_id: The ID of the job started for executing the command.
        - opts.debug: A boolean indicating whether debugging is enabled.
        - data: The standard error output data received from the job.
        - M.result_string: A string to accumulate the standard error output.
        - write_to_buffer: A function to write lines to the buffer.
]]
		on_stderr = function(_, data, _)
			if opts.debug then
				-- window was closed, so cancel the job
				if not M.float_win or not vim.api.nvim_win_is_valid(M.float_win) then
					if job_id then
						vim.fn.jobstop(job_id)
					end
					return
				end

				if data == nil or #data == 0 then
					return
				end

				M.result_string = M.result_string .. table.concat(data, "\n")
				local lines = vim.split(M.result_string, "\n")
				write_to_buffer(lines)
			end
		end,
		--[[
    This block of code handles the job exit event.

    Steps:
        1. Check if the job exited successfully (b == 0) and if the 'replace' option is enabled.
        2. If 'replace' is enabled and a result buffer exists, determine the lines to replace in the current buffer.
        3. If an extractor function is provided, use it to extract the relevant lines from the result string.
        4. If 'no_auto_close' option is not set, hide the floating window and delete the result buffer.
        5. If the job did not exit successfully or the 'replace' option is disabled, or 'no_auto_close' is set, reset the result_string.

    Variables:
        - b: The exit code of the job.
        - opts.replace: A boolean indicating whether to replace content in the current buffer with the job's output.
        - M.result_buffer: The buffer ID where the job's output is stored.
        - extractor: A function to extract relevant lines from the job's output.
        - opts.no_auto_close: A boolean indicating whether to automatically close the floating window and delete the result buffer.
        - M.float_win: The window ID of the floating window used for displaying generated text.
        - M.result_string: A string containing the job's output.
        - curr_buffer: The buffer ID of the current buffer.
        - start_pos: The start position of the selected text in the current buffer.
        - end_pos: The end position of the selected text in the current buffer.
        - vim.api.nvim_win_hide(): Function to hide a window.
        - vim.api.nvim_buf_delete(): Function to delete a buffer.
        - vim.api.nvim_buf_set_text(): Function to set the text of a buffer.
        - reset(): Function to reset state variables.

    Note:
        The 'reset' function is assumed to be defined elsewhere in the code.
]]

		on_exit = function(a, b)
			if b == 0 and opts.replace and M.result_buffer then
				local lines = {}
				if extractor then
					local extracted = M.result_string:match(extractor)
					if not extracted then
						if not opts.no_auto_close then
							vim.api.nvim_win_hide(M.float_win)
							vim.api.nvim_buf_delete(M.result_buffer, { force = true })
							reset()
						end
						return
					end
					lines = vim.split(extracted, "\n", true)
				else
					lines = vim.split(M.result_string, "\n", true)
				end
				lines = trim_table(lines)
				vim.api.nvim_buf_set_text(
					curr_buffer,
					start_pos[2] - 1,
					start_pos[3] - 1,
					end_pos[2] - 1,
					end_pos[3] - 1,
					lines
				)
				if not opts.no_auto_close then
					if M.float_win ~= nil then
						vim.api.nvim_win_hide(M.float_win)
					end
					if M.result_buffer ~= nil then
						vim.api.nvim_buf_delete(M.result_buffer, { force = true })
					end
					reset()
				end
			end
			M.result_string = ""
		end,
	})
	--[[
    This block of code creates an autocommand group and attaches an autocmd for the "WinClosed" event.

    Steps:
        1. Create an autocommand group named "gen" and clear any existing autocmds in the group.
        2. Define an autocmd for the "WinClosed" event, targeting the buffer associated with M.result_buffer.
        3. When the "WinClosed" event occurs, stop the job if it's still running, delete the result buffer, and reset state variables.

    Variables:
        - group: The autocommand group ID.
        - event: The event triggering the autocommand (in this case, "WinClosed").
        - M.result_buffer: The buffer ID associated with the result of a job.
        - job_id: The ID of the job running in the buffer.
        - vim.api.nvim_create_augroup(): Function to create an autocommand group.
        - vim.api.nvim_create_autocmd(): Function to create an autocmd.
        - vim.fn.jobstop(): Function to stop a job.
        - vim.api.nvim_buf_delete(): Function to delete a buffer.
        - reset(): Function to reset state variables.
]]

	local group = vim.api.nvim_create_augroup("gen", { clear = true })
	local event
	vim.api.nvim_create_autocmd("WinClosed", {
		buffer = M.result_buffer,
		group = group,
		callback = function()
			if job_id then
				vim.fn.jobstop(job_id)
			end
			if M.result_buffer then
				vim.api.nvim_buf_delete(M.result_buffer, { force = true })
			end
			reset()
		end,
	})
	--[[
    This code block checks if the option opts.show_prompt is enabled. If enabled, it prepares and displays the prompt in the result buffer.

    Steps:
        1. If opts.show_prompt is true:
            a. Split the prompt into lines.
            b. Add a ">" character at the beginning of each line to indicate it as part of the prompt.
            c. Extract the first three lines of the prompt and concatenate them, adding "..." if there are more lines.
            d. Prepare the heading based on whether M.show_model is enabled.
            e. Write the prompt to the buffer with appropriate formatting.

    Variables:
        - opts.show_prompt: Option to determine whether to display the prompt.
        - prompt: The prompt text.
        - lines: Array containing each line of the prompt.
        - short_prompt: Array containing the first three lines of the prompt.
        - heading: String indicating the heading level for the prompt.
        - write_to_buffer(): Function to write content to the result buffer.
]]

	if opts.show_prompt then
		local lines = vim.split(prompt, "\n")
		local short_prompt = {}
		for i = 1, #lines do
			lines[i] = "> " .. lines[i]
			table.insert(short_prompt, lines[i])
			if i >= 3 then
				if #lines > i then
					table.insert(short_prompt, "...")
				end
				break
			end
		end
		local heading = "#"
		if M.show_model then
			heading = "##"
		end
		write_to_buffer({
			heading .. " Prompt:",
			"",
			table.concat(short_prompt, "\n"),
			"",
			"---",
			"",
		})
	end

	vim.keymap.set("n", "<esc>", function()
		vim.fn.jobstop(job_id)
	end, { buffer = M.result_buffer })

	vim.api.nvim_buf_attach(M.result_buffer, false, {
		on_detach = function()
			M.result_buffer = nil
		end,
	})
end

M.win_config = {}

M.prompts = prompts
function select_prompt(cb)
	local promptKeys = {}
	for key, _ in pairs(M.prompts) do
		table.insert(promptKeys, key)
	end
	table.sort(promptKeys)
	vim.ui.select(promptKeys, {
		prompt = "Prompt:",
		format_item = function(item)
			return table.concat(vim.split(item, "_"), " ")
		end,
	}, function(item, idx)
		cb(item)
	end)
end

--[[
    This code block defines a custom user command "Gen" using `vim.api.nvim_create_user_command`.

    Steps:
        1. Determine the mode based on the range of the command (normal mode if range is 0, visual mode otherwise).
        2. If arguments are provided:
            a. Check if the provided argument corresponds to a predefined prompt.
            b. If valid, retrieve the prompt details and execute it using M.exec().
        3. If no arguments are provided:
            a. Call the select_prompt() function to prompt the user to select a predefined prompt.
            b. Once a prompt is selected, retrieve its details and execute it using M.exec().

    Variables:
        - "Gen": Name of the custom user command.
        - M.prompts: Table containing predefined prompts.
        - promptKeys: Array containing keys of predefined prompts for command completion.
        - select_prompt(): Function to prompt the user to select a predefined prompt.
        - M.exec(): Function to execute a prompt with specified options.
]]
vim.api.nvim_create_user_command("Virgil", function(arg)
	local mode
	if arg.range == 0 then
		mode = "n"
	else
		mode = "v"
	end
	if arg.args ~= "" then
		local prompt = M.prompts[arg.args]
		if not prompt then
			print("Invalid prompt '" .. arg.args .. "'")
			return
		end
		p = vim.tbl_deep_extend("force", { mode = mode }, prompt)
		return M.exec(p)
	end
	select_prompt(function(item)
		if not item then
			return
		end
		p = vim.tbl_deep_extend("force", { mode = mode }, M.prompts[item])
		M.exec(p)
	end)
end, {
	range = true,
	nargs = "?",
	complete = function(ArgLead, CmdLine, CursorPos)
		local promptKeys = {}
		for key, _ in pairs(M.prompts) do
			if key:lower():match("^" .. ArgLead:lower()) then
				table.insert(promptKeys, key)
			end
		end
		table.sort(promptKeys)
		return promptKeys
	end,
})

--[[
    This function processes a response received from a job.

    Steps:
        1. Check if the response string is empty, if so, return.
        2. If JSON response is expected:
            a. Attempt to decode the JSON response.
            b. If successful, extract the response text and update the context if provided.
            c. If decoding fails, write an error message to the buffer and stop the job.
        3. If JSON response is not expected:
            a. Use the response string as the text.
        4. Append the response text to M.result_string.
        5. Split the response text into lines and write them to the buffer.

    Parameters:
        - str: The response string received from the job.
        - job_id: The ID of the job.
        - json_response: A boolean indicating whether the response is in JSON format.
]]

function process_response(str, job_id, json_response)
	if string.len(str) == 0 then
		return
	end
	local text

	if json_response then
		local success, result = pcall(function()
			return vim.fn.json_decode(str)
		end)

		if success then
			text = result.response
			if result.context ~= nil then
				M.context = result.context
			end
		else
			write_to_buffer({ "", "====== ERROR ====", str, "-------------", "" })
			vim.fn.jobstop(job_id)
		end
	else
		text = str
	end

	if text == nil then
		return
	end

	M.result_string = M.result_string .. text
	local lines = vim.split(text, "\n")
	write_to_buffer(lines)
end

M.select_model = function()
	local models = M.list_models()
	vim.ui.select(models, { prompt = "Model:" }, function(item, idx)
		if item ~= nil then
			print("Model set to " .. item)
			M.model = item
		end
	end)
end

return M
