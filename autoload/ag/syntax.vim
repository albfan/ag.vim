""" Syntax helpers for syntax/ag.vim

" Change embedded syntax / update after changing any of b:ag._ options
function! ag#syntax#set(ft)
  let g = '@agEmbedSyn'
  " EXPL: remove all previously embedded syntax groups (sole method)
  syntax clear | set syntax=ag
  if a:ft ==# '' | return | endif
  exe 'syn cluster agMatchG add='.g
  " EXPL: load even syntax files with single-time loading guards
  if exists('b:current_syntax') | unlet b:current_syntax | endif
  " BUG: embedded syntax expects start-of-line '^' -- but there placed '\d:\d:'
  try|exe 'syn include '.g.' syntax/'.a:ft.'.vim'      |catch/E403\|E484/|endtry
  try|exe 'syn include '.g.' after/syntax/'.a:ft.'.vim'|catch/E403\|E484/|endtry
  let b:current_syntax = 'ag'  " EXPL: restore default guard (necessary)
endfunction


" Overlay to highlight only searched pattern
function! ag#syntax#himatch(patt)
  if a:patt ==# ''
    syn cluster agMatchG remove=agSearch | return
  else
    syn cluster agMatchG add=agSearch
  endif
  try| syn clear agSearch |catch/E391/|endtry
  execute "
    \ syn match agSearch display contained contains=NONE
    \ excludenl ".a:patt
endfunction


" TODO:DEV: replace try-catch by ag#bind#pcre2vim()
function! ag#syntax#himatch_pcre(patt, ...)  " a:1 -- ignorecase=1
  let _ = (get(a:, 1, 1) ? '\c' : '') . escape(a:patt, '/')
  try|try
    call ag#syntax#himatch('/\v'._.'/')
  catch /^Vim\%((\a\+)\)\=:E54/ " invalid regexp
    call ag#syntax#himatch('/'._.'/')
  endtry|catch|endtry
endfunction
