setlocal foldmethod=expr
setlocal foldexpr=ag#ctrl#FoldAg()
setlocal foldcolumn=2

" ALT:TRY: change ft in default way by hooking autocmd of 'setf <ft>'
"   -- au Syntax <buffer> call ag#syntax#set(<amatch>)' -- when <afile>==ag
command! -buffer -complete=filetype -nargs=?  AgFt  call ag#syntax#set(<q-args>)

noremap <silent> <buffer> o       zaj
noremap <silent> <buffer> <Space> :call ag#ctrl#NextFold()<CR>
noremap <silent> <buffer> O       :call ag#ctrl#ToggleEntireFold()<CR>
noremap <silent> <buffer> <CR>    :call ag#ctrl#OpenFile(0)<CR>
noremap <silent> <buffer> s       :call ag#ctrl#OpenFile(1)<CR>
noremap <silent> <buffer> S       :call ag#ctrl#OpenFile(2)<CR>
noremap <silent> <buffer> d       :call ag#ctrl#DeleteFold()<CR>
noremap <silent> <buffer> gl      :call ag#ctrl#ToggleShowLine()<CR>
