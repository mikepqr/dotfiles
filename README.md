# Mike Lee Williams's dotfiles

The install script uses [shtow](https://github.com/williamsmj/shtow) to symlink
dotfiles into the appropriate location.

## On systems with git

```sh
git clone https://github.com/williamsmj/dotfiles.git ~/.dotfiles
~/.dotfiles/install.sh
git clone https://github.com/williamsmj/dotfiles-private.git ~/.dotfiles-private
~/.dotfiles-private/install.sh
```

## On systems without git

```sh
mkdir ~/.dotfiles
curl -O https://github.com/williamsmj/shtow/archive/master.zip
unzip master.zip -d ~/.dotfiles
~/.dotfiles/install.sh

mkdir ~/.dotfiles-private
curl -O https://github.com/williamsmj/shtow/archive/master.zip
unzip master.zip -d ~/.dotfiles-private
~/.dotfiles-private/install.sh
```
