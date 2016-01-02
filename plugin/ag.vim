if exists('g:loaded_ag') | finish | endif
let s:cpo_save = &cpo
set cpo&vim

try
  call ag#opts#init()
catch
  echom v:exception | finish
endtry

try
  call ag#operator#init()
catch /E117:/
  " echom "Err: function not found or 'kana/vim-operator-user' not installed"
endtry

fun! s:fc(...)
  return call('ag#complete#file_fuzzy', a:000)
endfun

" NOTE: You must, of course, install ag / the_silver_searcher
command! -bang -nargs=* -complete=customlist,s:fc Ag           call ag#bind#f('qf', [<f-args>], [], '<bang>')
command! -bang -nargs=* -complete=customlist,s:fc AgAdd        call ag#bind#f('qf', [<f-args>], [], '<bang>+')
command! -bang -nargs=* -complete=customlist,s:fc AgBuffer     call ag#bind#f('qf', [<f-args>], 'buffers', '<bang>')
command! -bang -nargs=* -complete=customlist,s:fc AgFromSearch call ag#bind#f('qf', 'slash', [<f-args>], '<bang>')
command! -bang -nargs=* -complete=customlist,s:fc AgFile       call ag#bind#f('qf', ['-g', <f-args>], [], '<bang>')
command! -bang -nargs=* -complete=help            AgHelp       call ag#bind#f('qf', [<f-args>], 'help', '<bang>')

command! -bang -nargs=* -complete=customlist,s:fc LAg          call ag#bind#f('loc', [<f-args>], [], '<bang>')
command! -bang -nargs=* -complete=customlist,s:fc LAgAdd       call ag#bind#f('loc', [<f-args>], [], '<bang>+')
command! -bang -nargs=* -complete=customlist,s:fc LAgBuffer    call ag#bind#f('loc', [<f-args>], 'buffers', '<bang>')
command! -bang -nargs=* -complete=customlist,s:fc LAgFile      call ag#bind#f('loc', ['-g', <f-args>], [], '<bang>')
command! -bang -nargs=* -complete=help            LAgHelp      call ag#bind#f('loc', [<f-args>], 'help', '<bang>')

command! -count                                    AgRepeat    call ag#bind#repeat()
command! -count -nargs=* -complete=customlist,s:fc AgGroup     call ag#bind#f('grp', [<f-args>], [], '')
command! -count -nargs=* -complete=customlist,s:fc AgGroupFile call ag#bind#f('grp', [<f-args>], [], -1)


if !g:ag.no_abbreviations
  let s:ag_cabbrev =[
    \ ['ag',  'Ag'],
    \ ['aga', 'AgAdd'],
    \ ['agb', 'AgBuffer'],
    \ ['ags', 'AgFromSearch'],
    \ ['agf', 'AgFile'],
    \ ['agh', 'AgHelp'],
    \
    \ ['agl',  'LAg'],
    \ ['agbl', 'LAgBuffer'],
    \ ['agfl', 'AgFile'],
    \
    \ ['agr',  'AgRepeat'],
    \ ['agg',  'AgGroup'],
    \ ['aggf', 'AgGroupFile'],
  \]

  function! s:expabbr(lhs, rhs)
    if getcmdtype() !=# ":" | return a:lhs | endif
    let l:lhcmd = strpart(getcmdline(), 0, getcmdpos())
    return (l:lhcmd =~ '^\A*'.a:lhs.'$' ? a:rhs : a:lhs)
  endfunction

  for [lhs, rhs] in s:ag_cabbrev
    if maparg(lhs, 'c', 1) ==# ''  " User can selectively redefine abbrev
      exe printf('cnorea <expr> %s <SID>expabbr("%s","%s")', lhs, lhs, rhs)
    endif
  endfor
endif


nnoremap <silent> <Plug>(ag-repeat) :<C-u>call ag#bind#repeat()<CR>
nnoremap <silent> <Plug>(ag-group)  :<C-u>call ag#bind#f_tracked('AgGroup', 'grp', [], [], '')<CR>
xnoremap <silent> <Plug>(ag-group)  :<C-u>call ag#bind#f_tracked('AgGroup', 'grp', [], [], '')<CR>
" TODO: add <Plug> mappings for Ag* and LAg*


if !g:ag.no_default_mappings
  let s:ag_mappings = [
    \ ['nx', '<Leader>af', '<Plug>(ag-qf)'],
    \ ['nx', '<Leader>aa', '<Plug>(ag-qf-add)'],
    \ ['nx', '<Leader>ab', '<Plug>(ag-qf-buffer)'],
    \ ['nx', '<Leader>as', '<Plug>(ag-qf-searched)'],
    \ ['nx', '<Leader>aF', '<Plug>(ag-qf-file)'],
    \ ['nx', '<Leader>aH', '<Plug>(ag-qf-help)'],
    \
    \ ['nx', '<Leader>Af', '<Plug>(ag-loc)'],
    \ ['nx', '<Leader>Aa', '<Plug>(ag-loc-add)'],
    \ ['nx', '<Leader>Ab', '<Plug>(ag-loc-buffer)'],
    \ ['nx', '<Leader>AF', '<Plug>(ag-loc-file)'],
    \ ['nx', '<Leader>AH', '<Plug>(ag-loc-help)'],
    \
    \ ['nx', '<Leader>ag', '<Plug>(ag-group)'],
    \ ['n',  '<Leader>ra', '<Plug>(ag-repeat)'],
    \
    \ ['nx', '<Leader>ad', '<Plug>(operator-ag-qf)'],
    \ ['nx', '<Leader>Ad', '<Plug>(operator-ag-loc)'],
    \ ['nx', '<Leader>Ag', '<Plug>(operator-ag-grp)'],
    \]
endif


if exists('s:ag_mappings')
  for [modes, lhs, rhs] in s:ag_mappings
    for m in split(modes, '\zs')
      if mapcheck(lhs, m) ==# '' && maparg(rhs, m) !=# '' && !hasmapto(rhs, m)
        exe m.'map <silent>' lhs rhs
      endif
    endfor
  endfor
endif


let g:loaded_ag = 1
let &cpo = s:cpo_save
unlet s:cpo_save
