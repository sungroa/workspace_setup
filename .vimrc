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
set autoindent nocindent
set ignorecase smartcase
set formatoptions=croqlj
filetype plugin indent on
nnoremap <Leader>f :CtrlP %:h<CR>
nnoremap <Leader>b :CtrlPBuffer<CR>
nnoremap <Leader>m :CtrlPMRUFiles<CR>
nnoremap <Leader>r :RelatedFilesWindow<CR>
nnoremap yp :let @+ = expand("%")<CR>
