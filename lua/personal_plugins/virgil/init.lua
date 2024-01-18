local prompts = require("personal_plugins.virgil.virgil_prompts")
local virgil_ui = require("personal_plugins.virgil.virgil_ui")

local m = {}

local curr_buffer = nil
local start_pos = nil
local end_pos = nil
print(virgil_ui)

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

local default_options = {
	model = "mixtral",
	debug = false,
	show_prompt = false,
	show_model = false,
	command = "curl --silent --no-buffer -x post http://localhost:11434/api/generate -d $body",
	json_response = true,
	no_auto_close = true,
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
	m[k] = v
end

m.setup = function(opts)
	for k, v in pairs(opts) do
		m[k] = v
	end
end

function write_to_buffer(lines)
	if not m.result_buffer or not vim.api.nvim_buf_is_valid(m.result_buffer) then
		print("Buffer is invalid or does not exist")
		return
	end

	local success, error = pcall(function()
		local all_lines = vim.api.nvim_buf_get_lines(m.result_buffer, 0, -1, false)

		local last_row = #all_lines
		local last_row_content = all_lines[last_row]
		local last_col = string.len(last_row_content)

		local text = table.concat(lines or {}, "\n")

		vim.api.nvim_buf_set_option(m.result_buffer, "modifiable", true)
		vim.api.nvim_buf_set_text(
			m.result_buffer,
			last_row - 1,
			last_col,
			last_row - 1,
			last_col,
			vim.split(text, "\n")
		)
		vim.api.nvim_buf_set_option(m.result_buffer, "modifiable", false)
	end)

	if not success then
		print("An error occurred while writing to the buffer: " .. error)
	end
end
function reset()
	m.result_buffer = nil
	m.float_win = nil
	m.result_string = ""
	m.context = nil
end

m.exec = function(options)
	local opts = vim.tbl_deep_extend("force", m, options)

	if type(opts.init) == "function" then
		opts.init(opts)
	end

	curr_buffer = vim.fn.bufnr("%")
	local mode = opts.mode or vim.fn.mode()
	if mode == "v" or mode == "v" then
		start_pos = vim.fn.getpos("'<")
		end_pos = vim.fn.getpos("'>")
		end_pos[3] = vim.fn.col("'>") -- in case of `v`, it would be maxcol instead
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
			local answer = vim.fn.input("Virgil Prompt: ")
			text = string.gsub(text, "%$input", answer)
		end

		if string.find(text, "%$register") then
			local register = vim.fn.getreg('"')
			if not register or register:match("^%s*$") then
				error("prompt uses $register but yank register is empty")
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

	m.result_string = ""

	local cmd
	if type(opts.command) == "function" then
		cmd = opts.command(opts)
	else
		cmd = m.command
	end

	if string.find(cmd, "%$prompt") then
		local prompt_escaped = vim.fn.shellescape(prompt)
		cmd = string.gsub(cmd, "%$prompt", prompt_escaped)
	end
	cmd = string.gsub(cmd, "%$model", opts.model)
	if string.find(cmd, "%$body") then
		local body = { model = opts.model, prompt = prompt, stream = true }
		if m.context then
			body.context = m.context
		end
		local json = vim.fn.json_encode(body)
		json = vim.fn.shellescape(json)
		cmd = string.gsub(cmd, "%$body", json)
	end

	if m.context ~= nil then
		write_to_buffer({ "", "", "---", "" })
	end

	local partial_data = ""
	if opts.debug then
		print(cmd)
	end
	if m.result_buffer == nil or m.float_win == nil or not vim.api.nvim_win_is_valid(m.float_win) then
		local result_buffer, float_win = virgil_ui.create_window(opts)
		if opts.show_model then
			vim.schedule(function()
				write_to_buffer({ "# chat with " .. opts.model, "" })
			end)
		end
		m.result_buffer = result_buffer
		m.float_win = float_win
		print(m.result_buffer)
	end

	local job_id = vim.fn.jobstart(cmd, {
		-- stderr_buffered = opts.debug,
		on_stdout = function(_, data, _)
			--	print(m.result_buffer)

			-- window was closed, so cancel the job
			if not m.float_win or not vim.api.nvim_win_is_valid(m.float_win) then
				--	print("job failed on stdout")
				if job_id then
					vim.fn.jobstop(job_id)
				end
				if m.result_buffer then
					vim.api.nvim_buf_delete(m.result_buffer, { force = true })
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
				if not m.float_win or not vim.api.nvim_win_is_valid(m.float_win) then
					print("error: job stopped")
					if job_id then
						vim.fn.jobstop(job_id)
					end
					return
				end

				if data == nil or #data == 0 then
					return
				end

				m.result_string = m.result_string .. table.concat(data, "\n")
				local lines = vim.split(m.result_string, "\n")
				write_to_buffer(lines)
			end
		end,

		on_exit = function(a, b)
			if b == 0 and opts.replace and m.result_buffer then
				local lines = {}
				if extractor then
					local extracted = m.result_string:match(extractor)
					if not extracted then
						if not opts.no_auto_close then
							print("Window is getting hidden")

							vim.api.nvim_win_hide(m.float_win)
							vim.api.nvim_buf_delete(m.result_buffer, { force = true })
							reset()
						end
						return
					end
					lines = vim.split(extracted, "\n", true)
				else
					lines = vim.split(m.result_string, "\n", true)
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
					print("shutdown no_auto_close")

					if m.float_win ~= nil then
						vim.api.nvim_win_hide(m.float_win)
					end
					if m.result_buffer ~= nil then
						print("Result buffer deleted")

						vim.api.nvim_buf_delete(m.result_buffer, { force = true })
					end
					reset()
				end
			end
			m.result_string = ""
		end,
	})

	local group = vim.api.nvim_create_augroup("virgil", { clear = true })
	local event
	vim.api.nvim_create_autocmd("winclosed", {

		buffer = m.result_buffer,
		group = group,
		callback = function()
			if job_id then
				vim.fn.jobstop(job_id)
			end
			if m.result_buffer then
				vim.api.nvim_buf_delete(m.result_buffer, { force = true })
			end
			reset()
		end,
	})

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
		if m.show_model then
			heading = "##"
		end
		write_to_buffer({
			heading .. " Virgil:",
			table.concat(short_prompt, "\n"),
			"",
		})
	end

	vim.keymap.set("n", "<esc>", function()
		vim.fn.jobstop(job_id)
	end, { buffer = m.result_buffer })

	vim.api.nvim_buf_attach(m.result_buffer, false, {
		on_detach = function()
			m.result_buffer = nil
		end,
	})
end

m.win_config = {}

m.prompts = prompts
function select_prompt(cb)
	local promptkeys = {}
	for key, _ in pairs(m.prompts) do
		table.insert(promptkeys, key)
	end
	table.sort(promptkeys)
	vim.ui.select(promptkeys, {
		prompt = "Virgil",
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
		local prompt = m.prompts[arg.args]
		if not prompt then
			print("invalid prompt '" .. arg.args .. "'")
			return
		end
		p = vim.tbl_deep_extend("force", { mode = mode }, prompt)
		return m.exec(p)
	end
	select_prompt(function(item)
		if not item then
			return
		end
		p = vim.tbl_deep_extend("force", { mode = mode }, m.prompts[item])
		m.exec(p)
	end)
end, {
	range = true,
	nargs = "?",
	complete = function(arglead, cmdline, cursorpos)
		local promptkeys = {}
		for key, _ in pairs(m.prompts) do
			if key:lower():match("^" .. arglead:lower()) then
				table.insert(promptkeys, key)
			end
		end
		table.sort(promptkeys)
		return promptkeys
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
				m.context = result.context
			end
		else
			write_to_buffer({ "", "====== error ======", str, "-------------", "" })
			vim.fn.jobstop(job_id)
		end
	else
		text = str
	end

	if text == nil then
		return
	end

	m.result_string = m.result_string .. text
	local lines = vim.split(text, "\n")
	write_to_buffer(lines)
end

m.select_model = function()
	local models = m.list_models()
	vim.ui.select(models, { prompt = "model:" }, function(item, idx)
		if item ~= nil then
			print("model set to " .. item)
			m.model = item
		end
	end)
end

return m
