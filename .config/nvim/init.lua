-- Author: github.com/chillpert
require "user.options"
require "user.plugins"
require "user.keymaps"
require "user.colorscheme"
require "user.cmp"

-- @TODO: These things need to be put elsewhere

-- Enable colorizer plugin
require 'colorizer'.setup()

-- Override status line to improve visibility for horizontal splits
vim.cmd [[hi StatusLine guifg=white guibg=#444444 gui=bold ctermfg=59 ctermbg=black cterm=bold]]
vim.cmd [[hi StatusLineNC guifg=#8a8a8a guibg=#444444 gui=bold ctermfg=59 ctermbg=black cterm=bold]]
