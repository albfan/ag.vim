function! ag#provider#ag(e)
  let argv = [g:ag.bin]
  " Match case
  let t = g:ag.toggle
  let argv += [ t.case_ignore ? '-i' : t.case_smart ? '-S' : '-s']

  " File ignore patterns
  if !empty(g:ag.ignore)
    let argv += ['--ignore', g:ag.ignore]
  endif

  if !empty(g:ag.ignore_list)
    for ignore_item in g:ag.ignore_list
      let argv += [ "--ignore", ignore_item ]
    endfor
  endif

  " Viewer-specific
  if a:e.view =~# '\v(qf|loc)$'
    let argv += g:ag.default.qf
  elseif a:e.view =~# '\v(grp)$'
    let argv += g:ag.default.grp
  endif
  " Context lines for 'group'
  if a:e.count > 1
    let argv += ['-C', a:e.count]
  endif
  " Filename filter
  if !empty(a:e.filter)
    let argv += ['-G', a:e.filter]
  endif

  " Pattern and paths to search
  " TODO: allow e.pattern to be both string or array
  let argv += [a:e.pattern] + a:e.paths
  return ag#bind#join(argv)
endfunction
