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

function installpublickey() {
    server="$1"
    < ~/.ssh/id_ed25519.pub ssh "$server" "mkdir -p ~/.ssh && cat >> ~/.ssh/authorized_keys"
}
