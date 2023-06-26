set nocompatible
filetype plugin indent on 	" VimTex, vundle requirement
set encoding=utf8 			" VimTex requirement
syntax on 					" VimTex requirement

set t_Co=256
set wildmenu
set wildmode=full
set history=200
set nofixendofline

set incsearch

set mouse=a
set wrap
set number
set guicursor=i:block-nCursor
set cursorline
set noshowmode
set scrolloff=8

set tabstop=4
set shiftwidth=4

" Replace grep with ripgrep
set grepprg=rg\ $*\ --column\ --no-heading
set grepformat=%f:%l:%c%m,%l:%c%m

" Next map  makes the :edit %:h<Tab>
" equivalent to       :edit %%<Tab>
cnoremap <expr> %% getcmdtype() == ':' ? expand('%:h').'/' : '%%'

" Ukrainian language support
set keymap=ukrainian-jcuken
set iminsert=0 imsearch=-1
set spelllang=uk,en_us,ru_ru

" Buffers navigation
nnoremap <silent> [b :bprevious<CR>
nnoremap <silent> ]b :bnext<CR>
nnoremap <silent> [B :bfirst<CR>
nnoremap <silent> ]B :blast<CR>

" NO ARROW KEYS, U MFCKER! heheheha!!1!
noremap <Up> <Nop> 
noremap <Down> <Nop> 
noremap <Left> <Nop> 
noremap <Right> <Nop>

" Regenerate ctags file with F5
nnoremap <f5> :!ctags -R<CR>


set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

Plugin 'lervag/vimtex'

" Plugin 'ycm-core/YouCompleteMe'
" let g:ycm_min_num_of_chars_for_completion = 3
" let g:ycm_max_num_candidates =12

Plugin 'junegunn/fzf'
let g:fzf_action = {
  \ 'ctrl-t': 'tab split',
  \ 'ctrl-s': 'split',
  \ 'ctrl-v': 'vsplit' }
let g:fzf_layout = { 'window': { 'width': 0.9, 'height': 0.6, 'relative': v:true } }
let g:fzf_colors =
\ { 'fg':      ['fg', 'Normal'],
  \ 'bg':      ['bg', 'Normal'],
  \ 'hl':      ['fg', 'Comment'],
  \ 'fg+':     ['fg', 'CursorLine', 'CursorColumn', 'Normal'],
  \ 'bg+':     ['bg', 'CursorLine', 'CursorColumn'],
  \ 'hl+':     ['fg', 'Statement'],
  \ 'info':    ['fg', 'PreProc'],
  \ 'border':  ['fg', 'Ignore'],
  \ 'prompt':  ['fg', 'Conditional'],
  \ 'pointer': ['fg', 'Exception'],
  \ 'marker':  ['fg', 'Keyword'],
  \ 'spinner': ['fg', 'Label'],
  \ 'header':  ['fg', 'Comment'] }
let g:fzf_history_dir = '~/.local/share/fzf-history'

Plugin 'nvim-treesitter/nvim-treesitter'

Plugin 'godlygeek/tabular'
Plugin 'preservim/vim-markdown'

Plugin 'iamcco/markdown-preview.nvim'

Plugin 'ludovicchabant/vim-gutentags'

Plugin 'tpope/vim-surround'

Plugin 'SirVer/ultisnips'
let g:UltiSnipsExpandTrigger='<Tab>'
let g:UltiSnipsJumpForwardTrigger='<c-j>'
let g:UltiSnipsJumpBackwardTrigger='<c-k>'
let g:UltiSnipsEditSplit="tabdo"
let g:UltiSnippetsStorageDirectoryForUltisnipsEdit="/Users/vladyslav/.config/nvim/UltiSnips"

Plugin 'tpope/vim-fugitive'

Plugin 'morhetz/gruvbox'
let g:gruvbox_italic = 1
let g:gruvbox_contrast_dark = "hard"
Plugin 'NLKNguyen/papercolor-theme'
Plugin 'ChrisKempson/Tomorrow-Theme'

Plugin 'itchyny/lightline.vim'
let g:lightline = {
      \ 'colorscheme': 'PaperColor',
      \ 'active': {
      \   'left': [ [ 'mode', 'paste' ],
      \             [ 'gitbranch', 'readonly', 'filename', 'modified' ] ]
      \ },
      \ 'component_function': {
      \   'gitbranch': 'FugitiveHead'
      \ },
      \ }

call vundle#end()

lua require('config/treesitter')

set background=dark
colorscheme PaperColor

" autocmd BufEnter *.tex colorscheme PaperColor
