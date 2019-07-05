let s:ag = {}
let s:ag.toggle = {}

" Cmdline
" NOTE: for now use global case option, then move into .last if convenient
let s:ag.ignore_pattern_list = []
let s:ag.toggle.literal_vsel = 1
let s:ag.toggle.case_ignore = 0
let s:ag.toggle.ignore_vcs_ignore = 0
let s:ag.toggle.case_smart = 1
let s:ag.toggle.collapse_results = 0

" Settings
let s:ag.chandler = "botright copen"
let s:ag.lhandler = "botright lopen"
let s:ag.nhandler = "botright new"
let s:ag.working_path_mode = 'c'
let s:ag.root_markers = ['.rootdir', '.git/', '.hg/', '.svn/', 'bzr', '_darcs', 'build.xml']
let s:ag.toggle.highlight = 0
let s:ag.toggle.goto_exact_line = 0
let s:ag.toggle.open_first = 0
"let s:ag.ignore_list = ['tags']
let s:ag.ignore_list = []

" Mappings
let s:ag.use_default = {}
let s:ag.use_default.mappings = 1
let s:ag.use_default.cmappings = 1
let s:ag.use_default.lmappings = 1
let s:ag.use_default.abbreviations = 1
let s:ag.toggle.mapping_message = 1
let s:ag.toggle.mappings_to_cmd_history = 1
let s:ag.toggle.jump_in_preview = 0

" Folding configuration to obtain more tight compressing
let s:ag.toggle.foldpath  = 1          " Include group path
let s:ag.toggle.foldempty = 1          " Include trailing empty line
let s:ag.toggle.folddelim = 0          " Include context delimiter '--'
let s:ag.toggle.syntax_in_context = 1  " Embeds syntax in context area (also)
let s:ag.toggle.view_highlight = 1     " Highlight regex in view buffer


" NOTE: resets search entry to default state with defined fields
" EXPL: used to eliminate 'exists(...)' checks spread throughout the code
function! ag#opts#init_entry()
  let e = {}
  let e.view = 'qf'
  let e.pattern = ''
  let e.filter = ''
  let e.count = 0
  " Toggle
  let e.word = 0
  let e.literal = 0
  return e
endfunction


function! ag#opts#init()
  if exists('g:ag') && type(g:ag) == type({})
    call ag#opts#merge(g:ag, s:ag)
  else
    let g:ag = s:ag
  endif
  let g:ag.last = ag#opts#init_entry()
endfunction


fun! ag#opts#merge(dst, aug, ...)
  call extend(a:dst, a:aug, get(a:, 1, 'keep'))
  for k in keys(a:aug) | if type(a:aug[k]) == type({})
    if type(a:dst[k]) != type({})
      throw "Wrong type '".type(a:dst[k])."' for '".k."' option."
    endif
    call ag#opts#merge(a:dst[k], a:aug[k])
  endif | endfor
endf

fun! ag#opts#show(opt)
  if !exists('g:ag.'.a:opt)
    echom "Option '".a:opt."' doesn't exist!"
    return
  endif
  echo '  ag.'.a:opt.' = '.string(g:ag[a:opt])
endf

fun! ag#opts#reset(opt)
  if !exists('g:ag.'.a:opt)
    echom "Option '".a:opt."' doesn't exist!"
    return
  endif
  if type(g:ag[a:opt]) == type([])
    let g:ag[a:opt] = []
  elseif type(g:ag[a:opt]) == type("")
    let g:ag[a:opt] = ""
  elseif type(g:ag[a:opt]) == type(0)
    let g:ag[a:opt] = 0
  endif
  call ag#opts#show(a:opt)
endf

fun! ag#opts#show(opt)
  echo '  ag.'.a:opt.' = '.string(g:ag[a:opt])
endf

fun! ag#opts#append(opt, ...)
  if !exists('g:ag.'.a:opt)
    echom "Option '".a:opt."' doesn't exist!"
    return
  endif
  let type = type(g:ag[a:opt])
  if type == type([])
    call extend(g:ag[a:opt], a:000)
    echo '  ag.'.a:opt.' = '.string(g:ag[a:opt])
  elseif type(g:ag[a:opt]) == type("")
    exe 'let g:ag.'.a:opt.' += '.string(g:ag[a:opt])
  else
    echom "Cannot append to option '".o."' type '".type."'not managed"
    return
  endif
endf

" ATTENTION: rhs is evaluated and only then substituted. Use quotes to prevent.
fun! ag#opts#set(cmdline)
  let o = 'g:ag.' . matchstr(a:cmdline, '^\S\+')
  if !exists(o)
    echom "Option '".o."' doesn't exist!"
    return
  endif
  " if type(g:ag[a:opt]) != type(a:val)
  "   echom "Option '".a:opt."' has different type than type of '".a:val."'."
  let rhs = matchstr(a:cmdline, '\v^\S+\s+\zs.*')
  if !empty(rhs) | exec 'let '.o.' = '.rhs | endif
  exec 'echo "  '.o.' = ".string('.o.')'
endf

fun! ag#opts#ignore_pattern_list(ignore_pattern)
  call ag#opts#append('ignore_pattern_list', a:ignore_pattern)
  silent call ag#bind#repeat()
endf

fun! ag#opts#reset_ignore_pattern_list()
  call ag#opts#reset('ignore_pattern_list')
  silent call ag#bind#repeat()
endf

fun! ag#opts#ignore_list(ignore)
  call ag#opts#append('ignore_list', a:ignore)
  silent call ag#bind#repeat()
endf

fun! ag#opts#reset_ignore_list()
  call ag#opts#reset('ignore_list')
  silent call ag#bind#repeat()
endf

fun! ag#opts#toggle(cmdline)
  let l:lst = split(a:cmdline)
  for opt in l:lst | if !exists('g:ag.toggle.'.opt)
    echom "Option '".opt."' doesn't exist!" | return
  endif | endfor
  let msg = '  ag.toggle:'
  for opt in l:lst
    let g:ag.toggle[opt] = !g:ag.toggle[opt]
    let msg .= '  '.opt.'='.g:ag.toggle[opt]
  endfor
  echo msg
endf
