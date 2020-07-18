#!/bin/bash

function mktempdir() {
    dir="$1"
    if [[ -z $dir ]] ; then
        cd "$(mktemp -d)" || exit 1
    else
        mkdir -p "$HOME/tmp/$dir"
        cd "$HOME/tmp/$dir" || exit 1
    fi
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
