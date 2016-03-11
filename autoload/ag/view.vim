""" Closures to view results (can contain additional option tweaks)

function! ag#view#qf(lst, m)
  call ag#populate#qf(a:lst, 'c', a:m)
endfunction


function! ag#view#loc(lst, m)
  call ag#populate#qf(a:lst, 'l', a:m)
endfunction


function! ag#view#grp(lst, m)
  call ag#populate#grp(a:lst, 'preview', a:m)
endfunction
