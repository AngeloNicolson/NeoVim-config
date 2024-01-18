-- This file can be loaded by calling `lua require('plugins')` from your init.vim

-- Only required if you have packer configured as `opt`
vim.cmd([[packadd packer.nvim]])

-------------------------------------------------------------
--------------- PACKER CAN MANAGE ITSELF --------------------
-------------------------------------------------------------
return require("packer").startup(function(use)
	use("wbthomason/packer.nvim")

	-------------------------------------------------------------
	------------------------ TELESCOPE --------------------------
	-------------------------------------------------------------
	use({
		"nvim-telescope/telescope.nvim",
		tag = "0.1.5",
		-- or                            , branch = '0.1.x',
		requires = {
			{ "nvim-lua/plenary.nvim" },
			{
				"nvim-telescope/telescope-fzf-native.nvim",
				run = "cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build",
			},
		},
	})
	use({ "nvim-telescope/telescope-ui-select.nvim" })

	-------------------------------------------------------------
	--------------- POPUP UI/Floating Window --------------------
	-------------------------------------------------------------
	use({
		"folke/noice.nvim",
		requires = {
			-- if you lazy-load any plugin below, make sure to add proper `module="..."` entries
			"MunifTanjim/nui.nvim",
			-- OPTIONAL:
			--   `nvim-notify` is only needed, if you want to use the notification view.
			--   If not available, we use `mini` as the fallback
			"rcarriga/nvim-notify",
		},
	})

	-------------------------------------------------------------
	-------------------------- THEME ----------------------------
	-------------------------------------------------------------
	use("sainnhe/gruvbox-material")
	use("nvim-treesitter/nvim-treesitter", { run = ":TSUpdate" })
	use("christoomey/vim-tmux-navigator", { lazy = false })
	use("theprimeagen/harpoon")
	use("mbbill/undotree")
	use("tpope/vim-fugitive")

	-------------------------------------------------------------
	------------------- INDENTATION LINES -----------------------
	-------------------------------------------------------------
	use("lukas-reineke/indent-blankline.nvim")

	-------------------------------------------------------------
	-- MANAGING & INSTALLING LSP SERVERS, LINTERS & FORMATTERS --
	-------------------------------------------------------------
	use({
		"VonHeikemen/lsp-zero.nvim",
		branch = "v2.x",
		requires = {
			-- LSP Support
			{ "neovim/nvim-lspconfig" }, -- Required
			{ "williamboman/mason.nvim" }, -- Optional
			{ "williamboman/mason-lspconfig.nvim" }, -- Optional

			-- Autocompletion
			{ "hrsh7th/nvim-cmp" }, -- Required
			{ "hrsh7th/cmp-nvim-lsp" }, -- Required
			{ "L3MON4D3/LuaSnip" }, -- Required
		},
	})
	use({
		"nvim-lualine/lualine.nvim",
		requires = { "nvim-tree/nvim-web-devicons", opt = true },
	})

	-------------------------------------------------------------
	------------------- PRETTIER FORMATTING ---------------------
	-------------------------------------------------------------
	-- use('jay-babu/mason-null-ls.nvim')
	-- use("jose-elias-alvarez/null-ls.nvim")
	-- use('mhartington/formatter.nvim' )

	-- Replace jose-elias-alvarez/null-ls.nvim with nvimtools/none-ls.nvim in your choice of package manager.
	-- https://github.com/nvimtools/none-ls.nvim
	use({
		"nvimtools/none-ls.nvim",
		config = function()
			require("null-ls").setup()
		end,
		requires = { "nvim-lua/plenary.nvim" },
	}) -- use('MunifTanjim/prettier.nvim')

	-------------------------------------------------------------
	------------------- AI ASSISTANT VIRGIL ---------------------
	-------------------------------------------------------------
	--use({ "David-Kunz/gen.nvim" })
end)
