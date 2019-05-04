alias ls='ls -F --color=auto'
alias l='ls'
alias ll='ls -l'
alias grep='grep --color'
alias jn='jupyter notebook'

if command -v direnv >/dev/null 2>&1; then
    alias tmux='direnv exec / tmux'
fi

# Launch or reconnect to tmux session named `hostname` or first argument
function tms {
    session=${1:-$(hostname -s)}
    tmux attach -t "${session}" || tmux new -s "${session}"
}
