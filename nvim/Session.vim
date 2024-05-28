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
badd +33 init.lua
badd +67 ~/dotfiles/nvim/lua/plugins/colorscheme/catppuccin.lua
badd +11 ~/dotfiles/nvim/lua/plugins/colorscheme/gruvbox.lua
badd +1 ~/dotfiles/nvim/lua/plugins/colorscheme/papercolor.lua
badd +51 ~/dotfiles/nvim/lua/plugins/colorscheme/newpaper.lua
badd +1 ~/dotfiles/nvim/lua/plugins/colorscheme/kanagawa.lua
badd +58 ~/dotfiles/nvim/lua/plugins/colorschemes/material.lua
badd +3 ~/dotfiles/nvim/lua/plugins/colorschemes/vscode.lua
badd +1 lua/config/visuals.lua
badd +9 lua/plugins/lualine.lua
badd +1 ~/dotfiles/nvim/lua/plugins/colorschemes/papercolor.lua
badd +49 ~/dotfiles/nvim/lua/plugins/colorschemes/newpaper.lua
badd +8 ~/dotfiles/nvim/lua/plugins/colorschemes/night-owl.lua
badd +11 ~/dotfiles/nvim/lua/plugins/colorschemes/catppuccin.lua
badd +1 ~/dotfiles/nvim/lua/plugins/colorschemes/gruvbox.lua
badd +1 ~/dotfiles/nvim/lua/plugins/colorschemes/kanagawa.lua
badd +19 lua/plugins/telescope.lua
badd +23 ~/dotfiles/nvim/lua/plugins/indent-blankline.lua
argglobal
%argdel
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
let s:l = 29 - ((18 * winheight(0) + 19) / 39)
if s:l < 1 | let s:l = 1 | endif
keepjumps exe s:l
normal! zt
keepjumps 29
normal! 06|
tabnext
edit ~/dotfiles/nvim/lua/plugins/indent-blankline.lua
argglobal
balt lua/plugins/telescope.lua
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
let s:l = 25 - ((24 * winheight(0) + 19) / 39)
if s:l < 1 | let s:l = 1 | endif
keepjumps exe s:l
normal! zt
keepjumps 25
normal! 023|
tabnext
argglobal
enew | setl bt=help
help TSNode:type()@en
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
let s:l = 199 - ((29 * winheight(0) + 19) / 39)
if s:l < 1 | let s:l = 1 | endif
keepjumps exe s:l
normal! zt
keepjumps 199
normal! 0
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
