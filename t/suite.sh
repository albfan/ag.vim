#!/bin/bash
# vim:ts=2:sw=2:sts=2:fdm=marker

#set -xv

# functions {{{
help() {
  scriptname=$(basename $0)
  cat<<EOF
$scriptname [options] [test.vader]

This the suite to test ag vim plugin

It will download dependencies needed for test running an isolate environment

Options:

   -h, --help    Show this help
   -v, --verbose Be verbose on output
   -c, --clean   Clean deps to download again
   -e, --edit    Configure environment and edit test on vim
   -s, --save    Save fixture file changes on exit
   -f, --full    Edit without disable initialization files 

Examples:

   # Test all suite
   $ $scriptname
   # Test concrete case
   $ $scriptname grp-all.vader
   # Clean deps and be verbose
   $ $scriptname -vc
   # Edit a test
   $ $scriptname -esf grp-file.vader
EOF
}

if [[ -t 1 ]]
then
  color() {
    printf "%s" "$(tput setaf $1)${@:2}$(tput sgr0)"
  }
else
  color() {
    printf "%s" "${@:2}"
  }
fi

show() {
  printf "$(color ${1%% *} '[%7s] -%s-') %s %s\n" "${1#* }" "$2" "$(color $3)" "$4";
}

get_deps() {
  local url="https://github.com/junegunn/vader.vim"
  local vader="$TMPDIR/${url##*/}"
  local clone="git clone -b master --depth=1 $url"
  (($CLEAN)) && rm -rf "$vader"
  [[ -d "$vader" ]] || (cd "${vader%/*}" && $clone --single-branch || $clone && echo)
}

urun() {
  local file="$1"
  local name="$2"
  local cmd

  cp -rT "$ROOT/$name" "$testdir/fixture" || return
  if [ -x "$ROOT/$name.sh" ]
  then
    "$ROOT/$name.sh" >/dev/null 2>&1
  fi
  if ! (($EDIT))
  then
    BATCH=-nNes
  fi
  cmd="$EDITOR -i NONE $EDITMODE $BATCH -S '$ROOT/helper.vim'"
  if (($EDIT))
  then 
    cmd+=" -c 'call ShowTestFixtures()' -- '${file}'"
  else
    cmd+=" -c 'Vader!' -c 'echo\"\"\|qall!' -- '${file}'"
    if ! (($VERBOSE))
    then
      cmd+=' 2>/dev/null'
    else
      cmd+=" 2> >(echo;sed -n '/^Starting Vader/,\$p')"
    fi
  fi
  eval $cmd
}

utest() {
  local file="$1" 
  local title="$(sed -rn '/^"""\s*([^"].*)/ s//\1/p' "$file")"
  local expect="$(sed -rn '/^\s*""""\s*/ s///p' "$file")"

  name="${1##*/}"; name="${name%.vader}"

  if [[ " $SKIP_TESTS " =~ " $name " ]]
  then
    show "3 SKIP" "--" "3 $name" "$title"
    continue
  fi

  testdir="$(mktemp --tmpdir -d "${name}.XXX")"
  trap "teardown" RETURN INT TERM EXIT
  (cd "$testdir" && urun "$file" "$name")
  RET=$?
  ((--RET))  # EXPL: Until clarified, treat 0 as error also.

  case "$expect" in
    failed)
      FAILURE=1
      ((RET)) && msg="2 FAIL/OK" || msg="1 FAIL/NO"
      ;;      
    *)
      FAILURE=0
      ((RET)) && msg="1 FAIL" || msg="2 OK"
      ;;
  esac
  TEST_FAILED=$(( !RET != !FAILURE ))
  if ((TEST_FAILED))
  then
    if [ -z "$FAILED_LIST"]
    then
      FAILED_LIST="$name"
    else
      FAILED_LIST="$FAILED_LIST $name"
    fi
  fi
  ((STATUS)) || STATUS=$TEST_FAILED # Logical XOR
  ((++NUM))
  show "$msg" "$(printf "%02d" "$NUM")" "4 $name" "$title"
}

teardown() {
  if (($EDIT)) && (($SAVE)) 
  then 
    if (($VERBOSE))
    then
      echo "saving editions on fixture dir"
    fi
    rm -rf "$ROOT/$name/*"
    cp -rT "$testdir/fixture" "$name"
  fi
  if (($VERBOSE))
  then
    echo "removing fixture temp dir"
  fi
  rm -rf '$testdir'
}

testsuite() { 
  local NUM=0
  for rgx in "${@:-.*}"
  do
    for fl in $ROOT/*.vader
    do
      if [[ "${fl##*/}" =~ $rgx ]]
      then
        utest "$fl"
      fi
    done
    ((NUM<2)) || echo $(color 3 '~~~~~~~~~')
  done
  ((NUM<2)) || echo $(
                    if ((STATUS))
                     then
                       color 1 " tests $(color 4 "$FAILED_LIST") $(color 1 'failed')"
                     else
                       color 2 ' test suite passed'
                     fi
                   )
  return $STATUS
}

die() { 
  printf "Err: '"${0##*/}"' %s${1+\n}" "$1"
  help
  exit 1 
}
# }}}

ROOT="$(dirname $(readlink -m ${0}))"

[[ -n "$TMPDIR" ]] || TMPDIR="$(dirname $(mktemp --dry-run --tmpdir))"
[[ "$EDITOR" =~ vim ]] || EDITOR=vim
echo using EDITOR: ${EDITOR}

# parsing arguments {{{
EDITMODE="-u NONE -U NONE"
while getopts 'vchefs-' opt
do
  case "$opt" in
    v)
      VERBOSE=1
      ;;
    s)
      SAVE=1
      ;;
    e)
      EDIT=1
      ;;
    f)
      EDITMODE=
      ;;
    c)
      CLEAN=1
      ;;
    h)
      help
      exit 0
      ;;
    -)
      eval 'opt=${'$((OPTIND>2? --OPTIND :OPTIND))'#--}'
      OPTARG="${opt#*=}"
      case "${opt%%=*}" in
        verbose)
          VERBOSE=1
          ;;
        clean)
          CLEAN=1
          ;;
        edit)
          EDIT=1
          ;;
        full)
          EDITMODE=
          ;;
        save)
          SAVE=1
          ;;
        help)
          help
          exit 0
          ;;
        *)
          die "invalid long option '--$opt'"
      esac
      OPTIND=1
      shift
      ;;
    "?")
      die
      ;;
    :)
      die "needs value for '-$opt'"
      ;;
    *)
      die "has mismatched option '-$opt'"
  esac
done
shift $((OPTIND-1))
# }}}

get_deps && testsuite "$@"
