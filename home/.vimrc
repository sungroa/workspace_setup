syntax on
colorscheme ron
set nohlsearch
set number
set ls=2
set statusline=%F%=%l-%c\ %P
set mouse-=a
set clipboard+=unnamed
nmap <F2> :set invnumber<CR>
nmap <F3> :set hlsearch!<CR>
set pastetoggle=<F4>
set autoindent nocindent
set expandtab
set shiftwidth=2
set tabstop=2
set ignorecase smartcase
set formatoptions=croqlj
filetype plugin indent on
autocmd BufNewFile,BufRead .bash_common set filetype=sh
fun! TrimWhitespace()
    let l:save = winsaveview()
    keeppatterns %s/\s\+$//e
    call winrestview(l:save)
endfun
command! TrimWhitespace call TrimWhitespace()
