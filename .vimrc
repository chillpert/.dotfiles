" Author: github.com/chillpert

" -----------------------------------------------------------------------------
" Plugin manager (Vim-Plug, install with AUR)
" -----------------------------------------------------------------------------
call plug#begin('~/.vim/plugged')

Plug 'neoclide/coc.nvim', {'branch': 'release'} " Autocompletion for all sorts of languages
"Plug 'ycm-core/YouCompleteMe'
"Plug 'vim-scripts/cscope.vim'
Plug 'puremourning/vimspector' " Debug like with an IDE
Plug 'rhysd/vim-clang-format' " Autoformat using clang-format
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } } " Fuzzy file search for all kinds of vim features
Plug 'junegunn/fzf.vim' " Requires the_silver_searcher, ripgrep, fzf, git-delta, bat packages to work fully
Plug 'bfrg/vim-cpp-modern' " More up-to-date syntax highlighting
Plug 'tpope/vim-fugitive' " For git support 
Plug 'chrisbra/Colorizer'
"Plug 'vim-airline/vim-airline'

call plug#end()

" -----------------------------------------------------------------------------
" Settings
" -----------------------------------------------------------------------------
" Enable mouse click (necessary for vimspector)
set ttymouse=xterm2
set mouse=a

" Space to leader
nnoremap <SPACE> <Nop>
let mapleader = " "

" Vimspector
let g:vimspector_enable_mappings = 'HUMAN'
nnoremap <Leader>dr :call vimspector#Reset()<CR>
nnoremap <Leader>dB :call vimspector#ClearBreakpoints()<CR>

" Enable copy to clipboard in visual mode (works without the X11 feature enabled)
vnoremap <C-c> y: call system("xclip -selection clipboard", getreg("\""))<CR>

" Code highlighting for C++ 
let g:cpp_function_highlight=1
let g:cpp_attributes_highlight=1
let g:cpp_member_highlight=1

" Show line numbers 
set number

" Hightlight cursor line for better visibility
set cursorline

" Keep the cursor vertically centered (consider using zz instead?)
" set so=999

" Remove banner for netrw and show line numbers in netrw as well
nnoremap <Leader>ff :Explore<CR>
nnoremap <Leader>fv  :Vexplore<CR> 
nnoremap <Leader>fh  :Hexplore<CR> 
nnoremap <Leader>fl  :Lexplore<CR> 
let g:netrw_bufsettings = 'noma nomod nu nobl nowrap ro'
"let g:netrw_banner=0
let g:netrw_list_hide = '\(^\|\s\s\)\zs\.\S\+,\(^\|\s\s\)ntuser\.\S\+'
autocmd FileType netrw set nolist

" Highlight as you search
set is hls

" Open split below instead of above
set splitbelow

" Default indentation
"set expandtab
set shiftwidth=4
set tabstop=4
"set smartindent
"set autoindent

" Ctrl+p for finding files with FZF
nnoremap <C-p> :Files<CR>

" Navigate splits with 'leader h,j,k,l'
nnoremap <C-h> <C-W>h
nnoremap <C-j> <C-W>j
nnoremap <C-k> <C-W>k
nnoremap <C-l> <C-W>l

" Consistent faster scrolling
"" normal mode:
"nnoremap <c-j> 5j
"nnoremap <c-k> 5k
"" visual mode:
"xnoremap <c-j> 5j
"xnoremap <c-k> 5k

" Simply speed up the default bindings for resizing splits 
nnoremap <C-w>+ :resize +5<cr>
nnoremap <C-w>- :resize -5<cr>
nnoremap <C-w>< :vertical resize -10<cr>
nnoremap <C-w>> :vertical resize +10<cr>

" Ranger-like tab spawn
nnoremap gn :tabnew<CR>

" Theme
syntax on
let g:vim_monokai_tasty_italic=1
let g:monokai_gui_italic=1
colorscheme vim-monokai-tasty

" Use clang-format to format upon save (only if a .clang-format file was placed in root dir)
autocmd FileType c,cpp ClangFormatAutoEnable
let g:clang_format#auto_format=1
let g:clang_format#enable_fallback_style=0

