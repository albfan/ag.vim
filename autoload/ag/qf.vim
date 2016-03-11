function! ag#qf#search(lst, cmd)
  let l:efm_old = &efm
  try
    set errorformat=%f:%l:%c:%m,%f
    silent exec a:cmd . ' a:lst'
  finally
    let &efm=l:efm_old
  endtry

  if a:cmd =~# '^l'
    exe g:ag.lhandler
    let b:ag_apply_mappings = g:ag.use_default.lmappings
    let b:ag_win_prefix = 'l' " we're using the location list
  else
    exe g:ag.chandler
    let b:ag_apply_mappings = g:ag.use_default.cmappings
    let b:ag_win_prefix = 'c' " we're using the quickfix window
  endif

  let b:ag = get(b:, 'ag', {})
  setfiletype qf

  if b:ag_apply_mappings && g:ag.toggle.mapping_message
    echom "ag.vim keys: q=quit <cr>/e/t/h/v=enter/edit/tab/split/vsplit go/T/H/gv=preview versions of same"
  endif
endfunction
