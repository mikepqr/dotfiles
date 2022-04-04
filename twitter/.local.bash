#!/bin/bash

if [ -f "${HOME}/.private.bash" ]; then
    source "${HOME}/.private.bash"
else
    echo "${HOME}/.private.bash" not found
fi

if [ -f "${HOME}/.bashrc" ]; then
    source "${HOME}/.bashrc"
fi

alias stern="KUBECONFIG=~/.kube/config:~/.kube/twconfig stern"