" Fix transparency
hi Normal guibg=NONE ctermbg=NONE
hi LineNr ctermbg=NONE guibg=NONE

" -----------------------------------------------------------------------------
" Auto-highlight word under cursor
" -----------------------------------------------------------------------------
" Replace 'Underlined' with anything from :highlight
setl updatetime=300

" highlight the word under cursor (CursorMoved is inperformant)
highlight WordUnderCursor cterm=underline gui=underline
autocmd CursorHold * call HighlightCursorWord()
function! HighlightCursorWord()
    " if hlsearch is active, don't overwrite it!
    let search = getreg('/')
    let cword = expand('<cword>')
    if match(cword, search) == -1
        exe printf('match WordUnderCursor /\V\<%s\>/', escape(cword, '/\'))
    endif
endfunction

" -----------------------------------------------------------------------------
" Coc
" -----------------------------------------------------------------------------
let g:coc_global_extensions=[ 'coc-omnisharp', 'coc-cmake', 'coc-clangd' ]

" Set internal encoding of vim, not needed on neovim, since coc.nvim using some
" unicode characters in the file autoload/float.vim
set encoding=utf-8

" TextEdit might fail if hidden is not set.
set hidden

" Some servers have issues with backup files, see #649.
set nobackup
set nowritebackup

" Give more space for displaying messages.
set cmdheight=2

" Having longer updatetime (default is 4000 ms = 4 s) leads to noticeable
" delays and poor user experience.
set updatetime=300

" Don't pass messages to |ins-completion-menu|.
set shortmess+=c

" Always show the signcolumn, otherwise it would shift the text each time
" diagnostics appear/become resolved.
if has("nvim-0.5.0") || has("patch-8.1.1564")
  " Recently vim can merge signcolumn and number column into one
  set signcolumn=number
else
  set signcolumn=yes
endif

" Use tab for trigger completion with characters ahead and navigate.
" NOTE: Use command ':verbose imap <tab>' to make sure tab is not mapped by
" other plugin before putting this into your config.
inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" Use <c-space> to trigger completion.
if has('nvim')
  inoremap <silent><expr> <c-space> coc#refresh()
else
  inoremap <silent><expr> <c-@> coc#refresh()
endif

" Make <CR> auto-select the first completion item and notify coc.nvim to
" format on enter, <cr> could be remapped by other vim plugin
inoremap <silent><expr> <cr> pumvisible() ? coc#_select_confirm()
                              \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

" Use `[g` and `]g` to navigate diagnostics
" Use `:CocDiagnostics` to get all diagnostics of current buffer in location list.
nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)

" GoTo code navigation.
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" Use K to show documentation in preview window.
nnoremap <silent> K :call <SID>show_documentation()<CR>

function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  elseif (coc#rpc#ready())
    call CocActionAsync('doHover')
  else
    execute '!' . &keywordprg . " " . expand('<cword>')
  endif
endfunction

" Highlight the symbol and its references when holding the cursor.
autocmd CursorHold * silent call CocActionAsync('highlight')

" Symbol renaming.
nmap <leader>rn <Plug>(coc-rename)

" Formatting selected code.
xmap <leader>f  <Plug>(coc-format-selected)
nmap <leader>f  <Plug>(coc-format-selected)

augroup mygroup
  autocmd!
  " Setup formatexpr specified filetype(s).
  autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
  " Update signature help on jump placeholder.
  autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
augroup end

" Applying codeAction to the selected region.
" Example: `<leader>aap` for current paragraph
xmap <leader>a  <Plug>(coc-codeaction-selected)
nmap <leader>a  <Plug>(coc-codeaction-selected)

" Remap keys for applying codeAction to the current buffer.
nmap <leader>ac  <Plug>(coc-codeaction)
" Apply AutoFix to problem on the current line.
nmap <leader>qf  <Plug>(coc-fix-current)

" Map function and class text objects
" NOTE: Requires 'textDocument.documentSymbol' support from the language server.
xmap if <Plug>(coc-funcobj-i)
omap if <Plug>(coc-funcobj-i)
xmap af <Plug>(coc-funcobj-a)
omap af <Plug>(coc-funcobj-a)
xmap ic <Plug>(coc-classobj-i)
omap ic <Plug>(coc-classobj-i)
xmap ac <Plug>(coc-classobj-a)
omap ac <Plug>(coc-classobj-a)

" Remap <C-f> and <C-b> for scroll float windows/popups.
if has('nvim-0.4.0') || has('patch-8.2.0750')
  nnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
  nnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
  inoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(1)\<cr>" : "\<Right>"
  inoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(0)\<cr>" : "\<Left>"
  vnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
  vnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
endif

" Use CTRL-S for selections ranges.
" Requires 'textDocument/selectionRange' support of language server.
nmap <silent> <C-s> <Plug>(coc-range-select)
xmap <silent> <C-s> <Plug>(coc-range-select)

" Add `:Format` command to format current buffer.
command! -nargs=0 Format :call CocAction('format')

" Add `:Fold` command to fold current buffer.
command! -nargs=? Fold :call     CocAction('fold', <f-args>)

" Add `:OR` command for organize imports of the current buffer.
command! -nargs=0 OR   :call     CocAction('runCommand', 'editor.action.organizeImport')

" Add (Neo)Vim's native statusline support.
" NOTE: Please see `:h coc-status` for integrations with external plugins that
" provide custom statusline: lightline.vim, vim-airline.
"set statusline^=%{coc#status()}%{get(b:,'coc_current_function','')}

" Mappings for CoCList
" Show all diagnostics.
nnoremap <silent><nowait> <space>a  :<C-u>CocList diagnostics<cr>
" Manage extensions.
nnoremap <silent><nowait> <space>e  :<C-u>CocList extensions<cr>
" Show commands.
nnoremap <silent><nowait> <space>c  :<C-u>CocList commands<cr>
" Find symbol of current document.
nnoremap <silent><nowait> <space>o  :<C-u>CocList outline<cr>
" Search workspace symbols.
nnoremap <silent><nowait> <space>s  :<C-u>CocList -I symbols<cr>
" Do default action for next item.
nnoremap <silent><nowait> <space>j  :<C-u>CocNext<CR>
" Do default action for previous item.
nnoremap <silent><nowait> <space>k  :<C-u>CocPrev<CR>
" Resume latest coc list.
nnoremap <silent><nowait> <space>p  :<C-u>CocListResume<CR>

" -----------------------------------------------------------------------------
" Garbage and testing 
" -----------------------------------------------------------------------------

" Spawn a terminal emulator (alacritty) in the current file's directory 
"noremap <F6> :let $VIM_DIR=expand('%:p:h')<CR>:terminal<CR>cd $VIM_DIR<CR>clear<CR>

" Toggle line wrapping
"noremap <F8> :set wrap!<CR>

" Quickly open ranger in cwd
"nnoremap <F7> :let $VIM_DIR=expand('%:p:h')<CR>:terminal<CR>cd $VIM_DIR<CR>clear<CR>ranger .<CR>

" YCM
"let g:ycm_key_list_stop_completion = ['<C-x>']
"let g:ycm_filetype_whitelist = { 'cpp':1, 'h':2, 'hpp':3, 'c':4, 'cxx':5 }
"let g:ycm_autoclose_preview_window_after_insertion=1
"let g:ycm_autoclose_preview_window_after_completion=1
"let g:ycm_enable_diagnostic_signs=0 " Disable >> error to the left
"let g:ycm_collect_identifiers_from_tags_files=1
"set signcolumn=yes " always show vim gutter
"nnoremap <C-]> :YcmCompleter GoTo<CR>
"let g:ycm_collect_identifiers_from_tags_files = 1
"set tags+=/mnt/data/UnrealEngine/tags

" Replace search term (when pressing *)
"nnoremap <leader>r :%s///g<Left><Left>
"nnoremap <leader>rc :%s///gc<Left><Left><Left>
