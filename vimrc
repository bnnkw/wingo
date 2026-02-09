set nocompatible

execute 'set runtimepath=' .. getcwd()
runtime plugin/lswin.vim
nnoremap <Leader>w <Cmd>LsWin<CR>

fun! s:open_cmd_output(opencmd, cmd, opts = []) abort
  execute 'silent ' .. a:opencmd
  execute "silent 0put = execute('" .. a:cmd .. "')"
  execute 'silent file ' .. a:cmd
  for opt in a:opts
    execute 'set ' .. opt
  endfor
  goto 1
endfun

silent scriptnames 1

call s:open_cmd_output('tabnew', 'version', ['nomodified'])
silent help :version

call s:open_cmd_output('tabnew', 'scriptnames', ['nomodified'])
call s:open_cmd_output('new', 'map', ['modified'])
call s:open_cmd_output('topleft vnew', 'highlight', ['nomodified'])

call s:open_cmd_output('tabnew', 'set all', ['nomodified'])
call s:open_cmd_output('new', '', ['nomodified'])

for i in range(1, 100)
  $tabnew
endfor

tabnext 1

LsWin
