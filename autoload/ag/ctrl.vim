function! ag#ctrl#ToggleShowLine()
  if &conceallevel == 0
    setlocal conceallevel=2
  else
    setlocal conceallevel=0
  endif
endfunction


function! ag#ctrl#DeleteFold()
  if foldlevel(".") == 0
    return
  endif
  setlocal modifiable
  if foldclosed(".") != -1
    normal zo
  endif
  "normal stops if command fails. On  cursor at beginning of fold motion fails
  normal! [z
  let first = line('.') == 1
  if !first
    normal! k
  endif
  normal! V]zD
  if first
     normal! dd
  endif
  setlocal nomodifiable
  call ag#group#highlight_filenames()
endfunction

" Find next fold or go back to first one
"
function! ag#ctrl#NextFold()
  let save_a_mark = getpos("'a")
  let mark_a_exists = save_a_mark[1] == 0
  mark a
  execute 'normal zMzjzo'
  if getpos('.')[1] == getpos("'a")[1]
    "no movement go to first position
    normal gg
    execute 'normal zMzjzo'
  endif
  if mark_a_exists
    call setpos("'a", save_a_mark)
  else
    delmark a
  endif
endfunction

" Open file for AgGroup selection
"
" forceSplit:
"    0 no
"    1 horizontal
"    2 vertical
"
function! ag#ctrl#OpenFile(forceSplit)
  let curpos = line('.')
  let line = getline(curpos)
  if empty(line)
    return
  endif

  let increment = 1

  let poscol = curpos
  while line !~ '^\d\+:'
    let poscol = poscol + increment
    let line = getline(poscol)

    if empty(line)
      if increment == -1
        echom 'Cannot find file for match'
        break
      else
        let increment = -1
      endif
    endif
  endwhile

  let offset = curpos - poscol

  if line =~ '^\d\+:'
    let data = split(line,':')
    let pos = data[0]
    if g:ag.goto_exact_line
      let pos += offset
    endif
    let col = data[1]

    let filename = getline(curpos - 1)
    while !empty(filename) && curpos > 1
      let curpos = curpos - 1
      let filename = getline(curpos - 1)
    endwhile
    let filename = getline(curpos)
    let buffers_from_windows = map(range(1, winnr('$')), 'winbufnr(v:val)')
    let match_window = map(filter(copy(buffers_from_windows), 'bufname(v:val) == filename'), 'bufwinnr(v:val)')
    let winnr = 0
    if empty(match_window)
       let avaliable_windows = map(filter(copy(buffers_from_windows), 'buflisted(v:val)'), 'bufwinnr(v:val)')
       let winnr = get(avaliable_windows, 0)
    else
       let winnr = get(match_window, 0)
    endif
    let open_command = "edit"
    if a:forceSplit || winnr == 0
      if a:forceSplit > 1
        wincmd k
        let open_command = "vertical leftabove vsplit"
      else
        let open_command = "split"
      endif
    else
      exe winnr . "wincmd w"
    endif


    
    if bufname('%') == filename
      exe pos 
    else
      exe open_command . ' +' . pos . ' ' . filename
    endif
    exe 'normal ' . col . '|'
    exe 'normal zv'
  endif
endfunction


function! ag#ctrl#ToggleEntireFold()
  if foldclosed(2) == -1
    normal zM
  else
    normal zR
  endif
endfunction


function! ag#ctrl#FoldAg()
  let line = getline(v:lnum)
  if empty(line)
    return '0'
  else
    return '1'
  endif
  return '0'
endfunction

function! ag#ctrl#ForwardSkipConceal(count)
  let cnt=a:count
  let mvcnt=0
  let c=col('.')
  let l=line('.')
  let lc=col('$')
  let line=getline('.')
  while cnt
    if c>=lc
      let mvcnt+=cnt
      break
    endif
    if stridx(&concealcursor, 'n')==-1
      let isconcealed=0
    else
      let [isconcealed, cchar, group]=synconcealed(l, c)
    endif
    if isconcealed
      let cnt-=strchars(cchar)
      let oldc=c
      let c+=1
      while c<lc && synconcealed(l, c)[0]
        let c+=1
      endwhile
      let mvcnt+=strchars(line[oldc-1:c-2])
    else
      let cnt-=1
      let mvcnt+=1
      let c+=len(matchstr(line[c-1:], '.'))
    endif
  endwhile
  "exec "normal ".mvcnt."l"
  return ":\<C-u>\e".mvcnt."l"
endfunction

function! ag#ctrl#BackwardSkipConceal(count)
  let cnt=a:count
  let mvcnt=0
  let c=col('.')
  let l=line('.')
  let lc=1
  let line=getline('.')
  while cnt
    if c<=lc
      let mvcnt+=cnt
      break
    endif
    if stridx(&concealcursor, 'n')==-1
      let isconcealed=0
    else
      let [isconcealed, cchar, group]=synconcealed(l, c)
    endif
    if isconcealed
      let cnt-=strchars(cchar)
      let oldc=c
      let c+=1
      while c<lc && synconcealed(l, c)[0]
        let c-=1
      endwhile
      let mvcnt+=strchars(line[oldc-1:c-2])
    else
      let cnt-=1
      let mvcnt+=1
      let c+=len(matchstr(line[c-1:], '.'))
    endif
  endwhile
  "exec "normal ".mvcnt."h"
  return ":\<C-u>\e".mvcnt."h"
endfunction
