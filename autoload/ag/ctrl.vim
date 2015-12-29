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
  normal! kVj]zD
  setlocal nomodifiable
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
