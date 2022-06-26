call plug#begin('~/.vim/plugged')
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-commentary'
Plug 'christoomey/vim-tmux-navigator'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
call plug#end()

"let g:airline_powerline_fonts=1
let g:airline#extensions#tabline#enabled = 1 " Enable the list of buffers
let g:airline#extensions#tabline#buffer_nr_show = 1

"hide the save warning when switching buffers with unsaved changes
set hidden

"this turns off the bell sound that can occur after certain key presses
set visualbell
set t_vb=

"this turns on incremental search highlighting
set incsearch
set hlsearch

"this turns absolute and relative line numbering on by default
set nu rnu

"this converts tabs to spaces
set tabstop=2 shiftwidth=2 softtabstop=2 expandtab autoindent smartindent

"change the displayed tab character to </u2192/> u2192
"and end of line character to u21b2
"set listchars=tab:→\  
set list listchars=tab:→\ ,trail:·,nbsp:·

"Nerdtree like experience using netrw
let g:netrw_banner = 0
let g:netrw_liststyle = 3
let g:netrw_browse_split = 4
let g:netrw_altv = 1
let g:netrw_winsize = 25 
let ghregex='\(^\|\s\s\)\zs\.\S\+'
let g:netrw_list_hide=ghregex
let g:netrw_fastbrowse=0
"augroup ProjectDrawer
"  autocmd!
"  autocmd VimEnter * :Lexplore
"  autocmd VimEnter * wincmd l
"augroup END
set autochdir " Change directory to the current buffer when opening files.

"filetype and plugin detection
filetype plugin indent on
syntax on

" Source Vim configuration file and install plugins
nnoremap <silent><C-w>1 :source ~/.vimrc \| :PlugInstall<CR>
nnoremap <silent><C-w>2 :e $MYVIMRC<cr>

"key remaps
" nnoremap <silent> <C-w>p :Files<CR>
nnoremap <Tab> :bnext<CR>
nnoremap <S-Tab> :bprevious<CR>
nnoremap <C-p> :Lex<CR>
nnoremap <C-p>p :GFiles<CR>
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l
nnoremap <C-f> :Rg<Cr>
