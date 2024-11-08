#!/bin/bash
# shellcheck disable=SC1090,SC1091

source ~/.bash_lib

# See http://superuser.com/a/583502. Prevent global /etc/profile
# path_helper utility from prepending default PATH to previously chosen
# PATH in, e.g. tmux.
if [[ "$OSTYPE" == "darwin"* ]]; then
    if [ -f /etc/profile ]; then
        unset PATH
        source /etc/profile
    fi
fi
# If not running interactively, don't do anything
case $- in
    *i*) ;;
    *) return ;;
esac

## -- OS SPECIFIC --
if [[ "$OSTYPE" == "darwin"* ]]; then
    export XDG_CACHE_HOME="${HOME}/Library/Caches"
    pathadd "/opt/homebrew/bin"
    if [ -d /opt/homebrew ]; then
        BREW_PREFIX=/opt/homebrew # hard-coded for speed, `brew --prefix`
    else
        BREW_PREFIX=/usr/local
    fi
    pathadd "$BREW_PREFIX/sbin"
    # pathadd "$BREW_PREFIX/opt/coreutils/libexec/gnubin"
    # pathadd "$BREW_PREFIX/opt/findutils/libexec/gnubin"
    # manpathadd "$BREW_PREFIX/share/man"
    # manpathadd "$BREW_PREFIX/opt/coreutils/libexec/gnuman"
    # manpathadd "$BREW_PREFIX/opt/findutils/libexec/gnuman"
    [[ -r "$BREW_PREFIX/etc/profile.d/bash_completion.sh" ]] && . "$BREW_PREFIX/etc/profile.d/bash_completion.sh"
fi

# Move /usr/local/bin ahead of brew in $PATH
pathremove /usr/local/bin
pathadd /usr/local/bin

pathadd "$HOME/bin"
GOPATH=$HOME/go
pathadd "$GOPATH/bin"
if [ -f "$HOME/.cargo/env" ]; then
    source "$HOME/.cargo/env"
fi
pathadd "$HOME/.local/bin"

if [[ $USER == "mlw" ]]; then
    pathadd "$HOME/.toolbox/bin"
fi

# Aliases must come after brew activation, before use of cmd-available
if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# Make completion work on Debian-like systems
if ! shopt -oq posix; then
    if [ -f /usr/share/bash-completion/bash_completion ]; then
        . /usr/share/bash-completion/bash_completion
    elif [ -f /etc/bash_completion ]; then
        . /etc/bash_completion
    fi
fi

## -- PYTHON --
export PYTHONSTARTUP=${HOME}/.config/python/pythonrc.py
export VENVHOME="${HOME}/.ves"

## -- VI --
set -o vi
export EDITOR
if cmd-available nvim; then
    EDITOR=nvim
else
    EDITOR=vim
fi
export VISUAL=$EDITOR

## -- PROMPT --
PROMPT_COMMAND=""
# http://stackoverflow.com/questions/23399183/bash-command-prompt-with-virtualenv-and-git-branch
red="\[\033[0;31m\]"
#       green="\[\033[0;32m\]"
yellow="\[\033[1;33m\]"
blue="\[\033[1;34m\]"
#   light_red="\[\033[1;31m\]"
# light_green="\[\033[1;32m\]"
#       white="\[\033[1;37m\]"
#  light_gray="\[\033[0;37m\]"
color_none="\[\e[0m\]"

# Detect whether the current directory is a git repository.
function is_git_repository {
    git branch >/dev/null 2>&1
}

function set_git_branch {
    # Set the final branch string
    branch=$(parse_git_branch)
}

function parse_git_branch() {
    git branch --no-color 2>/dev/null | sed -e '/^[^*]/d' -e "s/* \(.*\)/\1$(parse_git_dirty)/"
}

function parse_git_dirty() {
    if [ "$MONOREPO" = "1" ]; then
        :
    else
        [[ $(git status --porcelain) ]] && echo "*"
    fi
}

# Return the prompt symbol to use, colorized based on the return value of the
# previous command.
function set_prompt_symbol() {
    if test "$1" -eq 0; then
        prompt_symbol="\$"
    else
        prompt_symbol="${red}\$${color_none}"
    fi
}

# Determine active Python virtualenv details.
function set_virtualenv() {
    if test -z "$VIRTUAL_ENV"; then
        python_virtualenv=""
    else
        python_virtualenv="${blue}[$(basename "$VIRTUAL_ENV")]${color_none} "
    fi
}
# Get remote hostname string
function set_remote_hostname() {
    if [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ]; then
        remote_hostname="${red}$(hostname)${color_none}:"
    else
        remote_hostname=""
    fi
}

# Set the full bash prompt.
function set_bash_prompt() {
    # Set the PROMPT_SYMBOL variable first so we don't lose the
    # return value of the last command.
    set_prompt_symbol $?
    set_virtualenv
    set_remote_hostname
    if is_git_repository; then
        set_git_branch
    else
        branch=''
    fi
    # Note the final character is a nbsp (ctrl-K<space><space> to insert in vim)
    # which makes it easier to search for (https://youtu.be/uglorjY0Ntg)
    PS1="${python_virtualenv}${remote_hostname}${yellow}\w${color_none} ${branch}\n${prompt_symbol} "
}
# Tell bash to execute this function just before displaying its prompt.
PROMPT_COMMAND+="set_bash_prompt;"

# Fix ssh agent forwarding in remote tmux sessions
if [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ] && [ -n "$TMUX" ]; then
    fixssh() {
        eval "$(tmux show-env -s | grep '^SSH_')"
    }
    PROMPT_COMMAND+="fixssh;"
fi

## -- HISTORY --
# Append to the history file, don't overwrite it
shopt -s histappend
# Save multi-line commands as one command
shopt -s cmdhist
# Confirm before running history command
shopt -s histverify
# avoid duplicate entries
HISTCONTROL="erasedups:ignoreboth"
# Don't record some commands
HISTIGNORE="&:[ ]*:exit:ls:ll:bg:fg:history:clear"
# Append to history after every command
PROMPT_COMMAND+="history -a;"
# Huge history
HISTSIZE=100000
HISTFILESIZE=10000000
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
        printf %s "$PWD" >~/.lastdir
    fi
    export LASTDIR=$newdir
}
PROMPT_COMMAND+='savelastdir;'

# source .envrc
if cmd-available direnv; then
    eval "$(direnv hook bash)"
fi

# readable colors
if cmd-available dircolors; then
    [ -e ~/.dircolors ] && eval "$(dircolors -b ~/.dircolors)"
fi

if [ -f ~/.fzf.bash ]; then
    source ~/.fzf.bash
    export FZF_DEFAULT_COMMAND="fd --hidden --follow --exclude .git"
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
    # ctrl-t lists everything under pwd by default. Then ctrl-f switches to
    # everying under $HOME, and ctrl-t switches back.
    export FZF_CTRL_T_OPTS="--bind 'ctrl-f:reload($FZF_DEFAULT_COMMAND .  $HOME),ctrl-t:reload($FZF_DEFAULT_COMMAND)'"
    if [ -d ~/p ]; then
        export FZF_ALT_C_COMMAND='(fd --follow --type d . ~/p; fd --follow --type d --exclude "/p" . ~)'
    else
        export FZF_ALT_C_COMMAND="fd  --follow --type d . ~"
    fi
fi

if [ -f ~/.bashrc_private ]; then
    source ~/.bashrc_private
fi
