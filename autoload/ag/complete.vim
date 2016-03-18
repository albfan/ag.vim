fun! s:largs(line, pos)
  let l = split(a:line[:a:pos-1], '\v%(%(%(^|[^\\])\\)@<!\s)+', 1)
  let n = len(l) - match(l, 'L\?Ag') - 1
  return [l, n]
endf


fun! ag#complete#file_fuzzy(arg, line, pos)
  let [l, n] = s:largs(a:line, a:pos)
  let l:cmd = 'ag -S -g '. shellescape(a:arg)
  if n>1 | return ag#bind#exec(l:cmd) | endif
endfun


fun! s:getopt(opt)
  " let prf = matchstr(a:opt, '.*\ze\.\w*$')
  " let key = matchstr(a:opt, '\v(^|\.)\zs\w*$')
  let elems = split(a:opt, '\.', 1)
  let [prf, key] = [ join(elems[0:-2], '.'), elems[-1] ]
  let o = ( empty(prf) ? 'g:ag' : 'g:ag.'.prf )
  exec 'let src = '.( exists(o) ? o : '{}' )
  return [src, key, prf]
endf


" BUG: <Tab> from middle of word don't recognize option as already completed
fun! ag#complete#opts_set(arg, line, pos)
  let [l, n] = s:largs(a:line, a:pos)
  if n < 2
    let [src, v, k] = s:getopt(a:arg)
    if type(src) != type({}) || empty(src) | return [] | endif
    " EXPL: Match option by name beginning part
    let lst = filter(sort(keys(src)), 'v:val =~# "^'.v.'"')
    if len(lst) == 1
      let sfx = ( type(get(src, lst[0]))==type({}) ? '.' : ' ' )
      let lst = [lst[0] . sfx]
    endif
    if !empty(k) | let lst = map(lst, '"'.k.'.".v:val') | endif
    return lst
  elseif n < 3
    " THINK:TODO: now completion works, only if cursor directly after option.
    "  - NEED to complete from any part of value, if its typed beginning
    "     matches to its current value.
    if l[1] =~# '\.'
      let [k, v] = split(l[1], '\.', 1)
      return [string(get(get(g:ag, k, {}), v, 1))]
    else
      return [string(get(g:ag, l[1], ''))]
    endif
  endif
endf


fun! ag#complete#opts_toggle(arg, line, pos)
  return filter(keys(g:ag.toggle), 'v:val =~ "^'.a:arg.'"')
endf
