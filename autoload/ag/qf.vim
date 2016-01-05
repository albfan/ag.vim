function! ag#qf#search(args, cmd)

  call ag#qf#exec(a:cmd, a:args)

  if a:cmd =~# '^l'
    let l:match_count = len(getloclist(winnr()))
  else
    let l:match_count = len(getqflist())
  endif

  if l:match_count
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
  endif

  " If highlighting is on, highlight the search keyword.
  if g:ag.toggle.highlight
    let @/ = matchstr(a:args, "\\v(-)\@<!(\<)\@<=\\w+|['\"]\\zs.{-}\\ze['\"]")
    call feedkeys(":let &hlsearch=1 \| echo \<CR>", 'n')
  end

  redraw!

  if l:match_count && b:ag_apply_mappings && g:ag.toggle.mapping_message
    echom "ag.vim keys: q=quit <cr>/e/t/h/v=enter/edit/tab/split/vsplit go/T/H/gv=preview versions of same"
  endif

  if !l:match_count
    " Close the split window automatically:
    cclose
    lclose
    echohl WarningMsg
    echom 'No matches for "'.a:args.'"'
    echohl None
  endif
endfunction


function! ag#qf#run(cmd, args)
  let l:efm_old = &efm
  try
    set errorformat=%f:%l:%c:%m,%f
    call ag#bind#populate(a:cmd, g:ag.prg.' '.a:args)
  finally
    let &efm=l:efm_old
  endtry
endfunction


function! s:lcd(f, ...)
  let l:cwd_back = getcwd()
  let l:cwd = ag#paths#pjroot('nearest')
  try
    exe "lcd ".l:cwd
  catch
    echom 'Failed to change directory to:'.l:cwd
  finally
    call call(f, a:000)
    exe "lcd ".l:cwd_back
  endtry
endfunction


function! ag#qf#exec(cmd, args)
  if g:ag.working_path_mode ==? 'r'
    call s:lcd(ag#qf#run, a:cmd, a:args)
  else
    call ag#qf#run(a:cmd, a:args)
  endif
endfunction
