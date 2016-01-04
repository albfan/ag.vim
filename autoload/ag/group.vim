" TODO: replace by direct patt supplying from bind args list
function! ag#group#get_patt(p)
  if exists('g:ag.last.auto') && g:ag.last.auto
    let args = join(g:ag.last.args[1:], " ")
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
  silent! wincmd P
  if !&previewwindow
    exe g:ag.nhandler
    execute  'resize ' . &previewheight
    set previewwindow
  endif
  setlocal modifiable
  execute "silent %delete_"
  setlocal buftype=nofile bufhidden=wipe noswapfile nobuflisted nowrap

  let fileregexp = (a:frgx==#'' ?'': '-G '.a:frgx)
  let context = (v:count<1 ?'': '-C '.v:count)
  let l:cmdline = g:ag.prg_grp.' '.fileregexp.' '.context.' '.a:args
  call ag#bind#populate('put =', l:cmdline)
  1delete _
  setlocal nomodifiable

  " REM:FIXME: -- after disallowing raw options in #55 and setting it directly
  let g:ag.last.context = matchstr(l:cmdline,
        \ '\v\s+%(-C|''-C'')\s*%(\zs\d+\ze|''\zs\d+\ze'')%(\s+|$)')

  setfiletype ag
  " let g:ag.ft = '<ft>'  " DEV: replace <ft> by derivation or inheritance
  " call ag#syntax#set(g:ag.ft)

  let l:pattern = ag#group#get_patt(a:args)
  let l:ignore_case = (l:pattern !~# '[A-Z]')
  call ag#syntax#himatch_pcre(l:pattern, l:ignore_case)
endfunction
