function! ag#qf#search(args, cmd)
  let _ = ag#bind#exec(g:ag.prg.' '.a:args)
  if empty(_) | return | endif

  call ag#qf#populate(a:cmd, _)

  if a:cmd =~# '^l'
    exe g:ag.lhandler
    let b:ag_apply_mappings = g:ag.use_default.lmappings
    let b:ag_win_prefix = 'l' " we're using the location list
  else
    exe g:ag.qhandler
    let b:ag_apply_mappings = g:ag.use_default.qmappings
    let b:ag_win_prefix = 'c' " we're using the quickfix window
  endif

  let b:ag = get(b:, 'ag', {})
  setfiletype qf

  " XXX: truly bad way of highlighting. TODO:USE: :keephist let @/=...
  " If highlighting is on, highlight the search keyword.
  if g:ag.toggle.highlight
    let @/ = matchstr(a:args, "\\v(-)\@<!(\<)\@<=\\w+|['\"]\\zs.{-}\\ze['\"]")
    call feedkeys(":let &hlsearch=1 \| echo \<CR>", 'n')
  end

  redraw!

  if b:ag_apply_mappings && g:ag.toggle.mapping_message
    echom "ag.vim keys: q=quit <cr>/e/t/h/v=enter/edit/tab/split/vsplit go/T/H/gv=preview versions of same"
  endif
endfunction


function! ag#qf#populate(cmd, lst)
  let l:efm_old = &efm
  try
    set errorformat=%f:%l:%c:%m,%f
    silent exec a:cmd . ' a:lst'
  finally
    let &efm=l:efm_old
  endtry
endfunction
