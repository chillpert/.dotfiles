-- Author: github.com/chillpert
local Plug = vim.fn["plug#"]

vim.call("plug#begin")

-- Plug 'patstockwell/vim-monokai-tasty'
-- Plug 'Mofiqul/vscode.nvim'
-- Plug 'tanvirtin/monokai.nvim'
Plug 'ellisonleao/gruvbox.nvim'
Plug 'norcalli/nvim-colorizer.lua'
Plug('ibhagwan/fzf-lua', { ['branch'] = 'main' })
Plug 'onsails/lspkind-nvim'
-- Plug 'rhysd/vim-clang-format'
-- Plug 'bfrg/vim-cpp-modern'
Plug 'mfussenegger/nvim-dap'
Plug 'neovim/nvim-lspconfig'
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'hrsh7th/cmp-buffer'
Plug 'hrsh7th/cmp-path'
Plug 'hrsh7th/nvim-cmp'
Plug 'hrsh7th/cmp-vsnip'
Plug 'hrsh7th/vim-vsnip'
Plug 'hrsh7th/cmp-nvim-lsp-signature-help'
Plug 'gfanto/fzf-lsp.nvim'
Plug 'p00f/clangd_extensions.nvim'
Plug('nvim-treesitter/nvim-treesitter', { ['do'] = vim.fn[':TSUpdate'] })

vim.call("plug#end")

-- Fzf configuration
local actions = require "fzf-lua.actions"
require "fzf-lua".setup {
    winopts = {
        fullscreen = true,
        preview = {
            vertical = "down:40%",
            layout = "vertical",
        },
    },
}

local dap_status_ok, dap = pcall(require, "dap")
dap.adapters.cppdbg = {
    id = 'cppdbg',
    type = 'executable',
    command = '/home/n30/.vscode/extensions/ms-vscode.cpptools-1.10.7-linux-x64/debugAdapters/bin/OpenDebugAD7',
}

-- @TODO: Not working
dap.configurations.cpp = {
    {
        name = "Launch Marmortal (Debug)",
        type = "cppdbg",
        request = "launch",
        program = "/home/n30/Repos/Marmortal/Binaries/Linux/Marmortal-Linux-DebugGame",
        cwd = "/mnt/data/unrealengine",
        -- visualizerFile = "/mnt/data/unrealengine/Engine/Extras/VisualStudioDebugging/Unreal.natvis",
        -- showDisplayString = "true",
    }
}

require 'nvim-treesitter.configs'.setup {
    ensure_installed = { "cpp", "lua", "cmake", "bash" },
    highlight = {
        enable = true,
    },
}

require 'gruvbox'.setup {}
