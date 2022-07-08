local colorscheme = "gruvbox" -- "vscode" -- "monokai" -- "vim-monokai-tasty"

local status_ok, _ = pcall(vim.cmd, "colorscheme " .. colorscheme)
if not status_ok then
    vim.notify("colorscheme " .. colorscheme .. " not found!")
    return
end

-- vim.g.vim_monokai_tasty_italic = 1
-- vim.o.background = "dark"
-- vim.g.vscode_transparent = 1
-- vim.g.vscode_italic_comment = 1

vim.o.background = "dark"
