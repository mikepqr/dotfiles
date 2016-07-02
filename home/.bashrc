## -- PATH --
pathadd() {
    if [ -d "$1" ] && [[ ":$PATH:" != *":$1:"* ]]; then
        PATH="$1:$PATH"
    fi
}
# See http://superuser.com/a/583502. Prevent global /etc/profile
# path_helper utility from prepending default PATH to previously chosen
# PATH in, e.g. tmux.
if [[ "$OSTYPE" == "darwin"* ]]; then
    if [ -f /etc/profile ]; then
        PATH=""
        source /etc/profile
    fi
fi
if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi
pathadd $HOME/usr/bin

# If not running interactively, don't do anything
[ -z "$PS1" ] && return

## -- OS SPECIFIC --
if [[ "$OSTYPE" == "linux-gnu" ]]; then
    DEFAULT_VIRTUALENV=tldr
elif [[ "$OSTYPE" == "darwin"* ]]; then
    DEFAULT_VIRTUALENV=ds3
    which -s brew
    if [[ $? == 0 ]]; then
        pathadd "$(brew --prefix coreutils)/libexec/gnubin"
        if [ -f $(brew --prefix)/share/bash-completion/bash_completion ]; then
            . $(brew --prefix)/share/bash-completion/bash_completion
        fi
    fi
fi

## -- PYTHON --
# pip should only run if there is a virtualenv currently activated
export PIP_REQUIRE_VIRTUALENV=true
export WORKON_HOME=$HOME/.virtualenvs
export PROJECT_HOME=$HOME/p
export VIRTUALENVWRAPPER_SCRIPT=$WORKON_HOME/$DEFAULT_VIRTUALENV/bin/virtualenvwrapper.sh
source $WORKON_HOME/$DEFAULT_VIRTUALENV/bin/virtualenvwrapper_lazy.sh
if [[ "$OSTYPE" == "darwin"* ]]; then
    source $WORKON_HOME/$DEFAULT_VIRTUALENV/bin/activate
fi

## -- HOMESHICK --
source "$HOME/.homesick/repos/homeshick/homeshick.sh"
source "$HOME/.homesick/repos/homeshick/completions/homeshick-completion.bash"
homeshick --quiet refresh

## -- VI BINDINGS --
set -o vi
export EDITOR=`which vim`

## -- PROMPT --
# http://stackoverflow.com/questions/23399183/bash-command-prompt-with-virtualenv-and-git-branch
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
}

function parse_git_branch() {
  git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e "s/* \(.*\)/\1$(parse_git_dirty)/"
}

function parse_git_dirty() {
  [[ $(git status 2> /dev/null | tail -n1) != *"working directory clean"* ]] && echo "*"
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
# Get remote hostname string (i.e. if not sabon)
function set_remote_hostname () {
  if [[ $(hostname) != "sabon" ]] ; then
      REMOTE_HOSTNAME="${RED}`hostname`${COLOR_NONE} "
  else
      REMOTE_HOSTNAME=""
  fi
}

# Set the full bash prompt.
function set_bash_prompt () {
  # Set the PROMPT_SYMBOL variable. We do this first so we don't lose the
  # return value of the last command.
  set_prompt_symbol $?

  # Set the PYTHON_VIRTUALENV and REMOTE_HOSTNAME variables.
  set_virtualenv
  set_remote_hostname

  # Set the BRANCH variable.
  if is_git_repository ; then
    set_git_branch
  else
    BRANCH=''
  fi

  # Set the bash prompt variable.
  PS1="${PYTHON_VIRTUALENV}${REMOTE_HOSTNAME}${YELLOW}\w${COLOR_NONE} ${BRANCH}\n${PROMPT_SYMBOL} "
}
# Tell bash to execute this function just before displaying its prompt.
PROMPT_COMMAND="set_bash_prompt;"

## -- HISTORY --
# Append to the history file, don't overwrite it
shopt -s histappend
# Save multi-line commands as one command
shopt -s cmdhist
# avoid duplicate entries
HISTCONTROL="erasedups:ignoreboth"
# Don't record some commands
HISTIGNORE="&:[ ]*:exit:ls:bg:fg:history:clear"
# Record each line as it gets issued
PROMPT_COMMAND+="history -a;"
# Huge history
HISTSIZE=500000
HISTFILESIZE=100000
# Use standard ISO 8601 timestamp
# %F equivalent to %Y-%m-%d
# %T equivalent to %H:%M:%S (24-hours format)
HISTTIMEFORMAT='%F %T '

## -- DIRECTORY --
# Change to most recently used directory
if [ -f ~/.lastdir ]; then
    cd "`cat ~/.lastdir`"
fi
# Augment PROMPT_COMMAND to list 7 recently changed files when:
# - a new shell is started in a directory other than home
# - cd to any directory
export LASTDIR=${HOME}
function autols {
    newdir=`pwd`
    if [ ! "$LASTDIR" = "$newdir" ]; then
        printf %s "$PWD" > ~/.lastdir
        ls -ltrFG | tail -7
    fi
    export LASTDIR=$newdir
}
PROMPT_COMMAND+='autols;'

# z must come after PROMPT_COMMAND stuff
which brew >> /dev/null
if [[ $? == 0 ]]; then
    [ -f $(brew --prefix)/etc/profile.d/z.sh ] && source $(brew --prefix)/etc/profile.d/z.sh
fi
