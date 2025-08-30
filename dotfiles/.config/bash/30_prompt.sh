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

if [[ "$(id -u)" == "0" ]]; then
    MY_PROMPT="(\[\e[1;31m\]\u@\h\[\e[0m\]) \$(__git_ps1) \[\e[1m\]\w\[\e[0m\]\n>"
else
    MY_PROMPT="(\[\e[1;34m\]\h\[\e[0m\]) \$(__git_ps1) \[\e[1m\]\w\[\e[0m\]\n>"
fi
PS1="$MY_PROMPT"
