return {
  -- Telescope
  {
    'nvim-telescope/telescope.nvim',
    version = '0.1.5',
    dependencies = {
      'nvim-lua/plenary.nvim',
      {
        'nvim-telescope/telescope-fzf-native.nvim',
        build = 'cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build'
      },
    },
  },
  'nvim-telescope/telescope-ui-select.nvim',

  -- Popup UI/Floating Window
  'MunifTanjim/nui.nvim',
  {
    'folke/noice.nvim',
    dependencies = { 'rcarriga/nvim-notify' },
  },

  -- Theme
  { "sainnhe/gruvbox-material" }, -- Gruvbox Material theme
  { "morhetz/gruvbox" },
  { 'nvim-treesitter/nvim-treesitter', build = ':TSUpdate' },
  'christoomey/vim-tmux-navigator',

  -- Tools
  {
    'ThePrimeagen/harpoon',
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function()
      require('harpoon').setup({
        menu = { width = vim.api.nvim_win_get_width(0) - 4 },
      })
    end,
  },
  'mbbill/undotree',
  'tpope/vim-fugitive',

  -- Indentation Lines
  'lukas-reineke/indent-blankline.nvim',

  -- LSP Management
  {
    'VonHeikemen/lsp-zero.nvim',
    branch = 'v2.x',
    dependencies = {
      'neovim/nvim-lspconfig',
      'williamboman/mason.nvim',
      'williamboman/mason-lspconfig.nvim',
      'hrsh7th/nvim-cmp',
      'hrsh7th/cmp-nvim-lsp',
      'L3MON4D3/LuaSnip',
    },
  },

  -- Status Line
  {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
  },

  -- Neo-tree
  {
    'nvim-neo-tree/neo-tree.nvim',
    branch = 'v3.x',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-tree/nvim-web-devicons',
      'MunifTanjim/nui.nvim',
    },
  },

  -- Prettier Formatting
  {
    'nvimtools/none-ls.nvim',
    config = function()
      require('null-ls').setup()
    end,
    dependencies = { 'nvim-lua/plenary.nvim' },
  },

  -- Obsidian
  {
    'epwalsh/obsidian.nvim',
    tag = '*',
    dependencies = {
      'nvim-lua/plenary.nvim',
    },
  },

  -- Markdown Preview
  {
    'iamcco/markdown-preview.nvim',
    build = 'cd app && npm install',
    setup = function()
      vim.g.mkdp_filetypes = { 'markdown' }
    end,
    ft = { 'markdown' },
  },

  -- File Browser
  {
    'nvim-telescope/telescope-file-browser.nvim',
    dependencies = { 'nvim-telescope/telescope.nvim', 'nvim-lua/plenary.nvim' },
  },
}

