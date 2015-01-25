## -- PATH --
pathadd() {
    if [ -d "$1" ] && [[ ":$PATH:" != *":$1:"* ]]; then
        PATH="$1:$PATH"
    fi
}
pathadd "$HOME/usr/bin"
pathadd "$(brew --prefix coreutils)/libexec/gnubin"
pathadd "$HOME/miniconda/bin"

## -- SOURCE STUFF --
if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi
which -s brew
if [[ $? == 0 ]]; then
    if [ -f $(brew --prefix)/etc/bash_completion ]; then
        . $(brew --prefix)/etc/bash_completion
    fi
fi

## -- PYTHON --
# pip should only run if there is a virtualenv currently activated
export PIP_REQUIRE_VIRTUALENV=true
export WORKON_HOME=$HOME/.virtualenvs
export PROJECT_HOME=$HOME/proj
source /usr/local/bin/virtualenvwrapper.sh

## -- HOMESHICK --
source "$HOME/.homesick/repos/homeshick/homeshick.sh"
source "$HOME/.homesick/repos/homeshick/completions/homeshick-completion.bash"
homeshick --quiet refresh

# Type a few characters before pressing up to search for commands that begin
# with that string: http://stackoverflow.com/questions/1030182/
bind '"\e[A": history-search-backward'
bind '"\e[B": history-search-forward'

## -- PROMPT --
PS1='\[\033[01;37m\]\h\[\033[00m\]:\[\033[01;33m\]\W\[\033[00m\]\$ '

## -- EDITOR --
export VISUAL=$HOME/usr/bin/mvim
export EDITOR=$HOME/usr/bin/vim

bash_prompt
# The various escape codes that we can use to color our prompt.
        RED="\[\033[0;31m\]"
     YELLOW="\[\033[1;33m\]"
      GREEN="\[\033[0;32m\]"
       BLUE="\[\033[1;34m\]"
  LIGHT_RED="\[\033[1;31m\]"
LIGHT_GREEN="\[\033[1;32m\]"
      WHITE="\[\033[1;37m\]"
 LIGHT_GRAY="\[\033[0;37m\]"
 COLOR_NONE="\[\e[0m\]"

 # Detect whether the current directory is a git repository.
 function is_git_repository {
   git branch > /dev/null 2>&1
 }

 function set_git_branch {
   # Set the final branch string
   BRANCH=`parse_git_branch`
   local TIME=`fmt_time` # format time for prompt string
 }

 function parse_git_branch() {
   git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e "s/* \(.*\)/\1$(parse_git_dirty)/"
 }

 function parse_git_dirty() {
   [[ $(git status 2> /dev/null | tail -n1) != *"working directory clean"* ]] && echo "*"
 }

 fmt_time () { #format time just the way I likes it
     if [ `date +%p` = "PM" ]; then
         meridiem="pm"
     else
         meridiem="am"
     fi
     date +"%l:%M:%S$meridiem"|sed 's/ //g'
 }

 # Return the prompt symbol to use, colorized based on the return value of the
 # previous command.
 function set_prompt_symbol () {
   if test $1 -eq 0 ; then
       PROMPT_SYMBOL="\$"
   else
       PROMPT_SYMBOL="${LIGHT_RED}\$${COLOR_NONE}"
   fi
 }

 # Determine active Python virtualenv details.
 function set_virtualenv () {
   if test -z "$VIRTUAL_ENV" ; then
       PYTHON_VIRTUALENV=""
   else
       PYTHON_VIRTUALENV="${BLUE}[`basename \"$VIRTUAL_ENV\"`]${COLOR_NONE} "
   fi
 }

 # Set the full bash prompt.
 function set_bash_prompt () {
   # Set the PROMPT_SYMBOL variable. We do this first so we don't lose the
   # return value of the last command.
   set_prompt_symbol $?

   # Set the PYTHON_VIRTUALENV variable.
   set_virtualenv

   # Set the BRANCH variable.
   if is_git_repository ; then
     set_git_branch
   else
     BRANCH=''
   fi

   # Set the bash prompt variable.
   PS1="${PYTHON_VIRTUALENV}${YELLOW}\w${COLOR_NONE} ${BRANCH}${PROMPT_SYMBOL} "
 }

 # Tell bash to execute this function just before displaying its prompt.
 PROMPT_COMMAND=set_bash_prompt

## -- HISTORY --
# avoid duplicates
export HISTCONTROL=ignoredups:erasedups  
# append history entries
shopt -s histappend
# after each command, save and reload history
export PROMPT_COMMAND="${PROMPT_COMMAND:+$PROMPT_COMMAND$'\n'}history -a; history -c; history -r"

## -- DIRECTORY --
# Change to most recently used directory
if [ -f ~/.lastdir ]; then
    cd "`cat ~/.lastdir`"
fi
# Augment PROMPT_COMMAND to list 7 recently changed files when:
# - a new shell is started in a directory other than home
# - cd to any directory
export LASTDIR=${HOME}
function prompt_command {
    newdir=`pwd`
    if [ ! "$LASTDIR" = "$newdir" ]; then
        printf %s "$PWD" > ~/.lastdir
        # Note script -q /dev/null is required to retain color output
        script -q /dev/null ls -ltrFG | tail -7
    fi
    export LASTDIR=$newdir
}
PROMPT_COMMAND+='; prompt_command'
