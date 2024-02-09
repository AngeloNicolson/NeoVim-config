local Popup = require("nui.popup")
local Menu = require("nui.menu")
local prompts = require("personal_plugins.virgil.virgil_prompts")
local Layout = require("nui.layout")
local M = {}

local default_options = {
	model = "dolphin-mistral",
	debug = true,
	show_prompt = false,
	show_model = false,
	command = "curl --silent --no-buffer -X POST http://localhost:11434/api/generate -d $body",
	json_response = true,
	init = function()
		pcall(io.popen, "ollama serve > /dev/null 2>&1 &")
	end,
	list_models = function()
		local response = vim.fn.systemlist("curl --silent --no-buffer http://localhost:11434/api/tags")
		--local list = vim.fn.json_decode(response)

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
------------------------------- AI MODEL API CALL ------------------------------
--------------------------------------------------------------------------------
local curr_buffer = nil
local start_pos = nil
local end_pos = nil

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
M.setup = function(opts)
	for k, v in pairs(opts) do
		M[k] = v
	end
end

--------------------------------------------------------------------------------
----------------------------- V.I.R.G.I.L BUFFER -------------------------------
--------------------------------------------------------------------------------
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
	--print(lines)
end

--------------------------------------------------------------------------------
---------------------------- V.I.R.G.I.L WINDOWS -------------------------------
--------------------------------------------------------------------------------
local function initiateVirgil(opts)
	-- Delete existing popup if it exists
	if M.float_win and vim.api.nvim_win_is_valid(M.float_win) then
		vim.api.nvim_win_close(M.float_win, true)
		vim.api.nvim_buf_delete(M.result_buffer, { force = true })
	end

	-- Call the initiateVirgil function to create a new Nui popup
	local virgilPopup = Popup({
		enter = false,
		focusable = true,
		border = {
			style = "rounded",
			highlight = "Normal", -- Border color
			text = {
				fg = "#FFFFFF",
				top = "VIRGIL",
			},
		},
		position = "50%",
		size = {
			width = "80%",
			height = "60%",
		},
		text = {
			fg = "VirgilPopupText", -- Color group for text
		},
		win_options = {
			-- Set the background color to match the editor's background
			winhighlight = "Normal:Normal,VirgilPopupText:Normal,VirgilPopupBorder:Normal",
		},
	})
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
		position = "50%",
		size = {
			width = "50%",
			height = "30%",
		},
		text = {
			fg = "VirgilPopupText", -- Color group for text
		},
		win_options = {
			-- Set the background color to match the editor's background
			winhighlight = "Normal:Normal,VirgilPopupText:Normal,VirgilPopupBorder:Normal",
		},
	})

	local layout = Layout(
		{
			position = "50%",
			size = {
				width = 80,
				height = "60%",
			},
		},
		Layout.Box({
			Layout.Box(virgilPopup, { size = "90%" }),
			Layout.Box(inputPopup, { size = "15%" }),
		}, { dir = "col" })
	)
	layout:mount()

	-- Update M.float_win and M.result_buffer with the new popup and buffer
	M.float_win = virgilPopup.winid
	M.result_buffer = virgilPopup.bufnr

	------------------------------------
	---------- BUFFER OPTIONS ----------
	------------------------------------
	vim.api.nvim_buf_set_option(M.result_buffer, "filetype", "markdown") -- Set options for the result buffer
	vim.api.nvim_win_set_option(M.float_win, "wrap", true)
	vim.api.nvim_win_set_option(M.float_win, "linebreak", true)
	vim.api.nvim_win_set_option(M.float_win, "breakindent", true)
	vim.api.nvim_win_set_option(M.float_win, "breakindentopt", "shift:2,min:10")
	-- Set focus to inputPopup and switch to insert mode
	vim.api.nvim_set_current_win(inputPopup.winid)
	vim.api.nvim_command("startinsert")

	------------------------------------
	------- HANDLE POPUP INPUT ---------
	------------------------------------
	-- Listen for Enter key press in inputPopup only if initiateVirgil is active
	if M.float_win and vim.api.nvim_win_is_valid(M.float_win) then
		-- Listen for Enter key press in insert mode
		vim.api.nvim_buf_set_keymap(0, "i", "<CR>", "<Cmd>lua submitPrompt()<CR>", { noremap = true, silent = true })

		_G.submitPrompt = function()
			local input_text = vim.api.nvim_buf_get_lines(inputPopup.bufnr, 0, -1, false)
			local prompt = table.concat(input_text, "\n")

			-- clear the buffer content
			vim.api.nvim_buf_set_lines(inputPopup.bufnr, 0, -1, false, {})

			if prompt:lower() == "exit" or prompt:lower() == ":q" then
				-- Set insert popup to normal mode
				vim.api.nvim_win_set_option(inputPopup.winid, "wrap", false)
				vim.api.nvim_win_set_option(inputPopup.winid, "cursorline", false)
				vim.api.nvim_command("stopinsert")

				-- Close down the popup and perform cleanup
				vim.api.nvim_win_close(inputPopup.winid, true)
				vim.api.nvim_buf_delete(inputPopup.bufnr, { force = true })
				reset()
				return
			end

			-- Process input prompt and send it to AI model
			M.exec({ prompt = prompt })
		end
	end
	-- print("M.result_buffer:", M.result_buffer)
	-- print("M.float_win:", M.float_win)
end

function reset()
	M.result_buffer = nil
	M.float_win = nil
	M.result_string = ""
	M.context = nil
end

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

	local group = vim.api.nvim_create_augroup("Virgil", { clear = true })
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
	------------------------------------
	----------- USER PROMPTS -----------
	------------------------------------
	if opts.show_prompt then
		local lines = vim.split(prompt, "\n")
		local short_prompt = {}
		for i = 1, #lines do
			table.insert(short_prompt, lines[i])
			if i >= 3 then
				if #lines > i then
					table.insert(short_prompt, "```")
				end
				break
			end
		end
		local heading = " "
		write_to_buffer({
			"",
			"# ---------------------------------- You ------------------------------------",
			"",
			table.concat(short_prompt, "\n"),
			" ",
			" ",
			"# --------------------------------- Virgil ----------------------------------",
			"",
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
			write_to_buffer({ "", "====== ERROR ======", str, "-------------", "" })
			vim.fn.jobstop(job_id)
		end
	else
		text = str
	end

	if text == nil then
		return
	end

	M.result_string = M.result_string .. text
	-- print(str)
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
