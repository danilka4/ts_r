let SessionLoad = 1
let s:so_save = &g:so | let s:siso_save = &g:siso | setg so=0 siso=0 | setl so=-1 siso=-1
let v:this_session=expand("<sfile>:p")
silent only
silent tabonly
cd ~/Documents/nvim/ts_r
if expand('%') == '' && !&modified && line('$') <= 1 && getline(1) == ''
  let s:wipebuf = bufnr('%')
endif
let s:shortmess_save = &shortmess
if &shortmess =~ 'A'
  set shortmess=aoOA
else
  set shortmess=aoO
endif
badd +15 lua/ts_r/init.lua
badd +3 lua/ts_r/meme.lua
badd +10 ~/Documents/nvim/ts_r/lua/./ts_r/term.lua
badd +50 ~/Documents/nvim/ts_r/lua/./ts_r/send.lua
badd +16 ~/scratch.Rmd
argglobal
%argdel
edit lua/ts_r/init.lua
let s:save_splitbelow = &splitbelow
let s:save_splitright = &splitright
set splitbelow splitright
wincmd _ | wincmd |
vsplit
1wincmd h
wincmd w
wincmd _ | wincmd |
split
1wincmd k
wincmd w
let &splitbelow = s:save_splitbelow
let &splitright = s:save_splitright
wincmd t
let s:save_winminheight = &winminheight
let s:save_winminwidth = &winminwidth
set winminheight=0
set winheight=1
set winminwidth=0
set winwidth=1
exe 'vert 1resize ' . ((&columns * 73 + 73) / 147)
exe '2resize ' . ((&lines * 15 + 16) / 33)
exe 'vert 2resize ' . ((&columns * 73 + 73) / 147)
exe '3resize ' . ((&lines * 15 + 16) / 33)
exe 'vert 3resize ' . ((&columns * 73 + 73) / 147)
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
let s:l = 15 - ((14 * winheight(0) + 15) / 31)
if s:l < 1 | let s:l = 1 | endif
keepjumps exe s:l
normal! zt
keepjumps 15
normal! 045|
wincmd w
argglobal
if bufexists(fnamemodify("~/Documents/nvim/ts_r/lua/./ts_r/send.lua", ":p")) | buffer ~/Documents/nvim/ts_r/lua/./ts_r/send.lua | else | edit ~/Documents/nvim/ts_r/lua/./ts_r/send.lua | endif
if &buftype ==# 'terminal'
  silent file ~/Documents/nvim/ts_r/lua/./ts_r/send.lua
endif
balt ~/Documents/nvim/ts_r/lua/./ts_r/term.lua
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
let s:l = 50 - ((2 * winheight(0) + 7) / 15)
if s:l < 1 | let s:l = 1 | endif
keepjumps exe s:l
normal! zt
keepjumps 50
normal! 08|
wincmd w
argglobal
if bufexists(fnamemodify("~/scratch.Rmd", ":p")) | buffer ~/scratch.Rmd | else | edit ~/scratch.Rmd | endif
if &buftype ==# 'terminal'
  silent file ~/scratch.Rmd
endif
balt ~/Documents/nvim/ts_r/lua/./ts_r/send.lua
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
let s:l = 20 - ((5 * winheight(0) + 7) / 15)
if s:l < 1 | let s:l = 1 | endif
keepjumps exe s:l
normal! zt
keepjumps 20
normal! 016|
wincmd w
2wincmd w
exe 'vert 1resize ' . ((&columns * 73 + 73) / 147)
exe '2resize ' . ((&lines * 15 + 16) / 33)
exe 'vert 2resize ' . ((&columns * 73 + 73) / 147)
exe '3resize ' . ((&lines * 15 + 16) / 33)
exe 'vert 3resize ' . ((&columns * 73 + 73) / 147)
tabnext 1
if exists('s:wipebuf') && len(win_findbuf(s:wipebuf)) == 0 && getbufvar(s:wipebuf, '&buftype') isnot# 'terminal'
  silent exe 'bwipe ' . s:wipebuf
endif
unlet! s:wipebuf
set winheight=1 winwidth=20
let &shortmess = s:shortmess_save
let &winminheight = s:save_winminheight
let &winminwidth = s:save_winminwidth
let s:sx = expand("<sfile>:p:r")."x.vim"
if filereadable(s:sx)
  exe "source " . fnameescape(s:sx)
endif
let &g:so = s:so_save | let &g:siso = s:siso_save
set hlsearch
nohlsearch
doautoall SessionLoadPost
unlet SessionLoad
" vim: set ft=vim :
