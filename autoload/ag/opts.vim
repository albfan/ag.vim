let s:ag = {}

" Inner fields
let s:ag.bin = 'ag'
let s:ag.ver = get(split(system(s:ag.bin.' --version'), '\_s'), 2, '')

" --vimgrep (consistent output we can parse) is available from ag v0.25.0+
let s:ag.prg = s:ag.bin . (s:ag.ver !~# '\v0\.%(\d|1\d|2[0-4])%(\.\d+|$)' ?
      \ ' --vimgrep' : ' --column --nogroup --noheading')
let s:ag.prg .=' --smart-case --ignore tags'  " TEMP:REMOVE?
let s:ag.prg_grp = s:ag.bin . ' --column --group --heading'
let s:ag.prg_grp .=' --smart-case --ignore tags'  " TEMP:REMOVE?
let s:ag.last = {}

" Settings
let s:ag.qhandler = "botright copen"
let s:ag.lhandler = "botright lopen"
let s:ag.nhandler = "botright new"
let s:ag.working_path_mode = 'c'
let s:ag.root_markers = ['.rootdir', '.git/', '.hg/', '.svn/', 'bzr', '_darcs', 'build.xml']
let s:ag.toggle = {}
let s:ag.toggle.highlight = 0
let s:ag.toggle.goto_exact_line = 0
let s:ag.toggle.open_first = 0

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


function! ag#opts#init()
  let g:ag = extend(get(g:, 'ag', {}), s:ag, 'keep')
  if !executable(g:ag.bin)
    throw "Binary '".g:ag.bin."' was not found in your $PATH. "
        \."Check if the_silver_searcher is installed and available."
  endif
endfunction


fun! ag#opts#set(opt, ...)
  if !exists('g:ag.'.a:opt)
    echom "Option '".a:opt."' doesn't exist!"
    return
  endif
  " if type(g:ag[a:opt]) != type(a:val)
  "   echom "Option '".a:opt."' has different type than type of '".a:val."'."
  let g:ag[a:opt] = join(a:000)
  echo '  ag.'.a:opt.' = '.string(g:ag[a:opt])
endf


fun! ag#opts#toggle(...)
  for opt in a:000 | if !exists('g:ag.toggle.'.opt)
    echom "Option '".opt."' doesn't exist!" | return
  endif | endfor
  let msg = '  ag.toggle:'
  for opt in a:000
    let g:ag.toggle[opt] = !g:ag.toggle[opt]
    let msg .= ' '.opt.'='.g:ag.toggle[opt]
  endfor
  echo msg
endf
