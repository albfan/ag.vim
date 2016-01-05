" Providers of search arguments
function! ag#args#auto(args)
  " TODO:ADD: -range to commands to use: '<,'>Ag rgx and 11,87Ag rgx
  if !empty(a:args)
    " DEV: return args (regex+path...) constructed from multiple providers
    " if type(a:args)==type([])
    if type(a:args)==type('') && exists('*ag#args#'.a:args)
      return ag#args#{a:args}()
    endif
  endif
  " THINK:FIX: this vsel disables using ranges?
  return ( exists('g:ag.visual') && g:ag.visual
    \ ? ag#args#vsel('\n') 
    \ : !empty(expand("<cword>"))
       \ ? ag#args#cword()
       \ : g:ag.last.args)
endfunction


function! ag#args#vsel(...)
  " DEV:RFC:ADD: 'range' postfix and use a:firstline, etc -- to exec f once?
  let [lnum1, col1] = getpos("'<")[1:2]
  let [lnum2, col2] = getpos("'>")[1:2]
  let lines = getline(lnum1, lnum2)
  " THINK:NEED: different croping for v/V/C-v
  let lines[-1] = lines[-1][: col2 - (&selection == 'inclusive' ? 1 : 2)]
  let lines[0] = lines[0][col1 - 1:]
  " TODO: for derived always add -Q -- if don't have option 'treat_as_rgx'
  return a:0 >= 1 ? [join(lines, a:1)] : lines
endfunction


function! ag#args#slash()
  " TODO:NEED: more perfect vim->perl regex converter
  let rgx = substitute(getreg('/'), '\(\\<\|\\>\)', '\\b', 'g')
  return [l:rgx]
endfunction


function! ag#args#cword()
  return [expand("<cword>")]
endfunction
