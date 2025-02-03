call plug#begin(stdpath('data') . '/vimplug')
Plug 'Vimjas/vim-python-pep8-indent'
Plug 'ap/vim-buftabline'
Plug 'aymericbeaumet/vim-symlink'
Plug 'christoomey/vim-tmux-navigator'
Plug 'cocopon/iceberg.vim'
Plug 'junegunn/fzf'
Plug 'justinmk/vim-dirvish'
Plug 'mbbill/undotree'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-rhubarb'
Plug 'tpope/vim-sensible'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-unimpaired'

Plug 'L3MON4D3/LuaSnip'
Plug 'ibhagwan/smartyank.nvim'
Plug 'stevearc/conform.nvim'
Plug 'nvim-lua/plenary.nvim'
Plug 'neovim/nvim-lspconfig'
Plug 'williamboman/mason.nvim'
Plug 'williamboman/mason-lspconfig.nvim'
Plug 'hrsh7th/nvim-cmp'
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'hrsh7th/cmp-buffer'
Plug 'hrsh7th/cmp-path'
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
Plug 'nvim-treesitter/nvim-treesitter-textobjects'
Plug 'lewis6991/gitsigns.nvim'
Plug 'ibhagwan/fzf-lua', {'branch': 'main'}
call plug#end()

try
    execute 'source ' . stdpath('config') . '/private.vim'
catch /E484:/
    echom "private.vim not found"
endtry

lua <<EOF
-- files
vim.opt.swapfile = false
-- Remember more files
vim.opt.shada = "!,'1000,<50,s10,h"
-- Overwrite files to update, instead of renaming + rewriting (which messes up
-- file watchers and crontab -e)
vim.opt.backupcopy = "yes"
-- Persist undo across sessions
vim.opt.undofile = true

-- search
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.showmatch = true

-- formatting
vim.opt.expandtab = true
vim.opt.textwidth = 80
vim.opt.shiftwidth = 4
vim.opt.formatoptions:remove("t")

-- UI
vim.opt.list = true
vim.opt.colorcolumn = "80"
vim.opt.scrolloff = 5
vim.opt.sidescrolloff = 3
vim.opt.wrap = false
vim.opt.diffopt:append("vertical")
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.mouse = "a"
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.cursorline = true
vim.opt.statusline = "%{FugitiveStatusline()} %f %y %=%c,%l/%L"
-- h and l and ~ wrap over lines
vim.opt.whichwrap = "h,l,~"
-- Show list of possible files on tab completion, rather than first guess
vim.opt.wildmode = "longest,list"
EOF

