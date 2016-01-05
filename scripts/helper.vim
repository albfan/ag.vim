if !exists('$TMPDIR')
  let $TMPDIR = fnamemodify(system('mktemp --dry-run --tmpdir'), ':h')
endif

let $VADER = expand($TMPDIR . '/vader.vim/')
let $PJROOT = fnamemodify(resolve(expand('<sfile>')), ':h:h')

set runtimepath+=$VADER,$PJROOT
exe 'so' fnameescape($VADER  .'/plugin/vader.vim')
exe 'so' fnameescape($PJROOT .'/plugin/ag.vim')
syntax on
