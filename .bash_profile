[ -z "$PS1" ] && return

if [ -f ~/.bashrc ]; then
    source ~/.bashrc
fi

# Setting PATH for Python 3.13
# The original version is saved in .bash_profile.pysave
PATH="/Library/Frameworks/Python.framework/Versions/3.13/bin:${PATH}"
export PATH
