" Providers of view search results:
function! s:qfcmd(m)
  return (a:m=~#'+' ? 'add' : (g:ag.toggle.open_first ?'': 'get')).'expr'
endfunction


function! ag#view#qf(args, m)
  call ag#qf#search(a:args, 'c'.s:qfcmd(a:m))
endfunction


function! ag#view#loc(args, m)
  call ag#qf#search(a:args, 'l'.s:qfcmd(a:m))
endfunction


function! ag#view#grp(args, cmd)
  call ag#group#search(a:args, a:cmd)
endfunction
