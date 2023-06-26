" VimTex -> Skim -> nvim link
function! s:write_server_name() abort
  let nvim_server_file = (has('win32') ? $TEMP : '/tmp') . '/vimtexserver.txt'
"  `rm /tmp/vimtexserver.txt`
  call writefile([v:servername], nvim_server_file)
endfunction
augroup vimtex_common
  autocmd!
  autocmd FileType tex call s:write_server_name()
augroup END

set suffixesadd+=.tex

set spell

let g:vimtex_view_method = 'skim'
let g:vimtex_view_skim_reading_bar = 1
let g:vimtex_view_skim_activate = 0
let g:vimtex_view_skim_sync = 1

" VimTeX uses latexmk as the default compiler backend. If you use it, which is
" strongly recommended, you probably don't need to configure anything. If you
" want another compiler backend, you can change it as follows. The list of
" supported backends and further explanation is provided in the documentation,
" see ":help vimtex-compiler".
let g:vimtex_compiler_method = 'latexmk'
let g:vimtex_compiler_latexmk = {
    \ 'build_dir' : '',
    \ 'callback' : 1,
    \ 'continuous' : 1,
    \ 'executable' : 'latexmk',
    \ 'hooks' : [],
    \ 'options' : [
    \   '-verbose',
    \   '-file-line-error',
    \   '-synctex=1',
    \   '-interaction=nonstopmode',
	\	'-shell-escape',
    \ ],
    \}
let g:vimtex_compiler_latexmk_engines = {
    \ '_'                : '-pdf',
    \ 'pdfdvi'           : '-pdfdvi',
    \ 'pdfps'            : '-pdfps',
    \ 'pdflatex'         : '-pdf',
    \ 'luatex'           : '-lualatex',
    \ 'lualatex'         : '-lualatex',
    \ 'xelatex'          : '-xelatex',
    \ 'context (pdftex)' : '-pdf -pdflatex=texexec',
    \ 'context (luatex)' : '-pdf -pdflatex=context',
    \ 'context (xetex)'  : '-pdf -pdflatex=''texexec --xtx''',
    \}

let g:vimtex_parser_bib_backend = "bibtex"

let g:vimtex_quickfix_open_on_warning = 0 

let g:vimtex_doc_handlers = ['vimtex#doc#handlers#texdoc']
let g:vimtex_complete_close_braces = 1

" Most VimTeX mappings rely on localleader and this can be changed with the
" following line. The default is usually fine and is the symbol "\".
let maplocalleader = '\'

" noremap <localleader>ll <Cmd>update<CR><Cmd>VimtexCompile<CR>
