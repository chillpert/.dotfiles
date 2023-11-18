local options = {
    completeopt = { "menu", "menuone", "noselect" },
    mouse = "n",
    clipboard = "unnamedplus",
    termguicolors = true,
    number = true,
    relativenumber = true,
    cursorline = true,
    ignorecase = true,
    smartcase = true,
    swapfile = false,
    backup = false,
    exrc = true,
    shiftwidth = 4,
    tabstop = 4,
    softtabstop = 4,
    expandtab = true,
    smartindent = true,
    splitbelow = true,
    spell = true,
    scrolloff = 8,
    -- autoread = true,
    -- undodir = "~/.vim/undo-dir",
    -- undofile = true,
    signcolumn = "yes", -- add extra column for linting and other output
}

for k, v in pairs(options) do
    vim.opt[k] = v
end
