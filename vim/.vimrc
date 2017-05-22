set nocompatible

call plug#begin()
Plug 'tpope/vim-sensible'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-unimpaired'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-vinegar'
Plug 'tpope/vim-fugitive'
Plug 'hynek/vim-python-pep8-indent'
Plug 'scrooloose/syntastic'
Plug 'christoomey/vim-tmux-navigator'
Plug 'bronson/vim-visual-star-search'
Plug 'chriskempson/base16-vim'
Plug '/usr/local/opt/fzf' | Plug 'junegunn/fzf.vim'
Plug 'ervandew/supertab'
if v:version >= 800 && (has('python') || has('python3'))
    Plug 'maralla/completor.vim'
endif
call plug#end()
let g:completor_auto_trigger=0


" Buffers
set hidden
" Windows
set nosplitbelow
set nosplitright
set diffopt+=vertical
" Tabs
set shiftwidth=4
set tabstop=4
set expandtab
" Mouse
set mouse=a                     " mouse support in terminals
if &term =~ '^screen'
    " resize splits in tmux
    set ttymouse=xterm2
endif
" Clipboard
set clipboard=unnamed           " yanks and cuts go in system clipboard
" Search
set ignorecase
set smartcase
set showmatch
set hlsearch
" Keys
set pastetoggle=<Leader>tp
nnoremap <leader><space> :noh<cr>
" h and l and ~ wrap over lines
set whichwrap=h,l,~
" Q reformats current paragraph or selected text
nnoremap Q gqap
vnoremap Q gq
" Make Y yank to the end of the line (like C and D) rather than the entire
" line
noremap Y y$
" Use up and down to move by screen line
map <up> gk
map <down> gj
vmap <up> gk
vmap <down> gj
inoremap <up> <c-o>gk
inoremap <down> <c-o>gj
nmap k gk
nmap j gj
vmap k gk
vmap j gj
" Color long lines
set colorcolumn=80
set cursorline

" Show list of possible files on tab completion, rather than first guess
set wildmode=longest,list

function! StatuslineGit()
    let l:branchname = fugitive#head()
    return strlen(l:branchname) > 0?'  '.l:branchname.' ':''
endfunction
set statusline=
set statusline+=%#PmenuSel#
set statusline+=%{StatuslineGit()}
set statusline+=%#LineNr#
set statusline+=\ %f\ %y\ %=%c,%l/%L

try
    " Use base16-default-dark
    let base16colorspace=256
    colorscheme base16-default-dark
catch
    " Otheriwse default
    set background=dark
    colorscheme default
endtry
" Match shell base16 colorscheme if set
if filereadable(expand("~/.vimrc_background"))
    source ~/.vimrc_background
endif

" Set fullscreen background to same color as normal text
if has("gui_running")
    set gfn=Source\ Code\ Pro:h13
    set fuoptions=maxvert
    set guioptions-=T
endif

" Change default position of new splits
set splitbelow
set splitright

" Open in TeXShop
nnoremap <leader>tx :!open -a TeXShop %<cr><cr>

" Use :w!! to save root files you forgot to open with sudo
ca w!! w !sudo tee "%"

" Syntastic options
let g:syntastic_check_on_open=1
let g:syntastic_python_checkers=["flake8"]
" let g:syntastic_python_flake8_args="--max-line-length=100"

" Format-specific formating
autocmd FileType markdown,text setlocal ai fo+=n nojoinspaces
autocmd Filetype gitcommit,markdown,text setlocal spell
autocmd FileType python setlocal textwidth=79 colorcolumn=79

" Go to the last cursor location when file opened, unless a git commit
au BufReadPost *
    \ if line("'\"") > 0 && line("'\"") <= line("$") && &filetype != "gitcommit" |
        \ execute("normal `\"") |
    \ endif

" Expand %% to directory of file in current buffer (also %:h<Tab>)
cnoremap <expr> %% getcmdtype() == ':' ? expand('%:h').'/' : '%%'

" Learn not to use arrow keys
noremap <Up> <Nop>
noremap <Down> <Nop>
noremap <Left> <Nop>
noremap <Right> <Nop>
inoremap <Up> <Nop>
inoremap <Down> <Nop>
inoremap <Left> <Nop>
inoremap <Right> <Nop>

" Name current syntax group
map <F10> :echo "hi<" . synIDattr(synID(line("."),col("."),1),"name") . '> trans<'
\ . synIDattr(synID(line("."),col("."),0),"name") . "> lo<"
\ . synIDattr(synIDtrans(synID(line("."),col("."),1)),"name") . ">"<CR>

" ss to generate new split
nnoremap <silent> ss <C-w>s

" readline bindings for command mode
cnoremap <C-A> <Home>
cnoremap <C-E> <End>

" FZF bindings
nmap <leader>h :History<cr>
vmap <leader>b :Buffers<cr>
