local lsp = require("lsp-zero").preset({})

lsp.on_attach(function(client, bufnr)
	lsp.default_keymaps({ buffer = bufnr })
end)

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
		},
	},
})

lsp.setup()

local null_ls = require("null-ls")

null_ls.setup({
	sources = {
		---------------------------------------------------------------------------------
		---------------------------------- PRETTIER ------------------------------------
		--------------------------------------------------------------------------------
		null_ls.builtins.formatting.prettierd.with({
			extra_args = {
				"--no-semi",
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

		--------------------------------------------------------------------------------
		------------------------------------ BLACK -------------------------------------
		--------------------------------------------------------------------------------
		null_ls.builtins.formatting.black.with({
			extra_args = {
				"--line-length=80",
			},
			filetypes = { "py", "python" },
		}),

		--------------------------------------------------------------------------------
		------------------------------- CLANG-FORMATTER --------------------------------
		--------------------------------------------------------------------------------
		null_ls.builtins.formatting.clang_format.with({
			extra_args = {
				"--style=LLVM", -- Use LLVM style
			},
			filetypes = { "c", "cpp", "h" },
		}),

		--------------------------------------------------------------------------------
		----------------------------------- LUA ----------------------------------------
		--------------------------------------------------------------------------------
		null_ls.builtins.formatting.stylua.with({ extra_args = {}, filetypes = { "lua" } }),

		--------------------------------------------------------------------------------
		---------------------------------- ESLINT_D -------------------------------------
		--------------------------------------------------------------------------------
		null_ls.builtins.diagnostics.eslint_d.with({
			diagnostics_format = "[eslint] #{m}\n(#{c})",
		}), --  null_ls.builtins.diagnostics.fish
	},
})
