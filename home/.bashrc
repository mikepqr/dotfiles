## -- PATH --
if [ -d $HOME/miniconda/bin ]; then
    PATH=/Users/mike/miniconda/bin:"$PATH"
fi
if [ -d ~/usr/bin ] ; then
    PATH=~/usr/bin:"${PATH}"
fi
if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi
if [ -f $(brew --prefix)/etc/bash_completion ]; then
    . $(brew --prefix)/etc/bash_completion
fi

## -- HOMESHICK --
source "$HOME/.homesick/repos/homeshick/homeshick.sh"
source "$HOME/.homesick/repos/homeshick/completions/homeshick-completion.bash"
homeshick --quiet refresh
