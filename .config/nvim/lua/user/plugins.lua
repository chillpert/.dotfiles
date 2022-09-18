-- @NOTE: Don't forget to update regularly with `PlugUpdate`
local Plug = vim.fn["plug#"]

vim.call("plug#begin")

-- colors and theming
Plug 'tanvirtin/monokai.nvim'
Plug 'norcalli/nvim-colorizer.lua'
Plug('nvim-treesitter/nvim-treesitter', { ['do'] = vim.fn[':TSUpdate'] })
Plug 'nvim-treesitter/nvim-treesitter-context'

-- navigation
Plug('ibhagwan/fzf-lua', { ['branch'] = 'main' })
Plug 'folke/which-key.nvim'
Plug 'phaazon/hop.nvim'

-- coding
Plug 'numToStr/Comment.nvim'
Plug 'lewis6991/gitsigns.nvim'
Plug 'windwp/nvim-autopairs'
Plug 'RRethy/vim-illuminate'
Plug 'nvim-lua/plenary.nvim'
Plug 'windwp/nvim-spectre'

-- lsp
Plug 'neovim/nvim-lspconfig'

-- debugging
Plug 'mfussenegger/nvim-dap'
Plug 'rcarriga/nvim-dap-ui'
Plug 'puremourning/vimspector'

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

-- markdown
Plug('iamcco/markdown-preview.nvim', { ['do'] = vim.fn[':call mkdp#util#install'] })
-- If it doesn't work run: :call mkdp#util#install()

vim.call("plug#end")

-- All plugins that don't require any configuration may be set up here
require 'colorizer'.setup()
require 'Comment'.setup()
require 'nvim-autopairs'.setup {}
require 'which-key'.setup {}
require 'hop'.setup {} -- needs to be set up after monokai theme
require 'illuminate'.configure({
    providers = {
        'lsp',
        'treesitter',
    },
})
require 'spectre'.setup()

vim.g.vimspector_enable_mappings = "HUMAN";

-- Markdown preview settings
vim.g.mkdp_browser = 'firefox';
vim.g.mkdp_auto_start = 1;
vim.g.mkdp_auto_open = 1;
vim.g.mkdp_auto_close = 1;
