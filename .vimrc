syntax on
" colorscheme elflord
" colorscheme slate
colorscheme ron
set nohlsearch
set number
set ls=2
set statusline=%F%=%l-%c\ %P
set mouse-=a
set clipboard+=unnamed
nmap <F2> :set invnumber<CR>
nmap <F3> :set hlsearch!<CR>
set autoindent nocindent
set expandtab
set shiftwidth=2
set tabstop=2
set ignorecase smartcase
set formatoptions=croqlj
filetype plugin indent on
" Getting ctrlp stuff for easier file browsing.
set runtimepath^=~/.vim/bundle/ctrlp.vim
nnoremap <Leader>f :CtrlP %:h<CR>
nnoremap <Leader>b :CtrlPBuffer<CR>
nnoremap <Leader>m :CtrlPMRUFiles<CR>
nnoremap yp :let @+ = expand("%")<CR>
