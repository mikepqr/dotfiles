#!/bin/bash
# shellcheck disable=SC1090
## -- PATH --
pathadd() {
    if [ -d "$1" ] && [[ ":$PATH:" != *":$1:"* ]]; then
        export PATH="$1:$PATH"
    fi
}
manpathadd() {
    if [ -d "$1" ] && [[ ":$MANPATH:" != *":$1:"* ]]; then
        export MANPATH="$1:$MANPATH"
    fi
}

# See http://superuser.com/a/583502. Prevent global /etc/profile
# path_helper utility from prepending default PATH to previously chosen
# PATH in, e.g. tmux.
if [[ "$OSTYPE" == "darwin"* ]]; then
    if [ -f /etc/profile ]; then
        unset PATH
        source /etc/profile
    fi
fi
if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi
pathadd "$HOME/bin"
# go
GOPATH=$HOME/go
pathadd "$GOPATH/bin"
# pipsi
pathadd "$HOME/.local/bin"

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return ;;
esac

## -- OS SPECIFIC --
if [[ "$OSTYPE" == "darwin"* ]]; then
    if command -v brew >/dev/null 2>&1; then
        BREW_PREFIX=$(brew --prefix)
        pathadd "$BREW_PREFIX/opt/coreutils/libexec/gnubin"
        pathadd "$BREW_PREFIX/opt/findutils/libexec/gnubin"
        manpathadd "$BREW_PREFIX/opt/coreutils/libexec/gnuman"
        manpathadd "$BREW_PREFIX/opt/findutils/libexec/gnuman"
        if [ -f "$BREW_PREFIX/share/bash-completion/bash_completion" ]; then
            source "$BREW_PREFIX/share/bash-completion/bash_completion"
        fi
    fi
fi

## -- PYTHON --
VENVHOME="${HOME}/.virtualenvs"
workon () {
    if [ -f "${VENVHOME}/$1/bin/activate" ]; then
        source "${VENVHOME}/$1/bin/activate"
    fi
}
mkvirtualenv () {
    deactivate 2> /dev/null || true
    python3 -m virtualenv "${VENVHOME}/${1}"
    workon ${1}
}
mkvirtualenv_legacy () {
    deactivate 2> /dev/null || true
    python2 -m virtualenv "${VENVHOME}/${1}"
    workon ${1}
}
workon ds3


## -- VI --
set -o vi
export EDITOR
EDITOR=$(which vim)

## -- PROMPT --
# http://stackoverflow.com/questions/23399183/bash-command-prompt-with-virtualenv-and-git-branch
        red="\[\033[0;31m\]"
     yellow="\[\033[1;33m\]"
      green="\[\033[0;32m\]"
       blue="\[\033[1;34m\]"
  light_red="\[\033[1;31m\]"
light_green="\[\033[1;32m\]"
      white="\[\033[1;37m\]"
 light_gray="\[\033[0;37m\]"
 color_none="\[\e[0m\]"

# Detect whether the current directory is a git repository.
function is_git_repository {
  git branch > /dev/null 2>&1
}

function set_git_branch {
  # Set the final branch string
  branch=$(parse_git_branch)
}

function parse_git_branch() {
  git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e "s/* \(.*\)/\1$(parse_git_dirty)/"
}

function parse_git_dirty() {
    [[ $(git status --porcelain) ]] && echo "*"
}

# Return the prompt symbol to use, colorized based on the return value of the
# previous command.
function set_prompt_symbol () {
  if test "$1" -eq 0 ; then
      prompt_symbol="\$"
  else
      prompt_symbol="${light_red}\$${color_none}"
  fi
}

# Determine active Python virtualenv details.
function set_virtualenv () {
  if test -z "$VIRTUAL_ENV" ; then
      python_virtualenv=""
  else
      python_virtualenv="${blue}[$(basename "$VIRTUAL_ENV")]${color_none} "
  fi
}
# Get remote hostname string (i.e. if not sabon)
function set_remote_hostname () {
  if [[ $(hostname) != "sabon" ]] ; then
      remote_hostname="${red}$(hostname)${color_none}:"
  else
      remote_hostname=""
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
    branch=''
  fi

  # Set the bash prompt variable.
  PS1="${python_virtualenv}${remote_hostname}${yellow}\w${color_none} ${branch}\n${prompt_symbol} "
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
    cd "$(cat ~/.lastdir)" || :
fi
export LASTDIR=${HOME}
function savelastdir {
    newdir=$(pwd)
    if [ ! "$LASTDIR" = "$newdir" ]; then
        printf %s "$PWD" > ~/.lastdir
    fi
    export LASTDIR=$newdir
}
PROMPT_COMMAND+='savelastdir;'

# modify cd to source $PWD/.env on cd
if [ -f "$BREW_PREFIX/opt/autoenv/activate.sh" ]; then
    source "$BREW_PREFIX/opt/autoenv/activate.sh"
fi

# readable colors
if command -v dircolors > /dev/null 2>&1; then
    [ -e ~/.dircolors ] && eval "$(dircolors -b ~/.dircolors)"
fi

# Use fasd to build up database of touched files and visited directories
eval "$(fasd --init bash-hook)"
# Use fzf to work with that database
[ -f ~/.fzf.bash ] && source ~/.fzf.bash
export FZF_DEFAULT_COMMAND='fasd -alR'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="fasd -dlR"
# cd
z() {
  local dir
  dir=$(fasd -dlR | fzf --reverse --height 40% -q "$*" -1 -0)
  [[ -n "$dir" ]] && cd "${dir}" || return
}
# v (~/.viminfo)
v() {
  local files
  files=$(grep '^>' ~/.viminfo | cut -c3- |
          while read -r line; do
            [ -f "${line/\~/$HOME}" ] && echo "$line"
          done | fzf -m -q "$*" -1) && vim $files
}
