#!/bin/bash

if [[ -r /etc/bash_completion.d/git-prompt ]]; then
    . /etc/bash_completion.d/git-prompt
    export GIT_PS1_SHOWDIRTYSTATE=1
else
   # Prompt with git branch
   function __git_ps1 {
       git branch --no-color 2>/dev/null | 'grep' -E '[*]' | sed "s/\* \(.*\)/ (\1)/"
   }
fi

function kube_ps1 { :; } # Dummy function for when kube-ps1 is not available
if [[ -x "$(command -v kubectl)" ]]; then
    install_dir="${HOME}"/.kube-ps1

    if [[ -d "${install_dir}" ]]; then
        source "${install_dir}"/kube-ps1.sh
        export KUBE_PS1_SYMBOL_USE_IMG=true
    fi
fi

MY_TITLEBAR="\[\e]0;\u@\h: \w\$(__git_ps1)\a\]"
if [[ "$(id -u)" == "0" ]]; then
    MY_PROMPT="(\[\e[1;31m\]\u@\h\[\e[0m\]) \$(kube_ps1)\$(__git_ps1) \[\e[1m\]\w\[\e[0m\]\n>"
else
    MY_PROMPT="(\[\e[1;34m\]\h\[\e[0m\]) \$(kube_ps1)\$(__git_ps1) \[\e[1m\]\w\[\e[0m\]\n>"
fi
PS1="$MY_TITLEBAR""$MY_PROMPT"
