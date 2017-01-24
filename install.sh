#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")" || exit
stowshurl=https://raw.githubusercontent.com/williamsmj/stowsh/master/stowsh
curl -o bin/bin/stowsh $stowshurl
chmod +x bin/bin/stowsh

pkgs="$(find . -maxdepth 1 ! -name '.*' -type d | sed "s|./||")"
pkgs=${pkgs//darwin/}
pkgs=${pkgs//linux/}

for pkg in $pkgs
do
    echo "Installing $pkg configuration"
    bin/bin/stowsh "$pkg"
done

if [[ $(uname) == "Darwin" ]] ; then
    bin/bin/stowsh darwin
fi

if [[ $(uname) == "Linux" ]] ; then
    bin/bin/stowsh linux
fi

curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
vim -c PlugInstall +qall
