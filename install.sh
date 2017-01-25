#!/bin/bash
cd "$(dirname "${BASH_SOURCE[0]}")" || exit

# get stowsh (and put it in a package)
curl -o bin/bin/stowsh https://raw.githubusercontent.com/williamsmj/stowsh/master/stowsh
chmod +x bin/bin/stowsh

# get all the root level directories that don't start with "."
pkgs="$(find . -maxdepth 1 ! -name '.*' -type d | sed "s|./||")"
# remove OS-specific packages from this list
pkgs=${pkgs//darwin/}
pkgs=${pkgs//linux/}

for pkg in $pkgs
do
    echo "Installing $pkg configuration"
    bin/bin/stowsh -s "$pkg"
done

# install OS-specific packages if appropriate
if [[ $(uname) == "Darwin" ]] ; then
    bin/bin/stowsh darwin
fi

if [[ $(uname) == "Linux" ]] ; then
    bin/bin/stowsh linux
fi

# bootstrap vim plugin configuration
curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
vim -c PlugInstall +qall
