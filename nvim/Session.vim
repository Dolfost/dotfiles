let SessionLoad = 1
let s:so_save = &g:so | let s:siso_save = &g:siso | setg so=0 siso=0 | setl so=-1 siso=-1
let v:this_session=expand("<sfile>:p")
silent only
silent tabonly
cd ~/dotfiles/nvim
if expand('%') == '' && !&modified && line('$') <= 1 && getline(1) == ''
  let s:wipebuf = bufnr('%')
endif
let s:shortmess_save = &shortmess
if &shortmess =~ 'A'
  set shortmess=aoOA
else
  set shortmess=aoO
endif
badd +2 init.lua
badd +22 lua/plugins/lspconfig.lua
badd +16 lua/plugins/alpha.lua
badd +10 lua/plugins/leetcode.lua
badd +160 lua/plugins/oil.lua
badd +21 lua/plugins/vimtex.lua
badd +25 lua/plugins/treesitter.lua
badd +45 lua/plugins/git.lua
badd +73 lua/plugins/misc.lua
badd +4 lua/config/options.lua
badd +11 gitsigns:///Users/vladyslav/dotfiles/.git/:0:nvim/lua/plugins/git.lua
badd +32 lua/plugins/telescope.lua
badd +6 lua/plugins/colorscheme.lua
badd +1 lua/plugins/dapconfig.lua
badd +1 lua/config/visuals.lua
badd +40 lua/plugins/conform.lua
badd +6 LuaSnip/all.lua
badd +5 lua/plugins/snippets/all.lua
badd +1 lua/plugins/snippets/tex/environments.lua
badd +168 lua/snippets/tex/environments.lua
badd +41 lua/utils/texsnip.lua
badd +28 lua/snippets/tex/math.lua
badd +1 lua/snippets/tex/bibliography.lua
badd +1 lua/snippets/c.lua
badd +4 lua/snippets/cpp.lua
badd +18 lua/plugins/neo-tree.lua
badd +16 lua/plugins/which-key.lua
badd +5 Session.vim
argglobal
%argdel
tabnew +setlocal\ bufhidden=wipe
tabnew +setlocal\ bufhidden=wipe
tabnew +setlocal\ bufhidden=wipe
tabnew +setlocal\ bufhidden=wipe
tabnew +setlocal\ bufhidden=wipe
tabnew +setlocal\ bufhidden=wipe
tabrewind
edit init.lua
argglobal
setlocal fdm=manual
setlocal fde=0
setlocal fmr={{{,}}}
setlocal fdi=#
setlocal fdl=0
setlocal fml=1
setlocal fdn=20
setlocal fen
silent! normal! zE
let &fdl = &fdl
let s:l = 2 - ((1 * winheight(0) + 26) / 52)
if s:l < 1 | let s:l = 1 | endif
keepjumps exe s:l
normal! zt
keepjumps 2
normal! 0
if exists(':tcd') == 2 | tcd ~/dotfiles/nvim | endif
tabnext
edit ~/dotfiles/nvim/lua/plugins/misc.lua
argglobal
balt ~/dotfiles/nvim/lua/config/options.lua
setlocal fdm=manual
setlocal fde=0
setlocal fmr={{{,}}}
setlocal fdi=#
setlocal fdl=0
setlocal fml=1
setlocal fdn=20
setlocal fen
silent! normal! zE
let &fdl = &fdl
let s:l = 73 - ((36 * winheight(0) + 26) / 52)
if s:l < 1 | let s:l = 1 | endif
keepjumps exe s:l
normal! zt
keepjumps 73
normal! 033|
if exists(':tcd') == 2 | tcd ~/dotfiles/nvim | endif
tabnext
edit ~/dotfiles/nvim/lua/plugins/vimtex.lua
argglobal
balt ~/dotfiles/nvim/lua/plugins/misc.lua
setlocal fdm=manual
setlocal fde=0
setlocal fmr={{{,}}}
setlocal fdi=#
setlocal fdl=0
setlocal fml=1
setlocal fdn=20
setlocal fen
silent! normal! zE
let &fdl = &fdl
let s:l = 21 - ((18 * winheight(0) + 23) / 46)
if s:l < 1 | let s:l = 1 | endif
keepjumps exe s:l
normal! zt
keepjumps 21
normal! 042|
if exists(':tcd') == 2 | tcd ~/dotfiles/nvim | endif
tabnext
argglobal
enew | setl bt=help
help g:vimtex_complete_close_braces@en
setlocal fdm=marker
setlocal fde=0
setlocal fmr={{{,}}}
setlocal fdi=#
setlocal fdl=0
setlocal fml=1
setlocal fdn=20
setlocal nofen
let s:l = 4890 - ((34 * winheight(0) + 23) / 46)
if s:l < 1 | let s:l = 1 | endif
keepjumps exe s:l
normal! zt
keepjumps 4890
normal! 0
if exists(':tcd') == 2 | tcd ~/dotfiles/nvim | endif
tabnext
argglobal
enew | setl bt=help
help which-key.nvim-which-key-usage@en
setlocal fdm=manual
setlocal fde=0
setlocal fmr={{{,}}}
setlocal fdi=#
setlocal fdl=0
setlocal fml=1
setlocal fdn=20
setlocal nofen
silent! normal! zE
let &fdl = &fdl
let s:l = 215 - ((23 * winheight(0) + 26) / 52)
if s:l < 1 | let s:l = 1 | endif
keepjumps exe s:l
normal! zt
keepjumps 215
normal! 032|
if exists(':tcd') == 2 | tcd ~/dotfiles/nvim | endif
tabnext
edit ~/dotfiles/nvim/lua/plugins/neo-tree.lua
argglobal
balt ~/dotfiles/nvim/lua/plugins/treesitter.lua
setlocal fdm=manual
setlocal fde=0
setlocal fmr={{{,}}}
setlocal fdi=#
setlocal fdl=0
setlocal fml=1
setlocal fdn=20
setlocal fen
silent! normal! zE
let &fdl = &fdl
let s:l = 18 - ((17 * winheight(0) + 26) / 52)
if s:l < 1 | let s:l = 1 | endif
keepjumps exe s:l
normal! zt
keepjumps 18
normal! 0
if exists(':tcd') == 2 | tcd ~/dotfiles/nvim | endif
tabnext
edit ~/dotfiles/nvim/lua/plugins/lspconfig.lua
argglobal
setlocal fdm=manual
setlocal fde=0
setlocal fmr={{{,}}}
setlocal fdi=#
setlocal fdl=0
setlocal fml=1
setlocal fdn=20
setlocal fen
silent! normal! zE
let &fdl = &fdl
let s:l = 22 - ((21 * winheight(0) + 26) / 52)
if s:l < 1 | let s:l = 1 | endif
keepjumps exe s:l
normal! zt
keepjumps 22
normal! 0
if exists(':tcd') == 2 | tcd ~/dotfiles/nvim | endif
tabnext 3
if exists('s:wipebuf') && len(win_findbuf(s:wipebuf)) == 0 && getbufvar(s:wipebuf, '&buftype') isnot# 'terminal'
  silent exe 'bwipe ' . s:wipebuf
endif
unlet! s:wipebuf
set winheight=1 winwidth=20
let &shortmess = s:shortmess_save
let s:sx = expand("<sfile>:p:r")."x.vim"
if filereadable(s:sx)
  exe "source " . fnameescape(s:sx)
endif
let &g:so = s:so_save | let &g:siso = s:siso_save
set hlsearch
let g:this_session = v:this_session
let g:this_obsession = v:this_session
doautoall SessionLoadPost
unlet SessionLoad
" vim: set ft=vim :
