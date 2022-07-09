require 'nvim-treesitter.configs'.setup {
    ensure_installed = { "cpp", "lua", "cmake", "bash" },
    highlight = {
        enable = true,
    },
}
