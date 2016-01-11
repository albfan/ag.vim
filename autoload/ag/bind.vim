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


function! s:lcd(f, varg)
  let l:cwd_old = getcwd()
  let l:cwd = ag#paths#pjroot('nearest')
  try
    exe "lcd ".l:cwd
  catch
    echom 'Failed to change directory to:'.l:cwd
  finally
    let _ = call(f, a:varg)
    if l:cwd !=# l:cwd_old
      exe "lcd ".l:cwd_old
    endif
  endtry
  return _
endfunction


if exists('*systemlist')  " ALT: has('patch-7.4.248')
  " NOTE: when empty, returns '' instead of []
  exe "fun! s:sh(_)\nreturn systemlist(a:_)\nendf"
else
  " DEV: for system() add arg 'ag --print0' and split lines at SOH (0x01)
  exe "fun! s:sh(_)\nreturn split(system(a:_),'\\n')\nendf"
endif

function! ag#bind#exec(...)
  if g:ag.working_path_mode ==? 'r'
    let _ = s:lcd('s:sh', a:000)
  else
    let _ = call('s:sh', a:000)
  endif
  if empty(_)
    echohl WarningMsg
    echom "No matches for '".join(g:ag.last.args)."'"
    echohl None
  endif
  return _
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
  let lena = len(a)
  let i = 0
  while i < lena
    let j = 1
    while j < lena - i
      if (a[i] =~# '^".*[^"]$' && a[i+j] =~# '^[^"].*"$')
        \||(a[i] =~# "^'.*[^']$" && a[i+j] =~# "^[^'].*'$")
        for k in range(1, j)
          let a[i] .= ' '.remove(a, i+1)
        endfor
        let lena-=j
      endif
      let j += 1
    endwhile
    let i += 1
  endwhile
  return a
endfunction


" NEED:DEV: more sane api -- THINK: how to separate flags, regex, paths?
function! ag#bind#f(view, args, paths, cmd)
  let auto = empty(a:args) || type(a:args)!=type([])
  if auto
    let l:args = ag#args#auto(a:args)
  else
    let l:args = ag#bind#fix_fargs(a:args)
  endif

  " REMOVE: temporary args splitter to unify api
  let l:cmd = (type(a:cmd)==type(0) ? remove(l:args, a:cmd) : a:cmd)

  if empty(l:args) | echom "empty search" | return | endif

  let g:ag.last = {'view': ag#view#auto(a:view), 'args': l:args,
        \ 'paths': ag#paths#auto(a:paths), 'cmd': l:cmd, 'orig_args': a:args, 'auto': auto}

  call ag#bind#call(g:ag.last)
endfunction

function! ag#bind#f_tracked(cmd, visual, count, ...)
  let g:ag.visual = a:visual
  let g:ag.count = a:count
  call call('ag#bind#f', a:000)
  if g:ag.toggle.mappings_to_cmd_history
     call histadd(":", a:cmd.' '.ag#bind#join(g:ag.last.args + g:ag.last.paths))
  endif
endfunction
