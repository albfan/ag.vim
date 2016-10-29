"" Syntax highlight for AgGroup results
if version < 600
  syntax clear
elseif exists('b:current_syntax')
  finish  " EXPL: allows to redefine this syntax by user's 'syntax/ag.vim'
endif

" DEV: embedded syntax in qf
" DEV: foldtext which shows all [agMatchLine]s instead whole agContextBlock
"   ALT:TRY: ability to conceal context regions, leaving only matches
"   -- by concealment text showed instead?

syntax case match  " Individual ignorecase done by '\c' prefix (performance)

" EXPL: compatibility fix with v7.2
let s:line_opts = 'display oneline keepend contained'
    \.(has('conceal') ? ' concealends' : '')

" EXPL: _implicit_ cluster @agMatchG used to toggle the highlighting options
execute "
  \ syn region agMatchLine ".s:line_opts." contains=@agMatchG
  \ matchgroup=agMatchNum start='\\v^%(\\d+:){1,2}'
  \ matchgroup=NONE excludenl end='$'"


" EXPL: fold continuous piece of file only when used search with context
if !empty(g:ag.last.count)
  syn cluster agGroupG  contains=agContextBlock
  syn cluster agContextG  contains=agContextLine,agMatchLine

  syn match agDelimiter  display contained contains=NONE excludenl '^--$'
  if g:ag.toggle.folddelim
    syn cluster agContextG  add=agDelimiter
  else
    syn cluster agGroupG  add=agDelimiter
  endif

  execute "
    \ syn region agContextLine ".s:line_opts."
    \ matchgroup=agContextNum start='^\\d\\+-' matchgroup=NONE end='$'
    \ contains=".(g:ag.toggle.syntax_in_context ? '@agMatchG' : 'NONE')
  execute "
    \ syn region agContextBlock  fold keepend contained contains=@agContextG
    \ start='\\v^%(\\d+:){1,2}' start='^\\d\\+-'
    \ end='^\\n'me=s-1 excludenl end='\\n--$'"
    \ .(g:ag.toggle.folddelim ?'': 'me=s-1')
else
  " EXPL:HACK: optimize performance impact by completely disabling agContextBlock
  syn cluster agGroupG  contains=agMatchLine
endif


" ATTENTION: Declared last to have highest priority in regions match order.
if g:ag.toggle.foldpath
  execute "
    \ syn region agGroupBlock  fold keepend contains=@agGroupG
    \ matchgroup=agPath excludenl start='^.\\+$'
    \ matchgroup=NONE end='\\%$' end='^\\n'"
    \.(g:ag.toggle.foldempty ?'': 'me=s-1')
else
  execute "
    \ syn region agGroupBlock  fold keepend contains=@agGroupG
    \ start='^.' end='\\%$' end='^\\n'"
    \.(g:ag.toggle.foldempty ?'': 'me=s-1')
  syn region agPath  oneline keepend contains=NONE
    \ start='^.' excludenl end='$' skipnl nextgroup=agGroupBlock
endif

" NOTE: highlight matches each time when re-applying syntax
if g:ag.toggle.view_highlight
  call ag#syntax#himatch_pcre(g:ag.last.pattern)
endif


""" Sync syntax highlight by nearest agGroupBlock (improved performance)
" ATTENTION: placed at the very end, after 'grouphere' value is defined
syntax sync clear
syntax sync minlines=0
syntax sync maxlines=500  " Disable highlight when group has >500 lines
syntax sync match agSync grouphere agGroupBlock '\%^\|^\_$\n\zs'


""" Highlighting colorscheme
hi def link agGroupBlock  NonText
hi def link agMatchLine   Normal
hi def link agContextLine Comment

hi def link agPath        Question
hi def link agDelimiter   Special
hi def link agMatchNum    Type
hi def link agContextNum  LineNr
hi def link agSearch      Todo
hi Folded ctermfg=244 ctermbg=235 cterm=NONE guifg=#8e9292 guibg=#2b2b2b gui=NONE
hi FoldColumn ctermfg=244 ctermbg=235 cterm=NONE guifg=#8e9292 guibg=#2b2b2b gui=NONE

" EXPL: must be last line -- set single-loading guard only if no exceptions
let b:current_syntax = 'ag'
