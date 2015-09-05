" NOTE: You must, of course, install ag / the_silver_searcher
command! -bang -nargs=* -complete=file Ag call ag#Ag('grep<bang>',<q-args>)
command! -bang -nargs=* -complete=file AgBuffer call ag#AgBuffer('grep<bang>',<q-args>)
command! -count -nargs=*               AgGroup call     ag#AgGroup(<count>, 0, '', <q-args>)
command! -count -nargs=*               AgGroupFile call ag#AgGroup(<count>, 0, <f-args>)
command! -count                        AgGroupLast call ag#AgGroupLast(<count>)
command! -bang -nargs=* -complete=file AgAdd call ag#Ag('grepadd<bang>', <q-args>)
command! -bang -nargs=* -complete=file AgFromSearch call ag#AgFromSearch('grep<bang>', <q-args>)
command! -bang -nargs=* -complete=file LAg call ag#Ag('lgrep<bang>', <q-args>)
command! -bang -nargs=* -complete=file LAgBuffer call ag#AgBuffer('lgrep<bang>',<q-args>)
command! -bang -nargs=* -complete=file LAgAdd call ag#Ag('lgrepadd<bang>', <q-args>)
command! -bang -nargs=* -complete=file AgFile call ag#Ag('grep<bang> -g', <q-args>)
command! -bang -nargs=* -complete=help AgHelp call ag#AgHelp('grep<bang>',<q-args>)
command! -bang -nargs=* -complete=help LAgHelp call ag#AgHelp('lgrep<bang>',<q-args>)

vnoremap <Leader>ag :call ag#AgGroup(v:count, 1, '', '')<CR>
nnoremap <Leader>ag :call ag#AgGroup(v:count, 0, '', '')<CR>
nnoremap <Leader>ra :call ag#AgGroupLast(v:count)<CR>
