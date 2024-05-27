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
badd +67 lua/plugins/lspconfig.lua
badd +16 lua/plugins/alpha.lua
badd +10 lua/plugins/leetcode.lua
badd +160 lua/plugins/oil.lua
badd +8 lua/plugins/vimtex.lua
badd +40 lua/plugins/treesitter.lua
badd +45 lua/plugins/git.lua
badd +34 lua/plugins/misc.lua
badd +1 lua/config/options.lua
badd +11 gitsigns:///Users/vladyslav/dotfiles/.git/:0:nvim/lua/plugins/git.lua
badd +32 lua/plugins/telescope.lua
badd +6 lua/plugins/colorscheme.lua
badd +1 lua/plugins/dapconfig.lua
badd +1 lua/config/visuals.lua
badd +40 lua/plugins/conform.lua
badd +6 LuaSnip/all.lua
badd +5 lua/plugins/snippets/all.lua
badd +1 lua/plugins/snippets/tex/environments.lua
badd +171 lua/snippets/tex/environments.lua
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
let s:l = 2 - ((1 * winheight(0) + 22) / 45)
if s:l < 1 | let s:l = 1 | endif
keepjumps exe s:l
normal! zt
keepjumps 2
normal! 0
if exists(':tcd') == 2 | tcd ~/dotfiles/nvim | endif
tabnext
edit ~/dotfiles/nvim/lua/plugins/vimtex.lua
argglobal
balt ~/dotfiles/nvim/init.lua
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
let s:l = 8 - ((7 * winheight(0) + 22) / 45)
if s:l < 1 | let s:l = 1 | endif
keepjumps exe s:l
normal! zt
keepjumps 8
normal! 021|
if exists(':tcd') == 2 | tcd ~/dotfiles/nvim | endif
tabnext
edit ~/dotfiles/nvim/lua/plugins/treesitter.lua
argglobal
balt ~/dotfiles/nvim/lua/plugins/vimtex.lua
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
let s:l = 28 - ((27 * winheight(0) + 22) / 45)
if s:l < 1 | let s:l = 1 | endif
keepjumps exe s:l
normal! zt
keepjumps 28
normal! 0
if exists(':tcd') == 2 | tcd ~/dotfiles/nvim | endif
tabnext
edit ~/dotfiles/nvim/lua/snippets/tex/environments.lua
argglobal
balt ~/dotfiles/nvim/lua/utils/texsnip.lua
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
let s:l = 171 - ((30 * winheight(0) + 22) / 45)
if s:l < 1 | let s:l = 1 | endif
keepjumps exe s:l
normal! zt
keepjumps 171
normal! 011|
if exists(':tcd') == 2 | tcd ~/dotfiles/nvim | endif
tabnext
edit ~/dotfiles/nvim/lua/snippets/tex/environments.lua
argglobal
balt ~/dotfiles/nvim/lua/utils/texsnip.lua
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
let s:l = 168 - ((26 * winheight(0) + 22) / 45)
if s:l < 1 | let s:l = 1 | endif
keepjumps exe s:l
normal! zt
keepjumps 168
normal! 06|
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
let s:l = 223 - ((8 * winheight(0) + 22) / 45)
if s:l < 1 | let s:l = 1 | endif
keepjumps exe s:l
normal! zt
keepjumps 223
normal! 018|
if exists(':tcd') == 2 | tcd ~/dotfiles/nvim | endif
tabnext
edit ~/dotfiles/nvim/lua/plugins/telescope.lua
argglobal
balt ~/dotfiles/nvim/init.lua
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
let s:l = 32 - ((29 * winheight(0) + 22) / 45)
if s:l < 1 | let s:l = 1 | endif
keepjumps exe s:l
normal! zt
keepjumps 32
normal! 092|
if exists(':tcd') == 2 | tcd ~/dotfiles/nvim | endif
tabnext 2
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
