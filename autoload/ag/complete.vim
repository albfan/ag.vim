fun! s:largs(line, pos)
  let l = split(a:line[:a:pos-1], '\v%(%(%(^|[^\\])\\)@<!\s)+', 1)
  let n = len(l) - match(l, 'L\?Ag') - 1
  return [l, n]
endf


fun! ag#complete#file_fuzzy(arg, line, pos)
  let [l, n] = s:largs(a:line, a:pos)
  let l:cmd = g:ag.bin." -S -g ".shellescape(a:arg)
  if n>1 | return ag#bind#exec(l:cmd) | endif
endfun


fun! ag#complete#opts_set(arg, line, pos)
  let [l, n] = s:largs(a:line, a:pos)
  if n < 2
    let ks = filter(keys(g:ag), 'v:val !~# "use_default\\|toggle"')
    return filter(ks, 'v:val =~# "^'.a:arg.'"')
  elseif n < 3
    " THINK:TODO: now completion works, only if cursor directly after option.
    "  - NEED to complete from any part of value, if its typed beginning
    "     matches to its current value.
    return [g:ag[l[1]]]
  endif
endf


fun! ag#complete#opts_toggle(arg, line, pos)
  return filter(keys(g:ag.toggle), 'v:val =~ "^'.a:arg.'"')
endf
