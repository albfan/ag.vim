"" Syntax highlight for Ag results in quickfix
if version < 600
  syntax clear
elseif exists('b:current_syntax') || !exists('b:ag')
  finish  " EXPL: allows to redefine this syntax by user 'syntax/ag.vim'
endif

" ATTENTION: instead of augment default 'syntax/qf.vim' we re-implement it.
"   Proc: completely separate syntax for ag-qf match results.
"   Cons: we don't respect any user 'syntax/qf.vim' for ag-qf.

syntax case match  " Individual ignorecase done by '\c' prefix (performance)

" DEV: fold results with same filename in qf
"   -- NOTE: much more difficult, as there no way to make simple match pattern
"   -- TRY: multiline match with group reusing like (...)|.*\_$\1.*\_$){2,}
"      WARNING: high CPU load

syn region agMatchLine  display contained oneline keepend contains=@agMatchG
    \ matchgroup=agDelimiter start='|' excludenl end='$'

syn match agPath      display           nextgroup=agDelimiter excludenl '^[^|]*'
syn match agDelimiter display contained nextgroup=agMatchNum  excludenl '|'
syn match agMatchNum  display contained nextgroup=agMatchLine excludenl '[^|]*'

" NOTE: highlight matches each time when re-applying syntax
if g:ag.toggle.view_highlight
  call ag#syntax#himatch_pcre(g:ag.last.pattern)
endif


""" No need to sync syntax at all (until block folding implemented)
syntax sync clear
syntax sync minlines=0
syntax sync maxlines=1


""" Highlighting colorscheme
hi def link agMatchLine   Normal
hi def link agPath        Directory
hi def link agDelimiter   Normal
hi def link agMatchNum    LineNr
hi def link agSearch      Todo


let b:current_syntax = 'qf'
