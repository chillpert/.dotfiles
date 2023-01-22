-- Install packer
local ensure_packer = function()
    local fn = vim.fn
    local install_path = fn.stdpath('data') .. '/site/pack/packer/start/packer.nvim'
    if fn.empty(fn.glob(install_path)) > 0 then
        fn.system({ 'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path })
        vim.cmd [[packadd packer.nvim]]
        return true
    end
    return false
end

local packer_bootstrap = ensure_packer()

require('packer').startup(function(use)
    -- Package manager
    use 'wbthomason/packer.nvim'

    use 'tanvirtin/monokai.nvim' -- The best theme

    use { -- Display colors
        'norcalli/nvim-colorizer.lua',
        config = function()
            require("colorizer").setup()
        end
    }

    use {
        'nvim-treesitter/nvim-treesitter',
        run = ':TSUpdate',
    }

    use 'nvim-treesitter/nvim-treesitter-context' -- Keep the current function's name in the first line
    use 'nvim-treesitter/nvim-treesitter-textobjects'

    use { 'ibhagwan/fzf-lua', -- Telescope, but better
        requires = { 'nvim-tree/nvim-web-devicons' },
        config = function()
            require 'fzf-lua'.setup {
                file_ignore_patterns = { "%.png$", "%.exe$", "%.tex$", "%.uasset$", "%.eps$", "%.pdf$", "%.sty$",
                    "Documentation/", "Content/" },
                winopts = {
                    fullscreen = true,
                    preview = {
                        vertical = "down:40%",
                        layout = "vertical",
                    },
                },
            }
        end
    }

    use { -- Shows possible keymaps when you are choking
        "folke/which-key.nvim",
        config = function()
            vim.o.timeout = true
            vim.o.timeoutlen = 300
            require 'which-key'.setup {}
        end
    }

    use { -- Quickly comment code selections
        'numToStr/Comment.nvim',
        config = function()
            require 'Comment'.setup {}
        end
    }

    use { -- Highlights all occurrences of
        'RRethy/vim-illuminate',
        config = function()
            require 'illuminate'.configure {}
        end
    }

    use 'lewis6991/gitsigns.nvim'

    use { -- Automatically insert braces etc.
        'windwp/nvim-autopairs',
        config = function()
            require 'nvim-autopairs'.setup {}
        end
    }

    use 'nvim-lua/plenary.nvim'
    use 'lukas-reineke/indent-blankline.nvim' -- Add indentation guides even on blank lines

    use 'jakemason/ouroboros' -- Switch between source and header

    -- LSP

    -- Debugging
    use 'mfussenegger/nvim-dap'
    use 'rcarriga/nvim-dap-ui'

    use { -- Rename globally
        'windwp/nvim-spectre',
        config = function()
            require 'spectre'.setup {}
        end
    }

    -- cmp
    use {
        'hrsh7th/nvim-cmp',
        requires = {
            -- LSP support
            { 'neovim/nvim-lspconfig' },

            -- Autocompletion
            { 'hrsh7th/cmp-nvim-lsp' },
            { 'hrsh7th/cmp-buffer' },
            { 'hrsh7th/cmp-path' },
            { 'hrsh7th/cmp-nvim-lsp-signature-help' },
            { 'hrsh7th/cmp-vsnip' },
            { 'hrsh7th/vim-vsnip' },
            { 'saadparwaiz1/cmp_luasnip' },

            -- Snippets
            { 'L3MON4D3/LuaSnip' },
            { 'rafamadriz/friendly-snippets' },
        }
    }

    -- cmp extras
    use 'onsails/lspkind-nvim'
    use 'p00f/clangd_extensions.nvim'

    -- Markdown
    use({
        "iamcco/markdown-preview.nvim",
        run = function()
            vim.fn["mkdp#util#install"]()
        end,
        config = function()
            vim.g.mkdp_browser = 'firefox'
            vim.g.mkdp_auto_start = 1
            vim.g.mkdp_auto_open = 1
            vim.g.mkdp_auto_close = 1
        end,

    })

    if packer_bootstrap then
        require('packer').sync()
    end
end)

local dap = require('dap')
dap.adapters.lldb = {
    type = 'executable',
    command = '/usr/bin/lldb-vscode', -- adjust as needed, must be absolute path
    name = 'lldb'
}

dap.configurations.cpp = {
    {
        name = 'Launch',
        type = 'lldb',
        request = 'launch',
        program = function()
            return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
        end,
        cwd = '${workspaceFolder}',
        stopOnEntry = false,
        args = {},
    },
}
