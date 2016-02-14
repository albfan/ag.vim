let s:ag = {}
let s:ag.toggle = {}

" Inner fields
let s:ag.bin = 'ag'
let s:ag.ver = get(split(system(s:ag.bin.' --version'), '\_s'), 2, '')
" --vimgrep (consistent output we can parse) is available from ag v0.25.0+
let s:ag.default = {}
let s:ag.default.qf = (s:ag.ver !~# '\v0\.%(\d|1\d|2[0-4])%(\.\d+|$)' ?
      \ ['--vimgrep'] : ['--column', '--nogroup', '--noheading'])
let s:ag.default.grp = ['--column', '--group', '--heading']

" Cmdline
" NOTE: for now use global case option, then move into .last if convenient
let s:ag.ignore = 'tags'
let s:ag.toggle.literal_vsel = 1
let s:ag.toggle.ignore_case = 0
let s:ag.toggle.smart_case = 1

" Settings
let s:ag.qhandler = "botright copen"
let s:ag.lhandler = "botright lopen"
let s:ag.nhandler = "botright new"
let s:ag.working_path_mode = 'c'
let s:ag.root_markers = ['.rootdir', '.git/', '.hg/', '.svn/', 'bzr', '_darcs', 'build.xml']
let s:ag.toggle.highlight = 0
let s:ag.toggle.goto_exact_line = 0
let s:ag.toggle.open_first = 0
let s:ag.ignore_list = []

" Mappings
let s:ag.use_default = {}
let s:ag.use_default.mappings = 1
let s:ag.use_default.qmappings = 1
let s:ag.use_default.lmappings = 1
let s:ag.use_default.abbreviations = 1
let s:ag.toggle.mapping_message = 1
let s:ag.toggle.mappings_to_cmd_history = 0

" Folding configuration to obtain more tight compressing
let s:ag.toggle.foldpath  = 1          " Include group path
let s:ag.toggle.foldempty = 1          " Include trailing empty line
let s:ag.toggle.folddelim = 0          " Include context delimiter '--'
let s:ag.toggle.syntax_in_context = 1  " Embeds syntax in context area (also)


" NOTE: resets search entry to default state with defined fields
" EXPL: used to eliminate 'exists(...)' checks spread throughout the code
function! ag#opts#init_last(gstate)
  let a:gstate.last = {}
  let state = a:gstate.last
  let state.view = 'qf'
  let state.pattern = ''
  let state.filter = ''
  let state.count = 0
  " Toggle
  let state.word = 0
  let state.literal = 0
endfunction


function! ag#opts#init()
  if exists('g:ag') && type(g:ag) == type({})
    call ag#opts#merge(g:ag, s:ag)
  else
    let g:ag = s:ag
  endif
  call ag#opts#init_last(g:ag)
  if !executable(g:ag.bin)
    throw "Binary '".g:ag.bin."' was not found in your $PATH. "
        \."Check if the_silver_searcher is installed and available."
  endif
endfunction


fun! ag#opts#merge(dst, aug)
  call extend(a:dst, a:aug, 'keep')
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
  if type(g:ag[a:opt]) != type([])
    let g:ag[a:opt] = []
  elseif type(g:ag[a:opt]) != type("")
    let g:ag[a:opt] = ""
  elseif type(g:ag[a:opt]) != type(0)
    let g:ag[a:opt] = 0
  endif
  echo '  ag.'.a:opt.' = '.string(g:ag[a:opt])
endf

fun! ag#opts#append(opt, ...)
  if !exists('g:ag.'.a:opt)
    echom "Option '".a:opt."' doesn't exist!"
    return
  endif
  if type(g:ag[a:opt]) != type([])
    echom "Option '".a:opt."' is not a list"
    return
  endif
  call extend(g:ag[a:opt], a:000)
  echo '  ag.'.a:opt.' = '.string(g:ag[a:opt])
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
