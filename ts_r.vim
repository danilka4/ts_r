"if exists("g:ts_r")
"    finish
"endif
"let g:ts_r = 1
"
"let s:lua_deps_loc = expand("<sfile>:h:r") . "/../lua/ts_r/deps"
"exe "lua package.path = package.path .. ';" . s:lua_deps_loc . "/lua-?/init.lua'"
"
"command! -nargs=0 OpenTerm lua require("ts_r").open_term()
"command! -nargs=0 CloseTerm lua require("ts_r").close_term()
"
"command! -nargs=0 SendLine lua require("ts_r").send_line()
"command! -nargs=0 SendChunk lua require("ts_r").send_chunk()
