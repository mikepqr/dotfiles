#!/bin/bash

set -e
set -u
mkdir "$HOME/bin"

BASEDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if command -v stow >/dev/null 2>&1; then
    cd "$BASEDIR" || exit
    stow "$(echo */)"
else
    find "$BASEDIR"/*/ -maxdepth 0 -exec cp -sfRT {} "${HOME}" \;
fi

curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
vim -c PlugInstall +qall