" Keys
set pastetoggle=<Leader>tp
nnoremap <leader><space> :noh<cr>
nnoremap <leader>w :bdelete<cr>
" Q reformats current paragraph or selected text
nnoremap Q gqap
vnoremap Q gq
" Use up and down to move by screen line
nnoremap k gk
nnoremap j gj
vnoremap k gk
vnoremap j gj
" keep cursor centered on n/N
nnoremap n nzz
nnoremap N Nzz
" keep cursor stationary on J
nnoremap J mzJ`z
" Use undotree
nnoremap <leader>u :UndotreeToggle<CR>
" Expand %% to directory of file in current buffer (also %:h<Tab>)
cnoremap <expr> %% getcmdtype() == ':' ? expand('%:h').'/' : '%%'
" ss to generate new split
nnoremap <silent> ss <C-w>s
" readline bindings for command mode
cnoremap <C-A> <Home>
cnoremap <C-E> <End>
" copy current buffer path to clipboard
noremap <silent> <leader>p :let @+ = expand("%")<CR>    " relative to current directory
noremap <silent> <leader>/ :let @+ = expand("%:p")<CR>  " absolute
noremap <silent> <leader>~ :let @+ = expand("%:~")<CR>  " relative to home
nnoremap <leader>f <cmd>lua require('fzf-lua').files()<CR><cr>
nnoremap <leader>h <cmd>lua require('fzf-lua').oldfiles()<CR><cr>
nnoremap <leader>b <cmd>lua require('fzf-lua').buffers()<CR><cr>
nnoremap <leader>c <cmd>lua require('fzf-lua').files({cwd="~/notes", cmd="rg --color=never --files --sortr modified"})<CR>
nnoremap <leader>g <cmd>lua require('fzf-lua').live_grep({cwd="~/notes", search=""})<CR>

" Colors
if filereadable(expand("~/.background-light"))
    set background=light
else
    set background=dark
endif
" Must happen before we set colorscheme; will rerun when colorscheme changes
augroup customize_iceberg
    autocmd!
    " Underline spelling problems
    autocmd ColorScheme iceberg highlight! link SpellBad Underlined
    autocmd ColorScheme iceberg highlight! link SpellCap SpellBad
    autocmd ColorScheme iceberg highlight! link SpellLocal SpellBad
    autocmd ColorScheme iceberg highlight! link SpellRare SpellBad
    " Tweak Error group (used for comments, etc.)
    " no bg (so it doesn't look weird under CursorLine)
    autocmd ColorScheme iceberg highlight Error ctermbg=NONE guibg=NONE
    " italic where it works, i.e. tmux-256color, xterm-256color, alacritty, etc.
    if &term !~ '^screen'
        autocmd ColorScheme iceberg highlight Error cterm=italic gui=italic
    endif
    " Prominent comments
    autocmd ColorScheme iceberg highlight! link Comment Error
    " Override iceberg.vim Visual to make Search visible
    if &background == "dark"
        autocmd ColorScheme iceberg highlight! Visual guibg=#272c42 guifg=fg
    else
        autocmd ColorScheme iceberg highlight! Visual guibg=#c9cdd7 guifg=fg
    endif
    " buftabline
    autocmd ColorScheme iceberg highlight! link BufTabLineCurrent PmenuSel
    autocmd ColorScheme iceberg highlight! link BufTabLineHidden LineNr
    autocmd ColorScheme iceberg highlight! link BufTabLineFill LineNr
    " statusline
    autocmd ColorScheme iceberg highlight! link StatusLine PmenuSel
    autocmd ColorScheme iceberg highlight! link StatusLineTerm PmenuSel
    autocmd ColorScheme iceberg highlight! link StatusLineNC LineNr
    autocmd ColorScheme iceberg highlight! link StatusLineTermNC LineNr
    " modify background if ~/.background-light file exists
    " `nested` so that ColorScheme autocmds fire after this
    autocmd FocusGained * nested if filereadable(expand("~/.background-light"))
        \ | set background=light
        \ | else
        \ | set background=dark
        \ | endif
augroup END
try
    colorscheme iceberg
catch /E185:/
    echom "iceberg colorscheme not available"
    set notermguicolors
endtry
" Treat trailing whitespace as TODO syntax group
match Todo /\s\+$/

" Use :w!! to save root files you forgot to open with sudo
cabbrev w!! w !sudo tee "%"

augroup vimrc
    autocmd! vimrc

    " Automatic rename of tmux window
    if exists('$TMUX') && !exists('$NORENAME')
        autocmd BufEnter * if empty(&buftype) | call system('tmux rename-window '.expand('%:t:S')) | endif
        autocmd VimLeave * call system('tmux set-window automatic-rename on')
    endif

    " Trigger `autoread` when files changes on disk
    " https://unix.stackexchange.com/questions/149209/refresh-changed-content-of-file-opened-in-vim/383044#383044
    " https://vi.stackexchange.com/questions/13692/prevent-focusgained-autocmd-running-in-command-line-editing-mode
    autocmd FocusGained,BufEnter,CursorHold,CursorHoldI *
        \ if mode() !~ '\v(c|r.?|!|t)' && getcmdwintype() == '' | checktime | endif

    " Notification after file change
    " https://vi.stackexchange.com/questions/13091/autocmd-event-for-autoread
    autocmd FileChangedShellPost *
        \ echohl WarningMsg | echo "File changed on disk. Buffer reloaded." | echohl None

    " When editing a file, always jump to the last known cursor position.
    " Don't do it for commit messages, when the position is invalid, or when
    " inside an event handler (happens when dropping a file on gvim).
    " https://github.com/dkarter/dotfiles/blob/99b4c5675cb859a9e50f95c40b73cb3f95414ad0/vimrc#L1128-L1134
    autocmd BufReadPost *
        \ if &ft != 'gitcommit' && line("'\"") > 0 && line("'\"") <= line("$") |
        \   exe "normal g`\"" |
        \ endif

    " formatlistpat taken from ftplugin/markdown.vim
    " spellcapcheck= disables capitalization checks
    autocmd FileType asciidoc,markdown,text,gitcommit,rst setlocal
        \ formatoptions+=tcqln formatoptions-=r formatoptions-=o
        \ formatlistpat=^\\s*\\d\\+\\.\\s\\+\\\|^\\s\\+[-*+]\\s\\+\\\|^\\[^\\ze[^\\]]\\+\\]:
        \ nojoinspaces spell spellcapcheck= shiftwidth=4

    " Don't spellcheck URLs https://vi.stackexchange.com/a/4003
    syntax match UrlNoSpell "\w\+:\/\/[^[:space:]]\+" contains=@NoSpell

    autocmd FileType css,html,javascript,typescript,typescriptreact,lua setlocal shiftwidth=2
    autocmd FileType go setlocal shiftwidth=8 tabstop=8 noexpandtab
    autocmd FileType bash,python,sh
        \ setlocal foldexpr=nvim_treesitter#foldexpr() |
        \ setlocal foldmethod=expr |
        \ setlocal nofoldenable

augroup END

" Recompile spell/*.add to *.add.spl if necessary
" https://vi.stackexchange.com/a/5052
for d in glob(stdpath('config') . '/spell/*.add', 1, 1)
    if filereadable(d) && (!filereadable(d . '.spl') || getftime(d) > getftime(d . '.spl'))
        exec 'mkspell! ' . fnameescape(d)
    endif
endfor

lua <<EOF
require("lsp")
require("completion")
require("treesitter")
require('gitsigns').setup()
require('smartyank').setup {
  highlight = {
    timeout = 150,
  },
  validate_yank = false, -- https://github.com/ibhagwan/smartyank.nvim/issues/8
}
require("conform").setup({
  formatters_by_ft = {
    python = { "ruff_format", "ruff_organize_imports" },
    bash = { "shfmt" },
  },
  format_on_save = {
    timeout_ms = 500,
    lsp_format = "fallback",
  },
})
EOF

" Don't indent continued vimscript lines 3 * shiftwidth(?!)
let g:vim_indent_cont = &sw
