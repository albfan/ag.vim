" Populate view implementations

function! ag#populate#qf(lst, dst, mode)
  if a:dst !~# '[cl]'
    throw "Err: populate#qf don't support '".a:dst."' destination type."
  endif

  let cmd = a:dst
  if a:mode =~# '+'
    let cmd .= 'add'
  " ATTENTION:DEV: actually dfl jump to first entry is non-congruent
" elseif a:mode =~# '-'  " THINK? '-' removes entries from already created list?
  elseif a:mode !~# '!' && !g:ag.toggle.open_first
    let cmd .= 'get'
  endif
  let cmd .= 'expr a:lst'

  let l:efm_old = &efm
  try
    set errorformat=%f:%l:%c:%m,%f
    silent exec cmd
  finally
    let &efm=l:efm_old
  endtry

  exec g:ag[a:dst.'handler']
  let b:ag = {}
  let b:ag.dst = a:dst
  " extend(get(b:, 'ag', {}), {'dst': a:dst})
  setfiletype ag_qf

  if g:ag.use_default[a:dst.'mappings'] && g:ag.toggle.mapping_message
    echom "ag.vim keys: q=quit <cr>/e/t/h/v=enter/edit/tab/split/vsplit go/T/H/gv=preview versions of same"
  endif
endfunction


function! ag#populate#grp(lst, dst, mode)
  if a:dst ==# 'preview'
    silent! wincmd P
    if !&previewwindow
      exe g:ag.nhandler
      execute  'resize ' . &previewheight
      setlocal previewwindow
    endif
    setlocal modifiable bt=nofile bufhidden=wipe noswapfile nobuflisted nowrap
  " RFC:(merge)DEV: constuct handler: buffer/[v]split/tab/file/unite/...
  elseif a:dst ==# 'buffer'
    setlocal modifiable bt=nofile noswapfile nowrap
  else
    throw "Err: populate#grp don't support '".a:dst."' destination type."
  endif

  if a:mode =~# '+'
    let cmd = '$put = a:lst'
  else
    let cmd = '%delete_ | put = a:lst | 1delete _'
  endif

  silent exec cmd
  setfiletype ag_grp
  normal zA
  normal zt
  " let g:ag.ft = '<ft>'  " DEV: replace <ft> by derivation or inheritance
  " call ag#syntax#set(g:ag.ft)
endfunction
