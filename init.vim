set nocompatible
filetype plugin indent on 	" vimtex, vundle requirement
syntax on 					" vimtex requirement
set t_Co=256
set number
set wildmenu
set wildmode=full
set tabstop=4
set shiftwidth=4
set history=200
set mouse=a
set nofixendofline
set encoding=utf8 			" vimtex requirement
set guicursor=i:block-nCursor
set cursorline
set scrolloff=8


function! s:write_server_name() abort
  let nvim_server_file = (has('win32') ? $TEMP : '/tmp') . '/vimtexserver.txt'
"  `rm /tmp/vimtexserver.txt`
  call writefile([v:servername], nvim_server_file)
endfunction

augroup vimtex_common
  autocmd!
  autocmd FileType tex call s:write_server_name()
augroup END


set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

Plugin 'lervag/vimtex'


" Plugin 'ycm-core/YouCompleteMe'
" let g:ycm_min_num_of_chars_for_completion = 3
" let g:ycm_max_num_candidates =12


Plugin 'ludovicchabant/vim-gutentags'


Plugin 'SirVer/ultisnips'
" Plugin 'honza/vim-snippets'
let g:UltiSnipsExpandTrigger='<Tab>'
let g:UltiSnipsJumpForwardTrigger='<c-j>'
let g:UltiSnipsJumpBackwardTrigger='<c-k>'
let g:UltiSnipsEditSplit="tabdo"
let g:UltiSnippetsStorageDirectoryForUltisnipsEdit="/Users/vladyslav/.config/nvim/UltiSnips"

Plugin 'morhetz/gruvbox'
let g:gruvbox_italic = 1
let g:gruvbox_contrast_dark = "hard"
Plugin 'NLKNguyen/papercolor-theme'
Plugin 'ChrisKempson/Tomorrow-Theme'


Plugin 'itchyny/lightline.vim'
set noshowmode

let g:lightline = { 'colorscheme': 'PaperColor' }
call vundle#end()

set background=dark
colorscheme PaperColor

" autocmd BufEnter *.tex colorscheme PaperColor
