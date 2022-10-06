function! ag#bind#AgReload()
  unlet g:loaded_ag
  source $MYVIMRC
endfunction

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
  fun! s:sh(_)
     return systemlist(a:_)
  endf
else
  " DEV: for system() add arg 'ag --print0' and split lines at SOH (0x01)
  fun! s:sh(_)
     return split(system(a:_),'\\n')
  endf
endif

function! ag#bind#exec(...)
  let result = call('s:sh', a:000)
  " Pattern filter
  if !empty(g:ag.ignore_pattern_list)
    for ignore_pattern_item in g:ag.ignore_pattern_list
      "TODO: Escape double commas
      let result = filter(result, "v:val !~ '^[0-9]\\+:[0-9]\\+:.*".ignore_pattern_item.".*'")
    endfor
  endif

  return result
endfunction


function Filter_lineending(key, val)
  return substitute(a:val, '', '', 'g')
endfunction

function! ag#bind#do(e)
  if empty(a:e.pattern)
    echom "empty pattern"
    return
  endif
  " DEV: clone current 'e' and move it to history (circle buffer)

  " FIND: another way -- to execute args list directly without join?
  let lst = ag#bind#exec(ag#provider#ag(g:ag.last))
  if has('win32unix') || has('win32')
    let lst = map(lst, function('Filter_lineending'))
  endif

  if v:shell_error && empty(lst)
    echohl WarningMsg
    " THINK: costruct more informative message
    "   -- flags indicators
    "   -- paths presence placeholder, etc
    echom get({0: "empty lst", 1: "no matches", 2: "incorrect pattern"}
          \, v:shell_error, "unknown error") . ": " . a:e.pattern
    echohl None
    call ag#view#{a:e.view}(lst, get(a:e, 'mode', ''))
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

function! ag#bind#toggle()
  silent! wincmd P
  if &previewwindow
    wincmd p
    pclose
  else
    call ag#bind#repeat()
  endif
endfunction

function! ag#bind#repeat()
  let g:ag.last.count = v:count
  call ag#bind#do(g:ag.last)
endfunction


" NEED:DEV: more sane api -- THINK: how to separate flags, regex, paths?
function! ag#bind#f(view, pattern, paths, mode)
  let e = g:ag.last
  let e.view = a:view
  " DEV: if a:src == 'filelist' -> paths=a:paths else paths=ag#paths#{a:src}() else ''
  let e.paths = a:paths

  let e.mode = a:mode

  if type(a:pattern) == type(0)
    if a:pattern == 0
      " Do nothing. Keep old pattern intact.
    elseif a:pattern == 1
      call ag#args#slash(e)
    endif
  elseif type(a:pattern) == type("")
    if !empty(a:pattern)
      let e.pattern = a:pattern
    elseif exists('g:ag.visual') && g:ag.visual
      call ag#args#vsel(e)
    else
      call ag#args#cword(e)
    endif
  endif

  call ag#bind#do(e)
endfunction

function! ag#bind#f_tracked(cmd, visual, count, ...)
  let t = g:ag
  let t.visual = a:visual
  let t.last.count = a:count
  if a:cmd =~ 'AgGroupFile'
    let list = split(a:2)
    call call('ag#bind#f', [a:1, join(list[1:-1],' '), [list[0]], ''])
  else
    call call('ag#bind#f', a:000)
  endif
  if t.toggle.mappings_to_cmd_history && "nvV" =~ mode()
   if a:cmd =~ 'File'
     let cmd = a:cmd.' '.join(g:ag.last.paths + [g:ag.last.pattern])
   else
     let cmd = a:cmd.' '.join([g:ag.last.pattern] + g:ag.last.paths)
   endif
   call histadd(":", cmd)
  endif
endfunction


