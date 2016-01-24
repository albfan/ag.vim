function! ag#provider#ag(state)
  let argv = [g:ag.bin]
  " Match case
  if g:ag.toggle.ignore_case
    let argv += ['-i']
  elseif g:ag.toggle.smart_case
    let argv += ['-S']
  else
    let argv += ['-s']
  endif
  " File ignore patterns
  if !empty(g:ag.ignore)
    let argv += ['--ignore', g:ag.ignore]
  endif

  " Viewer-specific
  if a:state.view =~# '\v(qf|loc)$'
    let argv += g:ag.default.qf
  elseif a:state.view =~# '\v(grp)$'
    let argv += g:ag.default.grp
  endif
  " Context lines for 'group'
  if a:state.count > 1
    let argv += ['-C', a:state.count]
  endif
  " Filename filter
  if !empty(a:state.filter)
    let argv += ['-G', a:state.filter]
  endif

  " Pattern and paths to search
  let argv += a:state.args + a:state.paths
  return ag#bind#join(argv)
endfunction
