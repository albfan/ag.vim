" Providers of search targets
function! ag#paths#lwd()
  return [expand('%:p', 1)]
endfunction


function! ag#paths#buffers()
  let l:bufs = filter(range(1, bufnr('$')), 'buflisted(v:val)')
  let l:files = map(l:bufs, 'fnamemodify(bufname(v:val), ":p")')
  return filter(l:files, '!isdirectory(v:val)')
endfunction


function! ag#paths#help()
  return globpath(&runtimepath, 'doc/*.txt', 1, 1)
endfunction


" EXPL: fs root can't be pj root. Moreover, eliminates recursion problem.
function! s:exists(dir, marker)
  return (a:path =~# '/$' && isdirectory(a:path)) || filereadable(a:path)
endfunction

function! ag#paths#pjroot(strategy)
  let _ = getcwd()
  if a:strategy ==# 'nearest'
    while _ !=# fnamemodify(_, ':h')
      for m in g:ag.root_markers
        if s:exists(_.'/'.m) | return m | endif
      endfor
      let _ = fnamemodify(_, ':h')
    endwhile
  elseif a:strategy ==# 'priority'
    for m in g:ag.root_markers
      while _ !=# fnamemodify(_, ':h')
        if s:exists(_.'/'.m) | return m | endif
        let _ = fnamemodify(_, ':h')
      endfor
    endwhile
  endif
  return getcwd()
endfunction
