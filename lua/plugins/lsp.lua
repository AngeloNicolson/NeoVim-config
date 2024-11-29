return {
	-- LSP Zero setup
	{
		"VonHeikemen/lsp-zero.nvim",
		branch = "v2.x",
		dependencies = {
			"neovim/nvim-lspconfig",
			"williamboman/mason.nvim",
			"williamboman/mason-lspconfig.nvim",
			"hrsh7th/nvim-cmp",
			"hrsh7th/cmp-nvim-lsp",
			"L3MON4D3/LuaSnip",
			"jose-elias-alvarez/null-ls.nvim", -- for null-ls integration
		},
		config = function()
			local lsp = require("lsp-zero").preset({})

			-- Set custom sign icons for LSP diagnostics
			lsp.set_sign_icons({
				error = "✘",
				warn = "▲",
				hint = "⚑",
				info = "»",
			})

			-- This function runs when the LSP attaches to a buffer
			lsp.on_attach(function(client, bufnr)
				lsp.default_keymaps({ buffer = bufnr })
			end)

			-- Format on save configuration
			lsp.format_on_save({
				format_opts = {
					async = true,
					timeout_ms = 10000,
				},
				servers = {
					["null-ls"] = {
						"css",
						"javascript",
						"typescript",
						"javascriptreact",
						"typescriptreact",
						"json",
						"html",
						"scss",
						"less",
						"py",
						"python",
						"c",
						"cpp",
						"hpp",
						"lua",
						"php",
					},
				},
			})

			-- Setup LSP
			lsp.setup()

			-- Setup null-ls with sources
			local null_ls = require("null-ls")

			null_ls.setup({
				sources = {
					---------------------------------- PRETTIER ------------------------------------
					null_ls.builtins.formatting.prettierd.with({
						extra_args = {
							"--double-quote",
							"--jsx",
							"--jsx=react",
							"--jsx-single-quote",
							"--jsx-bracket-same-line",
							"--jsx-closing-tag-with-newline",
						},
						filetypes = {
							"css",
							"javascript",
							"typescript",
							"javascriptreact",
							"typescriptreact",
							"json",
							"html",
							"scss",
							"less",
						},
					}),

					------------------------------------ BLACK -------------------------------------
					null_ls.builtins.formatting.black.with({
						extra_args = { "--line-length=80" },
						filetypes = { "py", "python" },
					}),

					------------------------------- CLANG-FORMATTER --------------------------------
					null_ls.builtins.formatting.clang_format.with({
						extra_args = { "--style=Microsoft" },
						filetypes = { "c", "cpp", "h", "hpp" },
					}),

					----------------------------------- LUA ----------------------------------------
					null_ls.builtins.formatting.stylua.with({
						extra_args = {},
						filetypes = { "lua" },
					}),

					---------------------------------- PHP-CS-FIXER --------------------------------
					null_ls.builtins.formatting.phpcsfixer.with({
						extra_args = {},
						filetypes = { "php" },
					}),

					---------------------------------- ESLINT_D -------------------------------------
					-- Uncomment and configure if needed
					-- null_ls.builtins.diagnostics.eslint_d.with({
					--     diagnostics_format = "[eslint] #{m}\n(#{c})",
					-- }),
				},
			})
		end,
	},
}
