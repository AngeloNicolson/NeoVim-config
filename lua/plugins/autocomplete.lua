return {
	-- LSP Management
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
		},

		config = function()
			-- Require lsp-zero
			local lsp = require("lsp-zero")

			-- Set up LSP with lsp-zero
			lsp.preset("recommended")

			-- Mason configuration
			require("mason").setup()
			require("mason-lspconfig").setup({
				ensure_installed = {
					"html",
					"yamlls",
					"pyright",
					"grammarly",
					"jsonls",
					"denols",
					"lua_ls",
					"clangd",
					"cmake",
				},
			})

			-- Additional LSP server-specific settings
			lsp.configure("lua_ls", {
				settings = {
					Lua = {
						diagnostics = {
							globals = { "vim" }, -- Recognize `vim` as a global
						},
					},
				},
			})

			-- Finalize LSP setup
			lsp.setup()

			-- nvim-cmp configuration
			local cmp = require("cmp")
			cmp.setup({
				-- Key mappings for nvim-cmp
				mapping = {
					["<Tab>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
					["<S-Tab>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
					["<CR>"] = cmp.mapping.confirm({ behavior = cmp.ConfirmBehavior.Insert, select = true }),
				},
				-- Additional configurations for cmp
				completion = {
					completeopt = "menu,menuone,noselect",
				},
				snippet = {
					expand = function(args)
						require("luasnip").lsp_expand(args.body)
					end,
				},
			})
		end,
	},
}
