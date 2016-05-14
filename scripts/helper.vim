if !exists('$TMPDIR')
  let $TMPDIR = fnamemodify(system('mktemp --dry-run --tmpdir'), ':h')
endif

let $VADER = expand($TMPDIR . '/vader.vim/')
let $PJROOT = fnamemodify(resolve(expand('<sfile>')), ':h:h')

set runtimepath+=$VADER,$PJROOT
exe 'so' fnameescape($VADER  .'/plugin/vader.vim')
exe 'so' fnameescape($PJROOT .'/plugin/ag.vim')
syntax on

function! ShowTestFixtures()
  vnew
  setlocal buftype=nofile
  put ='pwd: '.getcwd()
  exe "normal 30\<C-W>|"
  let readfilecommand="ls -R"
  if executable("tree")
    let readfilecommand="tree"
  endif
  exec "silent read !" readfilecommand
  setlocal nomodifiable
  setlocal readonly
  exec winnr('$').'wincmd w'
endfunction
