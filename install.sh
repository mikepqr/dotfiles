#!/bin/bash
cd "$(dirname "${BASH_SOURCE[0]}")" || exit

# get stowsh (and put it in a package)
curl -o ./bin/.local/bin/stowsh https://raw.githubusercontent.com/williamsmj/stowsh/master/stowsh
chmod +x ./bin/.local/bin/stowsh

# get all the root level directories that don't start with "."
pkgs="$(find . -maxdepth 1 ! -name '.*' -type d | sed "s|./||")"

# remove OS-specific packages from this list
# symlinked on macOS only
pkgs=${pkgs//darwin/}
# symlinked on macOS only
pkgs=${pkgs//linux/}
# symlinked if hostname is *.cloudera.com
pkgs=${pkgs//cloudera/}
# ignored by stowsh, not linked outside this directory
pkgs=${pkgs//nolink/}

for pkg in $pkgs; do
    bin/.local/bin/stowsh -v -s "$pkg" -t "$HOME"
done

# install OS-specific packages if appropriate
if [[ $(uname) == "Darwin" ]]; then
    bin/.local/bin/stowsh -s darwin -t "$HOME"
fi

if [[ $(uname) == "Linux" ]]; then
    bin/.local/bin/stowsh -s linux -t "$HOME"
fi

if [[ $(hostname) == *".cloudera.com" ]]; then
    bin/.local/bin/stowsh -s cloudera -t "$HOME"
fi

# bootstrap vim plugin configuration
curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
vim -c PlugInstall +qall
