local Popup = require("nui.popup")
local Layout = require("nui.layout")

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
local inputBuffer = "Hello"
vim.api.nvim_buf_set_lines(inputPopup.bufnr, 0, -1, false, { inputBuffer })

-- Set up autocommand to handle Enter key press in input popup buffer
vim.cmd([[
augroup inputPopupEnter
  autocmd!
  autocmd BufEnter <buffer> nnoremap <CR> :lua insert_value()<CR>
augroup END
]])

-- Function to insert value from input popup into main popup buffer
function insert_value()
	local value = vim.api.nvim_buf_get_lines(inputPopup.bufnr, 0, -1, false)[1]
	virgilPopup:update_content(value) -- Use the custom method to update content
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

-- Update the popup size when the Neovim window is resized
vim.cmd([[autocmd VimResized * lua require('virgil').resizePopup()]])

--------------------------------------------------------------------------------
----------------------------------- Virgio--------------------------------------
--------------------------------------------------------------------------------
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
		local success, errmsg = pcall(function()
			-- Attempt to start the server
			local devnull = "> /dev/null 2>&1"
			os.execute("ollama serve " .. devnull)
		end)
		if not success then
			print("Error starting server:", errmsg)
		end
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
local M = {}
M.exec = function(options)
	local opts = vim.tbl_deep_extend("force", M, options)

	if type(opts.init) == "function" then
		opts.init(opts)
	end

	curr_buffer = vim.fn.bufnr("%")
	local mode = opts.mode or vim.fn.mode()
	if mode == "v" or mode == "V" then
		start_pos = vim.fn.getpos("'<")
		end_pos = vim.fn.getpos("'>")
		end_pos[3] = vim.fn.col("'>")
	else
		local cursor = vim.fn.getpos(".")
		start_pos = cursor
		end_pos = start_pos
	end

	local content = table.concat(
		vim.api.nvim_buf_get_text(curr_buffer, start_pos[2] - 1, start_pos[3] - 1, end_pos[2] - 1, end_pos[3] - 1, {}),
		"\n"
	)

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

	if M.context ~= nil then
		write_to_buffer({ "", "", "---", "" })
	end

	local output_buffer = {}
	local job_id = vim.fn.jobstart(cmd, {
		on_stdout = function(_, data, _)
			-- Process the data received from the AI API
			for _, line in ipairs(data) do
				table.insert(output_buffer, line)
			end
		end,
		on_stderr = function(_, data, _)
			-- Handle errors or debug information from stderr
		end,
		on_exit = function(_, code)
			if code == 0 then
				-- API call was successful, process the output
				local output = table.concat(output_buffer, "\n")
				-- Update the content of the virgilPopup with the output
				virgilPopup:update_content(output)
			else
				-- API call failed, handle the error
				print("Error: AI API call failed")
			end
		end,
	})

	-- Handle cleanup or finalization tasks related to the AI API call here

	-- Remember to return the job_id(Maybe for storing the job so it can be called back)
	return job_id
end
return
