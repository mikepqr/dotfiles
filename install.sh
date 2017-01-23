#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")" || exit
pkgs="$(find . -maxdepth 1 ! -name '.*' -type d | sed "s|./||")"
stowurl=https://raw.githubusercontent.com/williamsmj/shtow/master/shtow
curl -O $stowurl
chmod +x shtow

for pkg in $pkgs
do
    echo "Installing $pkg configuration"
    bash ./shtow "$pkg"
done

curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
vim -c PlugInstall +qall
rm shtow
