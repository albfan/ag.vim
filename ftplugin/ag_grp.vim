call ag#syntax#init_buffer()

setlocal foldmethod=syntax
setlocal foldcolumn=2

noremap <silent> <buffer> o       zaj
noremap <silent> <buffer> <Space> :call ag#ctrl#NextFold()<CR>
noremap <silent> <buffer> O       :call ag#ctrl#ToggleEntireFold()<CR>
noremap <silent> <buffer> <CR>    :call ag#ctrl#OpenFile(0)<CR>
noremap <silent> <buffer> s       :call ag#ctrl#OpenFile(1)<CR>
noremap <silent> <buffer> S       :call ag#ctrl#OpenFile(2)<CR>
noremap <silent> <buffer> d       :call ag#ctrl#DeleteFold()<CR>
noremap <silent> <buffer> gl      :call ag#ctrl#ToggleShowLine()<CR>
noremap <expr> <silent> <buffer> l ag#ctrl#ForwardSkipConceal(v:count1)
noremap <expr> <silent> <buffer> h ag#ctrl#BackwardSkipConceal(v:count1)
