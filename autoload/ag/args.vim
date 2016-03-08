" Providers of search arguments
" THINK:FIX: this vsel disables using ranges?
function! ag#args#vsel(e, ...)
  " DEV:RFC:ADD: 'range' postfix and use a:firstline, etc -- to exec f once?
  let [lnum1, col1] = getpos("'<")[1:2]
  let [lnum2, col2] = getpos("'>")[1:2]
  let lines = getline(lnum1, lnum2)
  " THINK:NEED: different croping for v/V/C-v
  let lines[-1] = lines[-1][: col2 - (&selection == 'inclusive' ? 1 : 2)]
  let lines[0] = lines[0][col1 - 1:]

  " THINK: smart derivation word=0/1 depending on surrounding spaces/delims?
  let a:e.word = 0
  let a:e.literal = g:ag.toggle.literal_vsel
  if a:0 >= 1 && type(a:1)==type([])
    let a:e.pattern = lines
  else
    let a:e.pattern = escape(join(lines, get(a:, 1, '\n')), ' ')
  endif
endfunction


function! ag#args#slash(e)
  let a:e.word = 0
  let a:e.literal = 0
  " TODO:NEED: more perfect vim->perl regex converter
  let a:e.pattern = substitute(getreg('/'), '\(\\<\|\\>\)', '\\b', 'g')
endfunction


function! ag#args#cword(e)
  let a:e.word = 1
  let a:e.literal = 1
  let a:e.pattern = expand("<cword>")
endfunction
