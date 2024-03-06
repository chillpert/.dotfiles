require 'monokai'.setup {
    palette = {
        name = 'monokai',
        base1 = '#272a30',
        base2 = '#26292c',
        base3 = '#2E323C',
        base4 = '#333842',
        base5 = '#4d5154',
        base6 = '#9ca0a4',
        base7 = '#b1b1b1',
        border = '#a1b5b1',
        brown = '#504945',
        white = '#f8f8f0',
        grey = '#8F908A',
        black = '#000000',
        pink = '#f92672',
        green = '#a6e22e',
        aqua = '#66d9ef',
        yellow = '#e6db74',
        orange = '#fd971f',
        purple = '#ae81ff',
        red = '#e95678',
        diff_add = '#3d5213',
        diff_remove = '#4a0f23',
        diff_change = '#27406b',
        diff_text = '#23324d',
    },
    custom_hlgroups = {},
}

local colorscheme = "monokai"

local status_ok, _ = pcall(vim.cmd, "colorscheme " .. colorscheme)
if not status_ok then
    vim.notify("colorscheme " .. colorscheme .. " not found!")
    return
end

-- Override status line to improve visibility for horizontal splits
-- vim.cmd [[hi StatusLine guifg=white guibg=#444444 gui=bold ctermfg=59 ctermbg=black cterm=bold]]
-- vim.cmd [[hi StatusLineNC guifg=#8a8a8a guibg=#444444 gui=bold ctermfg=59 ctermbg=black cterm=bold]]

-- Adjust background color for treesitter-context
vim.cmd [[hi TreesitterContext guibg=#2e323c]]

-- Attempting to improve readability of tabs with monokai theme
vim.cmd [[hi TabLineSel guibg=#272a30]]
vim.cmd [[hi Title guibg=#2e323c]]
vim.cmd [[hi TabLine guibg=#2e323c]]
vim.cmd [[hi TabLineFill guibg=#2e323c]]

-- Fix visibility for popup windows
vim.cmd [[hi NormalFloat guibg=#4d5154]]

-- Gitsigns to match monokai
vim.cmd [[hi GitSignsChange guifg=#ae81ff guibg=#262626 gui=bold ctermfg=59 ctermbg=black cterm=bold]]

-- Keep spell checking font color the same but keep red line below (improves readability)
vim.cmd([[
  hi clear SpellBad
  hi SpellBad cterm=underline gui=undercurl guisp=red
]])
