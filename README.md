# Mike Lee Williams's dotfiles

The install script uses [stowsh](https://github.com/mikepqr/stowsh) to
symlink dotfiles into the appropriate location.

```sh
git clone git@github.com:mikepqr/dotfiles.git ~/.dotfiles
cd .dotfiles
git config --local user.email "mike@mike.place"
./install.sh
```

If you're running `install.sh` on an ssh one-liner, you need the `-t` option,
i.e. ssh -t server ~/.dotfiles/install.sh.
