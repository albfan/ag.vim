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
    return s:lcd('s:sh', a:000)
  else
    return call('s:sh', a:000)
  endif
endfunction


function! ag#bind#do(e)
  if empty(a:e.pattern) | echom "empty pattern" | return | endif
  " DEV: clone current 'e' and move it to history (circle buffer)

  " FIND: another way -- to execute args list directly without join?
  let lst = ag#bind#exec(ag#provider#ag(g:ag.last))
  if v:shell_error || empty(lst)
    echohl WarningMsg
    " THINK: costruct more informative message
    "   -- flags indicators
    "   -- paths presence placeholder, etc
    echom get({0: "empty lst", 1: "no matches", 2: "incorrect pattern"}
          \, v:shell_error, "unknown error") . ": " . a:e.pattern
    echohl None
    return
  endif
  call ag#view#{a:e.view}(lst, get(a:e, 'mode', ''))

  " XXX: truly bad way of highlighting. TODO:USE: :keephist let @/=...
  " If highlighting is on, highlight the search keyword.
  if g:ag.toggle.highlight
    " FIXME: broken derivation, replace by pcre2vim
    let @/ = matchstr(g:ag.last.pattern, "\\v(-)\@<!(\<)\@<=\\w+|['\"]\\zs.{-}\\ze['\"]")
    call feedkeys(":let &hlsearch=1 \| echo \<CR>", 'n')
    redraw!
  end
endfunction


function! ag#bind#repeat()
  call ag#bind#do(g:ag.last)
endfunction


" NEED:DEV: more sane api -- THINK: how to separate flags, regex, paths?
function! ag#bind#f(view, patt, paths, mode)
  let e = g:ag.last
  let e.view = a:view
  " DEV: if a:src == 'filelist' -> paths=a:paths else paths=ag#paths#{a:src}() else ''
  let e.paths = a:paths

  if e.view == 'grp'
    let e.filter = a:mode
  else
    let e.mode = a:mode
  endif

  if type(a:patt) == type(0)
    if a:patt == 0
      " Do nothing. Keep old pattern intact.
    elseif a:patt == 1
      call ag#args#slash(e)
    endif
  elseif type(a:patt) == type("")
    if !empty(a:patt)
      let e.pattern = a:patt
    elseif exists('g:ag.visual') && g:ag.visual
      call ag#args#vsel(e)
    else
      call ag#args#cword(e)
    endif
  endif

  call ag#bind#do(e)
endfunction

function! ag#bind#f_tracked(cmd, visual, count, ...)
  let g:ag.visual = a:visual  " RFC:REMOVE
  let g:ag.last.count = a:count
  if a:0 == 2
    let list = split(a:2)
    call call('ag#bind#f', [a:1, join(list[1:-1],' '), [list[0]], ''])
  else
    call call('ag#bind#f', a:000)
  endif
  if g:ag.toggle.mappings_to_cmd_history
    " TODO:DEV: more correct vim cmdline generator 'ag#bind#get_cmd(e)'
    call histadd(":", a:cmd.' '.ag#bind#join([g:ag.last.pattern] + g:ag.last.paths))
  endif
endfunction
