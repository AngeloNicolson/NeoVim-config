-- This file can be loaded by calling `lua require('plugins')` from your init.vim

-- Only required if you have packer configured as `opt`
vim.cmd [[packadd packer.nvim]]

 -------------------------------------------------------------
 --------------- PACKER CAN MANAGE ITSELF --------------------
 -------------------------------------------------------------
return require('packer').startup(function(use) 
  use 'wbthomason/packer.nvim'
  use {
	  'nvim-telescope/telescope.nvim', tag = '0.1.2',
	  -- or                            , branch = '0.1.x',
	  requires = { {'nvim-lua/plenary.nvim'} }
  }

 -------------------------------------------------------------
 -------------------------- THEME ----------------------------
 -------------------------------------------------------------
  use('folke/tokyonight.nvim', {lazy = false}, {priority = 1000})
  use('nvim-treesitter/nvim-treesitter', {run = ':TSUpdate'})
  use('christoomey/vim-tmux-navigator', {lazy = false})
  use('theprimeagen/harpoon')
  use('mbbill/undotree')
  use('tpope/vim-fugitive')

 -------------------------------------------------------------
 ------------------- PRETTIER FORMATTING ---------------------
 -------------------------------------------------------------
 -- use('jay-babu/mason-null-ls.nvim')
 -- use("jose-elias-alvarez/null-ls.nvim")
 -- use('mhartington/formatter.nvim' )



 -- Replace jose-elias-alvarez/null-ls.nvim with nvimtools/none-ls.nvim in your choice of package manager.
 -- https://github.com/nvimtools/none-ls.nvim
  use('jose-elias-alvarez/null-ls.nvim')
  -- use('MunifTanjim/prettier.nvim')



 -------------------------------------------------------------
 ------------------- INDENTATION LINES -----------------------
 -------------------------------------------------------------
  use("lukas-reineke/indent-blankline.nvim")

 -------------------------------------------------------------
 -- MANAGING & INSTALLING LSP SERVERS, LINTERS & FORMATTERS --
 -------------------------------------------------------------
  use {'VonHeikemen/lsp-zero.nvim',
	  branch = 'v2.x',
	  requires = {
		  -- LSP Support
		  {'neovim/nvim-lspconfig'},             -- Required
		  {'williamboman/mason.nvim'},           -- Optional
		  {'williamboman/mason-lspconfig.nvim'}, -- Optional

		  -- Autocompletion
		  {'hrsh7th/nvim-cmp'},     -- Required
		  {'hrsh7th/cmp-nvim-lsp'}, -- Required
		  {'L3MON4D3/LuaSnip'},     -- Required
	  }
  }
  use {
	  'nvim-lualine/lualine.nvim',
	  requires = { 'nvim-tree/nvim-web-devicons', opt = true }
  }
end)
