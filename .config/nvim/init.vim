" Author: github.com/chillpert

" Install plugins via VimPlug
call plug#begin()

Plug 'rhysd/vim-clang-format'
Plug 'bfrg/vim-cpp-modern'

Plug 'patstockwell/vim-monokai-tasty'

Plug 'norcalli/nvim-colorizer.lua'

Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'

Plug 'onsails/lspkind-nvim'

Plug 'mfussenegger/nvim-dap'

Plug 'neovim/nvim-lspconfig'
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'hrsh7th/cmp-buffer'
Plug 'hrsh7th/cmp-path'
Plug 'hrsh7th/nvim-cmp'
Plug 'hrsh7th/cmp-vsnip'
Plug 'hrsh7th/vim-vsnip'
Plug 'hrsh7th/cmp-nvim-lsp-signature-help'
" Plug 'hrsh7th/cmp-nvim-lsp-document-symbol'
Plug 'gfanto/fzf-lsp.nvim'

call plug#end()

" Completion window configuration
set completeopt=menu,menuone,noselect
lua require('lsp-config')

set termguicolors
lua require('colorizer').setup()

" Allow mouse clicking in normal mode
set mouse=n

" Enable (relative) line numbers
set number
set relativenumber

" Set theme
syntax on
let g:vim_monokai_tasty_italic = 1
colorscheme vim-monokai-tasty

" Override status line to improve visibility for horizontal splits
hi StatusLine guifg=white guibg=#444444 gui=bold ctermfg=59 ctermbg=black cterm=bold
hi StatusLineNC guifg=#8a8a8a guibg=#444444 gui=bold ctermfg=59 ctermbg=black cterm=bold

" Yanking and deleting also copies to clipboard
set clipboard+=unnamedplus

" Space to leader
nnoremap <SPACE> <Nop>
let mapleader = " "

" Center search results
nnoremap n nzz
nnoremap N nzz

" Undo breakpoints
inoremap , ,<c-g>u
inoremap . .<c-g>u
inoremap ! !<c-g>u
inoremap ? ?<c-g>u

" Hightlight cursor line for better visibility
set cursorline

" Netrw configuration
nnoremap <Leader>nf :Explore<CR>
nnoremap <Leader>nv :Vexplore<CR> 
nnoremap <Leader>nh :Hexplore<CR> 
nnoremap <Leader>nl :Lexplore<CR> 
nnoremap <Leader>ns :Sexplore<CR> 
let g:netrw_bufsettings = 'noma'

" If searched keyword doesn't have an upper case letter, search becomes case
" insensitive
set ignorecase
set smartcase

" Disable swap files and backups
set noswapfile
set nobackup

" Automatically source other vim scripts in current directory
set exrc

" Default indentation
set shiftwidth=4
set tabstop=4 softtabstop=4
set expandtab
set smartindent

" Ranger-like tab spawn
nnoremap gn :tabnew<CR>

" Use clang-format to format upon save (only if a .clang-format file was placed in root dir)
autocmd FileType c,cpp ClangFormatAutoEnable
let g:clang_format#auto_format=1
let g:clang_format#enable_fallback_style=0

" Open split below instead of above
set splitbelow

" Keep track of changes even after closing vim
set undodir=~/.vim/undo-dir
set undofile

" Add extra column for linting and other output
set signcolumn=yes

" fzf
" Set a default prefix (FzfFiles instead of Files)
let g:fzf_command_prefix = 'Fzf'

" [Buffers] Jump to the existing window if possible
let g:fzf_buffers_jump = 1

" Set custom default command specifically for Unreal Engine
let $FZF_DEFAULT_COMMAND="find ! -name '*.uasset' ! -path '*.git*' ! -path '*Binaries*' ! -path '*Saved*' ! -path '*Content*' ! -path '*DerivedDataCache*' ! -path '*.vscode*' ! -path '*.cache*' ! -path '*Intermediate*'"

let g:fzf_preview_window = ['up:50%', 'ctrl-/']

command! -bang -nargs=? -complete=dir Files
    \ call fzf#vim#files(<q-args>, {'options': ['--layout=reverse', '--info=inline', '--preview', 'nvimpager {}']}, <bang>0)

" All fzf bindings
nnoremap <Leader>o   :FzfFiles!<CR>
nnoremap <Leader>h   :FzfHistory!<CR>
nnoremap <Leader>a   :FzfAg!<CR>
"nnoremap <Leader>r   :FzfRg!<CR>
nnoremap <Leader>b   :FzfBuffers!<CR>
nnoremap <Leader>l   :FzfBLines!<CR>
nnoremap <Leader>m   :FzfMarks!<CR>
nnoremap <Leader>w   :FzfWindows!<CR>
" nnoremap <Leader>h   :FzfHistory:!<CR>
" nnoremap <Leader>s   :FzfSnippets!<CR>
nnoremap <Leader>gh  :FzfCommits!<CR>
nnoremap <Leader>gc  :FzfBCommits!<CR>
nnoremap <Leader>gs  :FzfGFiles!?<CR>
" nnoremap <Leader>gf  :FzfGFiles!<CR>
" nnoremap <Leader>c   :FzfCommands!?<CR>

