#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")" || exit
shtowurl=https://raw.githubusercontent.com/williamsmj/shtow/master/shtow
curl -o bin/bin/shtow $shtowurl
chmod +x bin/bin/shtow

pkgs="$(find . -maxdepth 1 ! -name '.*' -type d | sed "s|./||")"
pkgs=${pkgs//darwin/}
pkgs=${pkgs//linux/}

for pkg in $pkgs
do
    echo "Installing $pkg configuration"
    bin/bin/shtow "$pkg"
done

if [[ $(uname) == "Darwin" ]] ; then
    bin/bin/shtow darwin
fi

if [[ $(uname) == "Linux" ]] ; then
    bin/bin/shtow linux
fi

curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
vim -c PlugInstall +qall
