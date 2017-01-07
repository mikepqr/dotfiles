#!/bin/bash

set -e
set -u
mkdir -p "$HOME/bin"

basedir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
dirs="$(find . -maxdepth 1 ! -name '.*' -type d | sed "s|./||")"

for d in $dirs
do
    echo "Installing $d configuration"
    if command -v stow >/dev/null 2>&1; then
        stow "$d"
    else
        find "$basedir/$d/" -maxdepth 0 -exec cp -sfRT {} "${HOME}" \;
    fi
done

curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
vim -c PlugInstall +qall
