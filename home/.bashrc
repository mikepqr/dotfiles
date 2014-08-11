## -- PATH --
if [ -d ~/usr/bin ] ; then
    PATH=~/usr/bin:"${PATH}"
fi
if [ -d $HOME/miniconda/bin ]; then
    PATH="$HOME"/miniconda/bin:"$PATH"
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

# Type a few characters before pressing up to search for commands that begin
# with that string: http://stackoverflow.com/questions/1030182/
bind '"\e[A": history-search-backward'
bind '"\e[B": history-search-forward'

## -- PROMPT --
PS1='\[\033[01;37m\]\h\[\033[00m\]:\[\033[01;33m\]\W\[\033[00m\]\$ '

## -- EDITOR --
export VISUAL=$HOME/usr/bin/mvim
export EDITOR=$HOME/usr/bin/vim

## -- HISTORY --
# avoid duplicates
export HISTCONTROL=ignoredups:erasedups  
# append history entries
shopt -s histappend
# after each command, save and reload history
export PROMPT_COMMAND="${PROMPT_COMMAND:+$PROMPT_COMMAND$'\n'}history -a; history -c; history -r"

## -- DIRECTORY --
# Change to most recently used directory
if [ -f ~/.lastdir ]; then
    cd "`cat ~/.lastdir`"
fi
# Augment PROMPT_COMMAND to list 7 recently changed files when:
# - a new shell is started in a directory other than home
# - cd to any directory
export LASTDIR=${HOME}
function prompt_command {
    newdir=`pwd`
    if [ ! "$LASTDIR" = "$newdir" ]; then
        printf %s "$PWD" > ~/.lastdir
        # Note script -q /dev/null is required to retain color output
        script -q /dev/null ls -ltFG | tail -7
    fi
    export LASTDIR=$newdir
}
PROMPT_COMMAND+='; prompt_command'
