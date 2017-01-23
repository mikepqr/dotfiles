#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")" || exit
pkgs="$(find . -maxdepth 1 ! -name '.*' -type d | sed "s|./||")"
shtowurl=https://raw.githubusercontent.com/williamsmj/shtow/master/shtow
curl -O $shtowurl
chmod +x shtow
mv shtow bin/bin

for pkg in $pkgs
do
    echo "Installing $pkg configuration"
    bash bin/bin/shtow "$pkg"
done

curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
vim -c PlugInstall +qall
