function! ag#bind#escape(arg)
  if a:arg =~# '^".*"$' || a:arg =~# "^'.*'$"
    return escape(a:arg, '%#')    " Escapes file substitution %/#
  else
    return shellescape(a:arg, 1)  " Additionally wraps in single quotes
  endif
endfunction


function! ag#bind#join(args)
  return join(map(a:args, 'ag#bind#escape(v:val)'), ' ')
endfunction


if exists('*systemlist')  " ALT: has('patch-7.4.248')
  " NOTE: when empty, returns '' instead of []
  exe "fun! s:sh(_)\nreturn systemlist(a:_)\nendf"
else
  " DEV: for system() add arg 'ag --print0' and split lines at SOH (0x01)
  exe "fun! s:sh(_)\nreturn split(system(a:_),'\\n')\nendf"
endif

function! ag#bind#populate(consumer, shellcmd)
  silent exec a:consumer.' s:sh(a:shellcmd)'
endfunction


function! ag#bind#call(entry)
  " FIND: another way -- to execute args list directly without join?
  let l:args = ag#bind#join(a:entry.args + a:entry.paths)
  call {a:entry.view}(l:args, a:entry.cmd)
endfunction


function! ag#bind#repeat()
  if empty(g:ag.last) | echom "nothing to repeat" | return | endif
  call ag#bind#call(g:ag.last)
endfunction


function! ag#bind#fix_fargs(args)
  if len(a:args) < 2 | return a:args | endif
  let a = a:args
  for i in range(0, len(a) - 2)
    if (a[i] =~# '^".*[^"]$' && a[i+1] =~# '^[^"].*"$')
    \||(a[i] =~# "^'.*[^']$" && a[i+1] =~# "^[^'].*'$")
      let a[i] .= ' '.remove(a, i+1)
    endif
  endfor
  return a
endfunction


" NEED:DEV: more sane api -- THINK: how to separate flags, regex, paths?
function! ag#bind#f(view, args, paths, cmd)
  if !empty(a:args) && type(a:args)==type([])
    let l:args = ag#bind#fix_fargs(a:args)
  else
    let l:args = ag#args#auto(a:args)
  endif

  " REMOVE: temporary args splitter to unify api
  let l:cmd = (type(a:cmd)==type(0) ? remove(l:args, a:cmd) : a:cmd)

  if empty(l:args) | echom "empty search" | return | endif

  let g:ag.last = {'view': ag#view#auto(a:view), 'args': l:args,
        \ 'paths': ag#paths#auto(a:paths), 'cmd': l:cmd}

  call ag#bind#call(g:ag.last)
endfunction


function! ag#bind#f_tracked(cmd, ...)
  call call('ag#bind#f', a:000)
  if g:ag.toggle.mappings_to_cmd_history
     call histadd(":", a:cmd.' '.ag#bind#join(g:ag.last.args + g:ag.last.paths))
  endif
endfunction
