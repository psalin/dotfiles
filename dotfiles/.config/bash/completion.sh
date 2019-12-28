#!/bin/bash

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

if [ -x "$(command -v kubectl)" ]; then
    source <(kubectl completion bash)
    complete -F __start_kubectl k
fi

if [ -x "$(command -v helm)" ]; then
    source <(helm completion bash)
    complete -F __start_helm h
fi

[ -f "${HOME}"/.fzf.bash ] && source "${HOME}"/.fzf.bash
