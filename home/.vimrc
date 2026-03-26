syntax on
colorscheme ron

" Disable persistent search highlighting after search completes to prevent screen clutter.
set nohlsearch
set number

" Always show the status line (even with one window) to provide context.
set ls=2
set statusline=%F%=%l-%c\ %P
" Disable mouse support to ensure terminal-native text selection/copy-paste works smoothly.
set mouse-=a

" Use the system OS clipboard by default for yank/paste operations.
set clipboard+=unnamed

nmap <F2> :set invnumber<CR>
nmap <F3> :set hlsearch!<CR>
set pastetoggle=<F4>

set autoindent nocindent
set expandtab
set shiftwidth=2
set tabstop=2

" Search is case-insensitive by default, but becomes case-sensitive if you type an uppercase letter.
set ignorecase smartcase
set formatoptions=croqlj
filetype plugin indent on

" Ensure our custom extensionless bash script gets proper shell syntax highlighting.
autocmd BufNewFile,BufRead .bash_common set filetype=sh

" Utility function to strip trailing whitespace cleanly without jumping the cursor payload.
fun! TrimWhitespace()
    let l:save = winsaveview()
    keeppatterns %s/\s\+$//e
    call winrestview(l:save)
endfun
command! TrimWhitespace call TrimWhitespace()
