-- @NOTE: Don't forget to update regularly with `PlugUpdate`
local Plug = vim.fn["plug#"]

vim.call("plug#begin")

-- colors and theming
Plug 'tanvirtin/monokai.nvim'
Plug 'norcalli/nvim-colorizer.lua'
Plug('nvim-treesitter/nvim-treesitter', { ['do'] = vim.fn[':TSUpdate'] })

-- navigation
Plug('ibhagwan/fzf-lua', { ['branch'] = 'main' })

-- coding
Plug 'numToStr/Comment.nvim'
Plug 'lewis6991/gitsigns.nvim'
Plug 'windwp/nvim-autopairs'

-- lsp
Plug 'mfussenegger/nvim-dap'
Plug 'neovim/nvim-lspconfig'

-- cmp
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'hrsh7th/cmp-buffer'
Plug 'hrsh7th/cmp-path'
Plug 'hrsh7th/nvim-cmp'

-- cmp extras
Plug 'hrsh7th/cmp-nvim-lsp-signature-help'
Plug 'onsails/lspkind-nvim'
Plug 'p00f/clangd_extensions.nvim'

-- snippets
Plug 'hrsh7th/cmp-vsnip'
Plug 'hrsh7th/vim-vsnip'

vim.call("plug#end")

-- All plugins that don't require any configuration may be set up here
require 'colorizer'.setup()
require 'Comment'.setup()
require 'nvim-autopairs'.setup {}
