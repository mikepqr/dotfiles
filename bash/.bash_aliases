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

alias n='vim -c ":cd ~/notes"'
alias v='vim -c ":History"'

if cmd-available direnv; then
    alias tmux='direnv exec / tmux'
fi

alias jn='jupyter notebook'
alias cdf='cd "$HOME/.dotfiles"'
alias cdfp='cd "$HOME/.dotfiles-private"'
alias csp='(cdfp && git commit -m "Add words" vim/.vim/spell/en.utf-8.add)'

function usepyenv {
    if [ -f .envrc ]; then
        echo ".envrc already exists"
        return 1
    else
        echo "layout pyenv $(pyenv global)" >>./.envrc
        direnv allow
    fi
}

# Returns zero if git repository is clean (i.e. non-dirty)
function non-dirty {
    if [ -z "$(git status --porcelain)" ]; then
        return 0
    fi
    return 1
}

function sync-if-clean {
    (
        local dir="${1:-.}"
        cd "$dir" || return
        if non-dirty; then
            git pull --rebase | grep -v '^Already up to date.$'
            # git push writes this message to stderr
            git push 2>&1 | grep -v '^Everything up-to-date$'
            return 0
        else
            git status
            return 1
        fi
    )
}
complete -A directory sync-if-clean

function cspell {
    (
        cd "$HOME/.dotfiles-private" || return
        git commit -m "Update spellfile" vim/.vim/spell/en.utf-8.add
    )
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

function edex() {
    $EDITOR "$(which "$1")"
}
# add commands (i.e executables) as completions
complete -A command edex

function mktempdir() {
    dir="$1"
    if [[ -z $dir ]]; then
        cd "$(mktemp -d)" || exit 1
    else
        mkdir -p "$HOME/tmp/$dir"
        cd "$HOME/tmp/$dir" || exit 1
    fi
}

function compare_versions() {
    # https://stackoverflow.com/a/4025065/409879
    # returns 0 if first = second argument
    # returns 1 if first > second
    # returns 2 if first < second
    if [[ "$1" == "$2" ]]; then
        return 0
    fi
    local IFS=.
    # shellcheck disable=SC2206
    local i ver1=($1) ver2=($2)
    # fill empty fields in ver1 with zeros
    for ((i = ${#ver1[@]}; i < ${#ver2[@]}; i++)); do
        ver1[i]=0
    done
    for ((i = 0; i < ${#ver1[@]}; i++)); do
        if [[ -z ${ver2[i]} ]]; then
            # fill empty fields in ver2 with zeros
            ver2[i]=0
        fi
        if ((10#${ver1[i]} > 10#${ver2[i]})); then
            return 1
        fi
        if ((10#${ver1[i]} < 10#${ver2[i]})); then
            return 2
        fi
    done
    return 0
}

# Alias diff --color to dif if possible
diff_version=$(diff --version | head -1 | grep -o -E '[0-9]+\.[0-9]+')
# --color added in diff 3.4
compare_versions "$diff_version" 3.3.99999 || cmp_return=$?
unset diff_version
if [ $cmp_return -eq 1 ]; then
    alias dif="diff --color -u"
else
    alias dif="diff -u"
fi

# Launch or reconnect to tmux session named `hostname` or first argument
function tms {
    session=${1:-$(hostname -s)}
    tmux attach -t "${session}" || tmux new -s "${session}"
}

# Pipe to this to copy to system clipboard from remote host using osc52
# Adapted from https://github.com/chromium/hterm/blob/dfa57bf449980024c80b960214cc83c43fd3d218/etc/osc52.vim#L48-L52
if ! command -v pbcopy >/dev/null 2>&1; then
    function pbcopy {
        echo -ne '\e]52;c;'"$(base64 -)"'\x07'
    }
fi
