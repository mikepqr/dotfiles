#!/bin/bash

if cmd-available gls; then
    alias ls='gls -F --color=auto'
else
    alias ls='ls -F --color=auto'
fi
alias l=ls
alias ll='ls -Fl --color=auto'
alias la='ls -aFl --color=auto'

if cmd-available ggrep; then
    alias grep="ggrep --color"
else
    alias grep="grep --color"
fi

alias n='vim -c ":cd ~/vault/notes"'
alias v='vim -c ":History"'
alias t='tms'
alias k='kubectl'
alias gr='cd "$(git root)"'

alias cdl='cd "$(cat $HOME/.lastdir)"'

if cmd-available direnv; then
    alias tmux='direnv exec / tmux'
fi

alias ibrew='arch -x86_64 /usr/local/bin/brew'
complete -o bashdefault -o default -F _brew ibrew

alias cdf='cd "$HOME/.dotfiles"'
alias cdfp='cd "$HOME/.dotfiles-private"'
alias spell-commit='(cdfp && git commit -m "Add words" vim/.vim/spell/en.utf-8.add vim/.config/nvim/spell/en.utf-8.add)'
alias ..='cd ..'

alias toggle-colors='source $HOME/.local/bin/_toggle-colors'

function usepyenv {
    if [ -f .envrc ]; then
        echo ".envrc already exists"
        return 1
    else
        echo "layout pyenv $(pyenv global)" >>./.envrc
        direnv allow
    fi
}

function sdf {
    print-run-ok "sync-if-clean $HOME/.dotfiles" "dotfiles"
    [ -d "$HOME/.dotfiles-private" ] && print-run-ok "sync-if-clean $HOME/.dotfiles-private" "private dotfiles"
}

function print-run-ok() {
    # $1 is a command
    # $2 is an optional message
    # This function
    # - prints command (or the optional message)
    # - runs the command exits
    # - prints "OK" (on the same line if there was no output)
    local -r cmd="${1}"
    local -r msg="${2:-$1}"
    local -r colbefore='\033[0;33m' # orange
    local -r colerr='\033[0;31m'    # red
    local -r colok='\033[0;32m'     # green
    local -r nc='\033[0m'           # no color
    local -r up='\033[1A'           # move cursor up a line
    local output
    local col

    echo -e "${colbefore}>>> ${msg} ... ${nc}"

    # run $cmd and both capture and print the output
    # pipefail ensures subshell exits with exit of $cmd, not tee
    # set exitmessage appropriately based on $cmd's exit
    if output=$(
        set -o pipefail
        $cmd 2>&1 | tee /dev/tty
    ); then
        local exitmessage="OK ($?)"
        col=${colok}
    else
        local exitmessage="ERROR ($?)"
        col=${colerr}
    fi

    # if $cmd produced no output, overwrite the message line
    if [[ -z $output ]]; then
        local -r move="${up}"
    fi

    echo -e "${move:-}${col}>>> ${msg} ... ${exitmessage}${nc}"
}

# edit command
function edc() {
    $EDITOR "$(which "$1")"
}

function mktempdir() {
    dir="$1"
    if [[ -z $dir ]]; then
        cd "$(mktemp -d)" || exit 1
    else
        mkdir -p "$HOME/tmp/$dir"
        cd "$HOME/tmp/$dir" || exit 1
    fi
}

alias gdiff="git diff --no-index"

# Launch or reconnect to tmux session named `hostname` or first argument
function tms {
    session=${1:-$(hostname -s)}
    tmux attach -t "${session}" || tmux new -s "${session}"
}

# completions for my functions and scripts
complete -A command edc
complete -A directory sync-if-clean

function goc {
    cd "${HOME}/workplace/${__WORK_PROJ}" || return
}
function gow {
    cd "${HOME}"/workplace/ || return
}
