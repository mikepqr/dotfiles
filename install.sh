#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")"  || exit
stow $(echo */)
curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
vim -c PlugInstall +qall
