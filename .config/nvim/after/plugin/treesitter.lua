require 'nvim-treesitter.configs'.setup {
    ensure_installed = { "vimdoc", "cpp", "lua", "cmake", "bash" },
    highlight = {
        enable = true,
    },
}

require 'treesitter-context'.setup {
    patterns = {
        default = {
            'class',
            'function',
            'method',
            -- 'for',
            -- 'while',
            -- 'if',
            -- 'switch',
            -- 'case',
        },
    },
}
