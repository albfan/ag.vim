function! ag#group#search(lst, cmd)
  " DEV: use a:cmd to regulate 'add/new'
  silent! wincmd P
  if !&previewwindow
    exe g:ag.nhandler
    execute  'resize ' . &previewheight
    set previewwindow
  endif
  setlocal modifiable
  execute "silent %delete_"
  setlocal buftype=nofile bufhidden=wipe noswapfile nobuflisted nowrap
  put = a:lst | 1delete _
  setlocal nomodifiable

  setfiletype ag
  " let g:ag.ft = '<ft>'  " DEV: replace <ft> by derivation or inheritance
  " call ag#syntax#set(g:ag.ft)

  let l:ignore_case = (g:ag.last.pattern !~# '[A-Z]')
  call ag#syntax#himatch_pcre(g:ag.last.pattern, l:ignore_case)
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
