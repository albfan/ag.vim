" TODO: replace by direct patt supplying from bind args list
function! ag#group#get_patt(p)
  if exists('g:ag.last.auto') && g:ag.last.auto
    let args = join(g:ag.last.args, " ")
  else
    let args = join(g:ag.last.orig_args, " ")
    let args = args =~# '^"'
          \ ? split(args, '"')[0]
          \ : args =~# "^'"
              \ ? split(args, "'")[0]
              \ : split(args, '\s\+')[0]
  endif
  return args
endfunction

function! ag#group#search(args, frgx)
  let g:ag.last.filter = a:frgx
  let _ = ag#bind#exec(ag#provider#ag(g:ag.last))
  if empty(_) | return | endif

  silent! wincmd P
  if !&previewwindow
    exe g:ag.nhandler
    execute  'resize ' . &previewheight
    set previewwindow
  endif
  setlocal modifiable
  execute "silent %delete_"
  setlocal buftype=nofile bufhidden=wipe noswapfile nobuflisted nowrap
  put = _ | 1delete _
  setlocal nomodifiable

  setfiletype ag
  " let g:ag.ft = '<ft>'  " DEV: replace <ft> by derivation or inheritance
  " call ag#syntax#set(g:ag.ft)

  let l:pattern = ag#group#get_patt(a:args)
  let l:ignore_case = (l:pattern !~# '[A-Z]')
  call ag#syntax#himatch_pcre(l:pattern, l:ignore_case)
endfunction

function! ag#group#next()
  silent! wincmd P
  if &previewwindow
    call ag#ctrl#NextFold()
    call ag#ctrl#OpenFile(0)
  endif
endfunction

function! ag#group#prev()
  silent! wincmd P
  if &previewwindow
    call ag#ctrl#PrevFold()
    call ag#ctrl#OpenFile(0)
  endif
endfunction
