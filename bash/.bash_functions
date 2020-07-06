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
