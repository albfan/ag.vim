function! ag#provider#ag(e)
  let argv = ['ag', '--silent']

  let t = g:ag.toggle
  if t.ignore_vcs_ignore
    let argv += [ '-U']
  endif

  " One-time crutch to chech if ag available and choose arguments for qf
  if !exists('s:ag_args_qf')
    if !executable('ag')
      throw "Binary 'ag' was not found in your $PATH. "
          \."Check if the_silver_searcher is installed and available."
    endif
    " --vimgrep (consistent output we can parse) is available from ag v0.25.0+
    let ver = get(split(system('ag --version'), '\_s'), 2, '')
    let s:ag_args_qf = ver !~# '\v0\.%(\d|1\d|2[0-4])%(\.\d+|$)' ?
        \ ['--vimgrep'] : ['--column', '--nobreak', '--noheading']
  endif

  " Match case
  let argv += [ t.case_ignore ? '-i' : t.case_smart ? '-S' : '-s']

  if !empty(g:ag.ignore_list)
    for ignore_item in g:ag.ignore_list
      let argv += [ "--ignore", ignore_item ]
    endfor
  endif

  " Viewer-specific
  if a:e.view =~# '\v(qf|loc)$'
    let argv += s:ag_args_qf
  elseif a:e.view =~# '\v(grp|buf)$'
    let argv += ['--column', '--group']
  endif

  " Context lines for 'group'
  if a:e.count > 0
    let argv += ['-C', a:e.count]
  endif

  " Filename filter
  if !empty(a:e.filter)
    let argv += ['-G', a:e.filter]
  endif

  " Pattern and paths to search
  " TODO: allow e.pattern to be both string or array
  let argv += [a:e.pattern] + a:e.paths

  " Filename filter
  if !empty(g:ag.ignore_pattern_list)
    for ignore_pattern_item in g:ag.ignore_pattern_list
      "TODO: Escape double commas
      let argv += ['|', 'grep', '-v', '-e', '"^[0-9]\+:[0-9]\+:.*', ignore_pattern_item, '"']
    endfor
  endif

  let command = ag#bind#join(argv)
  "echom command
  return command
endfunction
