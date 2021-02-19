#!/bin/bash

alias ls='ls -F --color=auto'
alias l='ls'
alias ll='ls -l'
alias grep='grep --color'
alias jn='jupyter notebook'
alias n='vim -c ":cd ~/notes"'
alias v='vim -c ":History"'
alias pdf='(cd "$HOME/.dotfiles" && git pull)'

if command -v direnv >/dev/null 2>&1; then
    alias tmux='direnv exec / tmux'
fi

if command -v nvim > /dev/null 2>&1; then
    alias vim=nvim
fi

function mktempdir() {
    dir="$1"
    if [[ -z $dir ]] ; then
        cd "$(mktemp -d)" || exit 1
    else
        mkdir -p "$HOME/tmp/$dir"
        cd "$HOME/tmp/$dir" || exit 1
    fi
}

function compare_versions () {
    # https://stackoverflow.com/a/4025065/409879
    # returns 0 if first = second argument
    # returns 1 if first > second
    # returns 2 if first < second
    if [[ "$1" == "$2" ]]
    then
        return 0
    fi
    local IFS=.
    # shellcheck disable=SC2206
    local i ver1=($1) ver2=($2)
    # fill empty fields in ver1 with zeros
    for ((i=${#ver1[@]}; i<${#ver2[@]}; i++))
    do
        ver1[i]=0
    done
    for ((i=0; i<${#ver1[@]}; i++))
    do
        if [[ -z ${ver2[i]} ]]
        then
            # fill empty fields in ver2 with zeros
            ver2[i]=0
        fi
        if ((10#${ver1[i]} > 10#${ver2[i]}))
        then
            return 1
        fi
        if ((10#${ver1[i]} < 10#${ver2[i]}))
        then
            return 2
        fi
    done
    return 0
}

if [[ -n "$ITERM_PROFILE" ]]; then
    function toggle-profile() {
        case "$ITERM_PROFILE" in
            "Dark") export ITERM_PROFILE="Light" ;;
            "Light") export ITERM_PROFILE="Dark" ;;
        esac
        echo -ne "\033]50;SetProfile=$ITERM_PROFILE\a"
    }
fi

# Alias diff --color to dif if possible
diff_version=$(diff --version | head -1 | grep -o -E '[0-9]+\.[0-9]+')
# --color added in diff 3.4
compare_versions "$diff_version" 3.3.99999  || cmp_return=$?
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
if ! command -v pbcopy > /dev/null 2>&1; then
    function pbcopy {
        echo -ne '\e]52;c;'"$(base64 -)"'\x07'
    }
fi
