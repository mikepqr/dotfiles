if [ -f $HOME/code/anthropic/config/local/zsh/zshrc ]; then
    source $HOME/code/anthropic/config/local/zsh/zshrc
fi

# Idempotent PATH handling (no duplicates)
typeset -Ug path PATH
path=("$HOME/.local/bin" "${path[@]}")

# vi editing mode
bindkey -v
# Edit command in $EDITOR with 'v' in normal mode
autoload -Uz edit-command-line
zle -N edit-command-line
bindkey -M vicmd 'v' edit-command-line
# Keep some emacs-style bindings
bindkey '^A' beginning-of-line
bindkey '^E' end-of-line
bindkey '^K' kill-line
bindkey '^U' backward-kill-line

# Search history with up/down arrows based on what's already typed
autoload -U history-search-end
zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end history-search-end
bindkey '^[[A' history-beginning-search-backward-end
bindkey '^[[B' history-beginning-search-forward-end

# Insert last argument from previous command
bindkey '\e.' insert-last-word
bindkey '\e_' insert-last-word

function cmd-available() {
    if command -v "$1" >/dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

export EDITOR
if cmd-available nvim; then
    EDITOR=nvim
else
    EDITOR=vim
fi
export VISUAL=$EDITOR

if [ -f ~/.fzf.zsh ]; then
    source ~/.fzf.zsh
    export FZF_DEFAULT_COMMAND="fd --hidden --follow --exclude .git"
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
    # ctrl-t lists everything under pwd by default. Then ctrl-f switches to
    # everything under $HOME, and ctrl-t switches back.
    export FZF_CTRL_T_OPTS="--bind 'ctrl-f:reload($FZF_DEFAULT_COMMAND . $HOME),ctrl-t:reload($FZF_DEFAULT_COMMAND)'"
    if [ -d ~/src ]; then
        export FZF_ALT_C_COMMAND='(fd --follow --type d . ~/src; fd --follow --type d --exclude "/src" . ~)'
    else
        export FZF_ALT_C_COMMAND="fd --follow --type d . ~"
    fi
fi

export HISTSIZE=100000
export SAVEHIST=100000
setopt append_history           # allow multiple sessions to append to one history
setopt bang_hist                # treat ! special during command expansion
setopt extended_history         # Write history in :start:elasped;command format
setopt hist_expire_dups_first   # expire duplicates first when trimming history
setopt hist_find_no_dups        # When searching history, don't repeat
setopt hist_ignore_dups         # ignore duplicate entries of previous events
setopt hist_ignore_space        # prefix command with a space to skip it's recording
setopt hist_reduce_blanks       # Remove extra blanks from each command added to history
setopt hist_verify              # Don't execute immediately upon history expansion
setopt inc_append_history       # Write to history file immediately, not when shell quits
setopt share_history            # Share history among all sessions
setopt rm_star_silent           # Don't ask for confirmation when using rm with *

if cmd-available starship; then
    eval "$(starship init zsh)"
fi

# Launch or reconnect to tmux session named `hostname` or first argument
function tms {
    session=${1:-$(hostname -s)}
    tmux attach -t "${session}" || tmux new -s "${session}"
}

alias c='claude'
alias t='tms'

if [ -f "$HOME/.zshrc.local" ]; then
    source "$HOME/.zshrc.local"
fi
