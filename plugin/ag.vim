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
command! -bang -range -nargs=* -complete=customlist,s:fc Ag           call ag#bind#f('qf', <q-args>, [], '<bang>')
command! -bang -range -nargs=* -complete=customlist,s:fc AgAdd        call ag#bind#f('qf', <q-args>, [], '<bang>+')
command! -bang -range -nargs=* -complete=customlist,s:fc AgBuffer     call ag#bind#f('qf', <q-args>, 'buffers', '<bang>')
command! -bang -range -nargs=* -complete=customlist,s:fc AgFromSearch call ag#bind#f('qf', 1, '<bang>')
" command! -bang -range -nargs=* -complete=customlist,s:fc AgFile       call ag#bind#f('qf', ['-g', <f-args>], [], '<bang>')
command! -bang -range -nargs=* -complete=help            AgHelp       call ag#bind#f('qf', <q-args>, 'help', '<bang>')

command! -bang -range -nargs=* -complete=customlist,s:fc LAg          call ag#bind#f('loc', <q-args>, [], '<bang>')
command! -bang -range -nargs=* -complete=customlist,s:fc LAgAdd       call ag#bind#f('loc', <q-args>, [], '<bang>+')
command! -bang -range -nargs=* -complete=customlist,s:fc LAgBuffer    call ag#bind#f('loc', <q-args>, 'buffers', '<bang>')
" command! -bang -range -nargs=* -complete=customlist,s:fc LAgFile      call ag#bind#f('loc', ['-g', <f-args>], [], '<bang>')
command! -bang -range -nargs=* -complete=help            LAgHelp      call ag#bind#f('loc', <q-args>, 'help', '<bang>')

command! -bang -count                                    AgRepeat     call ag#bind#repeat()
command! -bang -count -nargs=* -complete=customlist,s:fc AgGroup      call ag#bind#f_tracked('AgGroup', 0, <count>, 'grp', <q-args>, [], '')
command! -bang -count -nargs=* -complete=customlist,s:fc AgGroupFile  call ag#bind#f_tracked('AgGroup', 0, <count>, 'grp', <q-args>)


command! -bang -nargs=+ -complete=customlist,ag#complete#opts_set    AgSet     call ag#opts#set(<q-args>)
command! -bang -nargs=+ -complete=customlist,ag#complete#opts_toggle AgToggle  call ag#opts#toggle(<q-args>)
command! -bang -nargs=+ -complete=customlist,ag#complete#opts_set    AgAppend      call ag#opts#append(<f-args>)
command! -bang -nargs=+ -complete=customlist,ag#complete#opts_set    AgReset       call ag#opts#reset(<f-args>)
command! -bang -nargs=+ -complete=customlist,ag#complete#opts_set    AgShow        call ag#opts#show(<f-args>)
command! -bang -nargs=+                                              AgIgnore      call ag#opts#ignore_list(<f-args>)
command! -bang -nargs=0                                              AgIgnoreReset call ag#opts#reset_ignore_list()

command! -bang -nargs=0 AgNext  call ag#ctrl#next()
command! -bang -nargs=0 AgPrev  call ag#ctrl#prev()


if g:ag.use_default.abbreviations
  let s:ag_cabbrev =[
    \ ['ag',  'Ag'],
    \ ['aga', 'AgAdd'],
    \ ['agb', 'AgBuffer'],
    \ ['ags', 'AgFromSearch'],
    \ ['agf', 'AgFile'],
    \ ['agh', 'AgHelp'],
    \
    \ ['agl',  'LAg'],
    \ ['agla', 'LAgAdd'],
    \ ['aglb', 'LAgBuffer'],
    \ ['aglf', 'LAgFile'],
    \ ['aglh', 'LAgHelp'],
    \
    \ ['agr',  'AgRepeat'],
    \ ['agg',  'AgGroup'],
    \ ['aggroup',  'AgGroup'],
    \ ['aggf', 'AgGroupFile'],
    \ ['agn', 'AgNext'],
    \ ['agp', 'AgPrev'],
  \]

  function! s:expabbr(lhs, rhs)
    if getcmdtype() !=# ":" | return a:lhs | endif
    let l:lhcmd = strpart(getcmdline(), 0, getcmdpos() - 1)
    return (l:lhcmd =~ '^\A*'.a:lhs.'$' ? a:rhs : a:lhs)
  endfunction

  for [lhs, rhs] in s:ag_cabbrev
    if maparg(lhs, 'c', 1) ==# ''  " User can selectively redefine abbrev
      exe printf('cnorea <expr> %s <SID>expabbr("%s","%s")', lhs, lhs, rhs)
    endif
  endfor
endif


noremap <silent> <Plug>(ag-qf)           :<C-u>call ag#bind#f('qf', '', [], '')<CR>
noremap <silent> <Plug>(ag-qf-add)       :<C-u>call ag#bind#f('qf', '', [], '+')<CR>
noremap <silent> <Plug>(ag-qf-buffer)    :<C-u>call ag#bind#f('qf', '', 'buffers', '')<CR>
noremap <silent> <Plug>(ag-qf-searched)  :<C-u>call ag#bind#f('qf', 1, [], '')<CR>
" noremap <silent> <Plug>(ag-qf-file)      :<C-u>call ag#bind#f('qf', ['-g'], [], '')<CR>
noremap <silent> <Plug>(ag-qf-help)      :<C-u>call ag#bind#f('qf', '', 'help', '')<CR>

noremap <silent> <Plug>(ag-loc)          :<C-u>call ag#bind#f('loc', '', [], '')<CR>
noremap <silent> <Plug>(ag-loc-add)      :<C-u>call ag#bind#f('loc', '', [], '+')<CR>
noremap <silent> <Plug>(ag-loc-buffer)   :<C-u>call ag#bind#f('loc', '', 'buffers', '')<CR>
" noremap <silent> <Plug>(ag-loc-file)     :<C-u>call ag#bind#f('loc', ['-g'], [], '')<CR>
noremap <silent> <Plug>(ag-loc-help)     :<C-u>call ag#bind#f('loc', '', 'help', '')<CR>

nnoremap <silent> <Plug>(ag-repeat) :<C-u>call ag#bind#repeat()<CR>
nnoremap <silent> <Plug>(ag-group)  :<C-u>call ag#bind#f_tracked('AgGroup', 0, 1, 'grp', '', [], '')<CR>
xnoremap <silent> <Plug>(ag-group)  :<C-u>call ag#bind#f_tracked('AgGroup', 1, 1, 'grp', '', [], '')<CR>

nnoremap <silent> <Leader>gg :AgNext<CR>
nnoremap <silent> <Leader>pp :AgPrev<CR>

nnoremap <Plug>(ag-ctrl-o) <C-O>
nnoremap <C-O> :<C-u>call ag#ctrl#jumpBack()<CR>

if g:ag.use_default.mappings
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
