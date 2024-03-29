local virgil = require("personal_plugins.virgil")
virgil.setup({
	model = "dolphin-mixtral", -- The default model to use.
	show_prompt = true, -- Shows the prompt submitted to Ollama.
	show_model = false, -- Displays which model you are using at the beginning of your chat session.
	no_auto_close = false, -- Never closes the window automatically.
	init = function(options)
		pcall(io.popen, "ollama serve > /dev/null 2>&1 &")
	end,
	-- Function to initialize Ollama
	command = "curl --silent --no-buffer -X POST http://localhost:11434/api/generate -d $body",
	-- The command for the Ollama service. You can use placeholders $prompt, $model, and $body (shellescaped).
	list_models = "<omitted lua function>", -- Retrieves a list of model names
	debug = false, -- Prints errors and the command which is run.
})

-- Key mappings for virgil (gen)
vim.keymap.set({ "n", "v" }, "<leader>]", ":Virgil<CR>")
