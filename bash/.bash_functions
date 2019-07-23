#!/bin/bash

function mktempdir() {
    dir="$1"
    if [[ -z $dir ]] ; then
        cd $(mktemp -d)
    else
        mkdir -p "$HOME/tmp/$dir"
        cd "$HOME/tmp/$dir"
    fi
}
