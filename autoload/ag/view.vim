" Providers of view search results:
function! s:qfcmd(m)
  return (a:m=~#'+' ? 'add' : (g:ag.toggle.open_first ?'': 'get')).'expr'
endfunction


function! ag#view#qf(lst, m)
  call ag#qf#search(a:lst, 'c'.s:qfcmd(a:m))
endfunction


function! ag#view#loc(lst, m)
  call ag#qf#search(a:lst, 'l'.s:qfcmd(a:m))
endfunction


function! ag#view#grp(lst, m)
  call ag#group#search(a:lst, a:m)
endfunction
